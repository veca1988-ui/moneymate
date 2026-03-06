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
    Color(0xFF4CAF50), // Groceries
    Color(0xFFFF9800), // Dining
    Color(0xFF2196F3), // Transport
    Color(0xFF9C27B0), // Bills
    Color(0xFFE91E63), // Entertainment
    Color(0xFF00BCD4), // Shopping
    Color(0xFFFF5722), // Health
    Color(0xFF607D8B), // Other
  ];
}
