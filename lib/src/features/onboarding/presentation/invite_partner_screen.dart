import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/onboarding/data/couples_repository_impl.dart';
import 'package:moneymate/src/features/onboarding/domain/couple_invite.dart';
import 'package:share_plus/share_plus.dart';

class InvitePartnerScreen extends ConsumerStatefulWidget {
  const InvitePartnerScreen({super.key});

  @override
  ConsumerState<InvitePartnerScreen> createState() =>
      _InvitePartnerScreenState();
}

class _InvitePartnerScreenState extends ConsumerState<InvitePartnerScreen> {
  CoupleInvite? _invite;
  bool _isLoading = false;

  Future<void> _skipForNow() async {
    setState(() => _isLoading = true);
    try {
      final userId = ref.read(firebaseAuthRepositoryProvider).currentUserId!;
      await ref.read(couplesRepositoryProvider).createSoloCouple(userId);
      // Force router to re-evaluate by invalidating auth state
      ref.invalidate(authStateChangesProvider);
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

  Future<void> _generateInvite() async {
    setState(() => _isLoading = true);
    try {
      final userId = ref.read(firebaseAuthRepositoryProvider).currentUserId!;
      final invite =
          await ref.read(couplesRepositoryProvider).createInvite(userId);
      setState(() => _invite = invite);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invite Partner')),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.favorite,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: Sizes.p24),
            Text(
              'Invite your partner to\ntrack expenses together',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.p32),
            if (_invite == null)
              ElevatedButton(
                onPressed: _isLoading ? null : _generateInvite,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Generate Invite Code'),
              )
            else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Sizes.p24),
                  child: Column(
                    children: [
                      const Text('Share this code with your partner:'),
                      const SizedBox(height: Sizes.p12),
                      Text(
                        _invite!.code,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: Sizes.p8),
                      Text(
                        'Expires in 48 hours',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Sizes.p16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: _invite!.code),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copied!')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                    ),
                  ),
                  const SizedBox(width: Sizes.p12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Share.share(
                          'Join me on MoneyMate! Use code: ${_invite!.code}',
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: Sizes.p24),
            TextButton(
              onPressed: _isLoading ? null : _skipForNow,
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
    );
  }
}
