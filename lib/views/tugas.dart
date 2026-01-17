import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../controller/task_controller.dart';
import 'widgets/task_card.dart';
import 'widgets/add_task_dialog.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskController _taskController = TaskController();
  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  final List<String> _filters = ['Semua', 'Belum Mulai', 'Berjalan', 'Selesai'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dastar Tugas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '6 tugas total',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  FloatingActionButton.extended(
                    onPressed: () {
                      _showAddTaskDialog(context);
                    },
                    label: const Text('Tambah'),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari tugas...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = _selectedFilter == filter;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (value) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: Colors.blue[600],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Tasks list
        Expanded(
          child: FutureBuilder<List<Task>>(
            future: _getFilteredTasks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final tasks = snapshot.data ?? [];

              if (tasks.isEmpty) {
                return Center(
                  child: Text(
                    'Tidak ada tugas',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return TaskCard(
                      task: task,
                      onEdit: () {
                        _showEditTaskDialog(context, task);
                      },
                      onDelete: () {
                        _deleteTask(task.id!);
                      },
                      onStatusChange: (status) {
                        _updateTaskStatus(task.id!, status);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<Task>> _getFilteredTasks() async {
    List<Task> tasks;

    if (_selectedFilter == 'Semua') {
      tasks = await _taskController.getAllTasks();
    } else {
      tasks = await _taskController.getTasksByStatus(_selectedFilter);
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      tasks = tasks
          .where(
            (task) =>
                task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                task.subject.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return tasks;
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

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTaskDialog(),
    ).then((result) {
      if (result == true) {
        setState(() {});
      }
    });
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(task: task),
    ).then((result) {
      if (result == true) {
        setState(() {});
      }
    });
  }
}
