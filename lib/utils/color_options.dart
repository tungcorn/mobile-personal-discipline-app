import 'package:flutter/material.dart';

class HabitColorOption {
  final String name;
  final int value;

  const HabitColorOption({required this.name, required this.value});

  Color get color => Color(value);
}

class AppColors {
  static const List<HabitColorOption> options = [
    HabitColorOption(name: 'Xanh ngọc', value: 0xFF10B981), // Emerald
    HabitColorOption(name: 'Xanh dương', value: 0xFF3B82F6), // Blue
    HabitColorOption(name: 'Tím Indigo', value: 0xFF6366F1), // Indigo
    HabitColorOption(name: 'Tím hoa cà', value: 0xFF8B5CF6), // Purple
    HabitColorOption(name: 'Hồng Rose', value: 0xFFF43F5E), // Rose
    HabitColorOption(name: 'Cam hổ phách', value: 0xFFF59E0B), // Amber
    HabitColorOption(name: 'Cam cháy', value: 0xFFF97316), // Orange
    HabitColorOption(name: 'Xanh bạc hà', value: 0xFF14B8A6), // Teal
    HabitColorOption(name: 'Đỏ tươi', value: 0xFFEF4444), // Red
    HabitColorOption(name: 'Xám thanh lịch', value: 0xFF64748B), // Slate
  ];

  static Color getColor(int? value) {
    if (value == null) return const Color(0xFF10B981);
    return Color(value);
  }
}
