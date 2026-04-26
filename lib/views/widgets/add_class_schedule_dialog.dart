import 'package:flutter/material.dart';
import '../../models/class_schedule_model.dart';
import '../../controller/class_schedule_controller.dart';
import '../../theme.dart';

class AddClassScheduleDialog extends StatefulWidget {
  final ClassSchedule? schedule;

  const AddClassScheduleDialog({super.key, this.schedule});

  @override
  State<AddClassScheduleDialog> createState() => _AddClassScheduleDialogState();
}

class _AddClassScheduleDialogState extends State<AddClassScheduleDialog> {
  late TextEditingController _subjectController;
  late TextEditingController _lecturerController;
  late TextEditingController _roomController;
  late TextEditingController _semesterController;

  int _selectedDay = 1;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _selectedColor = '#0F766E';

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Teal', 'color': '#0F766E'},
    {'name': 'Biru', 'color': '#2563EB'},
    {'name': 'Ungu', 'color': '#7C3AED'},
    {'name': 'Merah', 'color': '#DC2626'},
    {'name': 'Oranye', 'color': '#EA580C'},
    {'name': 'Kuning', 'color': '#CA8A04'},
  ];

  static const List<String> _dayNames = [
    '', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.schedule?.subject ?? '');
    _lecturerController = TextEditingController(text: widget.schedule?.lecturer ?? '');
    _roomController = TextEditingController(text: widget.schedule?.room ?? '');
    _semesterController = TextEditingController(text: widget.schedule?.semester ?? '');

    if (widget.schedule != null) {
      _selectedDay = widget.schedule!.dayOfWeek;
      _startTime = _parseTime(widget.schedule!.startTime);
      _endTime = _parseTime(widget.schedule!.endTime);
      _selectedColor = widget.schedule!.color;
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _lecturerController.dispose();
    _roomController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama mata kuliah harus diisi!')),
      );
      return;
    }

    final controller = ClassScheduleController();
    bool success;

    if (widget.schedule != null) {
      final updated = widget.schedule!.copyWith(
        subject: _subjectController.text.trim(),
        lecturer: _lecturerController.text.trim(),
        room: _roomController.text.trim(),
        semester: _semesterController.text.trim(),
        dayOfWeek: _selectedDay,
        startTime: _formatTime(_startTime),
        endTime: _formatTime(_endTime),
        color: _selectedColor,
        updatedAt: DateTime.now(),
      );
      success = await controller.updateClassSchedule(updated);
    } else {
      success = await controller.addClassSchedule(
        subject: _subjectController.text.trim(),
        lecturer: _lecturerController.text.trim(),
        room: _roomController.text.trim(),
        semester: _semesterController.text.trim(),
        dayOfWeek: _selectedDay,
        startTime: _formatTime(_startTime),
        endTime: _formatTime(_endTime),
        color: _selectedColor,
      );
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.schedule != null
                ? 'Jadwal kuliah berhasil diperbarui!'
                : 'Jadwal kuliah berhasil ditambahkan!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan jadwal kuliah!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.schedule != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_rounded : Icons.school_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Jadwal Kuliah' : 'Tambah Jadwal Kuliah',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Jadwal mingguan berulang otomatis',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(10),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Mata Kuliah
                  _buildLabel('Nama Mata Kuliah', isRequired: true),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _subjectController,
                    hint: 'Contoh: Pemrograman Aplikasi Mobile',
                    icon: Icons.menu_book_rounded,
                  ),
                  const SizedBox(height: 16),

                  // Dosen
                  _buildLabel('Nama Dosen'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _lecturerController,
                    hint: 'Contoh: Dr. Budi Santoso (opsional)',
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(height: 16),

                  // Ruangan & Semester
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Ruangan'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _roomController,
                              hint: 'Contoh: G.301',
                              icon: Icons.location_on_rounded,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Semester'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _semesterController,
                              hint: 'Contoh: 5',
                              icon: Icons.school_outlined,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Hari
                  _buildLabel('Hari', isRequired: true),
                  const SizedBox(height: 8),
                  _buildDaySelector(),
                  const SizedBox(height: 16),

                  // Jam
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Jam Mulai'),
                            const SizedBox(height: 8),
                            _buildTimeButton(context, true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Jam Selesai'),
                            const SizedBox(height: 8),
                            _buildTimeButton(context, false),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Warna
                  _buildLabel('Warna Label'),
                  const SizedBox(height: 12),
                  _buildColorSelector(),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _save,
                          icon: Icon(
                            isEditing ? Icons.save_rounded : Icons.add_rounded,
                            size: 20,
                          ),
                          label: Text(
                            isEditing ? 'Simpan' : 'Tambah',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ───────────────────────────────────────────────────────────

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(fontSize: 13, color: AppColors.overdue, fontWeight: FontWeight.w600),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.text.withValues(alpha: 0.4), fontSize: 13),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(icon, size: 18, color: AppColors.primary.withValues(alpha: 0.7)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (i) {
        final day = i + 1;
        final isSelected = _selectedDay == day;
        final isWeekend = day == 6 || day == 7;
        return GestureDetector(
          onTap: () => setState(() => _selectedDay = day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected
                  ? null
                  : isWeekend
                      ? AppColors.overdue.withValues(alpha: 0.08)
                      : AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : isWeekend
                        ? AppColors.overdue.withValues(alpha: 0.3)
                        : Colors.grey.shade300,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              _dayNames[day],
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : isWeekend
                        ? AppColors.overdue
                        : AppColors.text,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimeButton(BuildContext context, bool isStart) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _selectTime(context, isStart),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, size: 18,
                  color: AppColors.primary.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Text(
                _formatTime(isStart ? _startTime : _endTime),
                style: TextStyle(fontSize: 14, color: AppColors.text),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _colors.map((colorData) {
          final isSelected = _selectedColor == colorData['color'];
          final color = Color(int.parse(
            (colorData['color'] as String).replaceFirst('#', '0xFF'),
          ));
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = colorData['color'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 40 : 32,
              height: isSelected ? 40 : 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}
