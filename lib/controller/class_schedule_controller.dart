import '../models/class_schedule_model.dart';
import '../services/database_helper.dart';
import '../services/user_session.dart';

class ClassScheduleController {
  final DatabaseHelper _db = DatabaseHelper();

  int get _userId => UserSession().userId ?? 0;

  // Ambil semua jadwal kuliah milik user
  Future<List<ClassSchedule>> getAllClassSchedules() async {
    try {
      final maps = await _db.getClassSchedulesByUserId(_userId);
      return maps.map((m) => ClassSchedule.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  // Ambil jadwal kuliah berdasarkan hari (1=Senin...7=Minggu)
  Future<List<ClassSchedule>> getClassSchedulesByDay(int dayOfWeek) async {
    try {
      final maps = await _db.getClassSchedulesByDay(_userId, dayOfWeek);
      return maps.map((m) => ClassSchedule.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  // Ambil jadwal kuliah hari ini (berdasarkan hari dalam minggu)
  Future<List<ClassSchedule>> getTodayClassSchedules() async {
    final today = DateTime.now().weekday; // 1=Mon...7=Sun
    return getClassSchedulesByDay(today);
  }

  // Tambah jadwal kuliah baru
  Future<bool> addClassSchedule({
    required String subject,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String lecturer = '',
    String room = '',
    String semester = '',
    String color = '#0F766E',
  }) async {
    try {
      final now = DateTime.now();
      final schedule = ClassSchedule(
        userId: _userId,
        subject: subject,
        lecturer: lecturer,
        room: room,
        semester: semester,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        color: color,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      final id = await _db.insertClassSchedule(schedule.toMap());
      return id > 0;
    } catch (e) {
      return false;
    }
  }

  // Update jadwal kuliah
  Future<bool> updateClassSchedule(ClassSchedule schedule) async {
    try {
      final updated = schedule.copyWith(updatedAt: DateTime.now());
      final rowsAffected = await _db.updateClassSchedule(updated.toMap());
      return rowsAffected > 0;
    } catch (e) {
      return false;
    }
  }

  // Toggle aktif/nonaktif
  Future<bool> toggleActive(ClassSchedule schedule) async {
    return updateClassSchedule(schedule.copyWith(isActive: !schedule.isActive));
  }

  // Hapus jadwal kuliah
  Future<bool> deleteClassSchedule(int id) async {
    try {
      final rowsAffected = await _db.deleteClassSchedule(id);
      return rowsAffected > 0;
    } catch (e) {
      return false;
    }
  }

  // Ambil jadwal kuliah dikelompokkan per hari (untuk tampilan mingguan)
  Future<Map<int, List<ClassSchedule>>> getScheduleGroupedByDay() async {
    final all = await getAllClassSchedules();
    final grouped = <int, List<ClassSchedule>>{};
    for (int day = 1; day <= 7; day++) {
      grouped[day] = all.where((s) => s.dayOfWeek == day).toList();
    }
    return grouped;
  }
}
