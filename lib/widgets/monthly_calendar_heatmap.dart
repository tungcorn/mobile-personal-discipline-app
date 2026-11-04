import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../utils/date_utils.dart';

class MonthlyCalendarHeatmap extends StatelessWidget {
  final int year;
  final int month;

  const MonthlyCalendarHeatmap({
    super.key,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final daysInMonth = AppDateUtils.getDaysInMonth(year, month);
    final firstDayWeekday = daysInMonth.first.weekday; // 1 = Mon, 7 = Sun
    final emptyLeadingBoxes = firstDayWeekday - 1;

    final weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final today = AppDateUtils.normalizeDate(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lưới kỷ luật tháng $month/$year',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Tháng $month',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekday headers
          Row(
            children: weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: emptyLeadingBoxes + daysInMonth.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              if (index < emptyLeadingBoxes) {
                return const SizedBox.shrink();
              }

              final dayIndex = index - emptyLeadingBoxes;
              final date = daysInMonth[dayIndex];
              final isCurrentDay = AppDateUtils.isSameDay(date, today);
              final isFuture = date.isAfter(today);

              // Calculate day rate
              double rate = 0.0;
              if (!isFuture) {
                int scheduled = 0;
                int completed = 0;
                for (final habit in habitProvider.activeHabits) {
                  if (habit.frequency.isScheduledForDate(date)) {
                    scheduled++;
                    if (habitProvider.isHabitCompleted(habit.id, date)) {
                      completed++;
                    }
                  }
                }
                if (scheduled > 0) {
                  rate = (completed / scheduled).clamp(0.0, 1.0);
                }
              }

              Color cellColor;
              Color textColor;

              if (isFuture) {
                cellColor = isDark
                    ? Colors.white.withAlpha(5)
                    : Colors.black.withAlpha(5);
                textColor = theme.disabledColor;
              } else if (rate >= 0.8) {
                cellColor = const Color(0xFF10B981); // Emerald
                textColor = Colors.white;
              } else if (rate >= 0.5) {
                cellColor = const Color(0xFF34D399); // Light green
                textColor = Colors.white;
              } else if (rate > 0) {
                cellColor = const Color(0xFFA7F3D0); // Pale green
                textColor = const Color(0xFF065F46);
              } else {
                cellColor = isDark
                    ? Colors.white.withAlpha(12)
                    : Colors.black.withAlpha(8);
                textColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
              }

              return Tooltip(
                message:
                    '${AppDateUtils.formatVietnameseWeekday(date.weekday)} ${date.day}/$month: ${(rate * 100).toInt()}%',
                child: InkWell(
                  onTap: () {
                    habitProvider.setSelectedDate(date);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(8),
                      border: isCurrentDay
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 2.0,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isCurrentDay ? FontWeight.bold : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Ít',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                ),
              ),
              const SizedBox(width: 6),
              _buildLegendBox(
                isDark ? Colors.white.withAlpha(12) : Colors.black.withAlpha(8),
              ),
              const SizedBox(width: 4),
              _buildLegendBox(const Color(0xFFA7F3D0)),
              const SizedBox(width: 4),
              _buildLegendBox(const Color(0xFF34D399)),
              const SizedBox(width: 4),
              _buildLegendBox(const Color(0xFF10B981)),
              const SizedBox(width: 6),
              Text(
                'Nhiều',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
