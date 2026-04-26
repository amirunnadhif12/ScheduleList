import 'package:flutter/material.dart';
import '../theme.dart';
import '../../models/schedule_model.dart';
import '../../models/class_schedule_model.dart';
import '../../controller/schedule_controller.dart';
import '../../controller/class_schedule_controller.dart';
import 'widgets/schedule_card.dart';
import 'widgets/add_schedule_dialog.dart';
import 'widgets/class_schedule_card.dart';
import 'widgets/add_class_schedule_dialog.dart';
import 'login.dart';
import '../services/user_session.dart';

class ScheduleScreen extends StatefulWidget {
  final String userName;

  const ScheduleScreen({super.key, this.userName = 'User'});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  final ScheduleController _scheduleController = ScheduleController();
  final ClassScheduleController _classController = ClassScheduleController();
  late TabController _tabController;
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentMonth = DateTime.now();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startingDayOfWeek = firstDay.weekday;

    final days = <DateTime>[];

    // Padding: tanggal dari bulan sebelumnya
    for (int i = startingDayOfWeek - 1; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }

    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    return days;
  }

  String _getMonthYear(DateTime date) {
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
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getDayName(int weekday) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[weekday - 1];
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
            onPressed: () async {
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk navigation button
  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  // Helper widget untuk quick action button
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isPrimary ? null : AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? Colors.white : AppColors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_currentMonth);

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Modern Minimal Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top row with logo and logout
                  Row(
                    children: [
                      // Logo
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Image.asset(
                              'assets/icon/logo_schedule.png',
                              fit: BoxFit.cover,
                              color: Colors.white,
                              colorBlendMode: BlendMode.srcIn,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.calendar_month_rounded,
                                  color: Colors.white,
                                  size: 24,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title and greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jadwal Harian',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              'Halo, ${widget.userName}!',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.text.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Logout button
                      Material(
                        color: AppColors.overdue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () => _showLogoutDialog(context),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.logout_rounded,
                              color: AppColors.overdue,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── TabBar ──────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.calendar_today_rounded, size: 18), text: 'Jadwal Harian'),
                Tab(icon: Icon(Icons.school_rounded, size: 18), text: 'Jadwal Kuliah'),
              ],
            ),
          ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // ── Tab 1: Jadwal Harian ──────────────────────────────────
              SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Calendar Card - Premium Design
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Month Navigation Header - Premium
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.85),
                              AppColors.primaryDark,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildNavButton(
                                  icon: Icons.arrow_back_ios_rounded,
                                  onTap: () {
                                    setState(() {
                                      _currentMonth = DateTime(
                                        _currentMonth.year,
                                        _currentMonth.month - 1,
                                      );
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        _getMonthYear(_currentMonth),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${_selectedDate.day} ${_getMonthYear(_selectedDate).split(' ')[0]}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withValues(alpha: 0.95),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildNavButton(
                                  icon: Icons.arrow_forward_ios_rounded,
                                  onTap: () {
                                    setState(() {
                                      _currentMonth = DateTime(
                                        _currentMonth.year,
                                        _currentMonth.month + 1,
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Day headers - Modern Style
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.06),
                              AppColors.primary.withValues(alpha: 0.02),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['M', 'S', 'S', 'R', 'K', 'J', 'S']
                              .asMap()
                              .entries
                              .map(
                                (entry) {
                                  final isWeekend = entry.key == 0 || entry.key == 6;
                                  return Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isWeekend 
                                          ? AppColors.overdue.withValues(alpha: 0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        entry.value,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isWeekend
                                              ? AppColors.overdue
                                              : AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                              .toList(),
                        ),
                      ),

                      // Calendar days grid - Premium
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: GridView.count(
                          crossAxisCount: 7,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          children: days.map((day) {
                            final isSelected = _selectedDate.day == day.day &&
                                _selectedDate.month == day.month &&
                                _selectedDate.year == day.year;
                            final isToday = day.day == DateTime.now().day &&
                                day.month == DateTime.now().month &&
                                day.year == DateTime.now().year;
                            final isCurrentMonth = day.month == _currentMonth.month;
                            final isWeekend = day.weekday == 7 || day.weekday == 6;

                            return GestureDetector(
                              onTap: () {
                                if (isCurrentMonth) {
                                  setState(() {
                                    _selectedDate = day;
                                  });
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.primaryDark,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : isToday
                                          ? AppColors.accent.withValues(alpha: 0.12)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                  border: isToday && !isSelected
                                      ? Border.all(
                                          color: AppColors.accent,
                                          width: 2.5,
                                        )
                                      : isCurrentMonth && !isSelected
                                          ? Border.all(
                                              color: Colors.grey.withValues(alpha: 0.1),
                                              width: 1,
                                            )
                                          : null,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.45),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                            spreadRadius: -2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          day.day.toString(),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: isSelected
                                                ? Colors.white
                                                : !isCurrentMonth
                                                    ? AppColors.text.withValues(alpha: 0.2)
                                                    : isWeekend
                                                        ? AppColors.overdue.withValues(alpha: 0.75)
                                                        : AppColors.text.withValues(alpha: 0.85),
                                            fontWeight: isSelected || isToday
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Today indicator dot
                                    if (isToday && !isSelected)
                                      Positioned(
                                        bottom: 6,
                                        child: Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: AppColors.accent,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.accent.withValues(alpha: 0.5),
                                                blurRadius: 4,
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    // Selected indicator
                                    if (isSelected)
                                      Positioned(
                                        bottom: 6,
                                        child: Container(
                                          width: 16,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Quick Actions Row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionButton(
                                icon: Icons.today_rounded,
                                label: 'Hari Ini',
                                onTap: () {
                                  setState(() {
                                    _currentMonth = DateTime.now();
                                    _selectedDate = DateTime.now();
                                  });
                                },
                                isPrimary: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildQuickActionButton(
                                icon: Icons.add_rounded,
                                label: 'Jadwal Baru',
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const AddScheduleDialog(),
                                  ).then((value) {
                                    if (value == true) {
                                      setState(() {});
                                    }
                                  });
                                },
                                isPrimary: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_note, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Jadwal ${_selectedDate.day} ${_getMonthYear(_selectedDate)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                FutureBuilder<List<Schedule>>(
                  future: _scheduleController.getSchedulesByDate(_selectedDate),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.card,
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.event_busy_outlined,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada jadwal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Belum ada jadwal pada tanggal ini',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.text.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final schedules = snapshot.data!;
                    return Column(
                      children: schedules
                          .map(
                            (schedule) => ScheduleCard(
                              schedule: schedule,
                              onEdit: () async {
                                final result = await showDialog(
                                  context: context,
                                  builder: (context) => AddScheduleDialog(
                                    schedule: schedule,
                                  ),
                                );
                                if (result == true) {
                                  setState(() {});
                                }
                              },
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Hapus Jadwal'),
                                    content: const Text(
                                      'Apakah Anda yakin ingin menghapus jadwal ini?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Batal'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text(
                                          'Hapus',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                
                                if (confirm == true && schedule.id != null) {
                                  final success = await _scheduleController.deleteSchedule(schedule.id!);
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Jadwal berhasil dihapus'),
                                      ),
                                    );
                                    setState(() {});
                                  }
                                }
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                ),

                // ── Jadwal Kuliah pada hari yang dipilih ──
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Jadwal Kuliah — ${_getDayName(_selectedDate.weekday)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder<List<ClassSchedule>>(
                  future: _classController.getClassSchedulesByDay(_selectedDate.weekday),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5)),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy_outlined, color: Colors.grey.shade400, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Tidak ada kuliah di hari ini',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }
                    final classSchedules = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: classSchedules.map((cs) {
                          Color cardColor;
                          try {
                            cardColor = Color(int.parse(cs.color.replaceFirst('#', '0xFF')));
                          } catch (_) {
                            cardColor = AppColors.primary;
                          }
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border(left: BorderSide(color: cardColor, width: 4)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              child: Row(
                                children: [
                                  // Time column
                                  Column(
                                    children: [
                                      Text(cs.startTime, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cardColor)),
                                      Container(
                                        width: 1.5, height: 14,
                                        margin: const EdgeInsets.symmetric(vertical: 3),
                                        color: cardColor.withValues(alpha: 0.3),
                                      ),
                                      Text(cs.endTime, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
                                    ],
                                  ),
                                  // Divider
                                  Container(
                                    width: 1, height: 44,
                                    margin: const EdgeInsets.symmetric(horizontal: 14),
                                    color: Colors.grey.shade200,
                                  ),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cs.subject,
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (cs.room.isNotEmpty) ...[
                                              Icon(Icons.location_on_rounded, size: 13, color: Colors.grey.shade500),
                                              const SizedBox(width: 3),
                                              Text(cs.room, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                              const SizedBox(width: 12),
                                            ],
                                            if (cs.lecturer.isNotEmpty) ...[
                                              Icon(Icons.person_rounded, size: 13, color: Colors.grey.shade500),
                                              const SizedBox(width: 3),
                                              Flexible(
                                                child: Text(cs.lecturer, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ), // end Tab 1 SingleChildScrollView

              // ── Tab 2: Jadwal Kuliah ──────────────────────────────────
              _buildClassScheduleTab(),
            ], // end TabBarView children
          ), // end TabBarView
        ), // end Expanded
        ], // end Column children
      ), // end Column
    ); // end Container
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 2 — Jadwal Kuliah Tetap
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildClassScheduleTab() {
    const dayNames = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

    return FutureBuilder<Map<int, List<ClassSchedule>>>(
      future: _classController.getScheduleGroupedByDay(),
      builder: (context, snapshot) {
        final grouped = snapshot.data ?? {};
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Stack(
          children: [
            // List konten
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  // Jika belum ada data sama sekali
                  if (grouped.values.every((list) => list.isEmpty))
                    Container(
                      margin: const EdgeInsets.only(top: 40),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.school_outlined, size: 48, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text('Belum Ada Jadwal Kuliah',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
                          const SizedBox(height: 8),
                          Text('Tap tombol + untuk menambahkan\njadwal kuliah mingguan kamu',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  else
                    // Tampilkan per hari
                    ...List.generate(7, (i) {
                      final day = i + 1;
                      final list = grouped[day] ?? [];
                      if (list.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header hari
                          Container(
                            margin: const EdgeInsets.only(bottom: 10, top: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(dayNames[day],
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('${list.length} matkul',
                                      style: const TextStyle(fontSize: 11, color: Colors.white)),
                                ),
                              ],
                            ),
                          ),

                          // Card per matkul
                          ...list.map((cs) => ClassScheduleCard(
                                schedule: cs,
                                onEdit: () async {
                                  final result = await showDialog(
                                    context: context,
                                    builder: (_) => AddClassScheduleDialog(schedule: cs),
                                  );
                                  if (result == true) setState(() {});
                                },
                                onDelete: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      title: const Text('Hapus Jadwal Kuliah'),
                                      content: Text('Hapus ${cs.subject}?'),
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
                                  if (confirm == true && cs.id != null) {
                                    await _classController.deleteClassSchedule(cs.id!);
                                    setState(() {});
                                  }
                                },
                                onToggle: () async {
                                  await _classController.toggleActive(cs);
                                  setState(() {});
                                },
                              )),
                          const SizedBox(height: 8),
                        ],
                      );
                    }),
                ],
              ),

            // FAB tambah jadwal kuliah
            Positioned(
              bottom: 20,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  final result = await showDialog(
                    context: context,
                    builder: (_) => const AddClassScheduleDialog(),
                  );
                  if (result == true) setState(() {});
                },
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text('Tambah Matkul',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }
}
