import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/view/bottom_tabbar_view.dart';
import 'package:flutter_deneme_takip/view/lesson_views/tarih_view.dart';

class NavigationRoute {
  static final NavigationRoute _instance = NavigationRoute._init();
  static NavigationRoute get instance => _instance;

  NavigationRoute._init();

  Route<dynamic> generateRoute(RouteSettings? settings) {
    switch (settings?.name) {
      case NavigationConstants.homeView:
        return pageNavigate(BottomTabbarView(), settings!);

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
