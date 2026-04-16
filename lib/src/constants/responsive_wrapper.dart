import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  const ResponsiveWrapper({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: child,
      ),
    );
  }
}
