import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../utils/category_icon.dart';

class CategoryTag extends StatelessWidget {
  const CategoryTag({super.key, required this.category});

  final CategoryEntry category;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CategoryIcon.get(category.iconName), size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
