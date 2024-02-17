import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/utils/gradient_widget.dart';
import 'package:flutter_deneme_takip/core/constants/app_data.dart';
import 'package:flutter_deneme_takip/core/constants/color_constants.dart';
import 'package:flutter_deneme_takip/core/notifier/bottom_navigation_notifier.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/deneme_edit_tabbar.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/deneme_tabbar_view.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/lesson_tabbar_view.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_deneme_view_model.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class BottomTabbarView extends StatelessWidget {
  const BottomTabbarView({super.key});

  final List<Widget> currentScreen = const [
    LessonTabbarView(),
    DenemeTabbarView(),
    DenemeEditTabbarView(),
  ];

  @override
  Widget build(BuildContext context) {
    WidgetsBinding widgetsBinding = WidgetsBinding.instance;
    final bottomProv = Provider.of<BottomNavigationProvider>(context);
    final tabbarNavProv = Provider.of<TabbarNavigationProvider>(context);

    final lessonProv = Provider.of<LessonViewModel>(context);
    final denemeProv = Provider.of<DenemeViewModel>(context);
    final editProv = Provider.of<EditDenemeViewModel>(context);

    return Scaffold(
        body: currentScreen[bottomProv.getCurrentIndex],
        bottomNavigationBar: Visibility(
          visible:
              widgetsBinding.platformDispatcher.views.last.viewInsets.bottom ==
                  0,
          child: GradientWidget(
            blendModes: BlendMode.color,
            gradient: ColorConstants.bottomGradient,
            widget: BottomNavigationBar(
              currentIndex: bottomProv.getCurrentIndex,
              onTap: (index) {
                bottomProv.setCurrentIndex = index;
                denemeProv.setLessonName =
                    AppData.lessonNameList[tabbarNavProv.getCurrentDenemeIndex];
                denemeProv.initDenemeData(AppData
                    .lessonNameList[tabbarNavProv.getCurrentDenemeIndex]);

                lessonProv.setLessonName =
                    AppData.lessonNameList[tabbarNavProv.getLessonCurrentIndex];
                lessonProv.initLessonData(AppData
                    .lessonNameList[tabbarNavProv.getLessonCurrentIndex]);

                editProv.setFalseControllers =
                    editProv.getFalseCountsIntegers!.length;

                editProv.setLoading = true;
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesomeIcons.house,
                  ),
                  label: "Dersler",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesomeIcons.house,
                  ),
                  label: "Denemeler",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesomeIcons.house,
                  ),
                  label: "DenemeGir",
                ),
              ],
            ),
          ),
        ));
  }
}
