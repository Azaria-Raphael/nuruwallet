import 'package:flutter/material.dart';

abstract final class CategoryIcon {
  static IconData get(String iconName) =>
      _map[iconName] ?? Icons.label_outline;

  static const _map = <String, IconData>{
    // Expense categories
    'food': Icons.restaurant_outlined,
    'transport': Icons.directions_bus_outlined,
    'home': Icons.home_outlined,
    'health': Icons.local_hospital_outlined,
    'entertainment': Icons.movie_outlined,
    'education': Icons.school_outlined,
    'shopping': Icons.shopping_bag_outlined,
    'utilities': Icons.bolt_outlined,
    'savings': Icons.savings_outlined,
    'other': Icons.category_outlined,
    // Income categories
    'salary': Icons.work_outline,
    'business': Icons.storefront_outlined,
    'freelance': Icons.laptop_outlined,
    'investments': Icons.trending_up,
    'gift': Icons.card_giftcard_outlined,
    'rental': Icons.apartment_outlined,
    'grant': Icons.account_balance_outlined,
    'other_income': Icons.add_circle_outline,
  };

  // Full list for the custom-category icon picker.
  static const allOptions = <({String name, IconData icon, String label})>[
    (name: 'food',          icon: Icons.restaurant_outlined,      label: 'Food'),
    (name: 'transport',     icon: Icons.directions_bus_outlined,  label: 'Transport'),
    (name: 'home',          icon: Icons.home_outlined,            label: 'Home'),
    (name: 'health',        icon: Icons.local_hospital_outlined,  label: 'Health'),
    (name: 'entertainment', icon: Icons.movie_outlined,           label: 'Fun'),
    (name: 'education',     icon: Icons.school_outlined,          label: 'Education'),
    (name: 'shopping',      icon: Icons.shopping_bag_outlined,    label: 'Shopping'),
    (name: 'utilities',     icon: Icons.bolt_outlined,            label: 'Utilities'),
    (name: 'savings',       icon: Icons.savings_outlined,         label: 'Savings'),
    (name: 'salary',        icon: Icons.work_outline,             label: 'Salary'),
    (name: 'business',      icon: Icons.storefront_outlined,      label: 'Business'),
    (name: 'freelance',     icon: Icons.laptop_outlined,          label: 'Freelance'),
    (name: 'investments',   icon: Icons.trending_up,              label: 'Invest'),
    (name: 'gift',          icon: Icons.card_giftcard_outlined,   label: 'Gift'),
    (name: 'rental',        icon: Icons.apartment_outlined,       label: 'Rental'),
    (name: 'grant',         icon: Icons.account_balance_outlined, label: 'Grant'),
    (name: 'other_income',  icon: Icons.add_circle_outline,       label: 'Other+'),
    (name: 'other',         icon: Icons.category_outlined,        label: 'Other'),
  ];
}
