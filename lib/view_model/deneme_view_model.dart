// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';

import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';

import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/models/deneme.dart';

enum DenemeState {
  empty,
  loading,
  completed,
  error,
}

class DenemeViewModel extends ChangeNotifier {
  late DenemeState? _state;
  String? lessonName;
  late NavigationService _navigation;
  List<dynamic> tarihDeneme = LessonList.denemeHistory;
  late String? _lessonName;
  late String? _lessonTableName;
  late bool _isAlertOpen;
  late List<Map<String, dynamic>>? listDeneme;

  late List<dynamic> rowData;
  late List<dynamic> columnData;
  late List<Map<String, dynamic>> denemelerData;

  DenemeViewModel() {
    _navigation = NavigationService.instance;
    _isAlertOpen = false;
    _lessonName = lessonName;
    _state = DenemeState.empty;
    listDeneme = [];
    _lessonTableName =
        LessonList.tableNames[_lessonName] ?? DenemeTables.historyTableName;
    initTable(lessonName);
    columnData = List.of(findList(lessonName ?? 'Tarih'));
    rowData = [];
    denemelerData = [];
  }

  DenemeState get state => _state!;
  set state(DenemeState state) {
    _state = state;
    notifyListeners();
  }

  String initPng(String lessonName) {
    String? png =
        LessonList.lessonPngList[lessonName] ?? LessonList.lessonPngList[0];
    return png!;
  }

  List<Map<String, dynamic>> filterByDenemeId(List<Map<String, dynamic>> data) {
    Map<int, List<Map<String, dynamic>>> groupedData = {};
    List<Map<String, dynamic>> group = [];

    group.clear();
    groupedData.clear();
    denemelerData.clear();
    for (var item in data) {
      final denemeId = item['denemeId'] as int;
      if (!groupedData.containsKey(denemeId)) {
        groupedData[denemeId] = [];
      }
      groupedData[denemeId]!.add(item);
    }

    //_lastDenemeId =
    //  (await DenemeDbProvider.db.getFindLastId(initTable(), "denemeId"))!;
    //print(_lastDenemeId);
    // group = groupedData[1]!;

    group.addAll(groupedData.values.expand((items) => items));

    return group;
  }

  void convertToRow(List<Map<String, dynamic>> data) async {
    Map<int, List<Map<String, dynamic>>> idToRowMap = {};

    for (var item in filterByDenemeId(data)) {
      int id = item['id'];
      if (idToRowMap[id] == null) {
        idToRowMap[id] = [];
      }
      idToRowMap[id]!.add(item);
    }

    for (var entry in idToRowMap.entries) {
      Map<String, dynamic> rowItem = {"row": entry.value};
      denemelerData.add(rowItem);
    }

    //print('denemelerData');
    //print(denemelerData);
    // print('denemelerData');
  }

  Map<int, List<int>> falseCountsByDenemeId(
      List<Map<String, dynamic>> denemelerData) {
    Map<int, List<int>> falseCountsByDenemeId = {};

    for (var item in denemelerData) {
      var row = item['row'] as List<dynamic>;
      if (row.isNotEmpty) {
        var denemeId = row[0]['denemeId'] as int;
        var falseCount = row[0]['falseCount'] as int;

        if (!falseCountsByDenemeId.containsKey(denemeId)) {
          falseCountsByDenemeId[denemeId] = [];
        }

        falseCountsByDenemeId[denemeId]!.add(falseCount);
      }
    }
    return falseCountsByDenemeId;
  }

  void insertRowData(List<Map<String, dynamic>> denemelerData) {
    int i = 0;
    rowData.clear();

    falseCountsByDenemeId(denemelerData).forEach((denemeId, falseCounts) {
      List<dynamic> arr = List.generate(columnData.length, (index) => 0);

      for (int j = 0; j < (falseCounts.length); j++) {
        arr[0] = "Deneme$denemeId";
        arr[j] = falseCounts[j];
      }

      rowData.add({'row': List.from(arr)});

      i++;
      arr.clear();
    });

    rowData.sort((a, b) {
      // print("Sorted");
      String aTitle = a['row'][0].toString();
      String bTitle = b['row'][0].toString();

      // "Deneme" ifadesini atarak sadece sayısal değerleri alıyoruz
      int aNumber = int.parse(aTitle.replaceAll("Deneme", ""));
      int bNumber = int.parse(bTitle.replaceAll("Deneme", ""));

      return aNumber.compareTo(bNumber);
    });
    // print("rowData");
    // print(rowData);
    // print("rowData");
  }

  List<dynamic> sumByFiveGroups(List<List<int>> inputList) {
    List<List<int>> resultList = [];

    for (int i = 0; i < inputList.length; i += 5) {
      List<int> sumList = List.filled(inputList[i].length, 0);

      for (int j = i; j < i + 5 && j < inputList.length; j++) {
        for (int k = 0; k < inputList[j].length; k++) {
          sumList[k] += inputList[j][k];
        }
      }

      resultList.add(sumList);
    }

    return resultList;
  }

  List<String> findList(String lessonName) {
    return LessonList.lessonListMap[lessonName] ?? [];
  }

  void initTable(String? lessonName) async {
    state = DenemeState.loading;
    _lessonTableName =
        LessonList.tableNames[lessonName] ?? DenemeTables.historyTableName;
    print("deneme less init table $_lessonTableName");

    listDeneme = await DenemeDbProvider.db
        .getLessonDeneme(_lessonTableName ?? DenemeTables.historyTableName);
    state = DenemeState.completed;
  }

  void navigateToPageClear(
    String path,
    Object? data,
  ) {
    _navigation.navigateToPageClear(path: path, data: data);
  }

  void saveDeneme(DenemeModel deneme, String lessonTable) {
    try {
      DenemeDbProvider.db.insertDeneme(deneme, lessonTable);
    } catch (e) {
      printFunct("saveDeneme error", e);
    }
    notifyListeners();
  }

  void deleteItemById(String lessonTable, int id, String idName) {
    try {
      DenemeDbProvider.db.removeTableItem(lessonTable, id, idName);
    } catch (e) {
      printFunct("deleteDeneme error", e);
    }
    notifyListeners();
  }

  Future<void> getAllData(String dataTable) async {
    print("-------------$dataTable------------\n");
    print(await DenemeDbProvider.db.getLessonDeneme(dataTable));
    print("-------------$dataTable------------\n");
  }

  void printFunct(String label, Object? data) {
    print("----------- $label --------------");
    print(data);
    print("----------- $label --------------");
  }

  Future<int?> getLastId(String table, String id) async {
    return await DenemeDbProvider.db.getFindLastId(table, id);
  }

  int? _selectedGroupSize = 5;
  bool _isTotal = false;
  bool get getIsTotal => _isTotal;

  set setIsTotal(bool newTotal) {
    _isTotal = newTotal;
    notifyListeners();
  }

  int? get getSelectedGroupSize => _selectedGroupSize;

  set setSelectedGroupSize(int newSize) {
    _selectedGroupSize = newSize;
    notifyListeners();
  }

  bool get getIsAlertOpen => _isAlertOpen;

  set setAlert(bool newBool) {
    _isAlertOpen = newBool;
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
}
