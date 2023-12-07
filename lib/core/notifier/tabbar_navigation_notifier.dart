import 'package:flutter/material.dart';

class TabbarNavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int _currentDenemeIndex = 0;

  int get getLessonCurrentIndex => _currentIndex;

  set setLessonCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  int get getCurrentDenemeIndex => _currentDenemeIndex;

  set setCurrentDenemeIndex(int index) {
    _currentDenemeIndex = index;
    notifyListeners();
  }
}
