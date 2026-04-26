import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../controller/task_controller.dart';
import '../../theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(String) onStatusChange;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChange,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return AppColors.success.withValues(alpha: 0.12);
      case 'Berjalan':
        return AppColors.accent.withValues(alpha: 0.12);
      case 'Belum Mulai':
        return AppColors.overdue.withValues(alpha: 0.12);
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'Selesai':
        return AppColors.success;
      case 'Berjalan':
        return AppColors.accent;
      case 'Belum Mulai':
        return AppColors.overdue;
      default:
        return Colors.grey[300]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Selesai':
        return AppColors.success;
      case 'Berjalan':
        return const Color(0xFFD97706); // Darker amber
      case 'Belum Mulai':
        return AppColors.overdue;
      default:
        return Colors.grey[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskController = TaskController();
    final daysLeft = taskController.getDaysUntilDeadline(task.dueDate);
    final deadlineText = taskController.getDeadlineText(task.dueDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          left: BorderSide(
            color: _getStatusBorderColor(task.status),
            width: 4,
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.subject,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(task.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusTextColor(task.status),
                  ),
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: AppColors.overdue),
                        const SizedBox(width: 8),
                        const Text('Hapus'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'run',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, size: 18, color: AppColors.accent),
                        const SizedBox(width: 8),
                        const Text('Tandai Berjalan'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'done',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 18, color: AppColors.success),
                        const SizedBox(width: 8),
                        const Text('Tandai Selesai'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  } else if (value == 'run') {
                    onStatusChange('Berjalan');
                  } else if (value == 'done') {
                    onStatusChange('Selesai');
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            task.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Progress bar untuk tugas berjalan
          if (task.status == 'Berjalan')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      '${task.progress}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: task.progress / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      task.progress >= 75
                          ? AppColors.success
                          : task.progress >= 50
                              ? AppColors.accent
                              : AppColors.overdue,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          // Foto bukti penyelesaian tugas
          if (task.status == 'Selesai' && task.imagePath != null && task.imagePath!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.photo_camera,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Bukti Penyelesaian',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showFullImage(context, task.imagePath!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildTaskImage(task.imagePath!),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: daysLeft < 0 
                      ? AppColors.overdue.withValues(alpha: 0.1)
                      : AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  deadlineText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: daysLeft < 0 ? AppColors.overdue : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build image widget (support local file and network URL)
  Widget _buildTaskImage(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Network image
      return Image.network(
        imagePath,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 120,
            width: double.infinity,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 120,
            width: double.infinity,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.grey[400], size: 32),
                const SizedBox(height: 4),
                Text(
                  'Gagal memuat gambar',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Local file
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey[400], size: 32),
                  const SizedBox(height: 4),
                  Text(
                    'Gagal memuat gambar',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        return Container(
          height: 120,
          width: double.infinity,
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, color: Colors.grey[400], size: 32),
              const SizedBox(height: 4),
              Text(
                'File tidak ditemukan',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }
    }
  }

  // Show full image in dialog
  void _showFullImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: imagePath.startsWith('http://') || imagePath.startsWith('https://')
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 200,
                            height: 200,
                            color: Colors.white,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            color: Colors.white,
                            child: const Icon(Icons.broken_image, size: 64),
                          );
                        },
                      )
                    : Image.file(
                        File(imagePath),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            color: Colors.white,
                            child: const Icon(Icons.broken_image, size: 64),
                          );
                        },
                      ),
              ),
            ),
            // Close button
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}