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
    try {
      if (_database != null && _database!.isOpen) return _database!;

      _database = await openDb();
      return _database!;
    } catch (e) {
      print(e);
    }
    return _database!;
  }

  Future<void> closeDatabase() async {
    try {
      if (_database != null && _database!.isOpen) {
        print("Closed db..");
        await _database!.close();
      }
    } catch (e) {
      print(e);
    }
  }

  Future openDb() async {
    try {
      final Database db;
      print("open db...");
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
    } catch (e) {
      print("$e openDb ERROR");
    }
  }

  Future<void> insertDeneme(DenemeModel deneme, String lessonTable) async {
    try {
      final db = await getDatabase;
      //db.insert(lessonTable, deneme.toMap(),
      //   conflictAlgorithm: ConflictAlgorithm.replace);

      await db.rawInsert(
        'INSERT INTO $lessonTable (subjectId, denemeId, falseCount, denemeDate, subjectName) VALUES (?, ?, ?, ?, ?)',
        [
          deneme.subjectId,
          deneme.denemeId,
          deneme.falseCount,
          deneme.denemeDate,
          deneme.subjectName
        ],
      );
    } catch (e) {
      print("$e insertDeneme dbProv catch");
    }
  }

  Future<void> updateDeneme(DenemeModel deneme, String lessonTable) async {
    try {
      final db = await getDatabase;

      //db.update(
      // lessonTable,
      //  deneme.toMap(),
      // where: 'denemeId = ? AND subjectId = ?',
      // whereArgs: [deneme.denemeId, deneme.subjectId],
      //);

      await db.rawUpdate(
        'UPDATE $lessonTable SET subjectId = ?, denemeId = ?, falseCount = ?, denemeDate = ?, subjectName = ? WHERE denemeId = ? AND subjectId = ?',
        [
          deneme.subjectId,
          deneme.denemeId,
          deneme.falseCount,
          deneme.denemeDate,
          deneme.subjectName,
          deneme.denemeId,
          deneme.subjectId
        ],
      );
    } catch (e) {
      print("$e updateDeneme dbProv catch");
    }
  }

  List<Map<String, dynamic>>? convertFirebaseToSqliteData(
      List<dynamic> firebaseTableData) {
    List<Map<String, dynamic>>? listDeneme = [];

    listDeneme.addAll(firebaseTableData.map((e) => e));

    return listDeneme;
  }

  Future<void> inserAllDenemeData(
      Map<String, List<dynamic>>? denemePost) async {
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
      try {
        final db = await getDatabase;
        Batch batch = db.batch();
        for (int j = 0; j < denemePostData.length; j++) {
          final tableData = denemePostData[j];
          String tableName = lessonNames[j];

          for (var item in tableData) {
            DenemeModel denemeData = DenemeModel(
              denemeId: item['denemeId'],
              subjectId: item['subjectId'],
              falseCount: item['falseCount'],
              subjectName: item['subjectName'],
              denemeDate: item['denemeDate'],
            );

            // batch.insert(tableName, denemeData.toMap(),
            //   conflictAlgorithm: ConflictAlgorithm.replace);
            batch.rawInsert('''
        INSERT INTO $tableName (
          denemeId, subjectId, falseCount, subjectName, denemeDate
        ) VALUES (?, ?, ?, ?, ?)
      ''', [
              denemeData.denemeId,
              denemeData.subjectId,
              denemeData.falseCount,
              denemeData.subjectName,
              denemeData.denemeDate,
            ]);
          }
          await batch.commit();
        }
      } catch (e) {
        print("$e dbProv inserAllDenemeData catch");
      }
    }
  }

  Future<List<Map<String, dynamic>>?> getDenemelerByDenemeId(
      String lessonTable, int denemeId) async {
    try {
      final db = await getDatabase;
      final res = await db.rawQuery(
          'SELECT * FROM $lessonTable WHERE denemeId = ?', [denemeId]);
      if (res.isEmpty) {
        return [];
      } else {
        var denemeMap = res.toList();

        return denemeMap.isNotEmpty ? denemeMap : [];
      }
    } catch (e) {
      print("$e getDenemelerByDenemeId catch");
    }
    return [];
  }

  Future<void> groupBySubName() async {
    try {
      final db = await getDatabase;
      List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT subjectName, SUM(falseCount) AS totalFalseCount FROM historyTable GROUP BY subjectName',
      );
      print(result);
    } catch (e) {
      print("$e groupBySubName");
    }
  }

  Future<List<Map<String, dynamic>>> getAllDataOrderByDate(
      String lessonTable, String orderBy) async {
    try {
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
    } catch (e) {
      print("$e getAllDataOrderByDate catch");
    }
    return [];
  }

  Future<int?> removeTableItem(
      String lessonTable, int id, String idName) async {
    try {
      final db = await getDatabase;
      int delete = await db
          .rawDelete('DELETE FROM $lessonTable WHERE $idName = ?', [id]);
      return delete;
    } catch (e) {
      print("$e removeTableItem catch");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllDataByTable(String tableName) async {
    try {
      final db = await getDatabase;
      //  final res = await db.query(tableName);
      final res = await db.rawQuery('SELECT * FROM $tableName');

      if (res.isEmpty) {
        return [];
      } else {
        final denemeMap = res.toList();

        return denemeMap.isNotEmpty ? denemeMap : [];
      }
    } catch (e) {
      print("$e getAllDataByTable catch");
    }
    return [];
  }

  Future<int?> getFindLastId(String tableName, String idName) async {
    try {
      final db = await getDatabase;
      final result =
          await db.rawQuery('SELECT MAX($idName) as last_id FROM $tableName');
      int? lastId = result.first['last_id'] as int?;

      return lastId;
    } catch (e) {
      print("$e getFindLastId catch");
    }
    return null;
  }

  Future<List<int>> getAllDenemeIds(String tableName) async {
    try {
      final db = await getDatabase;
      final List<Map<String, dynamic>> maps =
          await db.query(tableName, columns: ['denemeId']);

      return List.generate(maps.length, (index) {
        return maps[index]['denemeId'] as int;
      });
    } catch (e) {
      print("$e getAllDenemeIds catch");
    }
    return [];
  }

  Future<void> clearDatabase() async {
    try {
      final db = await getDatabase;
      await db.rawQuery("DELETE FROM ${DenemeTables.historyTableName}");
      await db.rawQuery("DELETE FROM ${DenemeTables.mathTableName}");
      await db.rawQuery("DELETE FROM ${DenemeTables.geographyTable}");
      await db.rawQuery("DELETE FROM ${DenemeTables.citizenTable}");
      await db.rawQuery("DELETE FROM ${DenemeTables.turkishTable}");
    } catch (e) {
      print("$e clearDatabase catch");
    }
  }

  Future<void> clearDatabeByTableName(String tableName) async {
    try {
      final db = await getDatabase;
      await db.rawQuery("DELETE FROM $tableName");
    } catch (e) {
      print("$e clearDatabeByTableName catch");
    }
  }
}
