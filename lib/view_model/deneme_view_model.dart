// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/app_data.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/models/deneme.dart';
import 'package:flutter_deneme_takip/services/auth_service.dart';
import 'package:flutter_deneme_takip/services/firebase_service.dart';
import 'package:flutter_deneme_takip/components/alert_dialog/alert_dialog.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/bottom_tabbar_view.dart';
import 'package:flutter_deneme_takip/view_model/deneme_login_view_model.dart';

enum DenemeState {
  empty,
  loading,
  completed,
  error,
}

enum FirebaseState {
  empty,
  start,
  completed,
  catchError,
}

class DenemeViewModel extends ChangeNotifier {
  late DenemeState? _state;
  late FirebaseState? _firebaseState;
  late NavigationService _navigation;

  FirebaseFirestore? firestore = FirebaseFirestore.instance;

  late String? _lessonName;
  late String? _lessonTableName;
  late bool _isAlertOpen;
  late List<Map<String, dynamic>>? listDeneme;
  late List<Map<String, dynamic>>? fakeData;
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
    _firebaseState = FirebaseState.empty;

    listDeneme = [];
    fakeData = [];
    _lessonTableName =
        AppData.tableNames[_lessonName] ?? AppData.tableNames['Tarih'];

    initDenemeData(_lessonName!);
    initFakeData(_lessonName!);

    _initPng =
        AppData.lessonPngList[_lessonName] ?? AppData.lessonPngList['Tarih'];
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

  FirebaseState get getFirebaseState => _firebaseState!;
  set setFirebaseState(FirebaseState state) {
    _firebaseState = state;
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
    return AppData.lessonListMap[lessonName] ?? [];
  }

  void initDenemeData(String? lessonName) async {
    setDenemestate = DenemeState.loading;
    _lessonTableName =
        AppData.tableNames[lessonName] ?? DenemeTables.historyTableName;

    listDeneme = await DenemeDbProvider.db.getAllDataByTable(_lessonTableName!);

    setDenemestate = DenemeState.completed;
  }

  void initFakeData(String? lessonName) async {
    setDenemestate = DenemeState.loading;
    _lessonTableName =
        AppData.tableNames[lessonName] ?? DenemeTables.historyTableName;

    fakeData = await DenemeDbProvider.db.getAllDataByTable(_lessonTableName!);

    setDenemestate = DenemeState.completed;
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
    print(await DenemeDbProvider.db.getAllDataByTable(dataTable));
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
        AppData.tableNames[newTable] ?? DenemeTables.historyTableName;
    notifyListeners();
  }

  Future<void> removeAlert(BuildContext context, String title, String content,
      DenemeViewModel denemeProv, itemDeneme) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isOneButton: false,
      noFunction: () => {
        denemeProv.setAlert = false,
        Navigator.of(context, rootNavigator: true).pop(),
      },
      yesFunction: () async => {
        print("cell ${denemeProv.extractNumber(itemDeneme)}"),
        itemDeneme = denemeProv.extractNumber(itemDeneme),
        denemeProv.deleteItemById(
            denemeProv.getLessonTableName!, itemDeneme, 'denemeId'),
        denemeProv.setAlert = false,
        Navigator.of(context, rootNavigator: true).pop(),
        Future.delayed(const Duration(milliseconds: 50), () {
          denemeProv.initDenemeData(denemeProv.getLessonName);
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

  Future<void> deleteUserInFirebase(BuildContext context, String userId,
      DenemeViewModel denemeProv, DenemeLoginViewModel loginProv) async {
    try {
      final isOnline = await FirebaseService().isFromCache(userId);
      if (isOnline!.isEmpty) {
        Future.delayed(Duration.zero, () {
          navigation.navigateToPage(path: NavigationConstants.homeView);
          errorAlert(context, "Uyarı",
              "İnternet bağlantısı olduğuna emin olunuz!", denemeProv);
        });
      } else {
        FirebaseService().deleteUserFromCollection(userId).then((value) async {
          await Future.delayed(const Duration(milliseconds: 100), () async {
            await AuthService().signOut();
            loginProv.setAnonymousLogin = false;
            loginProv.setState = LoginState.notLoggedIn;
            loginProv.setCurrentUser = null;
          });
        });
      }
    } catch (e) {
      print("Delete USer DMV $e");
    }
  }

  Future<void> backUpAllTablesData(
      BuildContext context, String userId, DenemeViewModel denemeProv) async {
    try {
      final isOnline = await FirebaseService().isFromCache(userId);
      if (isOnline == null) {
        Future.delayed(Duration.zero, () {
          navigation.navigateToPage(path: NavigationConstants.homeView);
          denemeProv.errorAlert(context, "Uyarı",
              "İnternet bağlantısı olduğuna emin olunuz!", denemeProv);
        });
      } else {
        await FirebaseService().sendMultiplePostsToFirebase(userId);
        Future.delayed(Duration.zero, () {
          navigation.navigateToPage(path: NavigationConstants.homeView);
          denemeProv.errorAlert(
              context, "Bilgi", "Veriler başarıyla yedeklendi!", denemeProv);
        });
      }
    } catch (e) {
      print("catch denemeVM  CATCH ERROR ${e.toString()}");
    }
  }

  Future<Map<String, List<dynamic>>?> getTablesFromFirebase(
      String userId) async {
    final tables = await FirebaseService().getPostDataByUser(userId);
    if (tables != null) {
      return tables;
    }
    return null;
  }

  Future<void> sendFirebaseToSqlite(
      Map<String, List<dynamic>>? denemeData) async {
    await DenemeDbProvider.db.inserAllDenemeData(denemeData);
  }

  Future<void> removeUserPostData(
      String userId, BuildContext context, DenemeViewModel denemeProv) async {
    try {
      final isOnline = await FirebaseService().isFromCache(userId);
      if (isOnline!.isEmpty) {
        Future.delayed(Duration.zero, () {
          navigation.navigateToPage(path: NavigationConstants.homeView);
          denemeProv.errorAlert(context, "Uyarı",
              "İnternet bağlantısı olduğuna emin olunuz!", denemeProv);
        });
      } else {
        await FirebaseService().removeUserPostData(userId);
      }
    } catch (e) {
      print("REMOVE USER CATCH DMV $e");
    }
  }

  Future<void> errorAlert(BuildContext context, String title, String content,
      DenemeViewModel denemeProv) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isOneButton: true,
      noFunction: () => {
        denemeProv.setAlert = false,
        Navigator.of(context, rootNavigator: true)
            .pushNamed(NavigationConstants.homeView),
      },
      yesFunction: () async => {
        denemeProv.setAlert = false,
        Navigator.of(context, rootNavigator: true)
            .pushNamed(NavigationConstants.homeView),
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
