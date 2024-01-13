// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/alert_dialog.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';

enum LessonState {
  empty,
  loading,
  completed,
  error,
}

class LessonViewModel extends ChangeNotifier {
  late LessonState? _state;
  late NavigationService _navigation;
  late String? _lessonName;
  late String? _lessonTableName;
  late bool _isAlertOpen;
  late List<Map<String, dynamic>>? listDeneme;

  LessonViewModel() {
    _navigation = NavigationService.instance;
    _isAlertOpen = false;
    _lessonName = 'Tarih';
    _state = LessonState.empty;
    listDeneme = [];
    _lessonTableName = LessonList.tableNames[_lessonName] ??
        LessonList.tableNames[_lessonName];

    initLessonData(_lessonName);
  }

  LessonState get state => _state!;
  set state(LessonState state) {
    _state = state;
    notifyListeners();
  }

  void initLessonData(String? lessonName) async {
    state = LessonState.loading;
    _lessonTableName =
        LessonList.tableNames[lessonName] ?? DenemeTables.historyTableName;

    await DenemeDbProvider.db
        .getLessonDeneme(_lessonTableName!); //fixed the update data
    await DenemeDbProvider.db
        .getLessonDeneme(_lessonTableName!); //fixed the update data

    listDeneme = await DenemeDbProvider.db.getLessonDeneme(_lessonTableName!);

    state = LessonState.completed;
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
      group.sort((a, b) => a["denemeId"].compareTo(b["denemeId"]));

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
      DenemeDbProvider.db.removeTableItem(lessonTable, id, idName);
    } catch (e) {
      printFunct("deleteDeneme error", e);
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

  String? get getLessonName {
    return _lessonName ?? 'Tarih'; //null problems
  }

  set setLessonName(String? newLesson) {
    _lessonName = newLesson!;
    notifyListeners();
  }

  String? get getLessonTableName =>
      _lessonTableName ?? DenemeTables.historyTableName;

  set setLessonTableName(String? newTable) {
    _lessonName = _lessonTableName =
        LessonList.tableNames[newTable] ?? DenemeTables.historyTableName;
    notifyListeners();
  }

  bool get getIsAlertOpen => _isAlertOpen;

  set setAlert(bool newBool) {
    _isAlertOpen = newBool;
  }

  Future<void> removeAlert(BuildContext context, String title, String content,
      LessonViewModel lessonProv, itemDeneme) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isOneButton: false,
      noFunction: () => {
        lessonProv.setAlert = false,
        Navigator.of(context, rootNavigator: true).pop(),
      },
      yesFunction: () async => {
        lessonProv.deleteItemById(
            lessonProv.getLessonTableName!, itemDeneme, 'denemeId'),
        lessonProv.setAlert = false,
        Navigator.of(context, rootNavigator: true).pop(),
        Future.delayed(const Duration(milliseconds: 200), () {
          lessonProv.initLessonData(lessonProv.getLessonName!);
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
