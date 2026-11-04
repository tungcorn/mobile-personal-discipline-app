enum FrequencyType {
  daily,
  specificDays,
  timesPerWeek,
}

class HabitFrequency {
  final FrequencyType type;
  /// For `specificDays`: list of day of week (1 = Monday, 7 = Sunday)
  final List<int> daysOfWeek;
  /// For `timesPerWeek`: target number of days per week (1..7)
  final int targetTimesPerWeek;

  const HabitFrequency({
    this.type = FrequencyType.daily,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    this.targetTimesPerWeek = 7,
  });

  bool isScheduledForDate(DateTime date) {
    if (type == FrequencyType.daily) {
      return true;
    }
    if (type == FrequencyType.specificDays) {
      return daysOfWeek.contains(date.weekday);
    }
    // For timesPerWeek, it's active any day towards weekly target
    return true;
  }

  String getDisplayText() {
    switch (type) {
      case FrequencyType.daily:
        return 'Hàng ngày';
      case FrequencyType.timesPerWeek:
        return '$targetTimesPerWeek lần/tuần';
      case FrequencyType.specificDays:
        if (daysOfWeek.length == 7) return 'Hàng ngày';
        if (daysOfWeek.length == 5 &&
            daysOfWeek.toSet().containsAll([1, 2, 3, 4, 5])) {
          return 'Thứ 2 - Thứ 6';
        }
        if (daysOfWeek.length == 2 &&
            daysOfWeek.toSet().containsAll([6, 7])) {
          return 'Cuối tuần (T7, CN)';
        }
        final sorted = List<int>.from(daysOfWeek)..sort();
        return sorted.map((d) {
          switch (d) {
            case 1:
              return 'T2';
            case 2:
              return 'T3';
            case 3:
              return 'T4';
            case 4:
              return 'T5';
            case 5:
              return 'T6';
            case 6:
              return 'T7';
            case 7:
              return 'CN';
            default:
              return '';
          }
        }).join(', ');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'daysOfWeek': daysOfWeek,
      'targetTimesPerWeek': targetTimesPerWeek,
    };
  }

  factory HabitFrequency.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String? ?? 'daily';
    final type = FrequencyType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => FrequencyType.daily,
    );

    final rawDays = json['daysOfWeek'];
    List<int> days = const [1, 2, 3, 4, 5, 6, 7];
    if (rawDays is List) {
      days = rawDays.map((e) => (e as num).toInt()).toList();
    }

    final target = (json['targetTimesPerWeek'] as num?)?.toInt() ?? 7;

    return HabitFrequency(
      type: type,
      daysOfWeek: days,
      targetTimesPerWeek: target,
    );
  }
}
