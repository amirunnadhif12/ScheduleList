import 'package:flutter/material.dart';
import '../../models/class_schedule_model.dart';
import '../../theme.dart';

class ClassScheduleCard extends StatelessWidget {
  final ClassSchedule schedule;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggle;

  const ClassScheduleCard({
    super.key,
    required this.schedule,
    this.onEdit,
    this.onDelete,
    this.onToggle,
  });

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _parseColor(schedule.color);
    final isInactive = !schedule.isActive;

    return Opacity(
      opacity: isInactive ? 0.55 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: cardColor, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris pertama: nama matkul + menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon warna
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.menu_book_rounded, color: cardColor, size: 22),
                  ),
                  const SizedBox(width: 12),

                  // Judul + badge hari
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.subject,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isInactive ? Colors.grey : AppColors.text,
                            decoration: isInactive ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Badge hari
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: cardColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            schedule.dayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: cardColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Popup menu (only show if callbacks provided)
                  if (onEdit != null || onDelete != null || onToggle != null)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              schedule.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                              size: 18,
                              color: schedule.isActive ? AppColors.accent : AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            Text(schedule.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            const Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, size: 18, color: AppColors.overdue),
                            const SizedBox(width: 8),
                            const Text('Hapus'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                      if (value == 'toggle') onToggle?.call();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 10),

              // Baris info: jam, dosen, ruangan
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  // Jam
                  _buildInfoChip(
                    icon: Icons.access_time_rounded,
                    label: '${schedule.startTime} – ${schedule.endTime}',
                    color: cardColor,
                  ),
                  // Ruangan (jika ada)
                  if (schedule.room.isNotEmpty)
                    _buildInfoChip(
                      icon: Icons.location_on_rounded,
                      label: schedule.room,
                      color: AppColors.accent,
                    ),
                  // Semester (jika ada)
                  if (schedule.semester.isNotEmpty)
                    _buildInfoChip(
                      icon: Icons.school_rounded,
                      label: 'Sem ${schedule.semester}',
                      color: AppColors.success,
                    ),
                ],
              ),

              // Dosen (jika ada)
              if (schedule.lecturer.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        schedule.lecturer,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Badge nonaktif
              if (isInactive) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Nonaktif',
                    style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.text.withValues(alpha: 0.75), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
