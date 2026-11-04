import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';

class DailyProgressBanner extends StatelessWidget {
  const DailyProgressBanner({super.key});

  String _getMotivationalMessage(double rate, int completed, int total) {
    if (total == 0) {
      return 'Chưa có thói quen nào cho ngày này. Hãy bấm dấu (+) để thêm!';
    }
    if (rate >= 1.0) {
      return 'Xuất sắc! Bạn đã hoàn thành 100% mục tiêu ngày hôm nay! 🏆';
    }
    if (rate >= 0.7) {
      return 'Rất tốt! Bạn đang duy trì phong độ kỷ luật rất vững vàng. 💪';
    }
    if (rate >= 0.4) {
      return 'Tiến độ đang tăng đều! Hoàn thành nốt các mục tiêu còn lại nhé. ⚡';
    }
    if (completed > 0) {
      return 'Khởi đầu tích cực! Kỷ luật là chiếc cầu nối đến thành công. 🌱';
    }
    return 'Mỗi bước đi nhỏ hôm nay đều kiến tạo tương lai của bạn. Bắt đầu ngay! 🎯';
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final completed = habitProvider.completedCountForSelectedDate;
    final total = habitProvider.scheduledCountForSelectedDate;
    final rate = habitProvider.completionRateForSelectedDate;
    final percentage = (rate * 100).toInt();

    final message = _getMotivationalMessage(rate, completed, total);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF065F46), const Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF065F46))
                .withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFFFBBF24),
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'TIẾN ĐỘ KỶ LUẬT',
                          style: TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      total == 0
                          ? '0 / 0 thói quen'
                          : '$completed / $total thói quen',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white.withAlpha(220),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Circular progress indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: CircularProgressIndicator(
                      value: total == 0 ? 0.0 : rate,
                      backgroundColor: Colors.white.withAlpha(40),
                      color: rate >= 1.0
                          ? const Color(0xFF34D399)
                          : const Color(0xFFFBBF24),
                      strokeWidth: 6.5,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Filter Chips
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                context,
                label: 'Tất cả ($total)',
                filterKey: 'all',
                isSelected: habitProvider.filter == 'all',
              ),
              _buildFilterChip(
                context,
                label: 'Chưa xong (${total - completed})',
                filterKey: 'pending',
                isSelected: habitProvider.filter == 'pending',
              ),
              _buildFilterChip(
                context,
                label: 'Đã hoàn thành ($completed)',
                filterKey: 'completed',
                isSelected: habitProvider.filter == 'completed',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String filterKey,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        context.read<HabitProvider>().setFilter(filterKey);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withAlpha(40),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF065F46) : Colors.white,
          ),
        ),
      ),
    );
  }
}
