import 'package:flutter/material.dart';

class TabbarNavigationProvider with ChangeNotifier {
  int _examListTabIndex = 0;

  int _examTableTabIndex = 0;

  int _editExamTabIndex = 0;

  int _subjectsTabIndex = 0;

  int _lessonsTabIndex = 0;

  int get getLessonsTabIndex => _lessonsTabIndex;
  int get getSubjectTabIndex => _subjectsTabIndex;
  int get getExamListTabIndex => _examListTabIndex;
  int get getExamTableTabIndex => _examTableTabIndex;
  int get getEditExamTabIndex => _editExamTabIndex;

  set setLessonTab(int index) {
    _lessonsTabIndex = index;
    notifyListeners();
  }

  set setSubjectTab(int index) {
    _subjectsTabIndex = index;
    notifyListeners();
  }

  set setExamListIndex(int index) {
    _examListTabIndex = index;
    notifyListeners();
  }

  set setExamTableIndex(int index) {
    _examTableTabIndex = index;
    notifyListeners();
  }

  set setCurrentEditexam(int index) {
    _editExamTabIndex = index;
    notifyListeners();
  }
}
