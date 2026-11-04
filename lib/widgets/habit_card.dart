import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../screens/add_edit_habit_screen.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final DateTime date;

  const HabitCard({
    super.key,
    required this.habit,
    required this.date,
  });

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa thói quen "${habit.name}"? Dữ liệu lịch sử sẽ bị xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<HabitProvider>().deleteHabit(habit.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa thói quen "${habit.name}"'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final isCompleted = habitProvider.isHabitCompleted(habit.id, date);
    final streak = habitProvider.calculateCurrentStreak(habit.id);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final habitColor = habit.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isCompleted
            ? (isDark
                ? habitColor.withAlpha(25)
                : habitColor.withAlpha(18))
            : theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted
              ? habitColor.withAlpha(120)
              : theme.dividerColor.withAlpha(45),
          width: isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            final nowDone = await habitProvider.toggleHabitCompletion(
              habit.id,
              date,
            );
            if (context.mounted && nowDone) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Đã đánh dấu hoàn thành "${habit.name}"!',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? habitColor
                        : habitColor.withAlpha(35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    habit.icon,
                    color: isCompleted ? Colors.white : habitColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),

                // Habit Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted
                              ? theme.textTheme.bodyMedium?.color?.withAlpha(160)
                              : null,
                        ),
                      ),
                      if (habit.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          habit.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withAlpha(180),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),

                      // Badges Row
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Frequency Badge
                          _buildBadge(
                            icon: Icons.repeat_rounded,
                            text: habit.frequency.getDisplayText(),
                            color: theme.colorScheme.primary,
                            isDark: isDark,
                          ),
                          // Reminder Badge
                          if (habit.formattedReminderTime != null)
                            _buildBadge(
                              icon: Icons.notifications_active_outlined,
                              text: habit.formattedReminderTime!,
                              color: const Color(0xFFF59E0B),
                              isDark: isDark,
                            ),
                          // Streak Badge
                          if (streak > 0)
                            _buildBadge(
                              icon: Icons.local_fire_department_rounded,
                              text: '$streak ngày',
                              color: const Color(0xFFEF4444),
                              isDark: isDark,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Interactive Checkmark Button
                GestureDetector(
                  onTap: () async {
                    await habitProvider.toggleHabitCompletion(habit.id, date);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isCompleted ? habitColor : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? habitColor
                            : theme.dividerColor.withAlpha(120),
                        width: 2.2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  ),
                ),

                // Popup menu for Edit / Delete
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: theme.iconTheme.color?.withAlpha(160),
                  ),
                  tooltip: 'Tùy chọn',
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditHabitScreen(
                            habitToEdit: habit,
                          ),
                        ),
                      );
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 10),
                          Text('Chỉnh sửa'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              color: theme.colorScheme.error, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Xóa',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String text,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 40 : 25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withAlpha(isDark ? 80 : 60),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
