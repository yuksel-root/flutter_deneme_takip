import 'package:flutter/material.dart';

import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/view/bottom_tabbar_views/image_view.dart';
import 'package:flutter_deneme_takip/view/app_settings.dart';

import 'package:flutter_deneme_takip/view/tabbar_views/bottom_tabbar_view.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/exam_edit_tabbar.dart';

class NavigationRoute {
  static final NavigationRoute _instance = NavigationRoute._init();
  static NavigationRoute get instance => _instance;

  NavigationRoute._init();

  Route<dynamic> generateRoute(RouteSettings? settings) {
    switch (settings?.name) {
      case NavigationConstants.homeView:
        return pageNavigate(const BottomTabbarView(), settings!);

      case NavigationConstants.insertExam:
        return pageNavigate(const ExamEditTabbarView(), settings!);
      case NavigationConstants.settingsView:
        return pageNavigate(const AppSettings(), settings!);
      case NavigationConstants.imageView:
        return pageNavigate(const ImageView(), settings!);

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('Route is  not Found',
                  style: TextStyle(
                    fontSize: context.dynamicW(0.01) * context.dynamicH(0.005),
                  )),
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
