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
        return _CategoryConfig(Icons.shopping_cart, Color(0xFF4CAF50));
      case 'Dining':
        return _CategoryConfig(Icons.restaurant, Color(0xFFFF9800));
      case 'Transport':
        return _CategoryConfig(Icons.directions_car, Color(0xFF2196F3));
      case 'Bills':
        return _CategoryConfig(Icons.receipt_long, Color(0xFF9C27B0));
      case 'Entertainment':
        return _CategoryConfig(Icons.movie, Color(0xFFE91E63));
      case 'Shopping':
        return _CategoryConfig(Icons.shopping_bag, Color(0xFF00BCD4));
      case 'Health':
        return _CategoryConfig(Icons.medical_services, Color(0xFFFF5722));
      default:
        return _CategoryConfig(Icons.more_horiz, Color(0xFF607D8B));
    }
  }
}

class _CategoryConfig {
  const _CategoryConfig(this.icon, this.color);
  final IconData icon;
  final Color color;
}
