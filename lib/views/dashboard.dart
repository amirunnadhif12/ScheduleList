import 'package:flutter/material.dart';
import '../theme.dart';
import '../main.dart';
import '../../models/task_model.dart';
import '../../models/schedule_model.dart';
import '../../models/class_schedule_model.dart';
import '../../controller/task_controller.dart';
import '../../controller/schedule_controller.dart';
import '../../controller/class_schedule_controller.dart';
import '../services/user_session.dart';
import '../services/notification_service.dart';
import 'widgets/stats_card.dart';
import 'widgets/task_card.dart';
import 'widgets/schedule_card.dart';
import 'widgets/class_schedule_card.dart';
import 'widgets/bottom_navigation.dart';
import 'widgets/add_schedule_dialog.dart';
import 'login.dart';
import 'jadwal.dart';
import 'tugas.dart';
import 'riwayat.dart';

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
  int _selectedIndex = 0;
  final TaskController _taskController = TaskController();
  final ScheduleController _scheduleController = ScheduleController();
  final ClassScheduleController _classController = ClassScheduleController();

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

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        _classController.getTodayClassSchedules().catchError((e) => <ClassSchedule>[]),
      ]);
      return {
        'stats': results[0],
        'upcomingTasks': results[1],
        'todaySchedules': results[2],
        'todayClassSchedules': results[3],
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
        'todayClassSchedules': <ClassSchedule>[],
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.overdue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppColors.overdue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Konfirmasi Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Batal',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // Clear user session (persistent)
              await UserSession().logout();
              
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginRegisterScreen(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Keluar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.overdue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeScreen(),
      ScheduleScreen(userName: widget.userName),
      TaskScreen(userName: widget.userName),
      HistoryScreen(userName: widget.userName),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, {required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi 🌅';
    if (hour < 15) return 'Selamat Siang ☀️';
    if (hour < 18) return 'Selamat Sore 🌤️';
    return 'Selamat Malam 🌙';
  }

  Widget _buildHomeScreen() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        setState(() {
          _loadDashboardData();
        });
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // ── Premium Header ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0D9488),
                    Color(0xFF0F766E),
                    Color(0xFF0B5E58),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar: Logo + Actions
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 26, height: 26,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: Image.asset(
                                        'assets/icon/logo_schedule.png',
                                        fit: BoxFit.cover,
                                        color: AppColors.primary,
                                        colorBlendMode: BlendMode.srcIn,
                                        errorBuilder: (c, e, s) => Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 18),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Schedule List', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          _buildHeaderIcon(Icons.notifications_active_rounded, onTap: () async {
                            await NotificationService().testNotification();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test notifikasi dikirim!'), backgroundColor: Colors.green));
                            }
                          }),
                          const SizedBox(width: 8),
                          _buildHeaderIcon(
                            ThemeNotifierProvider.of(context).isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            onTap: () => ThemeNotifierProvider.of(context).toggleTheme(),
                          ),
                          const SizedBox(width: 8),
                          _buildHeaderIcon(Icons.logout_rounded, onTap: () => _showLogoutDialog(context)),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Greeting
                      Text(_getGreeting(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.8), letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(widget.userName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5, height: 1.2)),
                      const SizedBox(height: 18),
                      // Date Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Hari Ini', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 0.5)),
                                  const SizedBox(height: 2),
                                  Text(_getFormaltedDate(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                                ],
                              ),
                            ),
                            Material(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () {
                                  showDialog(context: context, builder: (context) => const AddScheduleDialog()).then((value) {
                                    if (value == true) _loadDashboardData();
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.add_rounded, size: 20, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Area with curved top
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    children: [
                      // Section Title - Statistik
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bar_chart_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Statistik Tugas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

            FutureBuilder(
              future: _dashboardData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat data...',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.overdue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.overdue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.overdue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 40,
                              color: AppColors.overdue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Gagal Memuat Data',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Terjadi kesalahan saat memuat data',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _loadDashboardData();
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final data = snapshot.data as Map<String, dynamic>;
                final stats = data['stats'] as Map<String, int>;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.7,
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

            // Section Title - Tugas Mendekati Deadline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deadline Terdekat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          '7 hari ke depan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.success,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Semua Aman! 🎉',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tidak ada deadline dalam 7 hari ke depan',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

            // Section Title - Jadwal Hari Ini
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jadwal Hari Ini',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          _getFormaltedDate(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            FutureBuilder(
              future: _dashboardData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                if (!snapshot.hasData) return const SizedBox.shrink();

                final data = snapshot.data as Map<String, dynamic>;
                final schedules = data['todaySchedules'] as List<Schedule>;
                final classSchedules = data['todayClassSchedules'] as List<ClassSchedule>;
                final hasAnything = schedules.isNotEmpty || classSchedules.isNotEmpty;

                if (!hasAnything) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.event_available_rounded, color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hari Bebas! ☀️',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text)),
                                const SizedBox(height: 4),
                                Text('Tidak ada jadwal untuk hari ini',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Jadwal harian biasa
                    ...schedules.map((schedule) => ScheduleCard(
                          schedule: schedule,
                          onEdit: () async {
                            final result = await showDialog(
                              context: context,
                              builder: (context) => AddScheduleDialog(schedule: schedule),
                            );
                            if (result == true) _loadDashboardData();
                          },
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Jadwal'),
                                content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && schedule.id != null) {
                              final success = await _scheduleController.deleteSchedule(schedule.id!);
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Jadwal berhasil dihapus')),
                                );
                                _loadDashboardData();
                              }
                            }
                          },
                        )),

                    // Jadwal kuliah hari ini
                    if (classSchedules.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Row(
                          children: [
                            Icon(Icons.school_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text('Kuliah Hari Ini',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary)),
                          ],
                        ),
                      ),
                      ...classSchedules.map((cs) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ClassScheduleCard(
                              schedule: cs,
                              onEdit: () {},
                              onDelete: () {},
                              onToggle: () {},
                            ),
                          )),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 24),
                    ],
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
