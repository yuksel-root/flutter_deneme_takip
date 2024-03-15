import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/alert_dialog/alert_dialog.dart';
import 'package:flutter_deneme_takip/components/app_bar/custom_app_bar.dart';

import 'package:flutter_deneme_takip/core/constants/color_constants.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/local_database/exam_db_provider.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/view/insert_views/insert_deneme_view.dart';

import 'package:flutter_deneme_takip/view/navbar_view/navigation_drawer.dart';
import 'package:flutter_deneme_takip/view_model/exam_table_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_exam_view_model.dart';

import 'package:provider/provider.dart';

class ExamEditTabbarView extends StatefulWidget {
  final List<String>? examSubjectList;
  final List<String>? lessonNameList;
  const ExamEditTabbarView(
      {super.key, this.examSubjectList, this.lessonNameList});

  @override
  State<ExamEditTabbarView> createState() => _ExamTabbarViewState();
}

class _ExamTabbarViewState extends State<ExamEditTabbarView>
    with TickerProviderStateMixin {
  late TabController tabController;
  //late List<String> examSubjectList;
  //late List<String>? lessonNameList;

  final NavigationService navigation = NavigationService.instance;
  @override
  void initState() {
    // examSubjectList = lessonNameList = AppData.lessonNameList;
    super.initState();

    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabbarNavProv = Provider.of<TabbarNavigationProvider>(context);
    final editexamProv = Provider.of<EditExamViewModel>(context);
    final examProv = Provider.of<ExamTableViewModel>(context);

    return DefaultTabController(
      length: 3,
      initialIndex: tabbarNavProv.getEditExamTabIndex,
      child: Builder(
        builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              editexamProv.getFormKey.currentState!.reset();
              FocusScope.of(context).unfocus();
              editexamProv.setKeyboardVisibility = false;

              tabbarNavProv.setCurrentEditexam = tabController.index;
              //   editexamProv.setLessonName =
//AppData.lessonNameList[tabbarNavProv.getCurrentEditexam];

              //            editexamProv.setSubjectList =
//AppData.subjectListNames[editexamProv.getLessonName];

              editexamProv.setFalseCountsIntegers =
                  List.filled(editexamProv.getFalseCountsIntegers!.length, 0);

              //   examProv.initExamData(
              //    AppData.lessonNameList[tabbarNavProv.getCurrentexamIndex]);

              editexamProv.setFalseControllers =
                  editexamProv.getFalseCountsIntegers!.length;
            }
          });
          return Scaffold(
            drawer: const NavDrawer(),
            appBar: buildAppBAr(context, examProv),
            body: const TabBarView(
              children: [
                InsertExam(),
                InsertExam(),
                InsertExam(),
              ],
            ),
          );
        },
      ),
    );
  }

  CustomAppBar buildAppBAr(BuildContext context, ExamTableViewModel examProv) {
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
                _showDialog(context, "DİKKAT!",
                    "Tüm verileri silmek istiyor musunuz?", examProv);
              }
              if (value == 'option2') {}
              if (value == 'option3') {}
            },
          ),
        ],
        title: const Center(child: Text('Deneme Verisi Ekle')),
        bottom: const TabBar(
            isScrollable: true,
            dragStartBehavior: DragStartBehavior.start,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: "Tarih"),
              Tab(text: "Coğrafya"),
              Tab(text: "Vatandaşlık"),
            ]),
      ),
      dynamicPreferredSize: context.dynamicH(0.15),
      gradients: ColorConstants.appBarGradient,
    );
  }

  _showDialog(BuildContext context, String title, String content,
      ExamTableViewModel examProv) async {
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
          //   examProv.initExamData(examProv.getLessonName);
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
