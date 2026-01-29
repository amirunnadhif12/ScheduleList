class Schedule {
  final String? id;
  final String title;
  final String description;
  final String date; // Format: YYYY-MM-DD
  final String time; // Format: HH:mm (start_time)
  final String? endTime; // Format: HH:mm
  final String? location;
  final String? color;

  Schedule({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.location,
    this.endTime,
    this.color,
  });

  // Constructor with all data (for updates)
  Schedule.withFullData({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required String this.endTime,
    this.location,
    required String this.color,
  });

  // Convert Schedule object to Map untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity': title,  // Backend uses 'activity' field
      'description': description,
      'date': date,
      'start_time': time,  // Backend uses 'start_time'
      'end_time': endTime ?? _calculateEndTime(time),  // Use provided or calculate
      'location': location ?? '',
      'color': color ?? '#2563eb',  // Use provided or default color
    };
  }

  // Helper to calculate end time (1 hour later)
  String _calculateEndTime(String startTime) {
    try {
      final parts = startTime.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        hour = (hour + 1) % 24;
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {}
    return startTime;
  }

  // Convert Map dari database to Schedule object
  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id']?.toString(),
      title: map['activity'] ?? map['title'] ?? '',  // Support both field names
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      time: map['start_time'] ?? map['time'] ?? '',  // Support both field names
      endTime: map['end_time'],
      location: map['location'],
      color: map['color'],
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'activity': title,
      'description': description,
      'date': date,
      'start_time': time,
      'end_time': endTime ?? _calculateEndTime(time),
      'location': location ?? '',
      'color': color ?? '#2563eb',
    };
  }

  // Create from Firestore document
  factory Schedule.fromFirestore(Map<String, dynamic> map) {
    return Schedule(
      id: map['id']?.toString(),
      title: map['activity'] ?? map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      time: map['start_time'] ?? map['time'] ?? '',
      endTime: map['end_time'],
      location: map['location'],
      color: map['color'],
    );
  }

  // Copy with method untuk update data
  Schedule copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? time,
    String? endTime,
    String? location,
    String? color,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      color: color ?? this.color,
    );
  }
}
