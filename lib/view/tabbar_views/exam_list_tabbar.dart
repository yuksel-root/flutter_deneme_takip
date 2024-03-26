import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/app_bar/custom_app_bar.dart';
import 'package:flutter_deneme_takip/core/constants/app_data.dart';
import 'package:flutter_deneme_takip/core/constants/color_constants.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/local_database/exam_db_provider.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/components/alert_dialog/alert_dialog.dart';
import 'package:flutter_deneme_takip/view/bottom_tabbar_views/exam_list_view.dart';
import 'package:flutter_deneme_takip/view/navbar_view/navigation_drawer.dart';
import 'package:flutter_deneme_takip/view_model/exam_table_view_model.dart';
import 'package:flutter_deneme_takip/view_model/exam_list_view_model.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';

class ExamListTabbarView extends StatefulWidget {
  const ExamListTabbarView({super.key});

  @override
  State<ExamListTabbarView> createState() => _ExamListTabbarViewState();
}

class _ExamListTabbarViewState extends State<ExamListTabbarView>
    with TickerProviderStateMixin {
  late TabController tabController;
  final NavigationService navigation = NavigationService.instance;
  @override
  void initState() {
    super.initState();

    tabController = TabController(length: tab.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabbarNavProv =
        Provider.of<TabbarNavigationProvider>(context, listen: true);
    final lessonProv = Provider.of<LessonViewModel>(context, listen: false);
    final examProv = Provider.of<ExamTableViewModel>(context, listen: false);
    final examListProv = Provider.of<ExamListViewModel>(context, listen: false);

    return DefaultTabController(
      length: AppData.kpssLessonNames.length,
      initialIndex: tabbarNavProv.getExamListTabIndex,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            tabbarNavProv.setExamListIndex = tabController.index;

            //     lessonProv.setLessonName =
            //       AppData.lessonNameList[tabbarNavProv.getLessonCurrentIndex];

            //    examListProv.initExamListData(
            //     AppData.lessonNameList[tabbarNavProv.getExamListIndex]);
          }
        });
        return Scaffold(
            drawer: const NavDrawer(),
            appBar: buildAppBar(context, examListProv, examProv),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, NavigationConstants.insertExam);
              },
              child: Icon(Icons.add),
            ),
            body: TabBarView(
              children: List.generate(AppData.kpssLessonNames.length, (index) {
                return const ExamListView();
              }),
            ));
      }),
    );
  }

  CustomAppBar buildAppBar(BuildContext context, ExamListViewModel lessonProv,
      ExamTableViewModel examProv) {
    return CustomAppBar(
      appBar: AppBar(
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
                      lessonProv,
                      examProv);
                }
                if (value == 'option2') {}
                if (value == 'option3') {}
              },
            ),
          ],
          title: const Center(
              child: Text(
                  textAlign: TextAlign.center,
                  "Konularına Göre Yanlış Listesi")),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: tab,
          )),
      dynamicPreferredSize: context.dynamicH(0.15),
      gradients: ColorConstants.appBarGradient,
    );
  }

  final List<Widget> tab = AppData.kpssLessonNames.map((tabName) {
    return Tab(
      text: tabName,
    );
  }).toList();

  _showDialog(BuildContext context, String title, String content,
      ExamListViewModel lessonProv, ExamTableViewModel examProv) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isOneButton: false,
      noFunction: () => {
        lessonProv.setAlert = false,
        Navigator.of(context, rootNavigator: true)
            .pushNamed(NavigationConstants.homeView)
      },
      yesFunction: () async => {
        ExamDbProvider.db.clearDatabase(),
        navigation
            .navigateToPageClear(path: NavigationConstants.homeView, data: []),
        lessonProv.setAlert = false,
        await Future.delayed(const Duration(milliseconds: 50), () {
          //   lessonProv.initExamListData(lessonProv.getLessonName);

          // examProv.initExamData(examProv.getLessonName);
        }),
      },
    );

    if (lessonProv.getIsAlertOpen == false) {
      lessonProv.setAlert = true;
      await showDialog(
          barrierDismissible: false,
          barrierColor: const Color(0x66000000),
          context: context,
          builder: (BuildContext context) {
            return alert;
          }).then(
        (value) => lessonProv.setAlert = false,
      );
    }
  }
}
