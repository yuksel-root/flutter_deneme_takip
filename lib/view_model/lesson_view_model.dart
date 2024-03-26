// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/app_data.dart';
import 'package:flutter_deneme_takip/core/local_database/exam_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/sql_tables.dart';
import 'package:flutter_deneme_takip/models/lesson.dart';

enum LessonState {
  empty,
  loading,
  completed,
  error,
}

class LessonViewModel extends ChangeNotifier {
  late LessonState? _state;

  late String? _lessonName;
  late List<LessonModel>? _lessonData;

  late GlobalKey<FormState> _updateFormK;
  late GlobalKey<FormState> _insertFormK;

  late TextEditingController _insertController;
  late List<TextEditingController> _updateController;

  bool _onEditText = false;
  late int _updateIndex;
  late int _clickIndex;

  final formKey0 = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();

  final List<bool> _checkedList =
      List.generate(AppData.examNames.length, (index) => false);

  LessonViewModel() {
    _state = LessonState.empty;

    _lessonName = null;
    _lessonData = [LessonModel()];

    _insertController = TextEditingController();
    _updateController =
        List.generate(_lessonData!.length, (index) => TextEditingController());

    _updateFormK = formKey0;
    _insertFormK = formKey1;
    _updateIndex = 0;
    _clickIndex = 0;

    initLessonData();
  }

  Future<void> initLessonData() async {
    state = LessonState.loading;
    _lessonData = await ExamDbProvider.db.getAllLessonData() ?? [LessonModel()];

    state = LessonState.completed;
  }

  LessonState get state => _state!;
  set state(LessonState state) {
    _state = state;
    notifyListeners();
  }

  bool get getOnEditText => _onEditText;
  set setOnEditText(bool newB) {
    _onEditText = newB;
    notifyListeners();
  }

  List<LessonModel> get getLessonData =>
      _lessonData!.isEmpty ? [LessonModel()] : _lessonData!;

  void removeLesson(int lessonId) async {
    await ExamDbProvider.db
        .removeTableItem(SqlTables.lessonsTable, lessonId, "lesson_id");

    await ExamDbProvider.db.removeAllSubjectsByLesson(lessonId);

    initLessonData();

    notifyListeners();
  }

  String? get getLessonName {
    return _lessonName ?? "nullName";
  }

  set setLessonname(String? newLesson) {
    _lessonName = newLesson!;

    notifyListeners();
  }

  set setUpdateFormKey(GlobalKey<FormState> formKey) {
    _updateFormK = formKey;
  }

  GlobalKey<FormState> get getUpdateKey {
    return _updateFormK;
  }

  void setUpdateController({required int index, required String initString}) {
    _updateController =
        List.generate(_lessonData!.length, (index) => TextEditingController());
    _updateController[index] = TextEditingController(text: initString);
  }

  List<TextEditingController> get getUpdateController {
    return _updateController;
  }

  void setUpdateIndex(int index) {
    _updateIndex = index;
  }

  int get getUpdateIndex {
    return _updateIndex;
  }

  void setClickIndex(int index) {
    _clickIndex = index;
    notifyListeners();
  }

  int get getClickIndex {
    return _clickIndex;
  }

  void setInsertController() {
    _insertController = TextEditingController();

    notifyListeners();
  }

  TextEditingController get getInsertController {
    return _insertController;
  }

  set setInsertKey(GlobalKey<FormState> formKey) {
    _insertFormK = formKey;
  }

  GlobalKey<FormState> get getInsertKey {
    return _insertFormK;
  }

  void updateItems(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final newData = getLessonData[newIndex];
    final oldData = getLessonData[oldIndex];

    ExamDbProvider.db.updateLesson(
      lessonId: oldData.lessonId!,
      lessonName: oldData.lessonName!,
      lessonIndex: newData.lessonIndex!,
    );

    ExamDbProvider.db.updateLesson(
      lessonId: newData.lessonId!,
      lessonName: newData.lessonName!,
      lessonIndex: oldData.lessonIndex!,
    );

    notifyListeners();
  }

  List<bool> get getCheckList => _checkedList;
  void checkedItemChange(int index, bool value) {
    _checkedList[index] = value;
    notifyListeners();
  }
}
