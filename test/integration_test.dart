// ============================================================================
// INTEGRATION TEST - ScheduleList Application
// Menguji interaksi antar komponen (Model ↔ Controller konversi)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:schedulelist/models/task.dart';
import 'package:schedulelist/models/task_model.dart' as task_model;
import 'package:schedulelist/models/schedule.dart';
import 'package:schedulelist/models/schedule_model.dart' as schedule_model;
import 'package:schedulelist/models/class_schedule_model.dart';

void main() {
  // ══════════════════════════════════════════════════════════════════════════
  // SKENARIO 1: Integrasi Task Model API ↔ Task Model View
  // ══════════════════════════════════════════════════════════════════════════
  group('Integrasi Task API Model ↔ Task View Model', () {
    // Helper: simulasi konversi seperti di TaskController
    task_model.Task convertFromApi(Task apiTask) {
      DateTime dueDate;
      try {
        dueDate = DateTime.parse(apiTask.deadline);
      } catch (_) {
        dueDate = DateTime.now();
      }
      String status = 'Belum Mulai';
      if (apiTask.isCompleted || apiTask.status == 'selesai') {
        status = 'Selesai';
      } else if (apiTask.status == 'berjalan') {
        status = 'Berjalan';
      }
      return task_model.Task(
        id: apiTask.id, title: apiTask.title,
        description: apiTask.description, subject: apiTask.subject,
        dueDate: dueDate, status: status, imagePath: apiTask.imagePath,
        progress: apiTask.progress, createdAt: apiTask.createdAt,
        updatedAt: DateTime.now(),
      );
    }

    Task convertToApi(task_model.Task viewTask) {
      final dl = '${viewTask.dueDate.year.toString().padLeft(4, '0')}-'
          '${viewTask.dueDate.month.toString().padLeft(2, '0')}-'
          '${viewTask.dueDate.day.toString().padLeft(2, '0')} 23:59';
      String apiStatus = 'belum_mulai';
      int progress = 0;
      bool isCompleted = false;
      if (viewTask.status == 'Selesai') {
        apiStatus = 'selesai'; progress = 100; isCompleted = true;
      } else if (viewTask.status == 'Berjalan') {
        apiStatus = 'berjalan';
        progress = viewTask.progress > 0 ? viewTask.progress : 50;
      }
      return Task(
        id: viewTask.id, title: viewTask.title,
        description: viewTask.description, subject: viewTask.subject,
        deadline: dl, priority: 'Important P1', isCompleted: isCompleted,
        createdAt: viewTask.createdAt, imagePath: viewTask.imagePath,
        status: apiStatus, progress: progress,
      );
    }

    test('IT-01: Konversi Task API→View→API roundtrip (semua status)', () {
      final apiTasks = [
        Task(id: '1', title: 'T1', description: 'D', subject: 'S',
            deadline: '2026-05-01 23:59', priority: 'P1',
            status: 'belum_mulai', progress: 0),
        Task(id: '2', title: 'T2', description: 'D', subject: 'S',
            deadline: '2026-05-02 23:59', priority: 'P1',
            isCompleted: true, status: 'selesai', progress: 100),
        Task(id: '3', title: 'T3', description: 'D', subject: 'S',
            deadline: '2026-05-03 23:59', priority: 'P1',
            status: 'berjalan', progress: 75),
      ];

      final viewTasks = apiTasks.map(convertFromApi).toList();
      expect(viewTasks[0].status, 'Belum Mulai');
      expect(viewTasks[1].status, 'Selesai');
      expect(viewTasks[2].status, 'Berjalan');

      // Convert back
      final backToApi = viewTasks.map(convertToApi).toList();
      expect(backToApi[0].status, 'belum_mulai');
      expect(backToApi[1].status, 'selesai');
      expect(backToApi[2].status, 'berjalan');
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // SKENARIO 2: Integrasi Schedule Model API ↔ Schedule Model View
  // ══════════════════════════════════════════════════════════════════════════
  group('Integrasi Schedule API Model ↔ Schedule View Model', () {
    String calculateEndTime(String startTime) {
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
      return '01:00';
    }

    schedule_model.Schedule convertFromApi(Schedule apiSchedule) {
      DateTime date;
      try { date = DateTime.parse(apiSchedule.date); } catch (_) { date = DateTime.now(); }
      return schedule_model.Schedule(
        id: apiSchedule.id, date: date,
        startTime: apiSchedule.time,
        endTime: apiSchedule.endTime ?? calculateEndTime(apiSchedule.time),
        activity: apiSchedule.title, location: apiSchedule.location ?? '',
        description: apiSchedule.description,
        color: apiSchedule.color ?? '#0F766E',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );
    }

    Schedule convertToApi(schedule_model.Schedule viewSchedule) {
      final ds = '${viewSchedule.date.year.toString().padLeft(4, '0')}-'
          '${viewSchedule.date.month.toString().padLeft(2, '0')}-'
          '${viewSchedule.date.day.toString().padLeft(2, '0')}';
      return Schedule.withFullData(
        id: viewSchedule.id, title: viewSchedule.activity,
        description: viewSchedule.description, date: ds,
        time: viewSchedule.startTime, endTime: viewSchedule.endTime,
        location: viewSchedule.location.isEmpty ? null : viewSchedule.location,
        color: viewSchedule.color,
      );
    }

    test('IT-02: Konversi Schedule API→View→API mempertahankan data', () {
      final apiSchedule = Schedule(
        id: '1', title: 'Meeting', description: 'Project sync',
        date: '2026-05-15', time: '09:00', endTime: '10:00',
        location: 'Room A', color: '#2563eb',
      );

      final viewSchedule = convertFromApi(apiSchedule);
      expect(viewSchedule.activity, 'Meeting');
      expect(viewSchedule.startTime, '09:00');

      final backToApi = convertToApi(viewSchedule);
      expect(backToApi.title, 'Meeting');
      expect(backToApi.time, '09:00');
      expect(backToApi.date, '2026-05-15');
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // SKENARIO 3: Integrasi ClassSchedule ↔ Database Map
  // ══════════════════════════════════════════════════════════════════════════
  group('Integrasi ClassSchedule ↔ Database (toMap/fromMap)', () {
    test('IT-03: Simpan dan baca ClassSchedule (roundtrip)', () {
      final now = DateTime.now();
      final original = ClassSchedule(
        id: 1, userId: 10, subject: 'Pemrograman Mobile',
        lecturer: 'Dr. Ahmad', room: 'Lab-3', semester: 'Ganjil 2025',
        dayOfWeek: 1, startTime: '08:00', endTime: '10:00',
        color: '#FF5722', isActive: true,
        createdAt: now, updatedAt: now,
      );

      final map = original.toMap();
      final restored = ClassSchedule.fromMap(map);

      expect(restored.subject, original.subject);
      expect(restored.lecturer, original.lecturer);
      expect(restored.room, original.room);
      expect(restored.dayOfWeek, original.dayOfWeek);
      expect(restored.isActive, original.isActive);
      expect(restored.dayName, 'Senin');
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // SKENARIO 4: Integrasi Task Statistik & Filtering
  // ══════════════════════════════════════════════════════════════════════════
  group('Integrasi Task Statistik & Filtering', () {
    test('IT-04: Statistik dari campuran status tugas', () {
      final tasks = [
        Task(id: '1', title: 'T1', description: 'D', subject: 'S',
            deadline: '2026-05-01 23:59', priority: 'P1',
            status: 'belum_mulai', progress: 0),
        Task(id: '2', title: 'T2', description: 'D', subject: 'S',
            deadline: '2026-05-02 23:59', priority: 'P1',
            isCompleted: true, status: 'selesai', progress: 100),
        Task(id: '3', title: 'T3', description: 'D', subject: 'S',
            deadline: '2026-05-03 23:59', priority: 'P1',
            status: 'berjalan', progress: 50),
        Task(id: '4', title: 'T4', description: 'D', subject: 'S',
            deadline: '2026-05-04 23:59', priority: 'P1',
            isCompleted: true, status: 'selesai', progress: 100),
        Task(id: '5', title: 'T5', description: 'D', subject: 'S',
            deadline: '2024-01-01 23:59', priority: 'Critical P0',
            status: 'belum_mulai', progress: 0), // overdue
      ];

      final active = tasks.where((t) => !t.isCompleted).toList();
      final completed = tasks.where((t) => t.isCompleted).toList();
      final overdue = tasks.where((t) => t.isOverdue()).toList();

      expect(tasks.length, 5);
      expect(active.length, 3);
      expect(completed.length, 2);
      expect(overdue.length, 1);
      expect(overdue.first.title, 'T5');
    });

    test('IT-05: Update status task dan verifikasi konsistensi', () {
      final task = Task(
        id: '1', title: 'Task Update', description: 'D', subject: 'S',
        deadline: '2026-05-01 23:59', priority: 'Important P1',
        status: 'belum_mulai', progress: 0, isCompleted: false,
      );

      // Simulasi update ke berjalan
      final updated1 = task.copyWith(status: 'berjalan', progress: 50);
      expect(updated1.status, 'berjalan');
      expect(updated1.progress, 50);

      // Simulasi update ke selesai
      final updated2 = updated1.copyWith(
          status: 'selesai', progress: 100, isCompleted: true);
      expect(updated2.status, 'selesai');
      expect(updated2.progress, 100);
      expect(updated2.isCompleted, true);
      expect(updated2.title, 'Task Update'); // Data lain tetap
    });
  });
}
