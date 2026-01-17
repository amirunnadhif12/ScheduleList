import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../models/schedule_model.dart';
import '../../controller/task_controller.dart';
import '../../controller/schedule_controller.dart';
import 'widgets/stats_card.dart';
import 'widgets/task_card.dart';
import 'widgets/schedule_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TaskController _taskController = TaskController();
  final ScheduleController _scheduleController = ScheduleController();

  late Future<Map<String, dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loaddashboardData() {
    if (mounted) {
      setState(() {
        _dashboardData = Future.wait([
          _taskController.getTaskStatistics(),
          _taskController.getUpcomingDeadlines(days: 7),
          _scheduleController.getSchedulesByDate(DateTime.now()),
        ]).then((results) => {
          'stats': results[0],
          'upcomingTasks': results[1],
          'todaySchedules': results[2],
        });
      });
    }
  }

  String _getFormaltedDate() {
    final now = DateTime.now();
    final days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _loadDashboardData();
        });
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue[600]!,
                    Colors.blue[800]!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue[600]!.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Schedule-List',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola jadwal & tugas Anda dengan elegan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[100],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat Datang! 👋',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFormaltedDate(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            FutureBuilder(
              future: _dashboardData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                          const SizedBox(height: 8),
                          const Text('Error loading data'),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _loadDashboardData();
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final data = snapshot.data as Map<String, dynamic>;
                final stats = data['stats'] as Map<String, int>;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StatsCard(
                        label: 'Total Tugas',
                        count: stats['total'] ?? 0,
                        backgroundColor: Colors.blue[50]!,
                        textColor: Colors.blue[600]!,
                        icon: Icons.check_circle,
                      ),
                      StatsCard(
                        label: 'Selesai',
                        count: stats['selesai'] ?? 0,
                        backgroundColor: Colors.green[50]!,
                        textColor: Colors.green[600]!,
                        icon: Icons.verified,
                      ),
                      StatsCard(
                        label: 'Berjalan',
                        count: stats['berjalan'] ?? 0,
                        backgroundColor: Colors.amber[50]!,
                        textColor: Colors.amber[700]!,
                        icon: Icons.schedule,
                      ),
                      StatsCard(
                        label: 'Belum Mulai',
                        count: stats['belumMulai'] ?? 0,
                        backgroundColor: Colors.red[50]!,
                        textColor: Colors.red[600]!,
                        icon: Icons.warning,
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tugas Mendekati Deadline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.warning_rounded,
                    color: Colors.orange[600],
                    size: 20,
                  ),
                ],
              ),
            ),

            FutureBuilder(
              future: _dashboardData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final data = snapshot.data as Map<String, dynamic>;
                final upcomingTasks = data['upcomingTasks'] as List<Task>;

                if (upcomingTasks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Tidak ada tugas yang mendekati deadline',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return Column(
                  children: upcomingTasks.map((task) {
                    return TaskCard(
                      task: task,
                      onEdit: () {},
                      onDelete: () {},
                      onStatusChange: (status) {},
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jadwal Hari Ini',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ],
              ),
            ),

            FutureBuilder(
              future: _dashboardData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final data = snapshot.data as Map<String, dynamic>;
                final schedules = data['todaySchedules'] as List<Schedule>;

                if (schedules.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Tidak ada jadwal untuk hari ini',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return Column(
                  children: schedules
                      .map((schedule) => ScheduleCard(
                            schedule: schedule,
                            onEdit: () {},
                            onDelete: () {},
                          ))
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}