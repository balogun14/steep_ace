import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('steep_ace.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session INTEGER,
        question TEXT,
        answer TEXT,
        options TEXT,  -- JSON-encoded list for MCQs (e.g., '["A", "B", "C", "D"]')
        imagePath TEXT,
        difficulty INTEGER  -- 1: Easy, 2: Medium, 3: Hard
      )
    ''');
    await db.execute('''
      CREATE TABLE scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userName TEXT,
        session INTEGER,
        difficulty INTEGER,
        score INTEGER,
        date TEXT
      )
    ''');
  }

  Future<void> insertQuestion(Map<String, dynamic> question) async {
    final db = await database;
    await db.insert('questions', question);
  }

  Future<List<Map<String, dynamic>>> getQuestions(int session, int difficulty) async {
    final db = await database;
    return await db.query(
      'questions',
      where: 'session = ? AND difficulty = ?',
      whereArgs: [session, difficulty],
      limit: 30,
      orderBy: 'RANDOM()',
    );
  }

  Future<void> insertScore(String userName, int session, int difficulty, int score) async {
    final db = await database;
    await db.insert('scores', {
      'userName': userName,
      'session': session,
      'difficulty': difficulty,
      'score': score,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getScores(String userName) async {
    final db = await database;
    return await db.query('scores', where: 'userName = ?', whereArgs: [userName]);
  }
}