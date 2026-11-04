import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final habitProvider = context.watch<HabitProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                Icons.settings_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Cài Đặt & Dữ Liệu',
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
              // Theme Section
              _buildSectionHeader('GIAO DIỆN & HIỂN THỊ', theme),
              Material(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.dividerColor.withAlpha(40)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        themeProvider.themeMode == ThemeMode.dark
                            ? Icons.dark_mode_rounded
                            : (themeProvider.themeMode == ThemeMode.light
                                ? Icons.light_mode_rounded
                                : Icons.brightness_auto_rounded),
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Chế độ giao diện'),
                      subtitle: Text(
                        themeProvider.themeMode == ThemeMode.dark
                            ? 'Chế độ tối (Dark)'
                            : (themeProvider.themeMode == ThemeMode.light
                                ? 'Chế độ sáng (Light)'
                                : 'Theo hệ thống thiết bị'),
                      ),
                      trailing: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_rounded, size: 16),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_rounded, size: 16),
                          ),
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.brightness_auto_rounded, size: 16),
                          ),
                        ],
                        selected: {themeProvider.themeMode},
                        onSelectionChanged: (set) {
                          themeProvider.setThemeMode(set.first);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Management Section
              _buildSectionHeader('QUẢN LÝ DỮ LIỆU CỤC BỘ', theme),
              Material(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.dividerColor.withAlpha(40)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.data_array_rounded,
                          color: Color(0xFF10B981)),
                      title: const Text('Tạo lại dữ liệu mẫu (Seed Demo)'),
                      subtitle: const Text(
                        'Nạp các thói quen mẫu và lịch sử hoàn thành để chấm điểm & trải nghiệm',
                      ),
                      onTap: () async {
                        await habitProvider.seedSampleData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã nạp thành công bộ dữ liệu mẫu!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.delete_sweep_rounded,
                          color: theme.colorScheme.error),
                      title: Text(
                        'Xóa toàn bộ dữ liệu (Reset)',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      subtitle: const Text('Đặt lại ứng dụng về trạng thái trống ban đầu'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            title: const Text('Xác nhận đặt lại toàn bộ'),
                            content: const Text(
                              'Thao tác này sẽ xóa sạch tất cả thói quen và lịch sử check-in lưu trữ trong SharedPreferences.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                child: const Text('Hủy'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                                onPressed: () async {
                                  Navigator.pop(dialogCtx);
                                  await habitProvider.resetAllData();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Đã xóa toàn bộ dữ liệu!'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Xóa sạch'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Discipline Philosophy Section
              _buildSectionHeader('NGUYÊN TẮC KỶ LUẬT (ATOMIC HABITS)', theme),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                        : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF10B981).withAlpha(80),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tips_and_updates_rounded,
                            color: Color(0xFF10B981)),
                        SizedBox(width: 8),
                        Text(
                          'Quy luật 1% mỗi ngày',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tốt hơn 1% mỗi ngày trong 1 năm: (1.01)^365 = 37.78 lần!\n'
                      'Kỷ luật không phải là sự gò bó, mà là tự do cao nhất. Khi bạn làm chủ được thói quen của mình, bạn làm chủ cuộc đời mình.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark
                            ? Colors.white.withAlpha(220)
                            : const Color(0xFF064E3B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // App Info
              Center(
                child: Column(
                  children: [
                    Text(
                      'Ứng Dụng Kỷ Luật Cá Nhân v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodySmall?.color?.withAlpha(150),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Flutter • SharedPreferences • Provider • Material 3',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color?.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
