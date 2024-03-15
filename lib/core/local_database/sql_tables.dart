import 'package:sqflite/sqflite.dart';

class SqlTables {
  static const subjectsTable = "subjects";
  static const lessonsTable = "lessons";
  static const examTable = "exams";
  static const examDetailsTable = "examDetails";

  static Future<void> reCreateTable(Database db) async {
    await db.execute('''
      DROP TABLE IF EXISTS $lessonsTable
    ''');
    await db.execute('''
      DROP TABLE IF EXISTS $subjectsTable
    ''');
    await db.execute('''
      DROP TABLE IF EXISTS $examTable
    ''');

    await db.execute('''
      DROP TABLE IF EXISTS $examDetailsTable
    ''');

    await lessonCreateTable(db);
    await subjectCreateTable(db);
    await examCreateTable(db);
    await examDetailCreateTable(db);
  }

  static Future<void> lessonCreateTable(Database db) async {
    await db.execute('''
    CREATE TABLE $lessonsTable (
      lesson_id INTEGER PRIMARY KEY AUTOINCREMENT,
      lesson_name TEXT NOT NULL,
      lesson_index INTEGER NOT NULL
    )
  ''');
  }

  static Future<void> subjectCreateTable(Database db) async {
    await db.execute('''
      CREATE TABLE $subjectsTable (
        subject_id  INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_name TEXT NOT NULL,
        subject_index INTEGER NOT NULL,
        lesson_id INTEGER REFERENCES $lessonsTable(lesson_id)
      )
    ''');
  }

  static Future<void> examCreateTable(Database db) async {
    await db.execute('''
      CREATE TABLE $examTable (
       exam_id INTEGER PRIMARY KEY AUTOINCREMENT,
       exam_name TEXT,
       exam_date DATE NOT NULL
      )
    ''');
  }

  static Future<void> examDetailCreateTable(Database db) async {
    await db.execute('''
    CREATE TABLE $examDetailsTable (
      examDetailId INTEGER PRIMARY KEY AUTOINCREMENT,
      exam_id INTEGER REFERENCES $examTable(exam_id),
      lesson_id INTEGER REFERENCES $lessonsTable(lesson_id),
      subject_id INTEGER REFERENCES $subjectsTable(subject_id),
      subject_false_count INTEGER NOT NULL
    )
  ''');
  }
}
