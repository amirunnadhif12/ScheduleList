import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/task.dart';
import 'user_session.dart';

class TaskService {
  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    try {
      final userId = UserSession().userId;
      if (userId == null) {
        return []; // Return empty list if not logged in
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.tasksEndpoint}?user_id=$userId'),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<Task> tasks = (data['data'] as List)
              .map((json) => Task.fromMap(json))
              .toList();
          return tasks;
        }
      }
      return []; // Return empty list instead of throwing error
    } catch (e) {
      return []; // Return empty list on error
    }
  }

  // Get tasks by status
  Future<List<Task>> getTasksByStatus(bool isCompleted) async {
    try {
      String status = isCompleted ? 'completed' : 'active';
      final response = await http.get(
        Uri.parse('${ApiConfig.tasksEndpoint}?status=$status'),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<Task> tasks = (data['data'] as List)
              .map((json) => Task.fromMap(json))
              .toList();
          return tasks;
        }
      }
      throw Exception('Failed to load tasks');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get tasks by priority
  Future<List<Task>> getTasksByPriority(String priority) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.tasksEndpoint}?priority=$priority'),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<Task> tasks = (data['data'] as List)
              .map((json) => Task.fromMap(json))
              .toList();
          return tasks;
        }
      }
      throw Exception('Failed to load tasks');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Search tasks
  Future<List<Task>> searchTasks(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.tasksEndpoint}?search=$query'),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<Task> tasks = (data['data'] as List)
              .map((json) => Task.fromMap(json))
              .toList();
          return tasks;
        }
      }
      throw Exception('Failed to search tasks');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get single task
  Future<Task?> getTask(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.tasksEndpoint}?id=$id'),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return Task.fromMap(data['data']);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create task
  Future<Task> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.tasksEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toMap()),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success']) {
          return Task.fromMap(data['data']);
        }
      }
      throw Exception('Failed to create task');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update task
  Future<bool> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.tasksEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toMap()),
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

  // Toggle task status
  Future<bool> toggleTaskStatus(int id) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.tasksEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id, 'toggle_status': true}),
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

  // Delete task
  Future<bool> deleteTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.tasksEndpoint}?id=$id'),
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
