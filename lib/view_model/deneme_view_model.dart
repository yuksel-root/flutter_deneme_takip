import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';

//-- HomeState Variables -- //
enum HomeState {
  empty,
  loading,
  completed,
  error,
}

class DenemeViewModel extends ChangeNotifier {
  late NavigationService _navigation;
  List<dynamic> tarihDeneme = LessonList.denemeTarih;

  DenemeViewModel() {
    _navigation = NavigationService.instance;
  }

  void navigateToPageClear(
    String path,
    Object? data,
  ) {
    _navigation.navigateToPageClear(path: path, data: data);
  }
}
