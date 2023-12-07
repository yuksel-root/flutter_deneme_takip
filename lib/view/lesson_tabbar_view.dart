import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/view/lesson_views/math_view.dart';
import 'package:flutter_deneme_takip/view/lesson_views/tarih_view.dart';
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
      length: 2,
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
            title: Center(
                child:
                    Text(style: TextStyle(color: Colors.white), 'Deneme App')),
            backgroundColor: Color(0xff1c0f45),
            bottom: TabBar(
                labelColor: Colors.green,
                indicatorColor: Colors.greenAccent,
                isScrollable: true,
                tabs: [
                  Tab(text: "Tarih"),
                  Tab(text: "Math"),
                ]),
          ),
          body: TabBarView(
            children: [
              TarihView(),
              MathView(),
            ],
          ),
        );
      }),
    );
  }

  int a = 0;
}
