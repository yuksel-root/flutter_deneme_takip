// ignore_for_file: avoid_print
import 'package:flutter/material.dart';

import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/core/local_database/exam_db_provider.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/models/exam_detail.dart';
import 'package:flutter_deneme_takip/services/firebase_service.dart';
import 'package:flutter_deneme_takip/components/alert_dialog/alert_dialog.dart';
import 'package:flutter_deneme_takip/view_model/exam_list_view_model.dart';
import 'package:flutter_deneme_takip/view_model/login_view_model.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

enum ExamState {
  empty,
  loading,
  completed,
  error,
}

enum FirebaseState {
  empty,
  loading,
  completed,
  catchError,
}

class ExamTableViewModel extends ChangeNotifier {
  late ExamState? _state;
  late FirebaseState? _firebaseState;
  late NavigationService _navigation;

  late String? _lessonName;

  late bool _isAlertOpen;
  late List<Map<String, dynamic>>? listexam;
  late List<Map<String, dynamic>>? fakeData;
  late List<dynamic> rowData;
  late List<dynamic> columnData;
  late List<Map<String, dynamic>> examlerData;
  late List<List<int>> _listFalseCounts;

  late bool _isOnline;
  final NavigationService navigation = NavigationService.instance;

  late double _subContainerHeight;
  late double _subContainerWidth;

  final double subContainerDEFH = 100;
  final double subContainerDEFW = 200;
  final List<double> listContHeights = [];

  ExamTableViewModel() {
    _navigation = NavigationService.instance;

    _isAlertOpen = false;
    _isOnline = false;
    _lessonName = 'TarihY';
    _state = ExamState.empty;
    _firebaseState = FirebaseState.empty;

    listexam = [];
    fakeData = [];

    initExamData(_lessonName!);
    initFakeData();

    columnData = List.of(findList(_lessonName ?? 'TarihY'));

    rowData = [];
    examlerData = [];
    _listFalseCounts = [];
  }

  ExamState get getexamState => _state!;
  set setexamstate(ExamState state) {
    _state = state;
    notifyListeners();
  }

  FirebaseState get getFirebaseState => _firebaseState!;
  set setFirebaseState(FirebaseState state) {
    _firebaseState = state;
    notifyListeners();
  }

  List<Map<String, dynamic>> filterByexamId(List<Map<String, dynamic>> data) {
    Map<int, List<Map<String, dynamic>>> groupedData = {};
    List<Map<String, dynamic>> group = [];

    group.clear();
    groupedData.clear();
    examlerData.clear();
    for (var item in data) {
      final examId = item['examId'] as int;
      if (!groupedData.containsKey(examId)) {
        groupedData[examId] = [];
      }
      groupedData[examId]!.add(item);
    }

    group.addAll(groupedData.values.expand((items) => items));

    return group;
  }

  void convertToRow(List<Map<String, dynamic>> data) async {
    Map<int, List<Map<String, dynamic>>> idToRowMap = {};

    for (var item in filterByexamId(data)) {
      int id = item['id'];
      if (idToRowMap[id] == null) {
        idToRowMap[id] = [];
      }
      idToRowMap[id]!.add(item);
    }

    for (var entry in idToRowMap.entries) {
      Map<String, dynamic> rowItem = {"row": entry.value};
      examlerData.add(rowItem);
    }

    //print('examlerData');
    //print(examlerData);
    // print('examlerData');
  }

  Map<int, List<int>> falseCountsByexamId(
      List<Map<String, dynamic>> examlerData) {
    Map<int, List<int>> falseCountsByexamId = {};

    for (var item in examlerData) {
      var row = item['row'] as List<dynamic>;
      if (row.isNotEmpty) {
        var examId = row[0]['examId'] as int;
        var falseCount = row[0]['falseCount'] as int;

        if (!falseCountsByexamId.containsKey(examId)) {
          falseCountsByexamId[examId] = [];
        }

        falseCountsByexamId[examId]!.add(falseCount);
      }
    }
    return falseCountsByexamId;
  }

  void insertRowData(List<Map<String, dynamic>> examlerData) {
    rowData.clear();
    _listFalseCounts.clear();

    falseCountsByexamId(examlerData).forEach((examId, falseCounts) {
      List<dynamic> arr =
          List.from(List.generate(columnData.length, (index) => 0));

      for (int j = 0; j < (columnData.length); j++) {
        arr[0] = "exam\n $examId";
        arr[j] = falseCounts[j];
      }

      rowData.add({'row': List.from(arr)});

      arr.clear();
    });

    rowData.sort((a, b) {
      String aTitle = a['row'][0].toString();
      String bTitle = b['row'][0].toString();

      int aNumber = int.parse(aTitle.replaceAll("exam", ""));
      int bNumber = int.parse(bTitle.replaceAll("exam", ""));

      return aNumber.compareTo(bNumber);
    });
  }

  void totalInsertRowData(List<Map<String, dynamic>> examData) {
    rowData.clear();
    _listFalseCounts.clear();

    falseCountsByexamId(examData).forEach((examId, falseCounts) {
      _listFalseCounts.add(falseCounts);
    });

    List<dynamic> sumList =
        List.from(sumByGroups(_listFalseCounts, getSelectedGroupSize));
    List<dynamic> sumArr = List.generate(columnData.length, (index) => 0);
    List<dynamic> totalSum = List.of(sumAllLists(_listFalseCounts));

    for (int j = 0; j < sumList.length; j++) {
      if (j == 0) {
        sumArr[0] = "exam 1-$getSelectedGroupSize";
      } else {
        if (getSelectedGroupSize == 5) {
          sumArr[0] = "exam ${(j * 5) + 1}-${(j * 5) + 5}";
        } else {
          sumArr[0] =
              "exam ${(j * getSelectedGroupSize)}-${(j * getSelectedGroupSize) + getSelectedGroupSize}";
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

    List<dynamic> sumList = List.from(List.filled(columnData.length, 0));

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
    return []; // AppData.lessonListMap[lessonName] ?? [];
  }

  void initExamData(String? lessonName) async {
    setexamstate = ExamState.loading;
    //_lessonTableName = AppData.tableNames[lessonName];

    listexam =
        []; // await ExamDbProvider.db.getAllDataByTable(_lessonTableName!);

    setexamstate = ExamState.completed;
  }

  void initFakeData() async {
    setexamstate = ExamState.loading;

    fakeData = [];

    setexamstate = ExamState.completed;
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

  void saveexam(ExamDetailModel exam, String lessonTable) {
    try {
      //  ExamDbProvider.db.insertexam(exam, lessonTable);
    } catch (e) {
      printFunct("saveexam error", e);
    }
    notifyListeners();
  }

  void deleteItemById(String lessonTable, int id, String idName) {
    try {
      ExamDbProvider.db.removeTableItem(lessonTable, id, idName);
    } catch (e) {
      printFunct("deleteexam error", e);
    }
    notifyListeners();
  }

  Future<void> getAllData(String dataTable) async {
    print("-------------$dataTable------------\n");
    print(await ExamDbProvider.db.getAllDataByTable(dataTable));
    print("-------------$dataTable------------\n");
  }

  void printFunct(String label, Object? data) {
    print("----------- $label --------------");
    print(data);
    print("----------- $label --------------");
  }

  Future<int?> getLastId(String table, String id) async {
    return await ExamDbProvider.db.getFindLastId(table, id);
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

  bool get getOnline => _isOnline;

  set setOnline(bool newBool) {
    _isOnline = newBool;
    notifyListeners();
  }

  double get getSubjectContainerHSize => _subContainerHeight;

  set setSubjectContainerHSize(double newD) {
    _subContainerHeight = newD;
  }

  double get getSubjectContainerWSize => _subContainerWidth;

  set setSubjectContainerWSize(double newD) {
    _subContainerWidth = newD;
    notifyListeners();
  }

  Future<void> removeAlert(BuildContext context, String title, String content,
      ExamTableViewModel examProv, itemexam) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isOneButton: false,
      noFunction: () => {
        examProv.setAlert = false,
        Navigator.of(context, rootNavigator: true).pop(),
      },
      yesFunction: () async => {
        print("cell ${examProv.extractNumber(itemexam)}"),
        itemexam = examProv.extractNumber(itemexam),
        //  examProv.deleteItemById(
        //       examProv.getLessonTableName!, itemexam, 'examId'),
        examProv.setAlert = false,
        Navigator.of(context, rootNavigator: true).pop(),
        Future.delayed(const Duration(milliseconds: 50), () {
          //   examProv.initExamData(examProv.getLessonName);
        }),
      },
    );

    if (examProv.getIsAlertOpen == false) {
      examProv.setAlert = true;
      await showDialog(
          barrierDismissible: false,
          barrierColor: const Color(0x66000000),
          context: context,
          builder: (BuildContext context) {
            return alert;
          }).then(
        (value) => examProv.setAlert = false,
      );
    }
  }

  Future<void> deleteUserInFirebase(BuildContext context, String userId,
      ExamTableViewModel examProv, LoginViewModel loginProv) async {
    try {
      await FirebaseService()
          .deleteUserFromCollection(userId)
          .then((value) async {
        await Future.delayed(const Duration(milliseconds: 100), () async {
          loginProv.setState = LoginState.notLoggedIn;
          loginProv.setCurrentUser = null;
        });
      });
    } catch (e) {
      print("Delete USer DMV $e");
    }
  }

  Future<void> backUpAllTablesData(BuildContext context, String userId,
      ExamTableViewModel examProv, LoginViewModel loginProv) async {
    try {
      final isOnline = await FirebaseService().isFromCache(userId) ?? {};

      if (isOnline.isEmpty) {
        Future.delayed(Duration.zero, () {
          navigation.navigateToPage(path: NavigationConstants.homeView);

          examProv.errorAlert(context, "Uyarı",
              "İnternet bağlantısı olduğuna emin olunuz!", examProv);
        });
        examProv.setAlert = false;
      } else {
        await FirebaseService().sendMultiplePostsToFirebase(userId);

        Future.delayed(Duration.zero, () {
          examProv.setFirebaseState = FirebaseState.completed;
          examProv.errorAlert(
              context, "Bilgi", "Veriler başarıyla yedeklendi!", examProv);
          examProv.setAlert = false;
        });
      }
    } catch (e) {
      print("catch examVM  CATCH ERROR ${e.toString()}");
      setFirebaseState = FirebaseState.catchError;
    }
  }

  void isOnline(String userId) async {
    try {
      final isOnline = await FirebaseService().isFromCache(userId) ?? {};
      if (isOnline.isEmpty) {
        setOnline = false;
      } else {
        setOnline = true;
      }
    } catch (e) {
      print(e);
      setOnline = false;
    }
  }

  Future<void> restoreData(BuildContext context, String userId,
      ExamTableViewModel examProv, ExamListViewModel lessonProv) async {
    try {
      final isOnline = await FirebaseService().isFromCache(userId) ?? {};
      final examPostData = await examProv.getTablesFromFirebase(userId) ?? {};

      if (isOnline.isEmpty) {
        Future.delayed(Duration.zero, () {
          examProv.setAlert = false;
          Navigator.of(context, rootNavigator: true)
              .pushNamed(NavigationConstants.homeView);
          examProv.errorAlert(
              context, "Uyarı", "İnternet olduğundan emin olunuz!", examProv);
          examProv.setAlert = false;
        });
      } else {
        await ExamDbProvider.db.clearDatabase();
        await examProv.sendFirebaseToSqlite(examPostData).then((value) {
          //lessonProv.initExamListData(lessonProv.getLessonName);
          //   examProv.initExamData(examProv.getLessonName);
          Navigator.of(context, rootNavigator: true)
              .pushNamed(NavigationConstants.homeView);
          setFirebaseState = FirebaseState.completed;
        });
      }
    } catch (e) {
      print(e);
      setFirebaseState = FirebaseState.catchError;
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
      Map<String, List<dynamic>>? examData) async {
    //await ExamDbProvider.db.inserAllexamData(examData);
  }

  Future<void> removeUserPostData(
      String userId, BuildContext context, ExamTableViewModel examProv) async {
    try {
      final examPostData = await examProv.getTablesFromFirebase(userId) ?? {};
      if (examPostData.isEmpty) {
        Future.delayed(Duration.zero, () {
          navigation.navigateToPage(path: NavigationConstants.homeView);
          examProv.errorAlert(context, "Uyarı",
              "İnternet bağlantısı olduğuna emin olunuz!", examProv);
        });
        examProv.setAlert = false;
      } else {
        await FirebaseService().removeUserPostData(userId);
      }
    } catch (e) {
      print("REMOVE USER CATCH DMV $e");
    }
  }

  Future<void> errorAlert(BuildContext context, String title, String content,
      ExamTableViewModel examProv) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isOneButton: true,
      noFunction: () => {
        Future.delayed(Duration.zero, () {
          Navigator.of(context, rootNavigator: true)
              .pushNamed(NavigationConstants.homeView);
        }),
        examProv.setAlert = false,
      },
      yesFunction: () async => {
        Future.delayed(Duration.zero, () {
          Navigator.of(context, rootNavigator: true)
              .pushNamed(NavigationConstants.homeView);
        }),
        examProv.setAlert = false
      },
    );
    print("err alert ${examProv.getIsAlertOpen}");
    if (examProv.getIsAlertOpen == false) {
      examProv.setAlert = true;
      await showDialog(
          barrierDismissible: false,
          barrierColor: const Color(0x66000000),
          context: context,
          builder: (BuildContext context) {
            return alert;
          }).then(
        (value) => examProv.setAlert = false,
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

  Future<void> generateAndSaveImage() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    // Output.png dosyasının tam yolu
    String filePath = '$appDocPath/output.png';

    // Resmi oluştur
    ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas canvas = ui.Canvas(
        recorder,
        ui.Rect.fromPoints(
            const ui.Offset(0.0, 0.0), const ui.Offset(200.0, 200.0)));

    // Resmi çiz
    Paint paint = Paint()..color = Colors.blue; // Resmin arka plan rengi
    canvas.drawRect(
        Rect.fromPoints(const Offset(0.0, 0.0), const Offset(200.0, 200.0)),
        paint);

    drawText(canvas, "Merhaba, Flutter!", 20.0,
        100.0); // Metni ekleyerek resmi özelleştir

    ui.Picture picture = recorder.endRecording();

    // Resmi PNG formatına dönüştür
    ui.Image img = await picture.toImage(200, 200);
    ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    // ByteData'ı dosyaya kaydet
    List<int> pngBytes = byteData!.buffer.asUint8List();
    await File(filePath).writeAsBytes(pngBytes);

    print('Resim başarıyla oluşturuldu: $filePath');
  }

  void drawText(ui.Canvas canvas, String text, double x, double y) {
    final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.left,
        fontSize: 16.0,
        textDirection: TextDirection.ltr,
      ),
    )
      ..pushStyle(ui.TextStyle(color: Colors.white))
      ..addText(text);

    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(const ui.ParagraphConstraints(width: 200.0));

    canvas.drawParagraph(paragraph, Offset(x, y));
  }

  void accessSavedImage() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    // Erişmek istediğiniz dosyanın adı
    String fileName = 'output.png';

    // Dosyanın tam yolu
    String filePath = '$appDocPath/$fileName';

    // Şimdi bu dosyayı okuyabilir veya işleyebilirsiniz
    File file = File(filePath);

    if (await file.exists()) {
      // Dosya mevcutsa işlemlerinizi gerçekleştirin
      print('Dosya mevcut: $filePath');
    } else {
      print('Dosya bulunamadı: $filePath');
    }
  }
}
