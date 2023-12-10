import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/core/notifier/bottom_navigation_notifier.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';
import 'package:provider/single_child_widget.dart';
import 'package:provider/provider.dart';

class ApplicationProvider {
  static ApplicationProvider? _instance;
  static ApplicationProvider get instance {
    _instance ??= ApplicationProvider._init();
    return _instance!;
  }

  ApplicationProvider._init();
  List<SingleChildWidget> dependItems = [
    ChangeNotifierProvider(
      create: (context) => DenemeViewModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => BottomNavigationProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => TabbarNavigationProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => LessonViewModel(),
    ),
    Provider.value(value: NavigationService.instance)
  ];
}
