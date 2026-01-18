import 'package:flutter/material.dart';
import '../theme.dart';
import '../../models/task_model.dart';
import '../../models/schedule_model.dart';
import '../../controller/task_controller.dart';
import '../../controller/schedule_controller.dart';
import '../services/user_session.dart';
import 'widgets/stats_card.dart';
import 'widgets/task_card.dart';
import 'widgets/schedule_card.dart';
import 'login.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final int? userId;

  const DashboardScreen({
    super.key,
    this.userName = 'User',
    this.userId,
  });

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

  void _loadDashboardData() {
    if (mounted) {
      setState(() {
        _dashboardData = _fetchDashboardData();
      });
    }
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    try {
      final results = await Future.wait([
        _taskController.getTaskStatistics().catchError((e) => <String, int>{
          'total': 0,
          'selesai': 0,
          'berjalan': 0,
          'belumMulai': 0,
        }),
        _taskController.getUpcomingDeadlines(days: 7).catchError((e) => <Task>[]),
        _scheduleController.getSchedulesByDate(DateTime.now()).catchError((e) => <Schedule>[]),
      ]);
      return {
        'stats': results[0],
        'upcomingTasks': results[1],
        'todaySchedules': results[2],
      };
    } catch (e) {
      return {
        'stats': <String, int>{
          'total': 0,
          'selesai': 0,
          'berjalan': 0,
          'belumMulai': 0,
        },
        'upcomingTasks': <Task>[],
        'todaySchedules': <Schedule>[],
      };
    }
  }

  String _getFormaltedDate() {
    final now = DateTime.now();
    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Clear user session
              UserSession().logout();
              
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginRegisterScreen(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _loadDashboardData();
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Image.asset(
                              'assets/icon/Logo Schedule.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.calendar_today_rounded,
                                  color: AppColors.primary,
                                  size: 28,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Schedule-List',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Halo, ${widget.userName}! 👋',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang! 👋',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFormaltedDate(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.overdue.withOpacity(0.9),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading data',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
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
                        backgroundColor: const Color(0xFFE0F2F1),
                        textColor: AppColors.primary,
                        icon: Icons.check_circle,
                      ),
                      StatsCard(
                        label: 'Selesai',
                        count: stats['selesai'] ?? 0,
                        backgroundColor: const Color(0xFFD1FAE5),
                        textColor: AppColors.success,
                        icon: Icons.verified,
                      ),
                      StatsCard(
                        label: 'Berjalan',
                        count: stats['berjalan'] ?? 0,
                        backgroundColor: const Color(0xFFFEF3C7),
                        textColor: const Color(0xFFD97706),
                        icon: Icons.schedule,
                      ),
                      StatsCard(
                        label: 'Belum Mulai',
                        count: stats['belumMulai'] ?? 0,
                        backgroundColor: const Color(0xFFFEE2E2),
                        textColor: AppColors.overdue,
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
                  Text(
                    'Tugas Mendekati Deadline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  Icon(
                    Icons.warning_rounded,
                    color: AppColors.accent,
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
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Center(
                        child: Text(
                          'Tidak ada tugas yang mendekati deadline',
                          style: TextStyle(
                            color: AppColors.text.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
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
                  Text(
                    'Jadwal Hari Ini',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
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
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Center(
                        child: Text(
                          'Tidak ada jadwal untuk hari ini',
                          style: TextStyle(
                            color: AppColors.text.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: schedules
                      .map(
                        (schedule) => ScheduleCard(
                          schedule: schedule,
                          onEdit: () {},
                          onDelete: () {},
                        ),
                      )
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
