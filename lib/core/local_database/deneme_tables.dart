import 'package:sqflite/sqflite.dart';

class DenemeTables {
  static const String tarihTableName = 'tarihDeneme';
  static const String mathTableName = 'mathDeneme';

  static Future<void> reCreateTable(Database db) async {
    await db.execute(''' 
      DROP TABLE IF EXISTS $tarihTableName
    ''');

    await db.execute(''' 
      DROP TABLE IF EXISTS $mathTableName
    ''');

    await tarihCreateTable(db);
    await mathCreateTable(db);
  }

  static Future<void> tarihCreateTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tarihTableName (
        denemeId INTEGER PRIMARY KEY AUTOINCREMENT,
        falseCount INTEGER,
        subjectName TEXT,
        denemeDate TEXT
      )
    ''');
  }

  static Future<void> mathCreateTable(Database db) async {
    await db.execute('''
      CREATE TABLE $mathTableName (
        denemeId INTEGER PRIMARY KEY AUTOINCREMENT,
        falseCount INTEGER,
        subjectName TEXT,
        denemeDate TEXT
      )
    ''');
  }
}
