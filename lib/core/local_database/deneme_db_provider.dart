import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';
import 'package:flutter_deneme_takip/models/deneme.dart';
import "package:path/path.dart";
import 'package:sqflite/sqflite.dart';

class DenemeDbProvider {
  DenemeDbProvider._();
  static final DenemeDbProvider db = DenemeDbProvider._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // if _database is null we instantiate it
    _database = await openDb();
    return _database!;
  }

  Future openDb() async {
    print("creating db");
    final Database db;
    db = await openDatabase(join(await getDatabasesPath(), "deneme_app.db"),
        onCreate: (db, version) async {
          await DenemeTables.tarihCreateTable(db);
          await DenemeTables.mathCreateTable(db);
        },
        version: 1,
        onOpen: (Database db) async {
          await DenemeTables.reCreateTable(db);
        });
    return db;
  }

  Future<void> addNewDeneme(DenemeModel deneme, String lessonTable) async {
    final db = await database;

    db.insert(lessonTable, deneme.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getDeneme() async {
    final db = await database;
    var res = await db.query(DenemeTables.tarihTableName);
    if (res.isEmpty) {
      return []; // Boş bir liste döndürülebilir
    } else {
      var denemeMap = res.toList();

      print("get");
      print(denemeMap);
      print("------------------------------\n");

      print("get");
      return denemeMap.isNotEmpty ? denemeMap : [];
    }
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.rawQuery("DELETE FROM ${DenemeTables.tarihTableName}");
  }
}
