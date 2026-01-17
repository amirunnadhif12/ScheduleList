import 'package:flutter/material.dart';
import '../theme.dart';
import '../../models/task_model.dart';
import '../../controller/task_controller.dart';
import 'widgets/task_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TaskController _taskController = TaskController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Riwayat Tugas Selesai',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
                  Text(
                    '1 tugas telah diselesaikan',
                    style: TextStyle(fontSize: 12, color: AppColors.text.withOpacity(0.65)),
                  ),
            ],
          ),
        ),

        Expanded(
          child: FutureBuilder<List<Task>>(
            future: _taskController.getTasksByStatus('Selesai'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final completedTasks = snapshot.data ?? [];

              if (completedTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: AppColors.primaryLight(0.6),
                          ),
                      const SizedBox(height: 16),
                          Text(
                            'Belum ada tugas yang diselesaikan',
                            style: TextStyle(fontSize: 16, color: AppColors.text.withOpacity(0.65)),
                          ),
                      const SizedBox(height: 8),
                      Text(
                        'Selesaikan tugas untuk melihatnya di sini',
                            style: TextStyle(fontSize: 12, color: AppColors.text.withOpacity(0.5)),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView(
                  children: [
                    if (completedTasks.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Riwayat Tugas Selesai',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${completedTasks.length} tugas telah diselesaikan',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    ...completedTasks.map((task) {
                      return TaskCard(
                        task: task,
                        onEdit: () {
                        },
                        onDelete: () {
                          _deleteTask(task.id!);
                        },
                        onStatusChange: (status) {
                          _updateTaskStatus(task.id!, status);
                        },
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _deleteTask(int taskId) async {
    await _taskController.deleteTask(taskId);
    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tugas dihapus')));
    }
  }

  Future<void> _updateTaskStatus(int taskId, String status) async {
    await _taskController.updateTaskStatus(taskId, status);
    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status diubah ke $status')));
    }
  }
}
