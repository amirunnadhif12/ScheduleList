import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_model.dart' as task_model;
import '../services/task_service.dart';

// ============================================================================
// TaskControllerAPI - Controller untuk API (menggunakan models/task.dart)
// ============================================================================
class TaskControllerAPI extends ChangeNotifier {
  final TaskService _service = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String _filterStatus = 'all';

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get filterStatus => _filterStatus;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _service.getAllTasks();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTasksByStatus(bool isCompleted) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _service.getTasksByStatus(isCompleted);
    } catch (e) {
      debugPrint('Error loading tasks by status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTask(Task task) async {
    try {
      final newTask = await _service.createTask(task);
      _tasks.add(newTask);
      _sortTasks();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding task: $e');
      return false;
    }
  }

  Future<bool> updateTask(Task task) async {
    try {
      bool success = await _service.updateTask(task);
      if (success) {
        int index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = task;
          _sortTasks();
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      debugPrint('Error updating task: $e');
      return false;
    }
  }

  Future<bool> toggleTaskStatus(int id) async {
    try {
      bool success = await _service.toggleTaskStatus(id);
      if (success) {
        int index = _tasks.indexWhere((t) => t.id == id);
        if (index != -1) {
          Task task = _tasks[index];
          _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      debugPrint('Error toggling task status: $e');
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      bool success = await _service.deleteTask(id);
      if (success) {
        _tasks.removeWhere((task) => task.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error deleting task: $e');
      return false;
    }
  }

  Future<void> searchTasks(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (query.isEmpty) {
        await loadTasks();
      } else {
        _tasks = await _service.searchTasks(query);
      }
    } catch (e) {
      debugPrint('Error searching tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  List<Task> get filteredTasks {
    if (_filterStatus == 'active') {
      return _tasks.where((task) => !task.isCompleted).toList();
    } else if (_filterStatus == 'completed') {
      return _tasks.where((task) => task.isCompleted).toList();
    }
    return _tasks;
  }

  List<Task> getTasksByPriority(String priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  List<Task> get activeTasks {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  List<Task> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  List<Task> get nearDeadlineTasks {
    return _tasks.where((task) => !task.isCompleted && task.isNearDeadline()).toList();
  }

  List<Task> get overdueTasks {
    return _tasks.where((task) => task.isOverdue()).toList();
  }

  List<Task> get criticalTasks {
    return _tasks.where((task) => task.priority == 'Critical P0' && !task.isCompleted).toList();
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;
      
      try {
        DateTime deadlineA = DateTime.parse(a.deadline);
        DateTime deadlineB = DateTime.parse(b.deadline);
        return deadlineA.compareTo(deadlineB);
      } catch (e) {
        return 0;
      }
    });
  }

  Map<String, int> get statistics {
    return {
      'total': _tasks.length,
      'active': activeTasks.length,
      'completed': completedTasks.length,
      'overdue': overdueTasks.length,
      'nearDeadline': nearDeadlineTasks.length,
      'critical': criticalTasks.length,
    };
  }
}

// ============================================================================
// TaskController - Wrapper untuk Views (menggunakan models/task_model.dart)
// ============================================================================
class TaskController {
  final TaskControllerAPI _apiController = TaskControllerAPI();

  task_model.Task _convertFromApi(Task apiTask) {
    DateTime dueDate;
    try {
      dueDate = DateTime.parse(apiTask.deadline);
    } catch (_) {
      dueDate = DateTime.now();
    }

    String status = 'Belum Mulai';
    if (apiTask.isCompleted) {
      status = 'Selesai';
    }

    return task_model.Task(
      id: apiTask.id,
      title: apiTask.title,
      description: apiTask.description,
      subject: '',
      dueDate: dueDate,
      status: status,
      createdAt: apiTask.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Task _convertToApi(task_model.Task viewTask) {
    final deadlineString = '${viewTask.dueDate.year.toString().padLeft(4, '0')}-'
        '${viewTask.dueDate.month.toString().padLeft(2, '0')}-'
        '${viewTask.dueDate.day.toString().padLeft(2, '0')} 23:59';

    return Task(
      id: viewTask.id,
      title: viewTask.title,
      description: viewTask.description,
      deadline: deadlineString,
      priority: 'Important P1',
      isCompleted: viewTask.status == 'Selesai',
      createdAt: viewTask.createdAt,
    );
  }

  Future<List<task_model.Task>> getAllTasks() async {
    await _apiController.loadTasks();
    return _apiController.tasks.map((t) => _convertFromApi(t)).toList();
  }

  Future<List<task_model.Task>> getTasksByStatus(String status) async {
    await _apiController.loadTasks();
    
    if (status == 'Selesai') {
      return _apiController.completedTasks.map((t) => _convertFromApi(t)).toList();
    } else if (status == 'Belum Mulai' || status == 'Berjalan') {
      return _apiController.activeTasks.map((t) => _convertFromApi(t)).toList();
    }
    
    return _apiController.tasks.map((t) => _convertFromApi(t)).toList();
  }

  Future<bool> addTask({
    required String title,
    required String subject,
    required String description,
    required DateTime dueDate,
    required String status,
  }) async {
    final deadlineString = '${dueDate.year.toString().padLeft(4, '0')}-'
        '${dueDate.month.toString().padLeft(2, '0')}-'
        '${dueDate.day.toString().padLeft(2, '0')} 23:59';

    final newTask = Task(
      title: title,
      description: description,
      deadline: deadlineString,
      priority: 'Important P1',
      isCompleted: status == 'Selesai',
    );

    return await _apiController.addTask(newTask);
  }

  Future<bool> updateTask(task_model.Task task) async {
    final apiTask = _convertToApi(task);
    return await _apiController.updateTask(apiTask);
  }

  Future<bool> deleteTask(int id) async {
    return await _apiController.deleteTask(id);
  }

  Future<bool> updateTaskStatus(int id, String status) async {
    await _apiController.loadTasks();
    final task = _apiController.tasks.firstWhere((t) => t.id == id);
    
    final updatedTask = task.copyWith(
      isCompleted: status == 'Selesai',
    );
    
    return await _apiController.updateTask(updatedTask);
  }

  Future<Map<String, int>> getTaskStatistics() async {
    await _apiController.loadTasks();
    final stats = _apiController.statistics;
    
    return {
      'total': stats['total'] ?? 0,
      'belumMulai': stats['active'] ?? 0,
      'berjalan': 0,
      'selesai': stats['completed'] ?? 0,
    };
  }

  Future<List<task_model.Task>> getUpcomingDeadlines({int days = 7}) async {
    await _apiController.loadTasks();
    final nearDeadline = _apiController.nearDeadlineTasks;
    
    return nearDeadline.map((t) => _convertFromApi(t)).toList();
  }

  int getDaysUntilDeadline(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    return difference.inDays;
  }

  String getDeadlineText(DateTime dueDate) {
    final days = getDaysUntilDeadline(dueDate);
    
    if (days < 0) {
      return '${days.abs()} hari terlambat';
    } else if (days == 0) {
      return 'Hari ini';
    } else if (days == 1) {
      return 'Besok';
    } else {
      return '$days hari lagi';
    }
  }
}
