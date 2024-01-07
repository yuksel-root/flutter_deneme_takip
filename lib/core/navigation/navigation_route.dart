import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/bottom_tabbar_view.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view/user_login.dart';

class NavigationRoute {
  static final NavigationRoute _instance = NavigationRoute._init();
  static NavigationRoute get instance => _instance;

  NavigationRoute._init();

  Route<dynamic> generateRoute(RouteSettings? settings) {
    switch (settings?.name) {
      case NavigationConstants.homeView:
        return pageNavigate(const BottomTabbarView(), settings!);
      case NavigationConstants.loginView:
        return pageNavigate(const UserLoginView(), settings!);
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
