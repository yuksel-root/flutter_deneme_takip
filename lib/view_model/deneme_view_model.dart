// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/alert_dialog.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/models/deneme.dart';
import 'package:flutter_deneme_takip/models/deneme_post_model.dart';
import 'package:flutter_deneme_takip/services/auth_service.dart';
import 'package:flutter_deneme_takip/services/firebase_service.dart';

enum DenemeState {
  empty,
  loading,
  completed,
  error,
}

class DenemeViewModel extends ChangeNotifier {
  late DenemeState? _state;
  late NavigationService _navigation;

  FirebaseFirestore? firestore = FirebaseFirestore.instance;

  List<dynamic> tarihDeneme = LessonList.denemeHistory;
  late String? _lessonName;
  late String? _lessonTableName;
  late bool _isAlertOpen;
  late List<Map<String, dynamic>>? listDeneme;
  late List<dynamic> rowData;
  late List<dynamic> columnData;
  late List<Map<String, dynamic>> denemelerData;
  late List<List<int>> _listFalseCounts;
  late String? _initPng;

  DenemeViewModel() {
    _navigation = NavigationService.instance;

    _isAlertOpen = false;
    _lessonName = 'Tarih';
    _state = DenemeState.empty;
    listDeneme = [];
    _lessonTableName =
        LessonList.tableNames[_lessonName] ?? LessonList.tableNames['Tarih'];
    initData(_lessonName);
    _initPng = LessonList.lessonPngList[_lessonName] ??
        LessonList.lessonPngList['Tarih'];
    columnData = List.of(findList(_lessonName ?? 'Tarih'));
    rowData = [];
    denemelerData = [];
    _listFalseCounts = [];
  }

  DenemeState get getDenemeState => _state!;
  set setDenemestate(DenemeState state) {
    _state = state;
    notifyListeners();
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
    rowData.clear();

    falseCountsByDenemeId(denemelerData).forEach((denemeId, falseCounts) {
      List<dynamic> arr = List.generate(columnData.length, (index) => 0);

      for (int j = 0; j < (falseCounts.length); j++) {
        arr[0] = "Deneme$denemeId";
        arr[j] = falseCounts[j];
      }

      rowData.add({'row': List.from(arr)});

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
  }

  void totalInsertRowData(List<Map<String, dynamic>> denemeData) {
    rowData.clear();
    _listFalseCounts.clear();

    // print("denemeData $denemeData");

    falseCountsByDenemeId(denemeData).forEach((denemeId, falseCounts) {
      _listFalseCounts.add(falseCounts);
    });

    // print("get groupSize $getSelectedGroupSize");
    List<dynamic> sumList =
        List.from(sumByGroups(_listFalseCounts, getSelectedGroupSize));
    List<dynamic> sumArr = List.generate(columnData.length, (index) => 0);
    List<dynamic> totalSum = List.of(sumAllLists(_listFalseCounts));

    for (int j = 0; j < sumList.length; j++) {
      if (j == 0) {
        sumArr[0] = "Deneme 1-$getSelectedGroupSize";
      } else {
        if (getSelectedGroupSize == 5) {
          sumArr[0] = "Deneme ${(j * 5) + 1}-${(j * 5) + 5}";
        } else {
          sumArr[0] =
              "Deneme ${(j * getSelectedGroupSize)}-${(j * getSelectedGroupSize) + getSelectedGroupSize}";
        }
      }

      for (int k = 1; k < columnData.length; k++) {
        sumArr[k] = sumList[j][k];
      }
      rowData.add({'row': List.from(sumArr)});
    }

    if (compareLists(sumArr, totalSum) == false) {
      // print("sumAr $sumArr totalSum $totalSum");
      totalSum[0] = "Toplam";
      rowData.add({'row': List.from(totalSum)});
    }

    // print("rowData");
    // print(rowData);
    // print("rowData");
  }

  List<dynamic> sumAllLists(List<List<int>> inputList) {
    if (inputList.isEmpty) return [];

    List<dynamic> sumList = List.filled(columnData.length, 0);

    for (int i = 0; i < inputList.length; i++) {
      for (int j = 0; j < inputList[i].length; j++) {
        if (j < sumList.length) {
          sumList[j] += inputList[i][j];
        } else {
          sumList.add(inputList[i][j]);
        }
      }
    }

    return sumList;
  }

  List<dynamic> sumByGroups(List<List<int>> inputList, int groupSize) {
    List<List<int>> resultList = [];

    for (int i = 0; i < inputList.length; i += groupSize) {
      List<int> sumList = List.filled(inputList[i].length, 0);

      for (int j = i; j < i + groupSize && j < inputList.length; j++) {
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

  void initData(String? lessonName) async {
    setDenemestate = DenemeState.loading;
    _lessonTableName =
        LessonList.tableNames[lessonName] ?? LessonList.tableNames['Tarih'];
    //print("deneme less init table $_lessonTableName");

    listDeneme = await DenemeDbProvider.db.getLessonDeneme(_lessonTableName!);

    Future.delayed(const Duration(milliseconds: 200), () {
      setDenemestate = DenemeState.completed;
    });
  }

  bool compareLists(List<dynamic> list1, List<dynamic> list2) {
    if (list1.length != list2.length) {
      return false;
    }

    for (int i = 1; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }

    return true;
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

  int? extractNumber(String text) {
    String aStr = text.replaceAll(RegExp(r'[^0-9]'), '');
    int? result = 1;
    if (aStr.isNotEmpty) {
      result = int.parse(aStr);
    }

    return result;
  }

  int? _selectedGroupSize = 5;
  bool _isTotal = false;
  bool get getIsTotal => _isTotal;

  set setIsTotal(bool newTotal) {
    _isTotal = newTotal;
    notifyListeners();
  }

  int get getSelectedGroupSize => _selectedGroupSize ?? 5;

  set setSelectedGroupSize(int newSize) {
    _selectedGroupSize = newSize;
    notifyListeners();
  }

  bool get getIsAlertOpen => _isAlertOpen;

  set setAlert(bool newBool) {
    _isAlertOpen = newBool;
  }

  String? get getLessonName {
    return _lessonName ?? 'Tarih';
  }

  set setLessonName(String? newLesson) {
    _lessonName = newLesson!;
    notifyListeners();
  }

  String? get getInitPng {
    return _initPng ?? 'hs'; //null problems
  }

  set setInitPng(String? newPng) {
    _initPng = newPng ?? 'hs';
    notifyListeners();
  }

  String? get getLessonTableName =>
      _lessonTableName ?? DenemeTables.historyTableName;

  set setLessonTableName(String? newTable) {
    _lessonName = _lessonTableName =
        LessonList.tableNames[newTable] ?? DenemeTables.historyTableName;
    notifyListeners();
  }

  Future<void> removeAlert(BuildContext context, String title, String content,
      DenemeViewModel denemeProv, itemDeneme) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isAlert: false,
      noFunction: () => {
        denemeProv.setAlert = false,
        Navigator.of(context).pop(),
      },
      yesFunction: () async => {
        print("cell ${denemeProv.extractNumber(itemDeneme)}"),
        itemDeneme = denemeProv.extractNumber(itemDeneme),
        denemeProv.deleteItemById(
            denemeProv.getLessonTableName!, itemDeneme, 'denemeId'),
        denemeProv.setAlert = false,
        Navigator.of(context).pop(),
        Future.delayed(const Duration(milliseconds: 200), () {
          denemeProv.initData(denemeProv.getLessonName!);
        }),
      },
    );

    if (denemeProv.getIsAlertOpen == false) {
      denemeProv.setAlert = true;
      await showDialog(
          barrierDismissible: false,
          barrierColor: const Color(0x66000000),
          context: context,
          builder: (BuildContext context) {
            return alert;
          }).then(
        (value) => denemeProv.setAlert = false,
      );
    }
  }

  Future<void> sendMultiplePostsToFirebase(String userId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      List<DenemePostModel> postModels = [
        DenemePostModel(
          userId: userId,
          tableName: DenemeTables.historyTableName,
          tableData: await DenemeDbProvider.db
              .getLessonDeneme(DenemeTables.historyTableName),
        ),
        DenemePostModel(
          userId: userId,
          tableName: DenemeTables.cografyaTableName,
          tableData: await DenemeDbProvider.db
              .getLessonDeneme(DenemeTables.cografyaTableName),
        ),
        DenemePostModel(
          userId: userId,
          tableName: DenemeTables.vatandasTableName,
          tableData: await DenemeDbProvider.db
              .getLessonDeneme(DenemeTables.vatandasTableName),
        ),
      ];

      Map<String, dynamic> combinedData = {};

      for (var postModel in postModels) {
        combinedData[postModel.tableName] = {
          'userId': postModel.userId,
          'tableData': postModel.tableData,
        };
      }

      await firestore
          .collection('users')
          .doc(userId)
          .set({'denemePosts': combinedData}, SetOptions(merge: true));

      print('Veriler başarıyla gönderildi!');
    } catch (e) {
      print('Veri gönderirken hata oluştu: $e');
    }
  }

  Future<DenemePostModel> getTablesFromFirebase(String userId) async {
    var tables = await FirebaseService().getDataByUsers(userId);
    return tables;
  }

  Future<void> removeUserCollectionData(String userId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        await firestore.collection('users').doc(userId).delete();
        print('Kullanıcı verileri başarıyla silindi!');
      } else {
        print('Kullanıcı bulunamadı!');
      }
    } catch (e) {
      print('Kullanıcı verileri silinirken hata oluştu: $e');
    }
  }
}
