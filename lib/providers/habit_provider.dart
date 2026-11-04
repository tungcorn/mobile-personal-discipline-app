import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../models/habit_frequency.dart';
import '../repositories/habit_repository.dart';
import '../utils/date_utils.dart';

class HabitProvider extends ChangeNotifier {
  final HabitRepository _repository;
  final Uuid _uuid = const Uuid();

  List<Habit> _habits = [];
  List<HabitCompletion> _completions = [];
  final Map<String, Set<String>> _completionsCache = {};

  DateTime _selectedDate = AppDateUtils.normalizeDate(DateTime.now());
  String _filter = 'all'; // 'all', 'pending', 'completed'
  bool _isLoading = true;
  Future<void>? _loadingFuture;

  HabitProvider(this._repository) {
    _loadingFuture = _performLoadData();
  }

  Future<void> get initialized => _loadingFuture ?? Future.value();

  // Getters
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;
  String get filter => _filter;
  List<Habit> get allHabits => List.unmodifiable(_habits);

  List<Habit> get activeHabits =>
      _habits.where((h) => !h.isArchived).toList();

  /// Habits scheduled for the currently selected date
  List<Habit> get scheduledHabitsForSelectedDate {
    return activeHabits
        .where((h) => h.frequency.isScheduledForDate(_selectedDate))
        .toList();
  }

  /// Habits filtered by completion status for the selected date
  List<Habit> get filteredHabits {
    final scheduled = scheduledHabitsForSelectedDate;
    if (_filter == 'completed') {
      return scheduled
          .where((h) => isHabitCompleted(h.id, _selectedDate))
          .toList();
    } else if (_filter == 'pending') {
      return scheduled
          .where((h) => !isHabitCompleted(h.id, _selectedDate))
          .toList();
    }
    return scheduled;
  }

  int get scheduledCountForSelectedDate =>
      scheduledHabitsForSelectedDate.length;

  int get completedCountForSelectedDate {
    final dateKey = AppDateUtils.toDateKey(_selectedDate);
    final completedSet = _completionsCache[dateKey] ?? <String>{};
    return scheduledHabitsForSelectedDate
        .where((h) => completedSet.contains(h.id))
        .length;
  }

  double get completionRateForSelectedDate {
    final total = scheduledCountForSelectedDate;
    if (total == 0) return 0.0;
    return (completedCountForSelectedDate / total).clamp(0.0, 1.0);
  }

  // ----------------------------------------------------
  // Initial Data Loading
  // ----------------------------------------------------
  Future<void> loadData() {
    if (_loadingFuture != null) return _loadingFuture!;
    _loadingFuture = _performLoadData();
    return _loadingFuture!;
  }

  Future<void> _performLoadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _repository.loadHabits();
      _completions = await _repository.loadCompletions();
      _rebuildCompletionsCache();
    } finally {
      _isLoading = false;
      _loadingFuture = null;
      notifyListeners();
    }
  }

  void _rebuildCompletionsCache() {
    _completionsCache.clear();
    for (final completion in _completions) {
      _completionsCache
          .putIfAbsent(completion.dateString, () => <String>{})
          .add(completion.habitId);
    }
  }

  // ----------------------------------------------------
  // UI Actions & Filters
  // ----------------------------------------------------
  void setSelectedDate(DateTime date) {
    _selectedDate = AppDateUtils.normalizeDate(date);
    notifyListeners();
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  // ----------------------------------------------------
  // CRUD Operations
  // ----------------------------------------------------
  Future<void> addHabit(Habit habit) async {
    final newHabit = habit.id.isEmpty
        ? habit.copyWith(id: _uuid.v4())
        : habit;
    _habits.add(newHabit);
    await _repository.saveHabits(_habits);
    notifyListeners();
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      await _repository.saveHabits(_habits);
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);
    _completions.removeWhere((c) => c.habitId == habitId);
    _rebuildCompletionsCache();
    await _repository.saveHabits(_habits);
    await _repository.saveCompletions(_completions);
    notifyListeners();
  }

  // ----------------------------------------------------
  // Completion Check-in
  // ----------------------------------------------------
  bool isHabitCompleted(String habitId, DateTime date) {
    final key = AppDateUtils.toDateKey(date);
    return _completionsCache[key]?.contains(habitId) ?? false;
  }

  Future<bool> toggleHabitCompletion(String habitId, DateTime date,
      {String? note}) async {
    final key = AppDateUtils.toDateKey(date);
    final isAlreadyCompleted = isHabitCompleted(habitId, date);

    if (isAlreadyCompleted) {
      // Remove completion
      _completions.removeWhere(
          (c) => c.habitId == habitId && c.dateString == key);
      _completionsCache[key]?.remove(habitId);
      await _repository.saveCompletions(_completions);
      notifyListeners();
      return false;
    } else {
      // Add completion
      final newCompletion = HabitCompletion(
        id: _uuid.v4(),
        habitId: habitId,
        dateString: key,
        completedAt: DateTime.now(),
        note: note,
      );
      _completions.add(newCompletion);
      _completionsCache.putIfAbsent(key, () => <String>{}).add(habitId);
      await _repository.saveCompletions(_completions);
      notifyListeners();
      return true;
    }
  }

  // ----------------------------------------------------
  // Advanced Statistics & Streaks
  // ----------------------------------------------------
  /// Calculates current streak for a given habit (days in a row completed)
  int calculateCurrentStreak(String habitId) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => Habit(
        id: '',
        name: '',
        frequency: const HabitFrequency(),
      ),
    );
    if (habit.id.isEmpty) return 0;

    final today = AppDateUtils.normalizeDate(DateTime.now());
    var checkDate = today;
    int streak = 0;

    // Check if completed today; if not yet, see if completed yesterday
    final isDoneToday = isHabitCompleted(habitId, today);
    if (!isDoneToday) {
      checkDate = today.subtract(const Duration(days: 1));
    }

    while (true) {
      if (habit.frequency.isScheduledForDate(checkDate)) {
        if (isHabitCompleted(habitId, checkDate)) {
          streak++;
        } else {
          break; // streak broke
        }
      }
      checkDate = checkDate.subtract(const Duration(days: 1));

      // Limit check to 365 days back
      if (today.difference(checkDate).inDays > 365) break;
    }

    return streak;
  }

  /// Calculates best streak historically for a habit
  int calculateBestStreak(String habitId) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => Habit(
        id: '',
        name: '',
        frequency: const HabitFrequency(),
      ),
    );
    if (habit.id.isEmpty) return 0;

    final today = AppDateUtils.normalizeDate(DateTime.now());
    int maxStreak = 0;
    int currentStreak = 0;

    // Iterate up to 180 days backwards
    for (int i = 180; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      if (habit.frequency.isScheduledForDate(date)) {
        if (isHabitCompleted(habitId, date)) {
          currentStreak++;
          if (currentStreak > maxStreak) {
            maxStreak = currentStreak;
          }
        } else {
          currentStreak = 0;
        }
      }
    }
    return maxStreak;
  }

  /// Total completions count for a habit
  int getHabitTotalCompletions(String habitId) {
    return _completions.where((c) => c.habitId == habitId).length;
  }

  /// Completion rate for a single habit over the past [days] days
  double getHabitCompletionRate(String habitId, {int days = 30}) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => Habit(
        id: '',
        name: '',
        frequency: const HabitFrequency(),
      ),
    );
    if (habit.id.isEmpty) return 0.0;

    final today = AppDateUtils.normalizeDate(DateTime.now());
    int scheduled = 0;
    int completed = 0;

    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      if (habit.frequency.isScheduledForDate(date)) {
        scheduled++;
        if (isHabitCompleted(habitId, date)) {
          completed++;
        }
      }
    }

    if (scheduled == 0) return 0.0;
    return (completed / scheduled).clamp(0.0, 1.0);
  }

  /// Weekly completion rate for the week containing [weekDate]
  double getWeeklyCompletionRate(DateTime weekDate) {
    final daysOfWeek = AppDateUtils.getDaysOfWeek(weekDate);
    final today = AppDateUtils.normalizeDate(DateTime.now());

    int totalScheduled = 0;
    int totalCompleted = 0;

    for (final date in daysOfWeek) {
      // Don't penalize future days
      if (date.isAfter(today)) continue;

      for (final habit in activeHabits) {
        if (habit.frequency.isScheduledForDate(date)) {
          totalScheduled++;
          if (isHabitCompleted(habit.id, date)) {
            totalCompleted++;
          }
        }
      }
    }

    if (totalScheduled == 0) return 0.0;
    return (totalCompleted / totalScheduled).clamp(0.0, 1.0);
  }

  /// List of 7 completion rates (0.0 to 1.0) for Monday through Sunday
  List<double> getDailyRatesForWeek(DateTime weekDate) {
    final daysOfWeek = AppDateUtils.getDaysOfWeek(weekDate);
    final today = AppDateUtils.normalizeDate(DateTime.now());

    return daysOfWeek.map((date) {
      if (date.isAfter(today)) return 0.0;

      int scheduled = 0;
      int completed = 0;

      for (final habit in activeHabits) {
        if (habit.frequency.isScheduledForDate(date)) {
          scheduled++;
          if (isHabitCompleted(habit.id, date)) {
            completed++;
          }
        }
      }

      if (scheduled == 0) return 0.0;
      return (completed / scheduled).clamp(0.0, 1.0);
    }).toList();
  }

  /// Monthly completion rate for [month] of [year]
  double getMonthlyCompletionRate(int year, int month) {
    final days = AppDateUtils.getDaysInMonth(year, month);
    final today = AppDateUtils.normalizeDate(DateTime.now());

    int totalScheduled = 0;
    int totalCompleted = 0;

    for (final date in days) {
      if (date.isAfter(today)) continue;

      for (final habit in activeHabits) {
        if (habit.frequency.isScheduledForDate(date)) {
          totalScheduled++;
          if (isHabitCompleted(habit.id, date)) {
            totalCompleted++;
          }
        }
      }
    }

    if (totalScheduled == 0) return 0.0;
    return (totalCompleted / totalScheduled).clamp(0.0, 1.0);
  }

  /// Overall best streak across any habit
  int get overallBestStreak {
    if (activeHabits.isEmpty) return 0;
    int max = 0;
    for (final habit in activeHabits) {
      final s = calculateBestStreak(habit.id);
      if (s > max) max = s;
    }
    return max;
  }

  int get totalCheckInsCount => _completions.length;

  // ----------------------------------------------------
  // Reset & Sample Data Tools
  // ----------------------------------------------------
  Future<void> resetAllData() async {
    await _repository.resetAllData();
    _habits = [];
    _completions = [];
    _completionsCache.clear();
    notifyListeners();
  }

  Future<void> seedSampleData() async {
    await _repository.seedFreshSampleData();
    await loadData();
  }
}
