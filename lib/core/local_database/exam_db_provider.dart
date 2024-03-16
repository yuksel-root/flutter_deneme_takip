// ignore_for_file: avoid_print

import 'package:flutter_deneme_takip/core/local_database/sql_tables.dart';
import 'package:flutter_deneme_takip/models/exam.dart';
import 'package:flutter_deneme_takip/models/exam_detail.dart';
import 'package:flutter_deneme_takip/models/lesson.dart';
import 'package:flutter_deneme_takip/models/subject.dart';
import "package:path/path.dart";
import 'package:sqflite/sqflite.dart';

class ExamDbProvider {
  ExamDbProvider._();
  static final ExamDbProvider db = ExamDbProvider._();

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
      db = await openDatabase(join(await getDatabasesPath(), "exam_app.db"),
          onCreate: (db, version) async {
            await SqlTables.lessonCreateTable(db);
            await SqlTables.subjectCreateTable(db);
            await SqlTables.examCreateTable(db);
            await SqlTables.examDetailCreateTable(db);
          },
          version: 1,
          onOpen: (Database db) async {
            // await SqlTables.reCreateTable(db);
          });
      return db;
    } catch (e) {
      print("$e openDb ERROR");
    }
  }

  Future<void> insertExam(ExamModel exam, ExamDetailModel examDetails) async {
    try {
      final db = await getDatabase;
      await db.transaction((txn) async {
        int examId = await txn.rawInsert('''
        INSERT INTO ${SqlTables.examTable} (exam_name, exam_date)
        VALUES (?, ?)
      ''', [exam.examName, exam.examDate]);

        await txn.rawInsert('''
        INSERT INTO ${SqlTables.examDetailsTable} (exam_id, lesson_id, subject_id, subject_false_count)
        VALUES (?, ?, ?, ?)
      ''', [
          examId,
          examDetails.lessonId,
          examDetails.subjectId,
          examDetails.falseCount
        ]);
      });
    } catch (e) {
      print("$e insertexam dbProv catch");
    }
  }

  Future<void> updateExam(ExamDetailModel exam, String lessonTable) async {
    try {
      final db = await getDatabase;

      //db.update(
      // lessonTable,
      //  exam.toMap(),
      // where: 'examId = ? AND subjectId = ?',
      // whereArgs: [exam.examId, exam.subjectId],
      //);

      await db.rawUpdate(
        'UPDATE $lessonTable SET subjectId = ?, examId = ?, falseCount = ?, examDate = ?, subjectName = ? WHERE examId = ? AND subjectId = ?',
        [
          exam.subjectId,
          exam.examId,
          exam.falseCount,
          exam.examId,
          exam.subjectId
        ],
      );
    } catch (e) {
      print("$e updateexam dbProv catch");
    }
  }

  List<Map<String, dynamic>>? convertFirebaseToSqliteData(
      List<dynamic> firebaseTableData) {
    List<Map<String, dynamic>>? listexam = [];

    listexam.addAll(firebaseTableData.map((e) => e));

    return listexam;
  }

  Future<void> insertAllExamData(Map<String, List<dynamic>>? examPost) async {
    if (examPost != null) {
      final hTable = examPost[SqlTables.lessonsTable];
      final gTable = examPost[SqlTables.lessonsTable];
      final cTable = examPost[SqlTables.lessonsTable];

      List<Map<String, dynamic>>? historyTable =
          convertFirebaseToSqliteData(hTable!);

      List<Map<String, dynamic>>? geographyTable =
          convertFirebaseToSqliteData(gTable!);

      List<Map<String, dynamic>>? citizenTable =
          convertFirebaseToSqliteData(cTable!);

      List<dynamic> examPostData = [
        historyTable,
        geographyTable,
        citizenTable,
      ];
      List<dynamic> lessonNames = [
        SqlTables.lessonsTable,
        SqlTables.lessonsTable,
        SqlTables.lessonsTable
      ];
      try {
        final db = await getDatabase;

        for (int j = 0; j < examPostData.length; j++) {
          final tableData = examPostData[j];
          String tableName = lessonNames[j];
          Batch batch = db.batch();

          for (var item in tableData) {
            ExamDetailModel examData = ExamDetailModel(
              examId: item['examId'],
              subjectId: item['subjectId'],
              falseCount: item['falseCount'],
            );

            //batch.insert(tableName, examData.toMap(),
            //  conflictAlgorithm: ConflictAlgorithm.replace);
            batch.rawInsert('''
        INSERT or REPLACE INTO $tableName (
          examId, subjectId, falseCount, subjectName, examDate
        ) VALUES (?, ?, ?, ?, ?)
      ''', [
              examData.examId,
              examData.subjectId,
              examData.falseCount,
            ]);
          }
          await batch.commit();
        }
      } catch (e) {
        print("$e dbProv inserAllexamData catch");
      }
    }
  }

  Future<List<Map<String, dynamic>>?> getExamsByExamId(
      String lessonTable, int examId) async {
    try {
      final db = await getDatabase;
      final res = await db
          .rawQuery('SELECT * FROM $lessonTable WHERE examId = ?', [examId]);
      if (res.isEmpty) {
        return [];
      } else {
        var examMap = res.toList();

        return examMap.isNotEmpty ? examMap : [];
      }
    } catch (e) {
      print("$e getexamlerByexamId catch");
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
        final examMap = res.toList();

        return examMap.isNotEmpty ? examMap : [];
      }
    } catch (e) {
      print("$e getAllDataOrderByDate catch");
    }
    return [];
  }

  Future<int?> removeTableItem(String table, int id, String idName) async {
    try {
      final db = await getDatabase;
      int delete =
          await db.rawDelete('DELETE FROM $table WHERE $idName = ?', [id]);
      return delete;
    } catch (e) {
      print("$e removeTableItem catch");
    }
    return null;
  }

  Future<void> insertLesson(String lessonName) async {
    try {
      final db = await getDatabase;
      int? maxLessonIndex = Sqflite.firstIntValue(await db.rawQuery('''
    SELECT MAX(lesson_index) AS max_lesson_index FROM ${SqlTables.lessonsTable}
  '''));

      await db.rawInsert('''
    INSERT INTO ${SqlTables.lessonsTable} (lesson_name, lesson_index)
    VALUES (?, ?)
  ''', [lessonName, (maxLessonIndex == null ? 0 : maxLessonIndex + 1)]);
    } catch (e) {
      print("$e  insertLesson catch ");
    }
  }

  Future<void> updateLesson({
    required int lessonId,
    required String lessonName,
    required int lessonIndex,
  }) async {
    try {
      final db = await getDatabase;

      await db.rawUpdate('''
      UPDATE ${SqlTables.lessonsTable}
      SET lesson_name = ?, lesson_index = ?
      WHERE lesson_id = ?
    ''', [lessonName, lessonIndex, lessonId]);
    } catch (e) {
      print("$e  updateLesson catch ");
    }
  }

  Future<void> insertSubject(String subjectName, int lessonId) async {
    final db = await getDatabase;

    try {
      final results = await db.rawQuery('''
      SELECT MAX(subject_index) AS max_sub_index FROM ${SqlTables.subjectsTable}
      WHERE lesson_id = ?
    ''', [lessonId]);

      int? maxSubjectIndex = results.first['max_sub_index'] as int?;

      await db.rawInsert('''
      INSERT INTO ${SqlTables.subjectsTable} (subject_name, subject_index, lesson_id)
      VALUES (?, ?, ?)
    ''', [
        subjectName,
        (maxSubjectIndex == null ? 0 : maxSubjectIndex + 1),
        lessonId
      ]);
    } catch (e) {
      print("$e insertSubject catch");
    }
  }

  Future<void> updateSubject({
    required int subjectId,
    required String subjectName,
    required int lessonId,
    required int subjectIndex,
  }) async {
    try {
      final db = await getDatabase;

      await db.rawUpdate('''
      UPDATE ${SqlTables.subjectsTable}
      SET subject_name = ?, subject_index = ?
      WHERE subject_id = ? AND lesson_id = ?
    ''', [subjectName, subjectIndex, subjectId, lessonId]);
    } catch (e) {
      print("$e  updateSubject catch ");
    }
  }

  Future<void> removeSubjectByLesson(int lessonId, int subjectId) async {
    try {
      final db = await getDatabase;

      await db.rawDelete('''
      DELETE FROM ${SqlTables.subjectsTable}
      WHERE lesson_id = ? AND subject_id = ?
    ''', [lessonId, subjectId]);
    } catch (e) {
      print("$e  removeSubjectByLesson catch ");
    }
  }

  Future<List<LessonModel>?> getAllLessonData() async {
    try {
      final db = await getDatabase;

      final result = await db.rawQuery(
          'SELECT * FROM ${SqlTables.lessonsTable} ORDER BY lesson_index');

      if (result.isEmpty) {
        return null;
      } else {
        return result.isNotEmpty
            ? result.map((lesson) => LessonModel().fromJson(lesson)).toList()
            : null;
      }
    } catch (e) {
      print("$e get lessonTable catch");
    }
    return null;
  }

  Future<List<SubjectModel>?>? getAllSubjectData(int lessonId) async {
    try {
      final db = await getDatabase;
      final result = await db.rawQuery('''
      SELECT * FROM ${SqlTables.subjectsTable}
      WHERE lesson_id = ?
      ORDER BY subject_index
    ''', [lessonId]);
      if (result.isEmpty) {
        return null;
      } else {
        return result.isNotEmpty
            ? result.map((subject) => SubjectModel().fromJson(subject)).toList()
            : null;
      }
    } catch (e) {
      print("$e get allSubjectData catch");
    }
    return null;
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

  Future<List<int>> getAllexamIds(String tableName) async {
    try {
      final db = await getDatabase;
      final List<Map<String, dynamic>> maps =
          await db.query(tableName, columns: ['examId']);

      return List.generate(maps.length, (index) {
        return maps[index]['examId'] as int;
      });
    } catch (e) {
      print("$e getAllexamIds catch");
    }
    return [];
  }

  Future<void> clearDatabase() async {
    try {
      final db = await getDatabase;
      await db.rawQuery("DELETE FROM ${SqlTables.examTable}");
      await db.rawQuery("DELETE FROM ${SqlTables.lessonsTable}");
      await db.rawQuery("DELETE FROM ${SqlTables.examDetailsTable}");
      await db.rawQuery("DELETE FROM ${SqlTables.subjectsTable}");
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
