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
  }
}
