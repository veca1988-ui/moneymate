import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/onboarding/data/couples_repository_impl.dart';

class AcceptInviteScreen extends ConsumerStatefulWidget {
  const AcceptInviteScreen({super.key, this.initialCode});
  final String? initialCode;

  @override
  ConsumerState<AcceptInviteScreen> createState() => _AcceptInviteScreenState();
}

class _AcceptInviteScreenState extends ConsumerState<AcceptInviteScreen> {
  late final TextEditingController _codeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialCode ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _acceptInvite() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a 6-character invite code')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = ref.read(firebaseAuthRepositoryProvider).currentUserId!;
      await ref.read(couplesRepositoryProvider).acceptInvite(code, userId);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Partner')),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.group_add,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: Sizes.p24),
            Text(
              'Enter the invite code\nfrom your partner',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.p32),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Invite Code',
                hintText: 'ABC123',
                prefixIcon: Icon(Icons.vpn_key_outlined),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Sizes.p24),
            ElevatedButton(
              onPressed: _isLoading ? null : _acceptInvite,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}
