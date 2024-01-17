// ignore_for_file: avoid_print

import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';
import 'package:flutter_deneme_takip/models/deneme.dart';
import "package:path/path.dart";
import 'package:sqflite/sqflite.dart';

class DenemeDbProvider {
  DenemeDbProvider._();
  static final DenemeDbProvider db = DenemeDbProvider._();

  Database? _database;

  Future<Database> get getDatabase async {
    if (_database != null) return _database!;

    _database = await openDb();
    return _database!;
  }

  Future openDb() async {
    print("creating db");
    final Database db;
    db = await openDatabase(join(await getDatabasesPath(), "deneme_app.db"),
        onCreate: (db, version) async {
          await DenemeTables.historyCreateTable(db);
          await DenemeTables.geographyCreateTable(db);
          await DenemeTables.citizenCreateTable(db);
          await DenemeTables.mathCreateTable(db);
          await DenemeTables.turkishCreateTable(db);
        },
        version: 1,
        onOpen: (Database db) async {
          // await DenemeTables.reCreateTable(db);
        });
    return db;
  }

  Future<void> insertDeneme(DenemeModel deneme, String lessonTable) async {
    final db = await getDatabase;
    db.insert(lessonTable, deneme.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateDeneme(DenemeModel deneme, String lessonTable) async {
    final db = await getDatabase;

    db.update(
      lessonTable,
      deneme.toMap(),
      where: 'denemeId = ? AND subjectId = ?',
      whereArgs: [deneme.denemeId, deneme.subjectId],
    );
  }

  List<Map<String, dynamic>>? convertFirebaseToSqliteData(
      List<dynamic> firebaseTableData) {
    List<Map<String, dynamic>>? listDeneme = [];

    listDeneme.addAll(firebaseTableData.map((e) => e));

    return listDeneme;
  }

  Future<void> inserAllDenemeData(
      Map<String, List<dynamic>>? denemePost) async {
    final db = await getDatabase;
    if (denemePost != null) {
      final hTable = denemePost[DenemeTables.historyTableName];
      final gTable = denemePost[DenemeTables.geographyTable];
      final cTable = denemePost[DenemeTables.citizenTable];

      List<Map<String, dynamic>>? historyTable =
          convertFirebaseToSqliteData(hTable!);

      List<Map<String, dynamic>>? geographyTable =
          convertFirebaseToSqliteData(gTable!);

      List<Map<String, dynamic>>? citizenTable =
          convertFirebaseToSqliteData(cTable!);

      List<dynamic> denemePostData = [
        historyTable,
        geographyTable,
        citizenTable,
      ];
      List<dynamic> lessonNames = [
        DenemeTables.historyTableName,
        DenemeTables.geographyTable,
        DenemeTables.citizenTable,
      ];

      for (int j = 0; j < denemePostData.length; j++) {
        final tableData = denemePostData[j];
        String tableName = lessonNames[j];

        Batch batch = db.batch();

        for (var item in tableData) {
          DenemeModel denemeData = DenemeModel(
            denemeId: item['denemeId'],
            subjectId: item['subjectId'],
            falseCount: item['falseCount'],
            subjectName: item['subjectName'],
            denemeDate: item['denemeDate'],
          );

          batch.insert(tableName, denemeData.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }

        await batch.commit();
      }
    }
  }

  Future<List<Map<String, dynamic>>> getDenemelerByDenemeId(
      String lessonTable, int denemeId) async {
    final db = await getDatabase;
    final res = await db
        .rawQuery('SELECT * FROM $lessonTable WHERE denemeId = ?', [denemeId]);
    if (res.isEmpty) {
      return [];
    } else {
      var denemeMap = res.toList();

      return denemeMap.isNotEmpty ? denemeMap : [];
    }
  }

  Future<void> groupBySubName() async {
    final db = await getDatabase;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT subjectName, SUM(falseCount) AS totalFalseCount FROM historyTable GROUP BY subjectName',
    );
    print(result);
  }

  Future<List<Map<String, dynamic>>> getAllDataOrderByDate(
      String lessonTable, String orderBy) async {
    final db = await getDatabase;
    var res = await db.query(
      lessonTable,
      orderBy: orderBy,
    );
    if (res.isEmpty) {
      return [];
    } else {
      final denemeMap = res.toList();

      return denemeMap.isNotEmpty ? denemeMap : [];
    }
  }

  Future<int> removeTableItem(String lessonTable, int id, String idName) async {
    final db = await getDatabase;
    int delete =
        await db.rawDelete('DELETE FROM $lessonTable WHERE $idName = ?', [id]);
    return delete;
  }

  Future<List<Map<String, dynamic>>> getAllDataByTable(String tableName) async {
    final db = await getDatabase;
    final res = await db.query(tableName); //Burası  null geliyo delay olmayınca

    if (res.isEmpty) {
      return [];
    } else {
      final denemeMap = res.toList();

      return denemeMap.isNotEmpty ? denemeMap : [];
    }
  }

  Future<int?> getFindLastId(String tableName, String idName) async {
    final db = await getDatabase;
    final result =
        await db.rawQuery('SELECT MAX($idName) as last_id FROM $tableName');
    int? lastId = result.first['last_id'] as int?;

    return lastId;
  }

  Future<List<int>> getAllDenemeIds(String tableName) async {
    final db = await getDatabase;
    final List<Map<String, dynamic>> maps =
        await db.query(tableName, columns: ['denemeId']);

    return List.generate(maps.length, (index) {
      return maps[index]['denemeId'] as int;
    });
  }

  Future<void> clearDatabase() async {
    final db = await getDatabase;
    await db.rawQuery("DELETE FROM ${DenemeTables.historyTableName}");
    await db.rawQuery("DELETE FROM ${DenemeTables.mathTableName}");
    await db.rawQuery("DELETE FROM ${DenemeTables.geographyTable}");
    await db.rawQuery("DELETE FROM ${DenemeTables.citizenTable}");
    await db.rawQuery("DELETE FROM ${DenemeTables.turkishTable}");
  }

  Future<void> clearDatabeByTableName(String tableName) async {
    final db = await getDatabase;
    await db.rawQuery("DELETE FROM $tableName");
  }
}
