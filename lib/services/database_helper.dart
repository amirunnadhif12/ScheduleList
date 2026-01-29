import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'schedulelist.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabel Schedules
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        activity TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        location TEXT,
        color TEXT DEFAULT '#2563eb',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Tabel Tasks
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        subject TEXT,
        deadline TEXT NOT NULL,
        priority TEXT DEFAULT 'sedang',
        status TEXT DEFAULT 'belum_mulai',
        progress INTEGER DEFAULT 0,
        image_path TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // ==================== USER METHODS ====================
  
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // ==================== SCHEDULE METHODS ====================

  Future<int> insertSchedule(Map<String, dynamic> schedule) async {
    final db = await database;
    schedule['created_at'] = DateTime.now().toIso8601String();
    schedule['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('schedules', schedule);
  }

  Future<List<Map<String, dynamic>>> getSchedulesByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'schedules',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date ASC, start_time ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getSchedulesByDate(int userId, String date) async {
    final db = await database;
    return await db.query(
      'schedules',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      orderBy: 'start_time ASC',
    );
  }

  Future<Map<String, dynamic>?> getScheduleById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> updateSchedule(Map<String, dynamic> schedule) async {
    final db = await database;
    schedule['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'schedules',
      schedule,
      where: 'id = ?',
      whereArgs: [schedule['id']],
    );
  }

  Future<int> deleteSchedule(int id) async {
    final db = await database;
    return await db.delete(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== TASK METHODS ====================

  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    task['created_at'] = DateTime.now().toIso8601String();
    task['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('tasks', task);
  }

  Future<List<Map<String, dynamic>>> getTasksByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'deadline ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getTasksByStatus(int userId, String status) async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, status],
      orderBy: 'deadline ASC',
    );
  }

  Future<Map<String, dynamic>?> getTaskById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> updateTask(Map<String, dynamic> task) async {
    final db = await database;
    task['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'tasks',
      task,
      where: 'id = ?',
      whereArgs: [task['id']],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> searchTasks(int userId, String query) async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'user_id = ? AND (title LIKE ? OR description LIKE ? OR subject LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%', '%$query%'],
      orderBy: 'deadline ASC',
    );
  }
}
