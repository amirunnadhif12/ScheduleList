// ============================================================================
// WHITE BOX UNIT TEST - ScheduleList Application
// Automated testing menggunakan flutter_test
// File: test/unit_test.dart
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:schedulelist/models/task.dart';
import 'package:schedulelist/models/task_model.dart' as task_model;
import 'package:schedulelist/models/schedule.dart';
import 'package:schedulelist/models/schedule_model.dart' as schedule_model;
import 'package:schedulelist/models/class_schedule_model.dart';

void main() {
  // ══════════════════════════════════════════════════════════════════════════
  // TEST GROUP 1: Task Model (models/task.dart)
  // ══════════════════════════════════════════════════════════════════════════
  group('Task Model (API) Tests', () {
    test('TC-01: Membuat Task dengan data lengkap', () {
      final task = Task(
        id: '1',
        title: 'Tugas Flutter',
        description: 'Buat aplikasi mobile',
        subject: 'Pemrograman Mobile',
        deadline: '2026-05-01 23:59',
        priority: 'Important P1',
        isCompleted: false,
        status: 'belum_mulai',
        progress: 0,
      );

      expect(task.id, '1');
      expect(task.title, 'Tugas Flutter');
      expect(task.subject, 'Pemrograman Mobile');
      expect(task.isCompleted, false);
      expect(task.progress, 0);
      expect(task.status, 'belum_mulai');
    });

    test('TC-02: Task.toMap() menghasilkan Map yang benar', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Deskripsi test',
        subject: 'Matematika',
        deadline: '2026-05-01 23:59',
        priority: 'Important P1',
        isCompleted: false,
        status: 'berjalan',
        progress: 50,
      );

      final map = task.toMap();

      expect(map['title'], 'Test Task');
      expect(map['subject'], 'Matematika');
      expect(map['deadline'], '2026-05-01 23:59');
      expect(map['status'], 'berjalan');
      expect(map['progress'], 50);
    });

    test('TC-03: Task.fromMap() parsing status selesai', () {
      final map = {
        'id': 2,
        'title': 'Selesai Task',
        'description': 'Desc',
        'subject': 'IPA',
        'deadline': '2026-05-01 23:59',
        'priority': 'sedang',
        'status': 'selesai',
        'progress': 100,
        'created_at': '2026-04-01T10:00:00.000',
      };

      final task = Task.fromMap(map);

      expect(task.isCompleted, true);
      expect(task.status, 'selesai');
      expect(task.progress, 100);
    });

    test('TC-04: Task.copyWith() update partial fields', () {
      final task = Task(
        id: '1',
        title: 'Original',
        description: 'Desc',
        subject: 'Math',
        deadline: '2026-05-01 23:59',
        priority: 'Important P1',
        isCompleted: false,
        status: 'belum_mulai',
        progress: 0,
      );

      final updated = task.copyWith(
        isCompleted: true,
        status: 'selesai',
        progress: 100,
      );

      expect(updated.title, 'Original'); // Tidak berubah
      expect(updated.isCompleted, true);
      expect(updated.status, 'selesai');
      expect(updated.progress, 100);
    });

    test('TC-05: Task.isNearDeadline() mendeteksi deadline dalam 7 hari', () {
      final nearDeadline = DateTime.now().add(const Duration(days: 3));
      final task = Task(
        title: 'Near Deadline',
        description: 'Desc',
        subject: 'Test',
        deadline: nearDeadline.toIso8601String(),
        priority: 'Important P1',
      );

      expect(task.isNearDeadline(), true);
    });

    test('TC-06: Task.isOverdue() mendeteksi tugas terlambat', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final task = Task(
        title: 'Overdue Task',
        description: 'Desc',
        subject: 'Test',
        deadline: pastDate.toIso8601String(),
        priority: 'Important P1',
        isCompleted: false,
      );

      expect(task.isOverdue(), true);
    });

    test('TC-07: Task.isNearDeadline() dengan deadline format invalid', () {
      final task = Task(
        title: 'Invalid Date',
        description: 'Desc',
        subject: 'Test',
        deadline: 'bukan-tanggal',
        priority: 'sedang',
      );

      // Harus return false, bukan crash
      expect(task.isNearDeadline(), false);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // TEST GROUP 2: Schedule Model (models/schedule.dart)
  // ══════════════════════════════════════════════════════════════════════════
  group('Schedule Model (API) Tests', () {
    test('TC-08: Membuat Schedule dan toMap()', () {
      final schedule = Schedule(
        id: '1',
        title: 'Meeting',
        description: 'Project meeting',
        date: '2026-05-01',
        time: '09:00',
        endTime: '10:00',
        location: 'Room A',
        color: '#2563eb',
      );

      expect(schedule.title, 'Meeting');

      final map = schedule.toMap();
      expect(map['activity'], 'Meeting');
      expect(map['start_time'], '09:00');
      expect(map['end_time'], '10:00');
    });

    test('TC-09: Schedule.toMap() auto-calculate endTime jika null', () {
      final schedule = Schedule(
        title: 'Quick',
        description: 'Desc',
        date: '2026-05-01',
        time: '14:30',
      );

      final map = schedule.toMap();
      expect(map['end_time'], '15:30'); // +1 jam
    });

    test('TC-10: Schedule.fromMap() parsing data benar', () {
      final map = {
        'id': 1,
        'activity': 'Test Activity',
        'description': 'Desc',
        'date': '2026-05-01',
        'start_time': '09:00',
        'end_time': '10:00',
        'location': 'Room B',
        'color': '#FF0000',
      };

      final schedule = Schedule.fromMap(map);

      expect(schedule.title, 'Test Activity');
      expect(schedule.time, '09:00');
      expect(schedule.endTime, '10:00');
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // TEST GROUP 3: ClassSchedule Model
  // ══════════════════════════════════════════════════════════════════════════
  group('ClassSchedule Model Tests', () {
    test('TC-11: Membuat ClassSchedule dan cek dayName', () {
      final now = DateTime.now();
      final cs = ClassSchedule(
        id: 1,
        userId: 1,
        subject: 'Pemrograman Mobile',
        lecturer: 'Dr. Ahmad',
        room: 'Lab 1',
        semester: 'Ganjil 2025/2026',
        dayOfWeek: 1,
        startTime: '08:00',
        endTime: '10:00',
        color: '#0F766E',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(cs.subject, 'Pemrograman Mobile');
      expect(cs.dayOfWeek, 1);
      expect(cs.dayName, 'Senin');
    });

    test('TC-12: ClassSchedule.toMap() output benar', () {
      final now = DateTime.now();
      final cs = ClassSchedule(
        id: 1,
        userId: 1,
        subject: 'Math',
        dayOfWeek: 3,
        startTime: '08:00',
        endTime: '10:00',
        createdAt: now,
        updatedAt: now,
      );

      final map = cs.toMap();
      expect(map['subject'], 'Math');
      expect(map['day_of_week'], 3);
      expect(map['is_active'], 1);
    });

    test('TC-13: ClassSchedule.fromMap() parsing benar', () {
      final now = DateTime.now();
      final map = {
        'id': 1,
        'user_id': 1,
        'subject': 'Fisika',
        'lecturer': 'Prof. Budi',
        'room': 'R-201',
        'semester': 'Ganjil',
        'day_of_week': 2,
        'start_time': '10:00',
        'end_time': '12:00',
        'color': '#FF0000',
        'is_active': 1,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final cs = ClassSchedule.fromMap(map);
      expect(cs.subject, 'Fisika');
      expect(cs.lecturer, 'Prof. Budi');
      expect(cs.dayOfWeek, 2);
      expect(cs.isActive, true);
    });

    test('TC-14: ClassSchedule.copyWith() update partial', () {
      final now = DateTime.now();
      final cs = ClassSchedule(
        id: 1,
        userId: 1,
        subject: 'Original',
        dayOfWeek: 1,
        startTime: '08:00',
        endTime: '10:00',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final updated = cs.copyWith(subject: 'Updated', isActive: false);
      expect(updated.subject, 'Updated');
      expect(updated.isActive, false);
      expect(updated.dayOfWeek, 1);
    });

    test('TC-15: ClassSchedule default values', () {
      final now = DateTime.now();
      final cs = ClassSchedule(
        userId: 1,
        subject: 'Test',
        dayOfWeek: 1,
        startTime: '08:00',
        endTime: '10:00',
        createdAt: now,
        updatedAt: now,
      );

      expect(cs.lecturer, '');
      expect(cs.room, '');
      expect(cs.semester, '');
      expect(cs.color, '#0F766E');
      expect(cs.isActive, true);
    });
  });
}
