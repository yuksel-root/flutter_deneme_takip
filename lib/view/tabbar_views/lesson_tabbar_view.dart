// ignore_for_file: avoid_print
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/alert_dialog/load_lesson_alert.dart';
import 'package:flutter_deneme_takip/components/shader_mask/gradient_widget.dart';
import 'package:flutter_deneme_takip/core/constants/app_data.dart';
import 'package:flutter_deneme_takip/view/bottom_tabbar_views/lesson_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_deneme_takip/components/alert_dialog/alert_dialog.dart';
import 'package:flutter_deneme_takip/components/app_bar/custom_app_bar.dart';
import 'package:flutter_deneme_takip/core/constants/color_constants.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/local_database/exam_db_provider.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/models/lesson.dart';
import 'package:flutter_deneme_takip/view/navbar_view/navigation_drawer.dart';
import 'package:flutter_deneme_takip/view_model/exam_table_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_exam_view_model.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';

class LessonTabbarView extends StatefulWidget {
  const LessonTabbarView({
    super.key,
  });

  @override
  State<LessonTabbarView> createState() => _ExamTabbarViewState();
}

class _ExamTabbarViewState extends State<LessonTabbarView>
    with TickerProviderStateMixin {
  late TabController tabController;

  late List<LessonModel> listLesson;

  final NavigationService navigation = NavigationService.instance;
  @override
  void initState() {
    listLesson =
        Provider.of<LessonViewModel>(context, listen: false).getLessonData;

    tabController =
        TabController(length: AppData.examNames.length, vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabbarNavProv = Provider.of<TabbarNavigationProvider>(context);
    final editExamProv = Provider.of<EditExamViewModel>(context);
    final examTableProv = Provider.of<ExamTableViewModel>(context);
    final lessonProv = Provider.of<LessonViewModel>(context);
    return buildDefTabController(lessonProv, editExamProv, examTableProv);
  }

  DefaultTabController buildDefTabController(LessonViewModel lessonProv,
      EditExamViewModel editexamProv, ExamTableViewModel examTableProv) {
    return DefaultTabController(
      length: AppData.examNames.length,
      initialIndex: 0,
      child: Builder(
        builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              editexamProv.setKeyboardVisibility = false;
            }
          });
          return buildScaffold(lessonProv, examTableProv);
        },
      ),
    );
  }

  Scaffold buildScaffold(
      LessonViewModel lessonProv, ExamTableViewModel examProv) {
    return Scaffold(
      drawer: const NavDrawer(),
      appBar: buildAppBAr(context, examProv),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showLoadLesson(context, examProv);
        },
        child: Icon(Icons.add),
      ),
      body: const LessonView(),
    );
  }

  TabBarView buildTabbarView(LessonViewModel lessonProv) {
    return TabBarView(
      children: List.generate(
        AppData.examNames.length,
        (index) => const LessonView(),
      ),
    );
  }

  List<Widget> generateTabs() {
    return List.generate(
      AppData.examNames.length,
      (index) {
        final examNames = AppData.examNames[index];

        return Tab(
          text: examNames,
        );
      },
    );
  }

  CustomAppBar buildAppBAr(BuildContext context, ExamTableViewModel examProv) {
    final lessonProv = Provider.of<LessonViewModel>(context, listen: false);
    return CustomAppBar(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry>[
                PopupMenuItem(
                  value: 'option1',
                  child: Row(
                    children: [
                      GradientWidget(
                          blendModes: BlendMode.dstOut,
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade300.withOpacity(0.3),
                              Colors.grey.shade200.withOpacity(0.3)
                            ],
                          ),
                          widget: const Icon(Icons.settings)),
                      const SizedBox(width: 8),
                      Text(
                        'Ders Ayarları',
                        style: TextStyle(
                            fontSize: context.dynamicW(0.01) *
                                context.dynamicH(0.004)),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'option2',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Veriyi Temizle',
                        style: TextStyle(
                            fontSize: context.dynamicW(0.01) *
                                context.dynamicH(0.004)),
                      ),
                    ],
                  ),
                ),
              ];
            },
            onSelected: (value) async {
              if (value == 'option1') {
                Navigator.of(context, rootNavigator: true)
                    .pushNamed(NavigationConstants.settingsView);
              }
              if (value == 'option2') {
                _showDialog(
                    context,
                    "DİKKAT!",
                    "Tüm verileri silmek istiyor musunuz?",
                    examProv,
                    lessonProv);
              }
              if (value == 'option3') {}
            },
          ),
        ],
        title: const Center(child: Text('Dersler')),
        bottom: TabBar(
          isScrollable: true,
          dragStartBehavior: DragStartBehavior.start,
          tabAlignment: TabAlignment.start,
          automaticIndicatorColorAdjustment: false,
          tabs: [
            ...generateTabs(),
          ],
        ),
      ),
      dynamicPreferredSize: context.dynamicH(0.15),
      gradients: ColorConstants.appBarGradient,
    );
  }

  _showDialog(BuildContext context, String title, String content,
      ExamTableViewModel examProv, LessonViewModel lessonProv) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isOneButton: false,
      noFunction: () => {
        examProv.setAlert = false,
        Navigator.of(context, rootNavigator: true)
            .pushNamed(NavigationConstants.homeView)
      },
      yesFunction: () async => {
        ExamDbProvider.db.clearDatabase(),
        navigation
            .navigateToPageClear(path: NavigationConstants.homeView, data: []),
        examProv.setAlert = false,
        await Future.delayed(const Duration(milliseconds: 50), () {
          examProv.initExamData(lessonProv.getLessonName);
        }),
      },
    );

    if (examProv.getIsAlertOpen == false) {
      examProv.setAlert = true;
      await showDialog(
          barrierDismissible: false,
          barrierColor: const Color(0x66000000),
          context: context,
          builder: (BuildContext context) {
            return alert;
          }).then(
        (value) => examProv.setAlert = false,
      );
    }
  }

  _showLoadLesson(BuildContext context, ExamTableViewModel examProv) async {
    LoadLessonAlert alert = const LoadLessonAlert();

    if (examProv.getIsAlertOpen == false) {
      examProv.setAlert = false;
      await showDialog(
          barrierDismissible: true,
          barrierColor: const Color(0x66000000),
          context: context,
          builder: (BuildContext context) {
            return alert;
          }).then(
        (value) => examProv.setAlert = false,
      );
    }
  }
}
