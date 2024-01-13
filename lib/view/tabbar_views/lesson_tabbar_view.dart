import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/alert_dialog.dart';
import 'package:flutter_deneme_takip/components/sign_button.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/services/auth_service.dart';
import 'package:flutter_deneme_takip/view/lesson_view.dart';
import 'package:flutter_deneme_takip/view/navigation_drawer.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/bottom_tabbar_view.dart';
import 'package:flutter_deneme_takip/view_model/deneme_login_view_model.dart';
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
    final loginProv = Provider.of<DenemeLoginViewModel>(context, listen: false);

    return DefaultTabController(
      length: LessonList.lessonNameList.length,
      initialIndex: tabbarNavProv.getLessonCurrentIndex,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            tabbarNavProv.setLessonCurrentIndex = tabController.index;

            lessonProv.setLessonName =
                LessonList.lessonNameList[tabbarNavProv.getLessonCurrentIndex];

            lessonProv.initLessonData(
                LessonList.lessonNameList[tabbarNavProv.getLessonCurrentIndex]);
          }
        });
        return Scaffold(
            drawer: const NavDrawer(),
            appBar: AppBar(
                iconTheme: const IconThemeData(color: Colors.white),
                actions: <Widget>[
                  // buildSignOutButton(context, loginProv),
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
                        PopupMenuItem(
                          value: 'option2',
                          child: Text(
                            'Google Çıkış',
                            style: TextStyle(
                                fontSize: context.dynamicW(0.01) *
                                    context.dynamicH(0.004)),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'option3',
                          child: Text(
                            'Verileri geri yükle',
                            style: TextStyle(
                                fontSize: context.dynamicW(0.01) *
                                    context.dynamicH(0.004)),
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
                            denemeProv);
                      }
                      if (value == 'option2') {
                        if (AuthService().fAuth.currentUser != null ||
                            await loginProv.getIsAnonymous == true) {
                          AuthService().signOut();
                          loginProv.setAnonymousLogin = false;
                          loginProv.setState = LoginState.notLoggedIn;
                          navigation.navigateToPageClear(
                              path: NavigationConstants.loginView);
                        }
                      }
                      if (value == 'option3') {
                        await DenemeDbProvider.db.clearDatabase();
                        lessonProv.initLessonData(lessonProv.getLessonName);
                        denemeProv.initDenemeData(denemeProv.getLessonName!);
                        navigation.navigateToPageClear(
                            path: NavigationConstants.homeView);

                        restoreData(loginProv, denemeProv, lessonProv);
                      }
                    },
                  ),
                ],
                title: Center(
                    child: Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: context.dynamicW(0.01) *
                                context.dynamicH(0.005)),
                        "Konularına Göre Yanlış Listesi")),
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

  Future<void> restoreData(DenemeLoginViewModel loginProv,
      DenemeViewModel denemeProv, LessonViewModel lessonProv) async {
    if (AuthService().fAuth.currentUser != null ||
        await loginProv.getIsAnonymous == true) {
      String? userId = AuthService().fAuth.currentUser?.uid;

      final denemePostData = await denemeProv.getTablesFromFirebase(userId!);

      denemeProv.sendFirebaseToSqlite(denemePostData);
    }
    lessonProv.initLessonData(lessonProv.getLessonName);
    denemeProv.initDenemeData(denemeProv.getLessonName!);
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
      isOneButton: false,
      noFunction: () => {
        lessonProv.setAlert = false,
        Navigator.of(context, rootNavigator: true)
            .pushNamed(NavigationConstants.homeView)
      },
      yesFunction: () => {
        DenemeDbProvider.db.clearDatabase(),
        navigation
            .navigateToPageClear(path: NavigationConstants.homeView, data: []),
        lessonProv.setAlert = false,
        Future.delayed(const Duration(milliseconds: 200), () {
          lessonProv.initLessonData(lessonProv.getLessonName);

          denemeProv.initDenemeData(denemeProv.getLessonName);
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

  SignButton buildSignOutButton(
      BuildContext context, DenemeLoginViewModel loginProv) {
    return SignButton(
        isGreyPng: true,
        onPressFunct: () async {
          if (AuthService().fAuth.currentUser != null ||
              await loginProv.getIsAnonymous == true) {
            AuthService().signOut();
            loginProv.setAnonymousLogin = false;
            loginProv.setState = LoginState.notLoggedIn;
            navigation.navigateToPageClear(path: NavigationConstants.loginView);
          } else {}
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        labelText: "Çıkış",
        labelStyle: TextStyle(
          color: Colors.white,
          fontSize: context.dynamicH(0.00571) * context.dynamicW(0.01),
        ));
  }
}
