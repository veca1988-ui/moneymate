import 'package:flutter/material.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';

class WelcomeTutorial extends StatefulWidget {
  const WelcomeTutorial({required this.onComplete, super.key});
  final VoidCallback onComplete;

  @override
  State<WelcomeTutorial> createState() => _WelcomeTutorialState();
}

class _WelcomeTutorialState extends State<WelcomeTutorial> {
  int _step = 0;

  static const _steps = [
    (
      icon: Icons.celebration,
      title: 'Welcome to MoneyMate!',
      message: 'Your partner invited you to track expenses together.',
    ),
    (
      icon: Icons.add_circle,
      title: 'Add Expenses',
      message: 'Tap the + button to add your expenses quickly.',
    ),
    (
      icon: Icons.lock_outlined,
      title: 'Privacy Controls',
      message:
          'Go to Settings > Privacy Controls to choose what your partner sees.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    final isLast = _step == _steps.length - 1;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(Sizes.p32),
          child: Padding(
            padding: const EdgeInsets.all(Sizes.p24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(step.icon, size: 64, color: AppColors.primary),
                const SizedBox(height: Sizes.p16),
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Sizes.p8),
                Text(
                  step.message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Sizes.p24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _steps.length,
                    (i) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _step
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Sizes.p16),
                ElevatedButton(
                  onPressed: () {
                    if (isLast) {
                      widget.onComplete();
                    } else {
                      setState(() => _step++);
                    }
                  },
                  child: Text(isLast ? 'Got it!' : 'Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
