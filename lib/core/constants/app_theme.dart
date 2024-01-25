import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deneme_takip/core/constants/color_constants.dart';

class AppTheme {
  static AppTheme? _instance;
  static AppTheme get instance {
    _instance ??= AppTheme._init();
    return _instance!;
  }

  AppTheme._init();
  AppTheme() {
    _themeData = ThemeData.light();
  }
  late final ThemeData _themeData;

  ThemeData get currentTheme => _themeData.copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.transparent,
            unselectedItemColor: Colors.white,
            selectedItemColor: Colors.greenAccent,
            unselectedLabelStyle: TextStyle(
                color: Colors.white,
                fontSize: (const MediaQueryData().size.width * 0.01) *
                    (const MediaQueryData().size.height * 0.005)),
            selectedLabelStyle: TextStyle(
              fontSize: (const MediaQueryData().size.width * 0.01) *
                  (const MediaQueryData().size.height * 0.005),
            )),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstants.lust,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            elevation: 0,
            foregroundColor: Colors.white,
            textStyle: _themeData.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: ColorConstants.lust,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
        ),
        colorScheme: const ColorScheme.dark(
          onSecondary: Colors.white,
          onPrimaryContainer: ColorConstants.potBlack,
          onBackground: ColorConstants.direWolf,
          onError: ColorConstants.lust,
        ),
        textTheme: _themeData.textTheme.copyWith(
          headlineLarge: ThemeData.dark().textTheme.headlineLarge?.copyWith(
                color: Colors.white,
              ),
          titleMedium: _themeData.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontSize: (const MediaQueryData().size.width * 0.01) *
                (const MediaQueryData().size.height * 0.005),
          ),
          titleSmall: _themeData.textTheme.titleSmall?.copyWith(
            color: Colors.white,
          ),
        ),
      );
}
