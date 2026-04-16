import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    required this.category,
    this.size = 40,
    super.key,
  });

  final String category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final config = _categoryConfig(category);
    final iconSize = size * 0.5;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        config.icon,
        color: config.color,
        size: iconSize,
      ),
    );
  }

  static _CategoryConfig _categoryConfig(String category) {
    switch (category) {
      case 'Groceries':
        return const _CategoryConfig(Icons.shopping_cart, Color(0xFF8BA87E));
      case 'Dining':
        return const _CategoryConfig(Icons.restaurant, Color(0xFFC4956A));
      case 'Transport':
        return const _CategoryConfig(Icons.directions_car, Color(0xFF7FA5C2));
      case 'Bills':
        return const _CategoryConfig(Icons.receipt_long, Color(0xFF9B8BB4));
      case 'Entertainment':
        return const _CategoryConfig(Icons.movie, Color(0xFFC08393));
      case 'Shopping':
        return const _CategoryConfig(Icons.shopping_bag, Color(0xFF7BAFAF));
      case 'Health':
        return const _CategoryConfig(Icons.medical_services, Color(0xFFCB8E6E));
      default:
        return const _CategoryConfig(Icons.more_horiz, Color(0xFF8E9AA0));
    }
  }
}

class _CategoryConfig {
  const _CategoryConfig(this.icon, this.color);
  final IconData icon;
  final Color color;
}
