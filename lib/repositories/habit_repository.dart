import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../utils/sample_data.dart';

class HabitRepository {
  static const String _keyHabits = 'discipline_habits_v1';
  static const String _keyCompletions = 'discipline_completions_v1';
  static const String _keySeeded = 'discipline_has_seeded_v1';

  final SharedPreferences _prefs;

  HabitRepository(this._prefs);

  static Future<HabitRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return HabitRepository(prefs);
  }

  bool get hasSeeded => _prefs.getBool(_keySeeded) ?? false;

  Future<void> setHasSeeded(bool val) async {
    await _prefs.setBool(_keySeeded, val);
  }

  Future<List<Habit>> loadHabits() async {
    final rawString = _prefs.getString(_keyHabits);
    if (rawString == null || rawString.isEmpty) {
      if (!hasSeeded) {
        // First launch: initialize with sample habits
        final initialHabits = SampleData.getInitialHabits();
        await saveHabits(initialHabits);
        final initialCompletions = SampleData.getInitialCompletions(initialHabits);
        await saveCompletions(initialCompletions);
        await setHasSeeded(true);
        return initialHabits;
      }
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(rawString) as List<dynamic>;
      return decoded
          .map((item) => Habit.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final list = habits.map((h) => h.toJson()).toList();
    final encoded = jsonEncode(list);
    await _prefs.setString(_keyHabits, encoded);
  }

  Future<List<HabitCompletion>> loadCompletions() async {
    final rawString = _prefs.getString(_keyCompletions);
    if (rawString == null || rawString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(rawString) as List<dynamic>;
      return decoded
          .map((item) =>
              HabitCompletion.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveCompletions(List<HabitCompletion> completions) async {
    final list = completions.map((c) => c.toJson()).toList();
    final encoded = jsonEncode(list);
    await _prefs.setString(_keyCompletions, encoded);
  }

  Future<void> resetAllData() async {
    await _prefs.remove(_keyHabits);
    await _prefs.remove(_keyCompletions);
    await _prefs.remove(_keySeeded);
  }

  Future<void> seedFreshSampleData() async {
    final habits = SampleData.getInitialHabits();
    final completions = SampleData.getInitialCompletions(habits);
    await saveHabits(habits);
    await saveCompletions(completions);
    await setHasSeeded(true);
  }
}
