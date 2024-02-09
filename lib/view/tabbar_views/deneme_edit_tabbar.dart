import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/alert_dialog/alert_dialog.dart';
import 'package:flutter_deneme_takip/components/app_bar/custom_app_bar.dart';
import 'package:flutter_deneme_takip/core/constants/app_data.dart';
import 'package:flutter_deneme_takip/core/constants/color_constants.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/view/insert_views/insert_deneme_view.dart';
import 'package:flutter_deneme_takip/view/navbar_view/navigation_drawer.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/bottom_tabbar_view.dart';
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
    denemeSubjectList = lessonNameList = AppData.lessonNameList;
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
      length: AppData.lessonNameList.length,
      initialIndex: tabbarNavProv.getCurrentEditDeneme,
      child: Builder(
        builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              tabbarNavProv.setCurrentEditDeneme = tabController.index;
              editDenemeProv.setLessonName =
                  AppData.lessonNameList[tabbarNavProv.getCurrentEditDeneme];

              editDenemeProv.setSubjectList =
                  AppData.subjectListNames[editDenemeProv.getLessonName];

              editDenemeProv.setFalseCountsIntegers =
                  List.filled(editDenemeProv.getFalseCountsIntegers!.length, 0);

              denemeProv.initDenemeData(
                  AppData.lessonNameList[tabbarNavProv.getCurrentDenemeIndex]);

              editDenemeProv.setFalseControllers =
                  editDenemeProv.getFalseCountsIntegers!.length;
            }
          });
          return Scaffold(
            drawer: const NavDrawer(),
            appBar: buildAppBAr(context, denemeProv),
            body: const TabBarView(
              children: [
                InsertDeneme(),
                InsertDeneme(),
                InsertDeneme(),
              ],
            ),
          );
        },
      ),
    );
  }

  CustomAppBar buildAppBAr(BuildContext context, DenemeViewModel denemeProv) {
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
                    "Tüm verileri silmek istiyor musunuz?", denemeProv);
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
      DenemeViewModel denemeProv) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isOneButton: false,
      noFunction: () => {
        denemeProv.setAlert = false,
        Navigator.of(context, rootNavigator: true)
            .pushNamed(NavigationConstants.homeView)
      },
      yesFunction: () async => {
        DenemeDbProvider.db.clearDatabase(),
        navigation
            .navigateToPageClear(path: NavigationConstants.homeView, data: []),
        denemeProv.setAlert = false,
        await Future.delayed(const Duration(milliseconds: 50), () {
          denemeProv.initDenemeData(denemeProv.getLessonName);
        }),
      },
    );

    if (denemeProv.getIsAlertOpen == false) {
      denemeProv.setAlert = true;
      await showDialog(
          barrierDismissible: false,
          barrierColor: const Color(0x66000000),
          context: context,
          builder: (BuildContext context) {
            return alert;
          }).then(
        (value) => denemeProv.setAlert = false,
      );
    }
  }
}
