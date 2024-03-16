// ignore_for_file: avoid_print
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/view_model/subject_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_deneme_takip/components/alert_dialog/alert_dialog.dart';
import 'package:flutter_deneme_takip/components/app_bar/custom_app_bar.dart';
import 'package:flutter_deneme_takip/components/text_dialog/lesson_alert_text_dialog.dart';
import 'package:flutter_deneme_takip/core/constants/color_constants.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/local_database/exam_db_provider.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/models/lesson.dart';
import 'package:flutter_deneme_takip/view/bottom_tabbar_views/subject_view.dart';
import 'package:flutter_deneme_takip/view/navbar_view/navigation_drawer.dart';
import 'package:flutter_deneme_takip/view_model/exam_table_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_exam_view_model.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';

class SubjectsTabbarView extends StatefulWidget {
  const SubjectsTabbarView({
    super.key,
  });

  @override
  State<SubjectsTabbarView> createState() => _ExamTabbarViewState();
}

class _ExamTabbarViewState extends State<SubjectsTabbarView>
    with TickerProviderStateMixin {
  late TabController tabController;

  late List<LessonModel> listLesson;

  final NavigationService navigation = NavigationService.instance;
  @override
  void initState() {
    listLesson =
        Provider.of<LessonViewModel>(context, listen: false).getLessonData;

    tabController = TabController(length: listLesson.length, vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabbarProv = Provider.of<TabbarNavigationProvider>(context);
    final editexamProv = Provider.of<EditExamViewModel>(context);
    final examProv = Provider.of<ExamTableViewModel>(context);
    final lessonProv = Provider.of<LessonViewModel>(context);
    final subjectProv = Provider.of<SubjectViewModel>(context);
    return buildTabController(
        subjectProv, lessonProv, editexamProv, examProv, tabbarProv);
  }

  DefaultTabController buildTabController(
      SubjectViewModel subjectProv,
      LessonViewModel lessonProv,
      EditExamViewModel editexamProv,
      ExamTableViewModel examProv,
      TabbarNavigationProvider tabbarProv) {
    return DefaultTabController(
      length: lessonProv.getLessonData.length,
      initialIndex: tabbarProv.getSubjectTabIndex,
      child: Builder(
        builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              editexamProv.setKeyboardVisibility = false;

              subjectProv.setLessonIndex =
                  lessonProv.getLessonData[tabController.index].lessonIndex;

              subjectProv.setLessonId = lessonProv
                  .getLessonData[subjectProv.getLessonIndex!].lessonId!;
            }
          });
          return buildScaffold(examProv, context, lessonProv);
        },
      ),
    );
  }

  Scaffold buildScaffold(ExamTableViewModel examProv, BuildContext context,
      LessonViewModel lessonProv) {
    return Scaffold(
      drawer: const NavDrawer(),
      appBar: buildAppBAr(context, examProv),
      body: TabBarView(
        children: List.generate(
          lessonProv.getLessonData.length,
          (index) => const SubjectView(),
        ),
      ),
    );
  }

  List<Widget> generateTabs() {
    final lessonProv = Provider.of<LessonViewModel>(context, listen: false);

    return List.generate(
      lessonProv.getLessonData.length,
      (index) {
        final lesson = lessonProv.getLessonData[index];

        return GestureDetector(
          onDoubleTap: () {
            lessonProv.removeLesson(lesson.lessonId!);
            Navigator.of(context, rootNavigator: true)
                .pushNamed(NavigationConstants.homeView);
          },
          child: Tab(
            iconMargin: const EdgeInsets.only(bottom: 2, left: 40),
            text: lesson.lessonName,
            icon: const Icon(
              Icons.remove_circle_outlined,
              color: Colors.red,
              size: 20,
            ),
          ),
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
                  child: Text(
                    'Veriyi Temizle',
                    style: TextStyle(
                        fontSize:
                            context.dynamicW(0.01) * context.dynamicH(0.004)),
                  ),
                ),
              ];
            },
            onSelected: (value) async {
              if (value == 'option1') {
                _showDialog(
                    context,
                    "DİKKAT!",
                    "Tüm verileri silmek istiyor musunuz?",
                    examProv,
                    lessonProv);
              }
              if (value == 'option2') {}
              if (value == 'option3') {}
            },
          ),
        ],
        title: const Center(child: Text('Konular')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Selector<LessonViewModel, int>(
              selector: (context, value) => value.getLessonData.length,
              builder: (context, lessonCount, child) =>
                  lessonProv.getLessonData[0].lessonId != null
                      ? TabBar(
                          isScrollable: true,
                          dragStartBehavior: DragStartBehavior.start,
                          tabAlignment: TabAlignment.start,
                          automaticIndicatorColorAdjustment: false,
                          tabs: [
                            ...generateTabs(),
                          ],
                        )
                      : TabBar(tabs: [
                          buildNewLesson(
                            examProv,
                            context,
                            lessonProv,
                          ),
                        ])),
        ),
      ),
      dynamicPreferredSize: context.dynamicH(0.15),
      gradients: ColorConstants.appBarGradient,
    );
  }

  GestureDetector buildNewLesson(ExamTableViewModel examProv,
      BuildContext context, LessonViewModel lessonProv) {
    return GestureDetector(
      onTap: () async {
        examProv.setAlert = false;

        await showLessonDialog(context,
            title: "Ders İsmi Giriniz",
            value: "",
            alert: examProv.getIsAlertOpen, onPressFunc: () async {
          ExamDbProvider.db.insertLesson(
            lessonProv.getLessonName ?? "nullLessName",
          );
          lessonProv.initLessonData();
          Navigator.of(context, rootNavigator: true)
              .pushNamed(NavigationConstants.homeView);
        });
      },
      child: const Center(
          child: Icon(size: 40, color: Colors.green, Icons.add_circle)),
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
}
