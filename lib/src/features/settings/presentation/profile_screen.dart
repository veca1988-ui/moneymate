import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
                _ProfileField(label: 'Name', value: user.name),
                _ProfileField(label: 'Email', value: user.email),
                _ProfileField(label: 'Currency', value: user.currency),
                _ProfileField(
                  label: 'Member since',
                  value: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
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
