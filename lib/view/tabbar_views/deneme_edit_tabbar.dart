import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/view/insert_views/insert_deneme_view.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_deneme_view_model.dart';
import 'package:provider/provider.dart';

class DenemeEditTabbarView extends StatefulWidget {
  final List<String>? denemeSubjectList;
  final List<String>? lessonNameList;
  const DenemeEditTabbarView(
      {super.key, this.denemeSubjectList, this.lessonNameList});

  @override
  State<DenemeEditTabbarView> createState() => _DenemeTabbarViewState();
}

class _DenemeTabbarViewState extends State<DenemeEditTabbarView>
    with TickerProviderStateMixin {
  late TabController tabController;
  late List<String> denemeSubjectList;
  late List<String>? lessonNameList;
  @override
  void initState() {
    denemeSubjectList = lessonNameList = LessonList.lessonNameList;
    super.initState();

    tabController = TabController(length: lessonNameList!.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabbarNavProv = Provider.of<TabbarNavigationProvider>(context);
    final editDenemeProv = Provider.of<EditDenemeViewModel>(context);
    final denemeProv = Provider.of<DenemeViewModel>(context);

    return DefaultTabController(
      length: LessonList.lessonNameList.length,
      initialIndex: tabbarNavProv.getCurrentEditDeneme,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            tabbarNavProv.setCurrentEditDeneme = tabController.index;
            editDenemeProv.setLessonName =
                LessonList.lessonNameList[tabbarNavProv.getCurrentEditDeneme];

            editDenemeProv.setSubjectList =
                LessonList.subjectListNames[editDenemeProv.getLessonName];

            editDenemeProv.setFalseCountsIntegers =
                List.filled(editDenemeProv.getFalseCountsIntegers!.length, 0);

            denemeProv.initData(
                LessonList.lessonNameList[tabbarNavProv.getCurrentDenemeIndex]);

            editDenemeProv.setFalseControllers =
                editDenemeProv.getFalseCountsIntegers!.length;

            editDenemeProv.setLoading = true;
          }
        });
        return Scaffold(
          appBar: AppBar(
            title: Center(
                child: Text(
                    style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            context.dynamicW(0.01) * context.dynamicH(0.005)),
                    'Deneme App')),
            backgroundColor: const Color(0xff1c0f45),
            bottom: TabBar(
                indicatorColor: Colors.greenAccent,
                isScrollable: true,
                dragStartBehavior: DragStartBehavior.start,
                tabAlignment: TabAlignment.start,
                unselectedLabelStyle: TextStyle(
                    fontSize: context.dynamicW(0.01) * context.dynamicH(0.005)),
                labelStyle: TextStyle(
                    fontSize: context.dynamicW(0.01) * context.dynamicH(0.005)),
                tabs: const [
                  Tab(text: "Tarih"),
                  Tab(text: "Coğrafya"),
                  Tab(text: "Vatandaşlık"),
                ]),
          ),
          body: const TabBarView(
            children: [
              InsertDeneme(),
              InsertDeneme(),
              InsertDeneme(),
            ],
          ),
        );
      }),
    );
  }
}
