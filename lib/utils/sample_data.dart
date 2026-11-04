import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../models/habit_frequency.dart';
import 'date_utils.dart';

class SampleData {
  static List<Habit> getInitialHabits() {
    final now = DateTime.now();
    return [
      Habit(
        id: 'habit_run',
        name: 'Chạy bộ 30 phút buổi sáng',
        description: 'Tăng cường sức bền, cải thiện sức khỏe tim mạch và tinh thần sảng khoái.',
        frequency: const HabitFrequency(type: FrequencyType.daily),
        reminderTime: const TimeOfDay(hour: 6, minute: 30),
        colorValue: 0xFF10B981, // Emerald
        iconKey: 'run',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Habit(
        id: 'habit_book',
        name: 'Đọc 20 trang sách phát triển bản thân',
        description: 'Tích lũy tri thức, mở rộng tư duy và duy trì sự tập trung mỗi ngày.',
        frequency: const HabitFrequency(type: FrequencyType.daily),
        reminderTime: const TimeOfDay(hour: 21, minute: 0),
        colorValue: 0xFF6366F1, // Indigo
        iconKey: 'book',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Habit(
        id: 'habit_water',
        name: 'Uống đủ 2 lít nước lọc',
        description: 'Bổ sung nước đều đặn suốt ngày làm việc, giúp thanh lọc cơ thể.',
        frequency: const HabitFrequency(type: FrequencyType.daily),
        reminderTime: const TimeOfDay(hour: 8, minute: 0),
        colorValue: 0xFF14B8A6, // Teal
        iconKey: 'water',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Habit(
        id: 'habit_code',
        name: 'Lập trình & học công nghệ mới 45 phút',
        description: 'Nâng cao kỹ năng lập trình, rèn luyện tư duy giải quyết vấn đề.',
        frequency: const HabitFrequency(
          type: FrequencyType.specificDays,
          daysOfWeek: [1, 2, 3, 4, 5],
        ),
        reminderTime: const TimeOfDay(hour: 19, minute: 30),
        colorValue: 0xFF3B82F6, // Blue
        iconKey: 'code',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Habit(
        id: 'habit_meditate',
        name: 'Thiền định 10 phút',
        description: 'Hít thở sâu, thư giãn tâm trí và giảm căng thẳng.',
        frequency: const HabitFrequency(type: FrequencyType.daily),
        reminderTime: const TimeOfDay(hour: 7, minute: 0),
        colorValue: 0xFF8B5CF6, // Purple
        iconKey: 'meditation',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Habit(
        id: 'habit_sleep',
        name: 'Đi ngủ trước 23:00',
        description: 'Không dùng thiết bị điện tử 30 phút trước khi ngủ để hồi phục năng lượng.',
        frequency: const HabitFrequency(type: FrequencyType.daily),
        reminderTime: const TimeOfDay(hour: 22, minute: 30),
        colorValue: 0xFFF59E0B, // Amber
        iconKey: 'sleep',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }

  /// Generates realistic completion history for the last 14 days
  static List<HabitCompletion> getInitialCompletions(List<Habit> habits) {
    final completions = <HabitCompletion>[];
    final now = DateTime.now();

    for (int dayOffset = 14; dayOffset >= 0; dayOffset--) {
      final date = now.subtract(Duration(days: dayOffset));
      final dateKey = AppDateUtils.toDateKey(date);

      for (int i = 0; i < habits.length; i++) {
        final habit = habits[i];
        if (!habit.frequency.isScheduledForDate(date)) continue;

        // Simulate high discipline completion (approx 70-90% check-ins)
        final isCompleted = ((dayOffset * 7 + i * 3) % 10) < 8;
        if (isCompleted) {
          completions.add(HabitCompletion(
            id: 'init_${habit.id}_$dateKey',
            habitId: habit.id,
            dateString: dateKey,
            completedAt: date.add(const Duration(hours: 12)),
          ));
        }
      }
    }
    return completions;
  }
}
