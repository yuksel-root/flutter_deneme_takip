import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/core/notifier/bottom_navigation_notifier.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/deneme_edit_tabbar.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/deneme_tabbar_view.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/lesson_tabbar_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class BottomTabbarView extends StatefulWidget {
  const BottomTabbarView({Key? key}) : super(key: key);

  @override
  State<BottomTabbarView> createState() => _BottomTabbarViewState();
}

final NavigationService navigation = NavigationService.instance;
void _navigateHome(context) =>
    navigation.navigateToPageClear(path: NavigationConstants.homeView);

class _BottomTabbarViewState extends State<BottomTabbarView> {
  @override
  void initState() {
    super.initState();
  }

  static List<Widget> currentScreen = const [
    LessonTabbarView(),
    DenemeTabbarView(),
    DenemeEditTabbarView(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BottomNavigationProvider>(context);
    final tabbarProvider = Provider.of<TabbarNavigationProvider>(context);
    return Scaffold(
      body: currentScreen[provider.getCurrentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff1c0f45),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.greenAccent,
        currentIndex: provider.getCurrentIndex,
        onTap: (index) {
          provider.setCurrentIndex(index);
          if (index == 0) {
            tabbarProvider.setLessonCurrentIndex = 0;
            // _navigateHome(context);
          } else {}
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
    );
  }
}
