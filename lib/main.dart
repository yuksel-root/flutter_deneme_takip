// ignore_for_file: avoid_print
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_route.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/core/notifier/provider_list.dart';
import 'package:flutter_deneme_takip/firebase_options.dart';
import 'package:flutter_deneme_takip/services/auth_service.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/bottom_tabbar_view.dart';
import 'package:flutter_deneme_takip/view_model/deneme_login_view_model.dart';
import 'package:google_api_availability/google_api_availability.dart';
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

Future<void> checkGooglePlayServices() async {
  final availability = await GoogleApiAvailability.instance
      .checkGooglePlayServicesAvailability();

  if (availability == GooglePlayServicesAvailability.success) {
    print('------------Google Play Services başarılı -----------');
  } else {
    print(
        '----------Google Play Services mevcut değil veya uygun değil---------');
  }
}

Future<void> _init() async {
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await checkGooglePlayServices();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom,
  ]);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    //print("mainUser ${AuthService().fAuth.currentUser}");
    final loginProv = Provider.of<DenemeLoginViewModel>(context, listen: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent)),
      onGenerateRoute: NavigationRoute.instance.generateRoute,
      navigatorKey: NavigationService.instance.navigatorKey,
      home: Scaffold(
        body: Center(
          child: StreamBuilder<User?>(
            stream: AuthService().fAuth.authStateChanges(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                User? user = snapshot.data;
                print("İF 0 ADSADSALDMLSAKDAS");
                print(user);
                print("İF 0 ADSADSALDMLSAKDAS");
                if (user == null) {
                  print("İF 1 NJNADLJASNDLJSADNSDMLASKMDSKLAD");
                  loginProv.setCurrentUser = null;
                  return const BottomTabbarView();
                } else {
                  print("ELSE SDASDASDACZXCZXCXZCXCZXCZXC");
                  loginProv.setCurrentUser = AuthService().fAuth.currentUser;
                  return const BottomTabbarView();
                }
              }
              return const BottomTabbarView();
            },
          ),
        ),
      ),
    );
  }

  Future<bool?> checkIfAnonymous(DenemeLoginViewModel loginProv) async {
    bool? isAnonymous = await loginProv.getIsAnonymous ?? false;
    //   print("anonMain $isAnonymous");
    return Future.value(isAnonymous);
  }
}
