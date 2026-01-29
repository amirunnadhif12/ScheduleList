class Schedule {
  final String? id;  // Changed from int? to String? for Firebase document ID
  final DateTime date;
  final String startTime; 
  final String endTime;   
  final String activity;
  final String location;
  final String description;
  final String color; 
  final DateTime createdAt;
  final DateTime updatedAt;

  Schedule({
    this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.activity,
    required this.location,
    required this.description,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for MySQL/PHP backend (legacy)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'activity': activity,
      'location': location,
      'description': description,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'start_time': startTime,
      'end_time': endTime,
      'activity': activity,
      'location': location,
      'description': description,
      'color': color,
    };
  }

  // Create from MySQL/PHP backend response (legacy)
  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id']?.toString(),
      date: DateTime.parse(map['date'] as String),
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      activity: map['activity'] as String,
      location: map['location'] as String,
      description: map['description'] as String,
      color: map['color'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Create from Firestore document
  factory Schedule.fromFirestore(Map<String, dynamic> map) {
    DateTime now = DateTime.now();
    
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

    return Schedule(
      id: map['id'] as String?,
      date: DateTime.parse(map['date'] as String),
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      activity: map['activity'] as String,
      location: (map['location'] ?? '') as String,
      description: map['description'] as String,
      color: (map['color'] ?? '#2563eb') as String,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Schedule copyWith({
    String? id,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? activity,
    String? location,
    String? description,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      activity: activity ?? this.activity,
      location: location ?? this.location,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Schedule(id: $id, activity: $activity, date: $date, startTime: $startTime - $endTime)';
  }
}