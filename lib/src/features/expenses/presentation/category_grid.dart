import 'package:flutter/material.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';
import 'package:moneymate/src/constants/category_icon.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;

  static const _categories = [
    'Groceries',
    'Dining',
    'Transport',
    'Bills',
    'Entertainment',
    'Shopping',
    'Health',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: Sizes.p8,
        crossAxisSpacing: Sizes.p8,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final name = _categories[index];
        final isSelected = selectedCategory == name;
        final color = AppColors.categoryColors[index];

        return GestureDetector(
          onTap: () => onCategorySelected(name),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: isSelected
                    ? BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(Sizes.p12),
                      )
                    : null,
                child: Center(
                  child: CategoryIcon(category: name, size: 40),
                ),
              ),
              const SizedBox(height: Sizes.p4),
              Text(
                name,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
