import 'package:sqflite/sqflite.dart';

class DenemeTables {
  static const String historyTableName = 'historyTable';
  static const String geographyTable = 'geographyTable';
  static const String citizenTable = 'citizenTable';
  static const String mathTableName = 'mathTable';
  static const String turkishTable = 'turkishTable';

  static Future<void> reCreateTable(Database db) async {
    await db.execute(''' 
      DROP TABLE IF EXISTS $historyTableName
    ''');
    await db.execute(''' 
      DROP TABLE IF EXISTS $geographyTable
    ''');
    await db.execute(''' 
      DROP TABLE IF EXISTS $citizenTable
    ''');

    await db.execute(''' 
      DROP TABLE IF EXISTS $mathTableName
    ''');

    await db.execute(''' 
      DROP TABLE IF EXISTS $turkishTable
    ''');

    await historyCreateTable(db);
    await geographyCreateTable(db);
    await citizenCreateTable(db);
    await mathCreateTable(db);
    await turkishCreateTable(db);
  }

  static Future<void> historyCreateTable(Database db) async {
    await db.execute('''
      CREATE TABLE $historyTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectId INTEGER,
        falseCount INTEGER,
        subjectName TEXT,
        denemeId INTEGER,
        denemeDate TEXT
      )
    ''');
  }

  static Future<void> geographyCreateTable(Database db) async {
    await db.execute('''
      CREATE TABLE $geographyTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectId INTEGER,
        falseCount INTEGER,
        subjectName TEXT,
        denemeId INTEGER,
        denemeDate TEXT
      )
    ''');
  }

  static Future<void> citizenCreateTable(Database db) async {
    await db.execute('''
      CREATE TABLE $citizenTable (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectId INTEGER,
        falseCount INTEGER,
        subjectName TEXT,
        denemeId INTEGER,
        denemeDate TEXT
      )
    ''');
  }

  static Future<void> mathCreateTable(Database db) async {
    await db.execute('''
      CREATE TABLE $mathTableName (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectId INTEGER,
        falseCount INTEGER,
        subjectName TEXT,
        denemeId INTEGER,
        denemeDate TEXT
      )
    ''');
  }

  static Future<void> turkishCreateTable(Database db) async {
    await db.execute('''
      CREATE TABLE $turkishTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectId INTEGER,
        falseCount INTEGER,
        subjectName TEXT,
        denemeId INTEGER,
        denemeDate TEXT
      )
    ''');
  }
}
