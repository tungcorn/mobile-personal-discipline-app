import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/daily_progress_banner.dart';
import '../widgets/date_timeline_bar.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/habit_card.dart';
import 'add_edit_habit_screen.dart';

class HabitListScreen extends StatelessWidget {
  const HabitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final theme = Theme.of(context);

    if (habitProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final displayedHabits = habitProvider.filteredHabits;
    final selectedDate = habitProvider.selectedDate;

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
                Icons.task_alt_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Kỷ Luật Cá Nhân',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Thêm thói quen mới',
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditHabitScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: CustomScrollView(
            slivers: [
              // Date Timeline Bar
              const SliverToBoxAdapter(
                child: DateTimelineBar(),
              ),

              // Daily Progress Banner & Filter Chips
              const SliverToBoxAdapter(
                child: DailyProgressBanner(),
              ),

              // Habit list header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Danh sách nhiệm vụ (${displayedHabits.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              theme.textTheme.bodySmall?.color?.withAlpha(190),
                        ),
                      ),
                      if (habitProvider.filter != 'all')
                        TextButton(
                          onPressed: () {
                            habitProvider.setFilter('all');
                          },
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Hiện tất cả'),
                        ),
                    ],
                  ),
                ),
              ),

              // Habit items or Empty state
              if (displayedHabits.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    icon: habitProvider.filter == 'completed'
                        ? Icons.checklist_rounded
                        : Icons.fact_check_outlined,
                    title: habitProvider.filter == 'completed'
                        ? 'Chưa hoàn thành thói quen nào'
                        : (habitProvider.activeHabits.isEmpty
                            ? 'Chưa có thói quen nào'
                            : 'Không có thói quen cho tiêu chí này'),
                    subtitle: habitProvider.activeHabits.isEmpty
                        ? 'Hãy bắt đầu thiết lập thói quen đầu tiên để rèn luyện kỷ luật mỗi ngày!'
                        : 'Hãy tích cực hoàn thành các nhiệm vụ hoặc kiểm tra lại bộ lọc.',
                    actionLabel: habitProvider.activeHabits.isEmpty
                        ? 'Thêm thói quen mới'
                        : null,
                    onAction: habitProvider.activeHabits.isEmpty
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AddEditHabitScreen(),
                              ),
                            );
                          }
                        : null,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = displayedHabits[index];
                      return HabitCard(
                        habit: habit,
                        date: selectedDate,
                      );
                    },
                    childCount: displayedHabits.length,
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditHabitScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Thêm thói quen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
