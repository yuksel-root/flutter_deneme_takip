import 'package:sqflite/sqflite.dart';

class DenemeTables {
  static const String tarihTableName = 'tarihTable';
  static const String mathTableName = 'mathTable';
  static const String vatandasTableName = 'vatandasTable';
  static const String cografyaTableName = 'cografyaTable';
  static const String turkceTableName = 'turkceDeneme';

  static Future<void> reCreateTable(Database db) async {
    await db.execute(''' 
      DROP TABLE IF EXISTS $tarihTableName
    ''');

    await db.execute(''' 
      DROP TABLE IF EXISTS $mathTableName
    ''');

    await db.execute(''' 
      DROP TABLE IF EXISTS $vatandasTableName
    ''');

    await db.execute(''' 
      DROP TABLE IF EXISTS $cografyaTableName
    ''');

    await db.execute(''' 
      DROP TABLE IF EXISTS $turkceTableName
    ''');

    await tarihCreateTable(db);
    await mathCreateTable(db);
    await vatandasCreateTable(db);
    await cografyaCreateTable(db);
    await turkceCreateTable(db);
  }

  static Future<void> tarihCreateTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tarihTableName (
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

  static Future<void> vatandasCreateTable(Database db) async {
    await db.execute('''
      CREATE TABLE $vatandasTableName (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectId INTEGER,
        falseCount INTEGER,
        subjectName TEXT,
        denemeId INTEGER,
        denemeDate TEXT
      )
    ''');
  }

  static Future<void> cografyaCreateTable(Database db) async {
    await db.execute('''
      CREATE TABLE $cografyaTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectId INTEGER,
        falseCount INTEGER,
        subjectName TEXT,
        denemeId INTEGER,
        denemeDate TEXT
      )
    ''');
  }

  static Future<void> turkceCreateTable(Database db) async {
    await db.execute('''
      CREATE TABLE $turkceTableName (
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
