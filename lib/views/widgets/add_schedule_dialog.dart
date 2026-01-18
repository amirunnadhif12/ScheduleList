import 'package:flutter/material.dart';
import '../../models/schedule_model.dart';
import '../../controller/schedule_controller.dart';
import '../../theme.dart';

class AddScheduleDialog extends StatefulWidget {
  final Schedule? schedule;

  const AddScheduleDialog({super.key, this.schedule});

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  late TextEditingController _activityController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _selectedColor = '#0F766E';

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Hijau', 'color': '#0F766E'},
    {'name': 'Biru', 'color': '#2563EB'},
    {'name': 'Merah', 'color': '#DC2626'},
    {'name': 'Kuning', 'color': '#F59E0B'},
    {'name': 'Ungu', 'color': '#7C3AED'},
  ];

  @override
  void initState() {
    super.initState();
    _activityController = TextEditingController(
      text: widget.schedule?.activity ?? '',
    );
    _locationController = TextEditingController(
      text: widget.schedule?.location ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.schedule?.description ?? '',
    );

    if (widget.schedule != null) {
      _selectedDate = widget.schedule!.date;
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
    _activityController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
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

  Future<void> _saveSchedule() async {
    if (_activityController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aktivitas harus diisi!')));
      return;
    }

    final controller = ScheduleController();

    if (widget.schedule != null) {
      final now = DateTime.now();
      final schedule = Schedule(
        id: widget.schedule!.id,
        date: _selectedDate,
        startTime: _formatTime(_startTime),
        endTime: _formatTime(_endTime),
        activity: _activityController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        color: _selectedColor,
        createdAt: widget.schedule!.createdAt,
        updatedAt: now,
      );
      await controller.updateSchedule(schedule);
    } else {
      await controller.addSchedule(
        date: _selectedDate,
        startTime: _formatTime(_startTime),
        endTime: _formatTime(_endTime),
        activity: _activityController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        color: _selectedColor,
      );
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.schedule != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Edit Jadwal' : 'Tambah Jadwal Baru',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isEditing
                            ? 'Ubah detail jadwal Anda'
                            : 'Masukkan detail jadwal baru Anda.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.text.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildLabel('Aktivitas *'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _activityController,
                hint: 'Masukkan nama aktivitas',
              ),
              const SizedBox(height: 16),

              _buildLabel('Tanggal'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: AppColors.text.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Waktu Mulai'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectTime(context, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 18,
                                  color: AppColors.text.withOpacity(0.5),
                                ),
                                const SizedBox(width: 8),
                                Text(_formatTime(_startTime)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Waktu Selesai'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectTime(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 18,
                                  color: AppColors.text.withOpacity(0.5),
                                ),
                                const SizedBox(width: 8),
                                Text(_formatTime(_endTime)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Lokasi'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _locationController,
                hint: 'Masukkan lokasi (opsional)',
              ),
              const SizedBox(height: 16),

              _buildLabel('Deskripsi'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hint: 'Masukkan deskripsi (opsional)',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              _buildLabel('Warna'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: _colors.map((colorData) {
                  final isSelected = _selectedColor == colorData['color'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = colorData['color'];
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(
                            colorData['color'].replaceFirst('#', '0xFF'),
                          ),
                        ),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Simpan Perubahan' : 'Tambah Jadwal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
