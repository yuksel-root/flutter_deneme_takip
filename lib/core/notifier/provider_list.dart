import 'package:flutter_deneme_takip/components/custom_painter/custom_painter.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/core/notifier/bottom_navigation_notifier.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/view_model/exam_table_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_exam_view_model.dart';
import 'package:flutter_deneme_takip/view_model/exam_list_view_model.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';
import 'package:flutter_deneme_takip/view_model/login_view_model.dart';
import 'package:flutter_deneme_takip/view_model/subject_view_model.dart';
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
      create: (context) => EditExamViewModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => ExamTableViewModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => BottomNavigationProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => TabbarNavigationProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => ExamListViewModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => SubjectViewModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => LessonViewModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => CustomWidgetPainter(),
    ),
    Provider.value(value: NavigationService.instance),
  ];
}
