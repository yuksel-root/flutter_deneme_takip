// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/models/deneme.dart';

enum DenemeState {
  empty,
  loading,
  completed,
  error,
}

class DenemeViewModel extends ChangeNotifier {
  late NavigationService _navigation;

  DenemeViewModel() {
    _navigation = NavigationService.instance;
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
}
