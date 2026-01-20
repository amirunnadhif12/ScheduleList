# Controllers Documentation

## Struktur Controller

Aplikasi ini menggunakan dua layer controller untuk kompatibilitas dengan view yang berbeda:

### 1. **API Controllers** (`lib/controllers/`)
Controller utama yang berkomunikasi langsung dengan backend API melalui services.

- **`task_controller.dart`** - Mengelola Task dari API (`models/task.dart`)
  - Menggunakan `TaskService` untuk berkomunikasi dengan backend
  - Model: `Task` dengan field: `id`, `title`, `description`, `deadline`, `priority`, `isCompleted`
  
- **`schedule_controller.dart`** - Mengelola Schedule dari API (`models/schedule.dart`)
  - Menggunakan `ScheduleService` untuk berkomunikasi dengan backend
  - Model: `Schedule` dengan field: `id`, `title`, `description`, `date`, `time`, `location`

### 2. **View Controllers** (`lib/controller/`)
Wrapper controller untuk kompatibilitas dengan views yang menggunakan model lama.

- **`task_controller.dart`** - Wrapper untuk Task views (`models/task_model.dart`)
  - Converts antara `task_model.dart` (view) dan `task.dart` (API)
  - Menyediakan method tambahan seperti `getDaysUntilDeadline()` dan `getDeadlineText()`
  - Mendukung field tambahan: `subject`, `dueDate`, `status`

- **`schedule_controller.dart`** - Wrapper untuk Schedule views (`models/schedule_model.dart`)
  - Converts antara `schedule_model.dart` (view) dan `schedule.dart` (API)
  - Mendukung field tambahan: `startTime`, `endTime`, `activity`, `color`

## Method yang Tersedia

### TaskController (View Wrapper)

```dart
// CRUD Operations
Future<List<Task>> getAllTasks()
Future<List<Task>> getTasksByStatus(String status)
Future<bool> addTask({title, subject, description, dueDate, status})
Future<bool> updateTask(Task task)
Future<bool> deleteTask(int id)
Future<bool> updateTaskStatus(int id, String status)

// Statistics & Filtering
Future<Map<String, int>> getTaskStatistics()
Future<List<Task>> getUpcomingDeadlines({int days = 7})

// Helpers
int getDaysUntilDeadline(DateTime dueDate)
String getDeadlineText(DateTime dueDate)
```

### ScheduleController (View Wrapper)

```dart
// CRUD Operations
Future<List<Schedule>> getSchedulesByDate(DateTime date)
Future<List<Schedule>> getAllSchedules()
Future<bool> addSchedule({date, startTime, endTime, activity, location, description, color})
Future<bool> updateSchedule(Schedule schedule)
Future<bool> deleteSchedule(int id)

// Filtering
Future<List<Schedule>> getSchedulesForMonth(DateTime month)
```

## Penggunaan di Views

```dart
import '../../controller/task_controller.dart';
import '../../models/task_model.dart';

final TaskController _taskController = TaskController();

// Get all tasks
List<Task> tasks = await _taskController.getAllTasks();

// Add task
await _taskController.addTask(
  title: 'UAS PAM',
  subject: 'Mobile Programming',
  description: 'Create schedule app',
  dueDate: DateTime.now().add(Duration(days: 7)),
  status: 'Belum Mulai',
);
```

## Koneksi ke Backend

Controllers menggunakan services yang sudah dikonfigurasi di `lib/config/api_config.dart`:

- **Web/Desktop**: `http://localhost/schedulelist/backend/api`
- **Android Emulator**: `http://10.0.2.2/schedulelist/backend/api`
- **iOS Simulator**: `http://localhost/schedulelist/backend/api`

Pastikan backend XAMPP sudah running sebelum menggunakan aplikasi!
