import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/auth/domain/app_user.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _selectedCurrency = 'USD';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _initFromUser(AppUser user) {
    if (!_isEditing) {
      _nameController.text = user.name;
      _selectedCurrency = user.currency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.valueOrNull;

    if (user != null) {
      _initFromUser(user);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (user != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() {
                  if (_isEditing) {
                    // Cancel editing — reset fields
                    _nameController.text = user.name;
                    _selectedCurrency = user.currency;
                  }
                  _isEditing = !_isEditing;
                });
              },
            ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(Sizes.p24),
              children: [
                const CircleAvatar(
                  radius: 48,
                  child: Icon(Icons.person, size: 48),
                ),
                const SizedBox(height: Sizes.p24),
                if (_isEditing)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  )
                else
                  _ProfileField(label: 'Name', value: user.name),
                const SizedBox(height: Sizes.p8),
                _ProfileField(label: 'Email', value: user.email),
                if (_isEditing)
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration:
                        const InputDecoration(labelText: 'Currency'),
                    items: ['USD', 'EUR', 'GBP', 'RSD', 'CAD', 'AUD']
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCurrency = v!),
                  )
                else
                  _ProfileField(label: 'Currency', value: user.currency),
                _ProfileField(
                  label: 'Member since',
                  value:
                      '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                ),
                if (_isEditing)
                  Padding(
                    padding: const EdgeInsets.only(top: Sizes.p16),
                    child: ElevatedButton(
                      onPressed: () async {
                        final messenger =
                            ScaffoldMessenger.of(context);
                        await ref.read(userRepositoryProvider).updateUser(
                          user.id,
                          {
                            'name': _nameController.text.trim(),
                            'currency': _selectedCurrency,
                          },
                        );
                        ref.invalidate(authStateChangesProvider);
                        setState(() => _isEditing = false);
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated'),
                            ),
                          );
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.p8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: Sizes.p4),
          Text(
            value.isEmpty ? '—' : value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(),
        ],
      ),
    );
  }
}
