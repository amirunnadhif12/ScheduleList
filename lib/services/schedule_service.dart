import '../models/schedule.dart';
import 'database_helper.dart';
import 'user_session.dart';

class ScheduleService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get all schedules
  Future<List<Schedule>> getAllSchedules() async {
    try {
      final userId = UserSession().userId;
      if (userId == null) {
        return [];
      }

      final List<Map<String, dynamic>> maps = await _dbHelper.getSchedulesByUserId(userId);
      return maps.map((map) => Schedule.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get schedules by date
  Future<List<Schedule>> getSchedulesByDate(String date) async {
    try {
      final userId = UserSession().userId;
      if (userId == null) {
        return [];
      }

      final List<Map<String, dynamic>> maps = await _dbHelper.getSchedulesByDate(userId, date);
      return maps.map((map) => Schedule.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get single schedule
  Future<Schedule?> getSchedule(int id) async {
    try {
      final map = await _dbHelper.getScheduleById(id);
      if (map != null) {
        return Schedule.fromMap(map);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create schedule
  Future<Schedule> createSchedule(Schedule schedule) async {
    final userId = UserSession().userId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final scheduleData = schedule.toMap();
    scheduleData['user_id'] = userId;
    scheduleData.remove('id'); // Remove id for auto increment

    final id = await _dbHelper.insertSchedule(scheduleData);
    return schedule.copyWith(id: id.toString());
  }

  // Update schedule
  Future<bool> updateSchedule(Schedule schedule) async {
    try {
      final scheduleData = schedule.toMap();
      // Convert string id to int for database
      if (schedule.id != null) {
        scheduleData['id'] = int.tryParse(schedule.id!) ?? schedule.id;
      }
      final result = await _dbHelper.updateSchedule(scheduleData);
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  // Delete schedule
  Future<bool> deleteSchedule(String id) async {
    try {
      final intId = int.tryParse(id);
      if (intId == null) return false;
      
      final result = await _dbHelper.deleteSchedule(intId);
      return result > 0;
    } catch (e) {
      return false;
    }
  }
}
