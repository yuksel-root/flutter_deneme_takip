// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/local_database/exam_db_provider.dart';
import 'package:flutter_deneme_takip/models/subject.dart';

enum SubjectState {
  empty,
  loading,
  completed,
  error,
}

class SubjectViewModel extends ChangeNotifier {
  late SubjectState _state;

  late List<SubjectModel>? _subjectData;
  late String _subjectName;
  late int? _lessonId;

  late GlobalKey<FormState> _updateFormK;
  late GlobalKey<FormState> _insertFormK;

  late TextEditingController _insertController;
  late List<TextEditingController> _updateController;

  bool _onEditText = false;
  late int _updateIndex;
  late int _clickIndex;

  final formKey0 = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();

  SubjectViewModel() {
    _subjectData = [];

    _insertController = TextEditingController();

    _updateController =
        List.generate(_subjectData!.length, (index) => TextEditingController());
    _updateFormK = formKey0;
    _insertFormK = formKey1;
    _updateIndex = 0;
    _clickIndex = 0;

    _state = SubjectState.empty;
    _subjectName = "";
    _lessonId = 1;

    initSubjectData(_lessonId);
  }

  List<SubjectModel> get getSubjectData {
    return _subjectData!.isEmpty ? [SubjectModel()] : _subjectData!;
  }

  void initSubjectData(int? lessonId) async {
    SubjectState.loading;
    print(lessonId);
    _subjectData = await ExamDbProvider.db.getAllSubject(lessonId ?? 1) ??
        [SubjectModel()];
    print(_subjectData![0].subjectName);
    SubjectState.completed;
  }

  SubjectState get state => _state;
  set state(SubjectState state) {
    _state = state;
    notifyListeners();
  }

  bool get getOnEditText => _onEditText;
  set setOnEditText(bool newB) {
    _onEditText = newB;
    notifyListeners();
  }

  String get getSubjectName => _subjectName;
  set setSubjectName(String newS) {
    _subjectName = newS;
    notifyListeners();
  }

  int? get getLessonId => _lessonId ?? 1;
  set setLessonId(int? newInt) {
    _lessonId = newInt;
    notifyListeners();
  }

  void removeSubject(int subjectId, int lessonId) {
    try {
      ExamDbProvider.db.removeSubjectByLesson(lessonId, subjectId);
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  set setUpdateFormKey(GlobalKey<FormState> formKey) {
    _updateFormK = formKey;
  }

  GlobalKey<FormState> get getUpdateKey {
    return _updateFormK;
  }

  void setUpdateController({int? index, String? initString}) {
    _updateController =
        List.generate(_subjectData!.length, (index) => TextEditingController());
    _updateController[index ?? 0] =
        TextEditingController(text: initString ?? "");
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
    final item = _subjectData!.removeAt(oldIndex);
    _subjectData!.insert(newIndex, item);
    notifyListeners();
  }
}
