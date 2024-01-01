import 'package:flutter/material.dart';
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
  String? lessonName;
  late NavigationService _navigation;
  List<dynamic> tarihDeneme = LessonList.denemeHistory;
  late String? _lessonName;
  late String? _lessonTableName;
  late bool _isAlertOpen;
  late List<Map<String, dynamic>>? listDeneme;

  LessonViewModel() {
    _navigation = NavigationService.instance;
    _isAlertOpen = false;
    _lessonName = lessonName;
    _state = LessonState.empty;
    listDeneme = [];
    _lessonTableName =
        LessonList.tableNames[_lessonName] ?? DenemeTables.historyTableName;
    initTable(_lessonName);
  }

  LessonState get state => _state!;
  set state(LessonState state) {
    _state = state;
    notifyListeners();
  }

  void initTable(String? lessonName) async {
    state = LessonState.loading;
    _lessonTableName =
        LessonList.tableNames[lessonName] ?? DenemeTables.historyTableName;
    print("lesson table $_lessonTableName");

    listDeneme = await DenemeDbProvider.db
        .getLessonDeneme(_lessonTableName ?? DenemeTables.historyTableName);
    state = LessonState.completed;
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
    return lessonName ?? 'Tarih'; //null problems
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
}
