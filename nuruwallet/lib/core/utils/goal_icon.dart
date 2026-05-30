import 'package:flutter/material.dart';

class GoalIconOption {
  const GoalIconOption(this.name, this.icon, this.label);
  final String name;
  final IconData icon;
  final String label;
}

abstract final class GoalIcon {
  static IconData get(String name) => _map[name] ?? Icons.savings_outlined;

  static const options = [
    GoalIconOption('savings', Icons.savings_outlined, 'Savings'),
    GoalIconOption('home', Icons.home_outlined, 'Home'),
    GoalIconOption('car', Icons.directions_car_outlined, 'Vehicle'),
    GoalIconOption('travel', Icons.flight_outlined, 'Travel'),
    GoalIconOption('education', Icons.school_outlined, 'Education'),
    GoalIconOption('phone', Icons.phone_iphone_outlined, 'Phone'),
    GoalIconOption('laptop', Icons.laptop_outlined, 'Electronics'),
    GoalIconOption('medical', Icons.local_hospital_outlined, 'Medical'),
    GoalIconOption('gift', Icons.card_giftcard_outlined, 'Gift'),
    GoalIconOption('other', Icons.emoji_objects_outlined, 'Other'),
  ];

  static const _map = <String, IconData>{
    'savings': Icons.savings_outlined,
    'home': Icons.home_outlined,
    'car': Icons.directions_car_outlined,
    'travel': Icons.flight_outlined,
    'education': Icons.school_outlined,
    'phone': Icons.phone_iphone_outlined,
    'laptop': Icons.laptop_outlined,
    'medical': Icons.local_hospital_outlined,
    'gift': Icons.card_giftcard_outlined,
    'other': Icons.emoji_objects_outlined,
  };
}
