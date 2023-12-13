import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/view/lesson_view.dart';
import 'package:provider/provider.dart';

class LessonTabbarView extends StatefulWidget {
  const LessonTabbarView({Key? key}) : super(key: key);

  @override
  State<LessonTabbarView> createState() => _LessonTabbarViewState();
}

class _LessonTabbarViewState extends State<LessonTabbarView>
    with TickerProviderStateMixin {
  late TabController tabController;

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
    final tabbarNavProv = Provider.of<TabbarNavigationProvider>(context);

    return DefaultTabController(
      length: LessonList.lessonNameList.length,
      initialIndex: tabbarNavProv.getLessonCurrentIndex,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            tabbarNavProv.setLessonCurrentIndex = tabController.index;
          }
        });
        return Scaffold(
            appBar: AppBar(
                title: const Center(
                    child: Text(
                        style: TextStyle(color: Colors.white), 'Deneme AppL')),
                backgroundColor: const Color(0xff1c0f45),
                bottom: TabBar(
                  labelColor: Colors.green,
                  indicatorColor: Colors.greenAccent,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: tab,
                )),
            body: TabBarView(
              children: List.generate(
                LessonList.lessonNameList.length,
                (index) =>
                    LessonView(lessonName: LessonList.lessonNameList[index]),
              ),
            ));
      }),
    );
  }

  List<Widget> tab = LessonList.lessonNameList.map((tabName) {
    return Tab(
      text: tabName,
    );
  }).toList();
}
