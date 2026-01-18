import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/login.php');
      
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(ApiConfig.timeoutDuration);

      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<')) {
        return {
          'success': false,
          'message': 'Server error: Pastikan XAMPP MySQL sudah running',
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'],
          'user': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      if (e.toString().contains('FormatException')) {
        return {
          'success': false,
          'message': 'Server error: Pastikan XAMPP Apache & MySQL sudah running',
        };
      }
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/register.php');
      
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(ApiConfig.timeoutDuration);

      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<')) {
        return {
          'success': false,
          'message': 'Server error: Pastikan XAMPP MySQL sudah running',
        };
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'],
          'user': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      if (e.toString().contains('FormatException')) {
        return {
          'success': false,
          'message': 'Server error: Pastikan XAMPP Apache & MySQL sudah running',
        };
      }
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }
}
