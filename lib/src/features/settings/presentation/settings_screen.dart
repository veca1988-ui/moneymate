import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/features/auth/data/firebase_auth_repository.dart';
import 'package:moneymate/src/features/auth/presentation/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Account'),
          ListTile(
            leading: const Icon(Icons.person_outlined),
            title: const Text('Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock_outlined),
            title: const Text('Privacy Controls'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/privacy'),
          ),
          const Divider(),
          const _SectionHeader(title: 'Partner'),
          ListTile(
            leading: const Icon(Icons.favorite_outlined),
            title: const Text('Invite Partner'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/invite'),
          ),
          ListTile(
            leading: const Icon(Icons.link_off),
            title: const Text('Unlink Partner'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showUnlinkDialog(context),
          ),
          const Divider(),
          const _SectionHeader(title: 'Subscription'),
          ListTile(
            leading: const Icon(Icons.star_outlined),
            title: const Text('MoneyMate Premium'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/subscription'),
          ),
          const Divider(),
          const _SectionHeader(title: 'Danger Zone'),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.warning),
            title: const Text('Sign Out'),
            onTap: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.delete_forever, color: AppColors.expense),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: AppColors.expense),
            ),
            onTap: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showUnlinkDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink Partner?'),
        content: const Text(
          'This will disconnect you from your partner. '
          'Your expenses will remain but you will no longer share data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Call couplesRepository.unlinkPartner()
            },
            child: const Text('Unlink'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete your account and all your data. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(firebaseAuthRepositoryProvider)
                  .deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Sizes.p16,
        Sizes.p16,
        Sizes.p16,
        Sizes.p4,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
