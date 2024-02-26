import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'course.dart';
import 'topic.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      // Initialize FFI only for desktop platforms
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('courses_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 6, onCreate: _createDB, onUpgrade: _UpgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE courses(
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        credits INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE topics(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        courseId INTEGER,
        parentId INTEGER,
        chapter TEXT,
        ranking INTEGER,
        notes TEXT,
        material TEXT,
        FOREIGN KEY(courseId) REFERENCES courses(id),
        FOREIGN KEY(parentId) REFERENCES topics(id)
        )
        ''');
  }

  Future _UpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute(
        '''
        CREATE TABLE topics(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        courseId INTEGER,
        parentId INTEGER,
        chapter TEXT,
        ranking INTEGER,
        notes TEXT,
        material TEXT,
        FOREIGN KEY(courseId) REFERENCES courses(id),
        FOREIGN KEY(parentId) REFERENCES topics(id)
        )
        ''');
    }
  }

  Future<int> createCourse(Map<String, dynamic> course) async {
    final db = await instance.database;
    return await db.insert('courses', course);
  }

  Future<List<Course>> getCourses() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('courses');

    return List.generate(maps.length, (i) {
      return Course.fromMap(maps[i]);
    });
  }

  Future<int> updateCourse(Map<String, dynamic> course) async {
    final db = await instance.database;
    return db.update(
      'courses', 
      course, 
      where: 'id = ?', 
      whereArgs: [course['id']]
    );
  }

  Future<int> deleteCourse(int id) async {
    final db = await instance.database;
    return await db.delete(
      'courses', 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  Future<int> createTopic(Map<String, dynamic> topic) async {
    final db = await instance.database;
    return await db.insert('topics', topic);
  }

  Future<List<Topic>> getTopics(int parentId) async {
    // List all topics where topic.parentId == parentId
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('topics', where: 'parentId = ?', whereArgs: [parentId]);
    
    return List.generate(maps.length, (i) {
      return Topic.fromMap(maps[i]);
    });
  }
  
  Future<Topic> getTopicById(int topicId) async {
  final db = await instance.database;
  final List<Map<String, dynamic>> maps = await db.query('topics', where: 'id = ?', whereArgs: [topicId]);
  if (maps.isNotEmpty) {
    return Topic.fromMap(maps.first); // Assuming maps is not empty
  }
  throw Exception('Topic not found');
}


  Future<int> updateTopic(Map<String, dynamic> topic) async {
    final db = await instance.database;
    return db.update(
      'topics', 
      topic, 
      where: 'id = ?', 
      whereArgs: [topic['id']]
    );
  }

  Future<int> deleteTopic(int id) async {
    final db = await instance.database;
    return await db.delete(
      'topics', 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  Future close() async {
    final db = await instance.database;
    if (db.isOpen) {
      await db.close();
    }
  }
}
