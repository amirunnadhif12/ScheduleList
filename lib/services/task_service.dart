import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/task.dart';
import 'database_helper.dart';
import 'user_session.dart';

class TaskService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    try {
      final userId = UserSession().userId;
      if (userId == null) {
        return [];
      }

      final List<Map<String, dynamic>> maps = await _dbHelper.getTasksByUserId(userId);
      return maps.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get tasks by status (bool)
  Future<List<Task>> getTasksByStatus(bool isCompleted) async {
    try {
      final userId = UserSession().userId;
      if (userId == null) {
        return [];
      }

      String status = isCompleted ? 'selesai' : 'belum_mulai';
      final List<Map<String, dynamic>> maps = await _dbHelper.getTasksByStatus(userId, status);
      return maps.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get tasks by status string
  Future<List<Task>> getTasksByStatusString(String status) async {
    try {
      final userId = UserSession().userId;
      if (userId == null) {
        return [];
      }

      final List<Map<String, dynamic>> maps = await _dbHelper.getTasksByStatus(userId, status);
      return maps.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get single task
  Future<Task?> getTask(int id) async {
    try {
      final map = await _dbHelper.getTaskById(id);
      if (map != null) {
        return Task.fromMap(map);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create task
  Future<Task> createTask(Task task) async {
    final userId = UserSession().userId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final taskData = task.toMap();
    taskData['user_id'] = userId;
    taskData.remove('id'); // Remove id for auto increment

    final id = await _dbHelper.insertTask(taskData);
    return task.copyWith(id: id.toString());
  }

  // Update task
  Future<bool> updateTask(Task task) async {
    try {
      final taskData = task.toMap();
      // Convert string id to int for database
      if (task.id != null) {
        taskData['id'] = int.tryParse(task.id!) ?? task.id;
      }
      final result = await _dbHelper.updateTask(taskData);
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  // Toggle task status
  Future<bool> toggleTaskStatus(String id) async {
    try {
      final intId = int.tryParse(id);
      if (intId == null) return false;

      final task = await _dbHelper.getTaskById(intId);
      if (task == null) return false;

      String newStatus;
      if (task['status'] == 'selesai') {
        newStatus = 'belum_mulai';
      } else {
        newStatus = 'selesai';
      }

      final result = await _dbHelper.updateTask({
        'id': intId,
        'status': newStatus,
        'progress': newStatus == 'selesai' ? 100 : 0,
      });
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String id) async {
    try {
      final intId = int.tryParse(id);
      if (intId == null) return false;

      // Hapus gambar jika ada
      final task = await _dbHelper.getTaskById(intId);
      if (task != null && task['image_path'] != null) {
        final file = File(task['image_path']);
        if (await file.exists()) {
          await file.delete();
        }
      }

      final result = await _dbHelper.deleteTask(intId);
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  // Search tasks
  Future<List<Task>> searchTasks(String query) async {
    try {
      final userId = UserSession().userId;
      if (userId == null) {
        return [];
      }

      final List<Map<String, dynamic>> maps = await _dbHelper.searchTasks(userId, query);
      return maps.map((map) => Task.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  // Upload/Save task image locally
  Future<String?> uploadTaskImage(String filePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/task_images');
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = 'task_${DateTime.now().millisecondsSinceEpoch}${path.extension(filePath)}';
      final newPath = '${imagesDir.path}/$fileName';

      final sourceFile = File(filePath);
      await sourceFile.copy(newPath);

      return newPath;
    } catch (e) {
      return null;
    }
  }
}
