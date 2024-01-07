import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/alert_dialog.dart';
import 'package:flutter_deneme_takip/components/sign_out_button.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/view/lesson_view.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/bottom_tabbar_view.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';

class LessonTabbarView extends StatefulWidget {
  const LessonTabbarView({super.key});

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
    final tabbarNavProv =
        Provider.of<TabbarNavigationProvider>(context, listen: true);
    final lessonProv = Provider.of<LessonViewModel>(context, listen: false);
    final denemeProv = Provider.of<DenemeViewModel>(context, listen: false);

    return DefaultTabController(
      length: LessonList.lessonNameList.length,
      initialIndex: tabbarNavProv.getLessonCurrentIndex,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            tabbarNavProv.setLessonCurrentIndex = tabController.index;

            lessonProv.setLessonName =
                LessonList.lessonNameList[tabController.index];

            lessonProv
                .initLessonData(LessonList.lessonNameList[tabController.index]);
          }
        });
        return Scaffold(
            appBar: AppBar(
                actions: <Widget>[
                  const SignOutButton(),
                  PopupMenuButton(
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry>[
                        PopupMenuItem(
                          value: 'option1',
                          child: Text(
                            'Veriyi Temizle',
                            style: TextStyle(
                                fontSize: context.dynamicW(0.01) *
                                    context.dynamicH(0.004)),
                          ),
                        ),

                        // Diğer seçenekler
                      ];
                    },
                    onSelected: (value) {
                      if (value == 'option1') {
                        _showDialog(
                            context,
                            "DİKKAT!",
                            "Tüm verileri silmek istiyor musunuz?",
                            lessonProv,
                            denemeProv);
                      }
                    },
                  ),
                ],
                title: Center(
                    child: Text(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          context.dynamicW(0.01) * context.dynamicH(0.005)),
                  '        Deneme App',
                )),
                backgroundColor: const Color(0xff1c0f45),
                bottom: TabBar(
                  labelColor: Colors.green,
                  indicatorColor: Colors.greenAccent,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelStyle: TextStyle(
                    fontSize: context.dynamicW(0.01) * context.dynamicH(0.005),
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: context.dynamicW(0.01) * context.dynamicH(0.005),
                  ),
                  tabs: tab,
                )),
            body: TabBarView(
              children:
                  List.generate(LessonList.lessonNameList.length, (index) {
                return const LessonView();
              }),
            ));
      }),
    );
  }

  List<Widget> tab = LessonList.lessonNameList.map((tabName) {
    return Tab(
      text: tabName,
    );
  }).toList();

  _showDialog(BuildContext context, String title, String content,
      LessonViewModel lessonProv, DenemeViewModel denemeProv) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isAlert: false,
      noFunction: () => {
        lessonProv.setAlert = false,
        Navigator.of(context).pop(),
      },
      yesFunction: () => {
        DenemeDbProvider.db.clearDatabase(),
        navigation
            .navigateToPageClear(path: NavigationConstants.homeView, data: []),
        lessonProv.setAlert = false,
        Future.delayed(const Duration(milliseconds: 200), () {
          lessonProv.initLessonData(lessonProv.getLessonName);

          denemeProv.initData(denemeProv.getLessonName);
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
