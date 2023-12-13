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
    print("Save");
    print(deneme);
    print("Save");
    try {
      DenemeDbProvider.db.addNewDeneme(deneme, lessonTable);
    } catch (e) {
      print("Save deneme Error");
      print(e);
      print("Save deneme Error");
    }
    notifyListeners();
  }

  void deleteDeneme(String lessonTable, int id, String idName) {
    try {
      DenemeDbProvider.db.deleteTableItem(lessonTable, id, idName);
    } catch (e) {
      print("Delete deneme error");
      print(e);
      print("Delete deneme error");
    }
    notifyListeners();
  }

  Future<void> getAllData(String dataTable) async {
    print("-------------$dataTable------------\n");
    print(await DenemeDbProvider.db.getDeneme(dataTable));
    print("-------------$dataTable------------\n");
  }

  void printFunct(String label, Object? data) {
    print("----------- $label --------------");
    print(data);
    print("----------- $label --------------");
  }
}
