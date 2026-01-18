import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Base URL - Otomatis menyesuaikan platform
  // Untuk emulator Android: 10.0.2.2
  // Untuk device fisik: IP address komputer (misal: 192.168.1.100)
  // Untuk iOS simulator & Web & Windows/Linux/macOS: localhost
  static String get baseUrl {
    if (kIsWeb) {
      // Web browser uses localhost
      return 'http://localhost/schedulelist/backend/api';
    } else if (Platform.isAndroid) {
      // Android emulator special IP
      return 'http://10.0.2.2/schedulelist/backend/api';
    } else {
      // iOS simulator, Windows, macOS, Linux
      return 'http://localhost/schedulelist/backend/api';
    }
  }
  
  // Endpoints
  static String get schedulesEndpoint => '$baseUrl/schedules/index.php';
  static String get tasksEndpoint => '$baseUrl/tasks/index.php';
  
  // Timeout duration
  static const Duration timeoutDuration = Duration(seconds: 30);
}
