class Schedule {
  final int? id;
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

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as int?,
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

  Schedule copyWith({
    int? id,
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