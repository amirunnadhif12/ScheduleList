import 'database_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dbHelper.getUserByEmail(email);

      if (user == null) {
        return {
          'success': false,
          'message': 'Email tidak ditemukan',
        };
      }

      if (user['password'] != password) {
        return {
          'success': false,
          'message': 'Password salah',
        };
      }

      return {
        'success': true,
        'message': 'Login berhasil',
        'user': {
          'id': user['id'],
          'name': user['name'],
          'email': user['email'],
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Cek apakah email sudah terdaftar
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        return {
          'success': false,
          'message': 'Email sudah terdaftar',
        };
      }

      // Insert user baru
      final userId = await _dbHelper.insertUser({
        'name': name,
        'email': email,
        'password': password,
      });

      return {
        'success': true,
        'message': 'Registrasi berhasil',
        'user': {
          'id': userId,
          'name': name,
          'email': email,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
