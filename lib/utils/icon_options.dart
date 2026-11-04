import 'package:flutter/material.dart';

class HabitIconOption {
  final String key;
  final String label;
  final IconData iconData;

  const HabitIconOption({
    required this.key,
    required this.label,
    required this.iconData,
  });
}

class AppIcons {
  static const List<HabitIconOption> options = [
    HabitIconOption(
      key: 'fitness',
      label: 'Thể dục',
      iconData: Icons.fitness_center_rounded,
    ),
    HabitIconOption(
      key: 'run',
      label: 'Chạy bộ',
      iconData: Icons.directions_run_rounded,
    ),
    HabitIconOption(
      key: 'book',
      label: 'Đọc sách',
      iconData: Icons.menu_book_rounded,
    ),
    HabitIconOption(
      key: 'water',
      label: 'Uống nước',
      iconData: Icons.water_drop_rounded,
    ),
    HabitIconOption(
      key: 'meditation',
      label: 'Thiền / Tĩnh tâm',
      iconData: Icons.self_improvement_rounded,
    ),
    HabitIconOption(
      key: 'sleep',
      label: 'Ngủ sớm',
      iconData: Icons.bedtime_rounded,
    ),
    HabitIconOption(
      key: 'alarm',
      label: 'Dậy sớm',
      iconData: Icons.alarm_rounded,
    ),
    HabitIconOption(
      key: 'code',
      label: 'Lập trình',
      iconData: Icons.code_rounded,
    ),
    HabitIconOption(
      key: 'study',
      label: 'Học tập',
      iconData: Icons.school_rounded,
    ),
    HabitIconOption(
      key: 'finance',
      label: 'Tiết kiệm / Tài chính',
      iconData: Icons.savings_rounded,
    ),
    HabitIconOption(
      key: 'diet',
      label: 'Ăn lành mạnh',
      iconData: Icons.restaurant_rounded,
    ),
    HabitIconOption(
      key: 'write',
      label: 'Viết nhật ký',
      iconData: Icons.edit_note_rounded,
    ),
    HabitIconOption(
      key: 'clean',
      label: 'Dọn dẹp',
      iconData: Icons.cleaning_services_rounded,
    ),
    HabitIconOption(
      key: 'music',
      label: 'Nhạc cụ / Âm nhạc',
      iconData: Icons.music_note_rounded,
    ),
    HabitIconOption(
      key: 'heart',
      label: 'Sức khỏe',
      iconData: Icons.favorite_rounded,
    ),
    HabitIconOption(
      key: 'check',
      label: 'Kỷ luật chung',
      iconData: Icons.check_circle_outline_rounded,
    ),
  ];

  static IconData getIcon(String? key) {
    if (key == null || key.isEmpty) {
      return Icons.check_circle_outline_rounded;
    }
    for (final opt in options) {
      if (opt.key == key) {
        return opt.iconData;
      }
    }
    return Icons.check_circle_outline_rounded;
  }
}
