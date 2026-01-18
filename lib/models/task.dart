class Task {
  final int? id;
  final String title;
  final String description;
  final String subject; // Subject/Mata Kuliah
  final String deadline; // Format: YYYY-MM-DD HH:mm:ss
  final String priority; // Critical P0, Important P1, Nice to have P2
  final bool isCompleted;
  final String? imagePath; // Path untuk foto tugas (P1)
  final DateTime createdAt;
  final String? status; // Status dari backend: belum_mulai, berjalan, selesai
  final int progress; // Progress 0-100

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.deadline,
    required this.priority,
    this.isCompleted = false,
    this.imagePath,
    DateTime? createdAt,
    this.status,
    this.progress = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Task object to Map untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject, // Backend uses 'subject' field
      'deadline': deadline,
      'priority': priority,
      'status': status ?? (isCompleted ? 'selesai' : 'belum_mulai'), // Backend uses status enum
      'progress': progress,
      'image_path': imagePath,
    };
  }

  // Convert Map dari database to Task object
  factory Task.fromMap(Map<String, dynamic> map) {
    // Support both field name variations
    String statusValue = '';
    bool completed = false;
    
    if (map.containsKey('status')) {
      // Status dari backend: 'belum_mulai', 'berjalan', 'selesai'
      statusValue = map['status'] ?? 'belum_mulai';
      completed = statusValue == 'selesai';
    } else if (map.containsKey('isCompleted')) {
      completed = map['isCompleted'] == 1;
      statusValue = completed ? 'selesai' : 'belum_mulai';
    }

    // Parse progress - bisa string atau int dari backend
    int progressValue = 0;
    if (map['progress'] != null) {
      if (map['progress'] is int) {
        progressValue = map['progress'];
      } else if (map['progress'] is String) {
        progressValue = int.tryParse(map['progress']) ?? 0;
      }
    } else {
      progressValue = completed ? 100 : 0;
    }

    // Parse id - bisa string atau int dari backend
    int? idValue;
    if (map['id'] != null) {
      if (map['id'] is int) {
        idValue = map['id'];
      } else if (map['id'] is String) {
        idValue = int.tryParse(map['id']);
      }
    }

    return Task(
      id: idValue,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      deadline: map['deadline'] ?? '',
      priority: map['priority'] ?? 'sedang',
      isCompleted: completed,
      imagePath: map['imagePath'] ?? map['image_path'],
      status: statusValue,
      progress: progressValue,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : (map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now()),
    );
  }

  // Copy with method untuk update data
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? subject,
    String? deadline,
    String? priority,
    bool? isCompleted,
    String? imagePath,
    DateTime? createdAt,
    String? status,
    int? progress,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }

  // Helper method untuk cek apakah tugas mendekati deadline (P1)
  bool isNearDeadline() {
    try {
      DateTime deadlineDate = DateTime.parse(deadline);
      DateTime now = DateTime.now();
      Duration difference = deadlineDate.difference(now);
      
      // Dianggap mendekati deadline jika kurang dari 2 hari
      return difference.inHours <= 48 && difference.inHours > 0;
    } catch (e) {
      return false;
    }
  }

  // Helper method untuk cek apakah tugas sudah lewat deadline
  bool isOverdue() {
    try {
      DateTime deadlineDate = DateTime.parse(deadline);
      DateTime now = DateTime.now();
      return now.isAfter(deadlineDate) && !isCompleted;
    } catch (e) {
      return false;
    }
  }
}
