import 'package:flutter/material.dart';

class BottomNavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get getCurrentIndex => _currentIndex;

  set setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
