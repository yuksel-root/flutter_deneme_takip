// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/local_database/exam_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/sql_tables.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/components/alert_dialog/alert_dialog.dart';
import 'package:flutter_deneme_takip/models/lesson.dart';

enum ExamListState {
  empty,
  loading,
  completed,
  error,
}

class ExamListViewModel extends ChangeNotifier {
  late ExamListState? _state;
  late NavigationService _navigation;

  late bool _isAlertOpen;
  late List<Map<String, dynamic>>? listExam;
  late List<LessonModel>? _listLesson;

  ExamListViewModel() {
    _navigation = NavigationService.instance;
    _isAlertOpen = false;

    _state = ExamListState.empty;
    listExam = [];
    _listLesson = [];

    initLessonTab();
    // initLessonExamData(_lessonName);
  }

  ExamListState get state => _state!;
  set state(ExamListState state) {
    _state = state;
    notifyListeners();
  }

  void initLessonTab() async {
    state = ExamListState.loading;
    _listLesson = await ExamDbProvider.db.getAllLessonData();
    state = ExamListState.completed;
  }

  void removeLessonTab(int index, LessonModel lesson) {
    ExamDbProvider.db
        .removeTableItem(SqlTables.lessonsTable, lesson.lessonId!, "lesson_id");
    _listLesson!.removeAt(index);
    notifyListeners();
  }

  void initExamListData(String? lessonName) async {
    state = ExamListState.loading;

    // listExam = await ExamDbProvider.db.getAllDataByTable(_lessonTableName!);

    state = ExamListState.completed;
  }

  void updateExamListData(List<Map<String, dynamic>>? data) {
    state = ExamListState.loading;
    listExam = data;
    state = ExamListState.completed;
  }

  Map<String, List<Map<String, dynamic>>> groupBySubjects(
      List<Map<String, dynamic>> data) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    List<Map<String, dynamic>> filteredData =
        data.where((item) => item['falseCount'] != 0).toList();

    for (var item in filteredData) {
      String subjectName = item['subjectName'];
      if (!groupedData.containsKey(subjectName)) {
        groupedData[subjectName] = [];
      }
      groupedData[subjectName]!.add(item);
    }

    return groupedData;
  }

  Map<String, int> sumSubjectFalseCount(List<Map<String, dynamic>> group) {
    Map<String, int> totalFalseM = {};

    for (var data in group) {
      String subName = data['subjectName'];
      int falseCount = data['falseCount'];

      if (!totalFalseM.containsKey(subName)) {
        totalFalseM[subName] = 0;
      }
      totalFalseM[subName] = totalFalseM[subName]! + falseCount;
    }

    return totalFalseM;
  }

  List<int> groupBySumFalseCounts(List<Map<String, dynamic>> group) {
    List<int> falseCounts = [];

    if (group.any((item) => item['falseCount'] != 0)) {
      group.sort((a, b) => a["examId"].compareTo(b["examId"]));

      int totalFalse = 0;

      for (int i = 0; i < group.length; i++) {
        totalFalse += group[i]['falseCount'] as int;

        if ((i + 1) % 5 == 0 || i == group.length - 1) {
          falseCounts.add(totalFalse);
          totalFalse = 0;
        }
      }
    } else {}
    return falseCounts;
  }

  void deleteItemById(String lessonTable, int id, String idName) {
    try {
      ExamDbProvider.db.removeTableItem(lessonTable, id, idName);
    } catch (e) {
      printFunct("deleteexam error", e);
    }
    notifyListeners();
  }

  void printFunct(String label, Object? data) {
    print("----------- $label --------------");
    print(data);
    print("----------- $label --------------");
  }

  void navigateToPageClear(
    String path,
    Object? data,
  ) {
    _navigation.navigateToPageClear(path: path, data: data);
  }

  bool get getIsAlertOpen => _isAlertOpen;

  set setAlert(bool newBool) {
    _isAlertOpen = newBool;
  }

  Future<void> removeAlert(BuildContext context, String title, String content,
      ExamListViewModel lessonProv, itemexam) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isOneButton: false,
      noFunction: () => {
        lessonProv.setAlert = false,
        Navigator.of(context, rootNavigator: true).pop(),
      },
      yesFunction: () async => {
        //  lessonProv.deleteItemById(
//lessonProv.getLessonTableName!, itemexam, 'examId'),
        lessonProv.setAlert = false,
        Navigator.of(context, rootNavigator: true).pop(),
        await Future.delayed(const Duration(milliseconds: 50), () {
          // lessonProv.initExamListData(lessonProv.getLessonName!);
        }),
      },
    );

    if (lessonProv.getIsAlertOpen == false) {
      lessonProv.setAlert = true;
      await showDialog(
          barrierDismissible: false,
          barrierColor: const Color(0x66000000),
          context: context,
          builder: (BuildContext context) {
            return alert;
          }).then(
        (value) => lessonProv.setAlert = false,
      );
    }
  }

  Future<void> showAlert(
    BuildContext context, {
    required bool isOneButton,
    required String title,
    required String content,
    required Function yesFunction,
    required Function noFunction,
  }) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isOneButton: isOneButton,
      noFunction: () async => {
        setAlert = false,
        noFunction(),
      },
      yesFunction: () async => {
        setAlert = false,
        yesFunction(),
      },
    );

    if (getIsAlertOpen == false) {
      setAlert = true;
      await showDialog(
          barrierDismissible: false,
          barrierColor: const Color(0x66000000),
          context: context,
          builder: (BuildContext context) {
            return alert;
          }).then(
        (value) => setAlert = false,
      );
    }
  }
}
