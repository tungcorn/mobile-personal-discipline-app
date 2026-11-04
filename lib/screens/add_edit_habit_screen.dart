import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../models/habit_frequency.dart';
import '../providers/habit_provider.dart';
import '../utils/color_options.dart';
import '../utils/icon_options.dart';

class AddEditHabitScreen extends StatefulWidget {
  final Habit? habitToEdit;

  const AddEditHabitScreen({super.key, this.habitToEdit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;

  FrequencyType _frequencyType = FrequencyType.daily;
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];
  int _targetTimesPerWeek = 5;

  bool _hasReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 7, minute: 0);

  late String _selectedIconKey;
  late int _selectedColorValue;

  bool get isEditing => widget.habitToEdit != null;

  @override
  void initState() {
    super.initState();
    final habit = widget.habitToEdit;
    if (habit != null) {
      _nameController = TextEditingController(text: habit.name);
      _descController = TextEditingController(text: habit.description);
      _frequencyType = habit.frequency.type;
      _selectedDays = List.from(habit.frequency.daysOfWeek);
      _targetTimesPerWeek = habit.frequency.targetTimesPerWeek;

      if (habit.reminderTime != null) {
        _hasReminder = true;
        _reminderTime = habit.reminderTime!;
      }

      _selectedIconKey = habit.iconKey;
      _selectedColorValue = habit.colorValue;
    } else {
      _nameController = TextEditingController();
      _descController = TextEditingController();
      _selectedIconKey = 'check';
      _selectedColorValue = 0xFF10B981; // Default emerald
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      helpText: 'CHỌN GIỜ NHẮC NHỞ',
      cancelText: 'HỦY',
      confirmText: 'CHỌN',
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_frequencyType == FrequencyType.specificDays && _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một ngày trong tuần!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final frequency = HabitFrequency(
      type: _frequencyType,
      daysOfWeek: _selectedDays,
      targetTimesPerWeek: _targetTimesPerWeek,
    );

    final habitProvider = context.read<HabitProvider>();

    if (isEditing) {
      final updated = widget.habitToEdit!.copyWith(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        frequency: frequency,
        reminderTime: _hasReminder ? _reminderTime : null,
        clearReminder: !_hasReminder,
        colorValue: _selectedColorValue,
        iconKey: _selectedIconKey,
      );
      habitProvider.updateHabit(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật thói quen "${updated.name}"'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final newHabit = Habit(
        id: '', // Will be assigned UUID by provider
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        frequency: frequency,
        reminderTime: _hasReminder ? _reminderTime : null,
        colorValue: _selectedColorValue,
        iconKey: _selectedIconKey,
      );
      habitProvider.addHabit(newHabit);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm thói quen mới "${newHabit.name}"'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Chỉnh sửa thói quen' : 'Tạo thói quen mới',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveHabit,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Lưu'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Preview Card
                _buildPreviewCard(theme, isDark),
                const SizedBox(height: 24),

                // Name input
                Text(
                  'Tên thói quen *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: Đọc sách 20 trang, Chạy bộ...',
                    prefixIcon: const Icon(Icons.fitness_center_rounded),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên thói quen';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description input
                Text(
                  'Mô tả / Động lực',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Mục đích rèn luyện hoặc lưu ý quan trọng...',
                    prefixIcon: const Icon(Icons.notes_rounded),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),

                // Frequency Section
                Text(
                  'Tần suất thực hiện *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFrequencySelector(theme, isDark),
                const SizedBox(height: 24),

                // Reminder Section
                _buildReminderTile(theme, isDark),
                const SizedBox(height: 24),

                // Icon Picker
                Text(
                  'Biểu tượng',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildIconGrid(theme, isDark),
                const SizedBox(height: 24),

                // Color Picker
                Text(
                  'Màu sắc chủ đạo',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildColorSelector(),
                const SizedBox(height: 32),

                // Submit Button
                FilledButton.icon(
                  onPressed: _saveHabit,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: Text(
                    isEditing ? 'Cập nhật thói quen' : 'Tạo thói quen',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(ThemeData theme, bool isDark) {
    final previewName = _nameController.text.trim().isEmpty
        ? 'Tên thói quen của bạn'
        : _nameController.text.trim();
    final previewDesc = _descController.text.trim().isEmpty
        ? 'Mô tả thói quen sẽ hiển thị tại đây'
        : _descController.text.trim();
    final habitColor = Color(_selectedColorValue);
    final iconData = AppIcons.getIcon(_selectedIconKey);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: habitColor.withAlpha(isDark ? 35 : 20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: habitColor.withAlpha(120),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: habitColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconData, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  previewName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  previewDesc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySelector(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<FrequencyType>(
            segments: const [
              ButtonSegment(
                value: FrequencyType.daily,
                label: Text('Hàng ngày'),
              ),
              ButtonSegment(
                value: FrequencyType.specificDays,
                label: Text('Theo thứ'),
              ),
              ButtonSegment(
                value: FrequencyType.timesPerWeek,
                label: Text('Số lần/tuần'),
              ),
            ],
            selected: {_frequencyType},
            onSelectionChanged: (set) {
              setState(() {
                _frequencyType = set.first;
              });
            },
          ),
          if (_frequencyType == FrequencyType.specificDays) ...[
            const SizedBox(height: 16),
            const Text(
              'Chọn các ngày trong tuần:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final dayNum = index + 1; // 1 = Mon .. 7 = Sun
                final label = _getDayShortName(dayNum);
                final isSelected = _selectedDays.contains(dayNum);

                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.textTheme.bodyMedium?.color,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(dayNum);
                        _selectedDays.sort();
                      } else {
                        _selectedDays.remove(dayNum);
                      }
                    });
                  },
                );
              }),
            ),
          ],
          if (_frequencyType == FrequencyType.timesPerWeek) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mục tiêu số ngày mỗi tuần:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  '$_targetTimesPerWeek ngày / tuần',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: _targetTimesPerWeek.toDouble(),
              min: 1,
              max: 7,
              divisions: 6,
              label: '$_targetTimesPerWeek ngày',
              onChanged: (val) {
                setState(() {
                  _targetTimesPerWeek = val.round();
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  String _getDayShortName(int day) {
    switch (day) {
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
  }

  Widget _buildReminderTile(ThemeData theme, bool isDark) {
    final hour = _reminderTime.hour.toString().padLeft(2, '0');
    final minute = _reminderTime.minute.toString().padLeft(2, '0');

    return Material(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(
              'Nhắc nhở hàng ngày',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              _hasReminder
                  ? 'Báo thức vào lúc $hour:$minute'
                  : 'Không đặt lịch nhắc nhở',
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color?.withAlpha(180),
              ),
            ),
            secondary: Icon(
              _hasReminder
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_outlined,
              color: _hasReminder ? const Color(0xFFF59E0B) : Colors.grey,
            ),
            value: _hasReminder,
            onChanged: (val) {
              setState(() {
                _hasReminder = val;
              });
            },
          ),
          if (_hasReminder) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.access_time_rounded),
              title: const Text('Thời gian nhắc nhở'),
              trailing: Chip(
                label: Text(
                  '$hour:$minute',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              onTap: _selectReminderTime,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconGrid(ThemeData theme, bool isDark) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: AppIcons.options.length,
        itemBuilder: (context, index) {
          final opt = AppIcons.options[index];
          final isSelected = opt.key == _selectedIconKey;
          final habitColor = Color(_selectedColorValue);

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedIconKey = opt.key;
                });
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 72,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? habitColor.withAlpha(isDark ? 40 : 25)
                      : (isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? habitColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      opt.iconData,
                      color: isSelected
                          ? habitColor
                          : theme.iconTheme.color?.withAlpha(180),
                      size: 26,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      opt.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? habitColor : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSelector() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: AppColors.options.length,
        itemBuilder: (context, index) {
          final opt = AppColors.options[index];
          final isSelected = opt.value == _selectedColorValue;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedColorValue = opt.value;
                });
              },
              customBorder: const CircleBorder(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: opt.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: opt.color.withAlpha(isSelected ? 140 : 60),
                      blurRadius: isSelected ? 8 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
