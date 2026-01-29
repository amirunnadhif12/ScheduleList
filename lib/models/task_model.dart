class Task {
  final String? id;  // Changed from int? to String? for Firebase document ID
  final String title;
  final String description;
  final String subject;
  final DateTime dueDate;
  final String status;
  final String priority;  // Added priority field
  final DateTime createdAt;
  final DateTime updatedAt;
  final int progress; // 0-100
  final String? imagePath;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    required this.status,
    this.priority = 'sedang',
    required this.createdAt,
    required this.updatedAt,
    this.progress = 0,
    this.imagePath,
  });

  // Convert to Map for MySQL/PHP backend (legacy)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'due_date': dueDate.toIso8601String(),
      'status': status,
      'priority': priority,
      'progress': progress,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'subject': subject,
      'deadline': dueDate.toIso8601String(),
      'status': status,
      'priority': priority,
      'progress': progress,
    };
  }

  // Create from MySQL/PHP backend response (legacy)
  factory Task.fromMap(Map<String, dynamic> map) {
    // Parse progress - bisa string atau int
    int progressValue = 0;
    if (map['progress'] != null) {
      if (map['progress'] is int) {
        progressValue = map['progress'];
      } else if (map['progress'] is String) {
        progressValue = int.tryParse(map['progress']) ?? 0;
      }
    }

    return Task(
      id: map['id']?.toString(),
      title: map['title'] as String,
      description: map['description'] as String,
      subject: map['subject'] as String,
      dueDate: DateTime.parse(map['due_date'] as String),
      status: map['status'] as String,
      priority: (map['priority'] ?? 'sedang') as String,
      progress: progressValue,
      imagePath: map['image_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Create from Firestore document
  factory Task.fromFirestore(Map<String, dynamic> map) {
    DateTime now = DateTime.now();
    
    // Parse progress
    int progressValue = 0;
    if (map['progress'] != null) {
      if (map['progress'] is int) {
        progressValue = map['progress'];
      } else if (map['progress'] is String) {
        progressValue = int.tryParse(map['progress']) ?? 0;
      }
    }

    // Parse created_at
    DateTime createdAt;
    if (map['created_at'] != null) {
      if (map['created_at'] is DateTime) {
        createdAt = map['created_at'];
      } else if (map['created_at'].toDate != null) {
        createdAt = map['created_at'].toDate();
      } else {
        createdAt = DateTime.parse(map['created_at'].toString());
      }
    } else {
      createdAt = now;
    }

    // Parse updated_at
    DateTime updatedAt;
    if (map['updated_at'] != null) {
      if (map['updated_at'] is DateTime) {
        updatedAt = map['updated_at'];
      } else if (map['updated_at'].toDate != null) {
        updatedAt = map['updated_at'].toDate();
      } else {
        updatedAt = DateTime.parse(map['updated_at'].toString());
      }
    } else {
      updatedAt = now;
    }

    // Parse deadline
    DateTime dueDate;
    if (map['deadline'] != null) {
      if (map['deadline'] is DateTime) {
        dueDate = map['deadline'];
      } else if (map['deadline'].toDate != null) {
        dueDate = map['deadline'].toDate();
      } else {
        dueDate = DateTime.parse(map['deadline'].toString());
      }
    } else {
      dueDate = now;
    }

    return Task(
      id: map['id'] as String?,
      title: map['title'] as String,
      description: (map['description'] ?? '') as String,
      subject: (map['subject'] ?? '') as String,
      dueDate: dueDate,
      status: (map['status'] ?? 'belum_mulai') as String,
      priority: (map['priority'] ?? 'sedang') as String,
      progress: progressValue,
      imagePath: map['image_path'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    DateTime? dueDate,
    String? status,
    String? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? progress,
    String? imagePath,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status, subject: $subject, dueDate: $dueDate)';
  }
}