// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deneme_takip/core/constants/app_theme.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_route.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/core/notifier/provider_list.dart';
import 'package:flutter_deneme_takip/firebase_options.dart';
import 'package:flutter_deneme_takip/services/auth_service.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/bottom_tabbar_view.dart';
import 'package:flutter_deneme_takip/view_model/app_life_cycle_manager.dart';
import 'package:flutter_deneme_takip/view_model/login_view_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  await _init();
  runApp(
    MultiProvider(
      providers: [...ApplicationProvider.instance.dependItems],
      child: const MainApp(),
    ),
  );
}

Future<void> _init() async {
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom,
  ]);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static Size screenSize =
      WidgetsBinding.instance.platformDispatcher.views.single.display.size;
  @override
  Widget build(BuildContext context) {
    final loginProv = Provider.of<LoginViewModel>(context, listen: false);
    print(
        "table fontSize ${AppTheme.dynamicSize(dynamicHSize: 0.0045, dynamicWSize: 0.0085)}");
    print(
        "table height ${AppTheme.dynamicSize(dynamicHSize: 0.0117, dynamicWSize: 0.032)}");
    print(
        "table width ${AppTheme.dynamicSize(dynamicHSize: 0.014, dynamicWSize: 0.02)}");
    return AppLifeCycleManager(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme().currentTheme,
        onGenerateRoute: NavigationRoute.instance.generateRoute,
        navigatorKey: NavigationService.instance.navigatorKey,
        home: Scaffold(
          body: Center(
            child: StreamBuilder<User?>(
              stream: AuthService().fAuth.authStateChanges(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  User? user = snapshot.data;

                  if (user == null) {
                    loginProv.setCurrentUser = null;
                    return const BottomTabbarView();
                  } else {
                    loginProv.setCurrentUser = user;
                    return const BottomTabbarView();
                  }
                }
                return const BottomTabbarView();
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> checkIfAnonymous(LoginViewModel loginProv) async {
    bool? isAnonymous = await loginProv.getIsAnonymous ?? false;
    //   print("anonMain $isAnonymous");
    return Future.value(isAnonymous);
  }
}
