// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/models/deneme.dart';
import 'package:intl/intl.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/components/alert_dialog.dart';

enum EditDenemeState {
  empty,
  loading,
  completed,
  error,
}

class EditDenemeViewModel extends ChangeNotifier {
  late NavigationService _navigation;
  final DateTime _now = DateTime.now();
  late EditDenemeState _state;

  late bool _isDiffZero;
  late bool _isLoading;
  late bool _isAlertOpen;

  late String? _lessonName;
  late int? _lastSubjectId;
  late int? _lastDenemeId;
  late String _date;

  late List<String>? _subjectList;
  List<String?> _subjectSavedList = [];
  late List<TextEditingController> _falseCountControllers;
  late int? _falseInputCount;
  List<int?> _falseCountsIntegers = [];

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final formKey0 = GlobalKey<FormState>();

  EditDenemeViewModel() {
    _falseCountsIntegers.clear();
    _subjectSavedList.clear();

    _navigation = NavigationService.instance;
    _state = EditDenemeState.loading;
    _date =
        DateFormat('HH:mm:ss | d MMMM EEEE', 'tr_TR').format(_now).toString();

    _isLoading = true;
    _isDiffZero = false;
    _isAlertOpen = false;

    _lessonName = 'Tarih';
    _subjectList = LessonList.historySubjects;
    _falseInputCount = _subjectList!.length;
    _formKey = formKey0;

    _lastSubjectId = 0;
    _lastDenemeId = 0;

    _falseCountsIntegers = List.generate(_falseInputCount!, (index) => 0);
    _subjectSavedList = List.of(findList(_lessonName!));
    _falseCountControllers = List.generate(_falseCountsIntegers.length,
        (index) => TextEditingController(text: '0'));
  }

  EditDenemeState get getState => _state;
  set setState(EditDenemeState state) {
    _state = state;
    notifyListeners();
  }

  List<String> findList(String lessonName) {
    return LessonList.lessonListMap[lessonName] ?? [];
  }

  set setLessonName(String newLesson) {
    _lessonName = newLesson;
    notifyListeners();
  }

  String get getLessonName {
    return _lessonName ?? 'Tarih';
  }

  set setFormKey(GlobalKey<FormState> newKey) {
    _formKey = newKey;
  }

  GlobalKey<FormState> get getFormKey {
    return _formKey;
  }

  set setIsDiffZero(bool newBool) {
    _isDiffZero = newBool;
    notifyListeners();
  }

  bool get getIsDiffZero {
    return _isDiffZero;
  }

  set setLoading(bool newBool) {
    _isLoading = newBool;
    //notifyListeners();
  }

  bool get getIsLoading {
    return _isLoading;
  }

  set setSubjectList(List<String>? newSubjects) {
    _subjectList = newSubjects ?? LessonList.subjectListNames['Tarih'];
  }

  List<String> get getSubjectList {
    return _subjectList ?? [];
  }

  set setFalseCountsIntegers(List<int?>? newFalseCount) {
    _falseCountsIntegers =
        newFalseCount ?? List.generate(_falseInputCount!, (index) => 0);
    notifyListeners();
  }

  List<int?>? get getFalseCountsIntegers {
    return _falseCountsIntegers;
  }

  set setFalseControllers(int controllerCount) {
    _falseCountControllers = List.generate(
        controllerCount, (index) => TextEditingController(text: "0"));
    notifyListeners();
  }

  List<TextEditingController> get getFalseControllers {
    return _falseCountControllers;
  }

  int getFindDenemeId(List<int> existingIds, int latestId) {
    int lastId = 1;
    final int latest = latestId;
    List<int> existingId = existingIds;
    Set<int> existingIdSet = Set.from(existingId);

    for (int i = 1; i <= latest; i++) {
      if (!existingIdSet.contains(i)) {
        lastId = i;
        _lastDenemeId = lastId;
        return lastId;
      } else {
        lastId = (latest) + 1;
      }
    }
    return lastId;
  }

  Future<void> saveButton(BuildContext context) async {
    DateTime now = DateTime.now();

    _date =
        DateFormat('HH:mm:ss | d MMMM EEEE', 'tr_TR').format(now).toString();

    _subjectSavedList = getSubjectList;
    _lastSubjectId = await DenemeDbProvider.db
        .getFindLastId(LessonList.tableNames[_lessonName]!, "subjectId");
    List<int> existingIds = await DenemeDbProvider.db
        .getAllDenemeIds(LessonList.tableNames[_lessonName]!);
    int latestId = await DenemeDbProvider.db
            .getFindLastId(LessonList.tableNames[_lessonName]!, "denemeId") ??
        0;
    int k = 1;

    //printFunct("falseCounters", _falseCountsIntegers);
    //printFunct("subjectSavedList", _subjectSavedList);

    _lastDenemeId = getFindDenemeId(existingIds, latestId);
    for (int i = 0; i < _falseCountsIntegers.length; i++) {
      DenemeModel denemeModel = DenemeModel(
          denemeId: _lastDenemeId,
          subjectId: (_lastSubjectId ?? 0) + k,
          falseCount: _falseCountsIntegers[i],
          denemeDate: _date,
          subjectName: _subjectSavedList[i]);

      saveDeneme(denemeModel);
      Future.delayed(const Duration(milliseconds: 200), () async {
        setLoading = false;
        _navigation
            .navigateToPageClear(path: NavigationConstants.homeView, data: []);
      });

      //print(bottomProv.getCurrentIndex);

      k++;
    }
  }

  void saveDeneme(DenemeModel deneme) {
    try {
      DenemeDbProvider.db
          .insertDeneme(deneme, LessonList.tableNames[_lessonName]!);
    } catch (e) {
      printFunct("saveDeneme error", e);
    }
    notifyListeners();
  }

  bool get getIsAlertOpen => _isAlertOpen;

  set setAlert(bool newBool) {
    _isAlertOpen = newBool;
  }

  Future<dynamic> buildLoadingAlert(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: AlertDialog(
                  backgroundColor: Colors.white,
                  alignment: Alignment.center,
                  actions: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(context.dynamicH(0.0714)),
                            child: Transform.scale(
                              scale: 2,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                  strokeWidth: 5,
                                  strokeCap: StrokeCap.round,
                                  value: null,
                                  backgroundColor: Colors.blueGrey,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green),
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height: context.mediaQuery.size.height / 500),
                          Center(
                              child: Text(
                                  style: TextStyle(
                                      color: const Color(0xff1c0f45),
                                      fontSize: context.dynamicW(0.01) *
                                          context.dynamicH(0.005)),
                                  textAlign: TextAlign.center,
                                  ' Kaydediliyor...')),
                        ],
                      ),
                    ),
                  ]),
            ),
          );
        });
  }

  Future<void> errorAlert(
      BuildContext context, String title, String content) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isOneButton: true,
      noFunction: () =>
          {setAlert = false, Navigator.of(context, rootNavigator: true).pop()},
      yesFunction: () =>
          {setAlert = false, Navigator.of(context, rootNavigator: true).pop()},
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
}
