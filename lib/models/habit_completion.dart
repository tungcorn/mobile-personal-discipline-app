class HabitCompletion {
  final String id;
  final String habitId;
  /// Format: YYYY-MM-DD
  final String dateString;
  final DateTime completedAt;
  final String? note;

  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.dateString,
    required this.completedAt,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'dateString': dateString,
      'completedAt': completedAt.toIso8601String(),
      'note': note,
    };
  }

  factory HabitCompletion.fromJson(Map<String, dynamic> json) {
    return HabitCompletion(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      dateString: json['dateString'] as String,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      note: json['note'] as String?,
    );
  }
}
