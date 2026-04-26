class ClassSchedule {
  final int? id;
  final int userId;
  final String subject;     // Nama mata kuliah
  final String lecturer;    // Nama dosen
  final String room;        // Ruangan
  final String semester;    // Semester
  final int dayOfWeek;      // 1=Senin, 2=Selasa, ..., 7=Minggu
  final String startTime;   // Format HH:mm
  final String endTime;     // Format HH:mm
  final String color;       // Hex color
  final bool isActive;      // Toggle aktif/nonaktif
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassSchedule({
    this.id,
    required this.userId,
    required this.subject,
    this.lecturer = '',
    this.room = '',
    this.semester = '',
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.color = '#0F766E',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'subject': subject,
      'lecturer': lecturer,
      'room': room,
      'semester': semester,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'color': color,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ClassSchedule.fromMap(Map<String, dynamic> map) {
    return ClassSchedule(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      subject: map['subject'] as String,
      lecturer: (map['lecturer'] ?? '') as String,
      room: (map['room'] ?? '') as String,
      semester: (map['semester'] ?? '') as String,
      dayOfWeek: map['day_of_week'] as int,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      color: (map['color'] ?? '#0F766E') as String,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  ClassSchedule copyWith({
    int? id,
    int? userId,
    String? subject,
    String? lecturer,
    String? room,
    String? semester,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? color,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassSchedule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subject: subject ?? this.subject,
      lecturer: lecturer ?? this.lecturer,
      room: room ?? this.room,
      semester: semester ?? this.semester,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Nama hari dalam Bahasa Indonesia
  String get dayName {
    const days = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[dayOfWeek];
  }

  @override
  String toString() {
    return 'ClassSchedule(id: $id, subject: $subject, day: $dayName, $startTime-$endTime)';
  }
}
