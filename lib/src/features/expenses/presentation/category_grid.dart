import 'package:flutter/material.dart';
import 'package:moneymate/src/constants/app_colors.dart';
import 'package:moneymate/src/constants/app_sizes.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;

  static const _categories = [
    ('Groceries', Icons.shopping_cart),
    ('Dining', Icons.restaurant),
    ('Transport', Icons.directions_car),
    ('Bills', Icons.receipt_long),
    ('Entertainment', Icons.movie),
    ('Shopping', Icons.shopping_bag),
    ('Health', Icons.local_hospital),
    ('Other', Icons.more_horiz),
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
        final (name, icon) = _categories[index];
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
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Sizes.p12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
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
