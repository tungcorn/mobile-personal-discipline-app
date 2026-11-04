import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../utils/date_utils.dart';

class DateTimelineBar extends StatelessWidget {
  const DateTimelineBar({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final selectedDate = habitProvider.selectedDate;
    final theme = Theme.of(context);

    // Provide a range: 10 days before today to 3 days after today
    final today = AppDateUtils.normalizeDate(DateTime.now());
    final dates = List.generate(
      18,
      (index) => today.subtract(Duration(days: 14 - index)),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppDateUtils.formatDisplayFullDate(selectedDate),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!AppDateUtils.isToday(selectedDate))
                TextButton.icon(
                  onPressed: () {
                    habitProvider.setSelectedDate(DateTime.now());
                  },
                  icon: const Icon(Icons.today_rounded, size: 18),
                  label: const Text('Về hôm nay'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 84,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = AppDateUtils.isSameDay(date, selectedDate);
              final isCurrentToday = AppDateUtils.isToday(date);
              final isFuture = date.isAfter(today);

              final dayLetter =
                  AppDateUtils.formatVietnameseWeekday(date.weekday, short: true);
              final dayNumber = date.day.toString();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () {
                    habitProvider.setSelectedDate(date);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 54,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isCurrentToday
                              ? theme.colorScheme.primaryContainer.withAlpha(128)
                              : theme.colorScheme.surface),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isCurrentToday
                                ? theme.colorScheme.primary
                                : theme.dividerColor.withAlpha(40)),
                        width: isSelected || isCurrentToday ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withAlpha(80),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayLetter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : (isFuture
                                    ? theme.disabledColor
                                    : theme.textTheme.bodySmall?.color),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayNumber,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : (isFuture
                                    ? theme.disabledColor
                                    : theme.textTheme.bodyLarge?.color),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Dot for completed status indicator
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : (isCurrentToday
                                    ? theme.colorScheme.primary
                                    : Colors.transparent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
