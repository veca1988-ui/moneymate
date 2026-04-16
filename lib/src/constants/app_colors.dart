import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42DB);

  // Semantic
  static const Color income = Color(0xFF4CAF50);
  static const Color expense = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);

  // Budget progress
  static const Color budgetSafe = Color(0xFF4CAF50);
  static const Color budgetWarning = Color(0xFFFF9800);
  static const Color budgetExceeded = Color(0xFFE53935);

  // Neutrals
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  // Category colors
  static const List<Color> categoryColors = [
    Color(0xFF8BA87E), // Groceries — sage green
    Color(0xFFC4956A), // Dining — warm peach
    Color(0xFF7FA5C2), // Transport — soft blue
    Color(0xFF9B8BB4), // Bills — muted purple
    Color(0xFFC08393), // Entertainment — dusty rose
    Color(0xFF7BAFAF), // Shopping — teal
    Color(0xFFCB8E6E), // Health — warm terracotta
    Color(0xFF8E9AA0), // Other — cool grey
  ];
}
