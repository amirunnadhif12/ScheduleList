import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../models/schedule_model.dart' as schedule_model;
import '../services/schedule_service.dart';

// ============================================================================
// ScheduleControllerAPI - Controller untuk API (menggunakan models/schedule.dart)
// ============================================================================
class ScheduleControllerAPI extends ChangeNotifier {
  final ScheduleService _service = ScheduleService();
  List<Schedule> _schedules = [];
  bool _isLoading = false;

  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;

  Future<void> loadSchedules() async {
    _isLoading = true;
    notifyListeners();

    try {
      _schedules = await _service.getAllSchedules();
    } catch (e) {
      debugPrint('Error loading schedules: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Schedule>> getSchedulesByDate(String date) async {
    try {
      return await _service.getSchedulesByDate(date);
    } catch (e) {
      debugPrint('Error loading schedules by date: $e');
      return [];
    }
  }

  Future<bool> addSchedule(Schedule schedule) async {
    try {
      final newSchedule = await _service.createSchedule(schedule);
      _schedules.add(newSchedule);
      _sortSchedules();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding schedule: $e');
      return false;
    }
  }

  Future<bool> updateSchedule(Schedule schedule) async {
    try {
      bool success = await _service.updateSchedule(schedule);
      if (success) {
        int index = _schedules.indexWhere((s) => s.id == schedule.id);
        if (index != -1) {
          _schedules[index] = schedule;
          _sortSchedules();
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      debugPrint('Error updating schedule: $e');
      return false;
    }
  }

  Future<bool> deleteSchedule(int id) async {
    try {
      bool success = await _service.deleteSchedule(id);
      if (success) {
        _schedules.removeWhere((schedule) => schedule.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error deleting schedule: $e');
      return false;
    }
  }

  List<Schedule> getTodaySchedules() {
    final today = DateTime.now();
    final todayString = '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    
    return _schedules.where((schedule) => schedule.date == todayString).toList();
  }

  void _sortSchedules() {
    _schedules.sort((a, b) {
      try {
        int dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        
        return a.time.compareTo(b.time);
      } catch (e) {
        return 0;
      }
    });
  }
}

// ============================================================================
// ScheduleController - Wrapper untuk Views (menggunakan models/schedule_model.dart)
// ============================================================================
class ScheduleController {
  final ScheduleControllerAPI _apiController = ScheduleControllerAPI();

  schedule_model.Schedule _convertFromApi(Schedule apiSchedule) {
    DateTime date;
    try {
      date = DateTime.parse(apiSchedule.date);
    } catch (_) {
      date = DateTime.now();
    }

    return schedule_model.Schedule(
      id: apiSchedule.id,
      date: date,
      startTime: apiSchedule.time,
      endTime: _calculateEndTime(apiSchedule.time),
      activity: apiSchedule.title,
      location: apiSchedule.location ?? '',
      description: apiSchedule.description,
      color: 'blue',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Schedule _convertToApi(schedule_model.Schedule viewSchedule) {
    final dateString = '${viewSchedule.date.year.toString().padLeft(4, '0')}-'
        '${viewSchedule.date.month.toString().padLeft(2, '0')}-'
        '${viewSchedule.date.day.toString().padLeft(2, '0')}';

    return Schedule(
      id: viewSchedule.id,
      title: viewSchedule.activity,
      description: viewSchedule.description,
      date: dateString,
      time: viewSchedule.startTime,
      location: viewSchedule.location.isEmpty ? null : viewSchedule.location,
    );
  }

  String _calculateEndTime(String startTime) {
    try {
      final parts = startTime.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        
        hour += 1;
        if (hour >= 24) hour = 23;
        
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {}
    return '${(int.tryParse(startTime.split(':')[0]) ?? 0) + 1}:00';
  }

  Future<List<schedule_model.Schedule>> getSchedulesByDate(DateTime date) async {
    await _apiController.loadSchedules();
    
    final dateString = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    
    final filtered = _apiController.schedules.where((schedule) {
      return schedule.date == dateString;
    }).toList();
    
    return filtered.map((s) => _convertFromApi(s)).toList();
  }

  Future<List<schedule_model.Schedule>> getAllSchedules() async {
    await _apiController.loadSchedules();
    return _apiController.schedules.map((s) => _convertFromApi(s)).toList();
  }

  Future<bool> addSchedule({
    required DateTime date,
    required String startTime,
    required String endTime,
    required String activity,
    required String location,
    required String description,
    required String color,
  }) async {
    final dateString = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final newSchedule = Schedule(
      title: activity,
      description: description,
      date: dateString,
      time: startTime,
      location: location.isEmpty ? null : location,
    );

    return await _apiController.addSchedule(newSchedule);
  }

  Future<bool> updateSchedule(schedule_model.Schedule schedule) async {
    final apiSchedule = _convertToApi(schedule);
    return await _apiController.updateSchedule(apiSchedule);
  }

  Future<bool> deleteSchedule(int id) async {
    return await _apiController.deleteSchedule(id);
  }

  Future<List<schedule_model.Schedule>> getSchedulesForMonth(DateTime month) async {
    await _apiController.loadSchedules();
    
    final schedules = _apiController.schedules.where((schedule) {
      try {
        final scheduleDate = DateTime.parse(schedule.date);
        return scheduleDate.year == month.year && 
               scheduleDate.month == month.month;
      } catch (_) {
        return false;
      }
    }).toList();
    
    return schedules.map((s) => _convertFromApi(s)).toList();
  }
}
