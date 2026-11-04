import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/monthly_calendar_heatmap.dart';
import '../widgets/stat_metric_card.dart';
import '../widgets/weekly_bar_chart.dart';
import 'add_edit_habit_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late DateTime _currentWeekStart;
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentWeekStart = AppDateUtils.getStartOfWeek(now);
    _selectedYear = now.year;
    _selectedMonth = now.month;
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final theme = Theme.of(context);

    final activeHabits = habitProvider.activeHabits;

    if (activeHabits.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Thống Kê Tiến Độ'),
        ),
        body: EmptyStateView(
          icon: Icons.insights_rounded,
          title: 'Chưa có dữ liệu thống kê',
          subtitle: 'Hãy thêm thói quen và hoàn thành check-in để xem biểu đồ phân tích!',
          actionLabel: 'Thêm thói quen ngay',
          onAction: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditHabitScreen(),
              ),
            );
          },
        ),
      );
    }

    // Rates calculation
    final todayRate = habitProvider.completionRateForSelectedDate;
    final weeklyRate = habitProvider.getWeeklyCompletionRate(_currentWeekStart);
    final monthlyRate =
        habitProvider.getMonthlyCompletionRate(_selectedYear, _selectedMonth);
    final dailyRatesForWeek =
        habitProvider.getDailyRatesForWeek(_currentWeekStart);

    final bestStreak = habitProvider.overallBestStreak;
    final totalCompletions = habitProvider.totalCheckInsCount;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.insights_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Thống Kê Tiến Độ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Section 1: Overview Summary Cards
              Text(
                'Tổng quan tỷ lệ hoàn thành',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // 3-card metric grid: Day, Week, Month
              Row(
                children: [
                  Expanded(
                    child: StatMetricCard(
                      title: 'Hôm nay',
                      value: '${(todayRate * 100).toInt()}%',
                      subtitle:
                          '${habitProvider.completedCountForSelectedDate}/${habitProvider.scheduledCountForSelectedDate} mục tiêu',
                      icon: Icons.today_rounded,
                      color: const Color(0xFF10B981), // Emerald
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatMetricCard(
                      title: 'Tuần này',
                      value: '${(weeklyRate * 100).toInt()}%',
                      subtitle: 'Thứ 2 - CN',
                      icon: Icons.calendar_view_week_rounded,
                      color: const Color(0xFF3B82F6), // Blue
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatMetricCard(
                      title: 'Tháng $_selectedMonth',
                      value: '${(monthlyRate * 100).toInt()}%',
                      subtitle: 'Năm $_selectedYear',
                      icon: Icons.calendar_month_rounded,
                      color: const Color(0xFF8B5CF6), // Purple
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2 extra cards: Best Streak & Total Check-ins
              Row(
                children: [
                  Expanded(
                    child: StatMetricCard(
                      title: 'Chuỗi cao nhất',
                      value: '$bestStreak ngày',
                      subtitle: 'Kỷ luật bền bỉ 🔥',
                      icon: Icons.local_fire_department_rounded,
                      color: const Color(0xFFEF4444), // Red
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatMetricCard(
                      title: 'Tổng lượt check-in',
                      value: '$totalCompletions',
                      subtitle: 'Lần hoàn thành 🎯',
                      icon: Icons.done_all_rounded,
                      color: const Color(0xFFF59E0B), // Amber
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 2: Weekly Progress Chart
              WeeklyBarChart(
                dailyRates: dailyRatesForWeek,
                weekStart: _currentWeekStart,
              ),
              const SizedBox(height: 24),

              // Section 3: Monthly Heatmap Grid
              MonthlyCalendarHeatmap(
                year: _selectedYear,
                month: _selectedMonth,
              ),
              const SizedBox(height: 24),

              // Section 4: Individual Habits Breakdown
              Text(
                'Chi tiết từng thói quen',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...activeHabits.map((habit) {
                final rate = habitProvider.getHabitCompletionRate(habit.id);
                final curStreak =
                    habitProvider.calculateCurrentStreak(habit.id);
                final maxStreak = habitProvider.calculateBestStreak(habit.id);
                final totalDone =
                    habitProvider.getHabitTotalCompletions(habit.id);

                final isDark = theme.brightness == Brightness.dark;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.dividerColor.withAlpha(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: habit.color.withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(habit.icon,
                                color: habit.color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  habit.frequency.getDisplayText(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withAlpha(180),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${(rate * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: habit.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: rate,
                          minHeight: 8,
                          backgroundColor:
                              habit.color.withAlpha(isDark ? 40 : 20),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(habit.color),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailStat(
                            '🔥 Chuỗi hiện tại',
                            '$curStreak ngày',
                            theme,
                          ),
                          _buildDetailStat(
                            '🏆 Kỷ lục',
                            '$maxStreak ngày',
                            theme,
                          ),
                          _buildDetailStat(
                            '✓ Tổng hoàn thành',
                            '$totalDone lần',
                            theme,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.textTheme.bodySmall?.color?.withAlpha(160),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
