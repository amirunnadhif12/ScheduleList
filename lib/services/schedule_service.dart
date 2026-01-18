import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/schedule.dart';
import 'user_session.dart';

class ScheduleService {
  // Get all schedules
  Future<List<Schedule>> getAllSchedules() async {
    try {
      final userId = UserSession().userId;
      if (userId == null) {
        return []; // Return empty list if not logged in
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.schedulesEndpoint}?user_id=$userId'),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<Schedule> schedules = (data['data'] as List)
              .map((json) => Schedule.fromMap(json))
              .toList();
          return schedules;
        }
      }
      return []; // Return empty list instead of throwing
    } catch (e) {
      return []; // Return empty list on error
    }
  }

  // Get schedules by date
  Future<List<Schedule>> getSchedulesByDate(String date) async {
    try {
      final userId = UserSession().userId;
      if (userId == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.schedulesEndpoint}?user_id=$userId&date=$date'),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<Schedule> schedules = (data['data'] as List)
              .map((json) => Schedule.fromMap(json))
              .toList();
          return schedules;
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get single schedule
  Future<Schedule?> getSchedule(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.schedulesEndpoint}?id=$id'),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return Schedule.fromMap(data['data']);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create schedule
  Future<Schedule> createSchedule(Schedule schedule) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.schedulesEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(schedule.toMap()),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success']) {
          return Schedule.fromMap(data['data']);
        }
      }
      throw Exception('Failed to create schedule');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update schedule
  Future<bool> updateSchedule(Schedule schedule) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.schedulesEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(schedule.toMap()),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'];
      }
      return false;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete schedule
  Future<bool> deleteSchedule(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.schedulesEndpoint}?id=$id'),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'];
      }
      return false;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
