import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_discipline_app/models/habit.dart';
import 'package:personal_discipline_app/models/habit_frequency.dart';
import 'package:personal_discipline_app/providers/habit_provider.dart';
import 'package:personal_discipline_app/repositories/habit_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Habit Model & Frequency Tests', () {
    test('HabitFrequency daily returns true for any date', () {
      const freq = HabitFrequency(type: FrequencyType.daily);
      expect(freq.isScheduledForDate(DateTime(2026, 11, 4)), isTrue);
      expect(freq.getDisplayText(), 'Hàng ngày');
    });

    test('HabitFrequency specificDays filters correctly', () {
      // 1 = Monday, 3 = Wednesday, 5 = Friday
      const freq = HabitFrequency(
        type: FrequencyType.specificDays,
        daysOfWeek: [1, 3, 5],
      );
      // 2026-11-04 is Wednesday (weekday = 3)
      expect(freq.isScheduledForDate(DateTime(2026, 11, 4)), isTrue);
      // 2026-11-05 is Thursday (weekday = 4)
      expect(freq.isScheduledForDate(DateTime(2026, 11, 5)), isFalse);
    });

    test('Habit json serialization & deserialization', () {
      final habit = Habit(
        id: 'test_1',
        name: 'Đọc sách 20 phút',
        description: 'Tăng cường tri thức',
        frequency: const HabitFrequency(type: FrequencyType.daily),
        reminderTime: const TimeOfDay(hour: 21, minute: 30),
        colorValue: 0xFF10B981,
        iconKey: 'book',
      );

      final json = habit.toJson();
      final recreated = Habit.fromJson(json);

      expect(recreated.id, 'test_1');
      expect(recreated.name, 'Đọc sách 20 phút');
      expect(recreated.formattedReminderTime, '21:30');
      expect(recreated.iconKey, 'book');
    });
  });

  group('HabitProvider CRUD & Check-in Tests', () {
    test('Adds habit and toggles completion', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = HabitRepository(prefs);
      final provider = HabitProvider(repo);
      await provider.loadData();

      final habit = Habit(
        id: 'h_test',
        name: 'Chạy bộ',
        frequency: const HabitFrequency(type: FrequencyType.daily),
      );

      await provider.addHabit(habit);
      expect(provider.allHabits.any((h) => h.id == 'h_test'), isTrue);

      final today = DateTime.now();
      expect(provider.isHabitCompleted('h_test', today), isFalse);

      final toggledOn = await provider.toggleHabitCompletion('h_test', today);
      expect(toggledOn, isTrue);
      expect(provider.isHabitCompleted('h_test', today), isTrue);

      final toggledOff = await provider.toggleHabitCompletion('h_test', today);
      expect(toggledOff, isFalse);
      expect(provider.isHabitCompleted('h_test', today), isFalse);
    });

    test('Calculates streaks correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = HabitRepository(prefs);
      final provider = HabitProvider(repo);
      await provider.loadData();

      final habit = Habit(
        id: 'h_streak',
        name: 'Tập thể dục',
        frequency: const HabitFrequency(type: FrequencyType.daily),
      );
      await provider.addHabit(habit);

      final now = DateTime.now();
      // Complete today and yesterday
      await provider.toggleHabitCompletion('h_streak', now);
      await provider.toggleHabitCompletion(
        'h_streak',
        now.subtract(const Duration(days: 1)),
      );

      final streak = provider.calculateCurrentStreak('h_streak');
      expect(streak, 2);
    });
  });
}
