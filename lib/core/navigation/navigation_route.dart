import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/view/deneme_view.dart';
import 'package:flutter_deneme_takip/view/lesson_view.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/bottom_tabbar_view.dart';

class NavigationRoute {
  static final NavigationRoute _instance = NavigationRoute._init();
  static NavigationRoute get instance => _instance;

  NavigationRoute._init();

  Route<dynamic> generateRoute(RouteSettings? settings) {
    switch (settings?.name) {
      case NavigationConstants.homeView:
        return pageNavigate(const BottomTabbarView(), settings!);
      case NavigationConstants.lessonView:
        return pageNavigate(const LessonView(), settings!);
      case NavigationConstants.denemeView:
        return pageNavigate(const DenemeView(), settings!);
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Route is  not Found'),
            ),
          ),
          settings: settings,
        );
    }
  }

  static MaterialPageRoute pageNavigate(
          Widget widget, RouteSettings? settings) =>
      MaterialPageRoute(
        builder: (context) => widget,
        settings: settings,
      );
}
