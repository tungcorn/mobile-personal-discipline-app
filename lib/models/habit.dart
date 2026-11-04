import 'package:flutter/material.dart';
import '../utils/color_options.dart';
import '../utils/icon_options.dart';
import 'habit_frequency.dart';

class Habit {
  final String id;
  final String name;
  final String description;
  final HabitFrequency frequency;
  final TimeOfDay? reminderTime;
  final int colorValue;
  final String iconKey;
  final DateTime createdAt;
  final bool isArchived;

  Habit({
    required this.id,
    required this.name,
    this.description = '',
    required this.frequency,
    this.reminderTime,
    this.colorValue = 0xFF10B981,
    this.iconKey = 'check',
    DateTime? createdAt,
    this.isArchived = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Color get color => AppColors.getColor(colorValue);
  IconData get icon => AppIcons.getIcon(iconKey);

  String? get formattedReminderTime {
    if (reminderTime == null) return null;
    final hour = reminderTime!.hour.toString().padLeft(2, '0');
    final minute = reminderTime!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    HabitFrequency? frequency,
    TimeOfDay? reminderTime,
    bool clearReminder = false,
    int? colorValue,
    String? iconKey,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      reminderTime: clearReminder ? null : (reminderTime ?? this.reminderTime),
      colorValue: colorValue ?? this.colorValue,
      iconKey: iconKey ?? this.iconKey,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequency': frequency.toJson(),
      'reminderHour': reminderTime?.hour,
      'reminderMinute': reminderTime?.minute,
      'colorValue': colorValue,
      'iconKey': iconKey,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    TimeOfDay? reminder;
    if (json['reminderHour'] != null && json['reminderMinute'] != null) {
      reminder = TimeOfDay(
        hour: (json['reminderHour'] as num).toInt(),
        minute: (json['reminderMinute'] as num).toInt(),
      );
    }

    return Habit(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      frequency: json['frequency'] != null
          ? HabitFrequency.fromJson(
              Map<String, dynamic>.from(json['frequency'] as Map))
          : const HabitFrequency(),
      reminderTime: reminder,
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF10B981,
      iconKey: json['iconKey'] as String? ?? 'check',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }
}
