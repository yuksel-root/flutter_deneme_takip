import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/view/deneme_view.dart';
import 'package:provider/provider.dart';

class DenemeTabbarView extends StatefulWidget {
  const DenemeTabbarView({Key? key}) : super(key: key);

  @override
  State<DenemeTabbarView> createState() => _DenemeTabbarViewState();
}

class _DenemeTabbarViewState extends State<DenemeTabbarView>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 6, vsync: this);
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
      initialIndex: tabbarNavProv.getCurrentDenemeIndex,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            tabbarNavProv.setCurrentDenemeIndex = tabController.index;
          }
        });
        return Scaffold(
            appBar: AppBar(
              title: const Center(
                  child: Text(
                      style: TextStyle(color: Colors.white), 'Deneme App')),
              backgroundColor: const Color(0xff1c0f45),
              bottom: TabBar(
                  indicatorColor: Colors.greenAccent,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: tab),
            ),
            body: TabBarView(
              children: List.generate(
                LessonList.lessonNameList.length,
                (index) =>
                    DenemeView(lessonName: LessonList.lessonNameList[index]),
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
