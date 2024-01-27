import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deneme_takip/core/constants/color_constants.dart';

class AppTheme {
  static AppTheme? _instance;
  static AppTheme get instance {
    _instance ??= AppTheme._init();
    return _instance!;
  }

  AppTheme() {
    _themeData = ThemeData.light();
  }
  AppTheme._init();
  late ThemeData _themeData;
  static Size screenSize =
      WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
  double width = screenSize.width;
  double height = screenSize.height;

  ThemeData get currentTheme => _themeData.copyWith(
        appBarTheme: AppBarTheme(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          centerTitle: true,
          titleTextStyle:
              TextStyle(fontSize: (width * 0.01) * (height * 0.0025)),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: const Color(0xff1c0f45),
          titleTextStyle: TextStyle(
            fontSize: (width * 0.01) * (height * 0.0025),
            fontFamily: "Greycliff CF Bold",
          ),
          contentTextStyle: TextStyle(
            fontSize: (width * 0.01) * (height * 0.002),
            fontFamily: "Greycliff CF Medium",
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.white,
          unselectedLabelStyle:
              TextStyle(fontSize: (width * 0.01) * (height * 0.002)),
          selectedLabelStyle: TextStyle(
            fontSize: (width * 0.01) * (height * 0.002),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstants.deepPurple,
            animationDuration: const Duration(milliseconds: 100),
            alignment: Alignment.center,
            shape: const StadiumBorder(),
            elevation: 0,
            foregroundColor: Colors.white,
            textStyle: _themeData.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        popupMenuTheme: const PopupMenuThemeData(
          iconColor: Colors.white,
          surfaceTintColor: Color(0xFF00008B),
          color: Color(0xFF1C0F45),
        ),
        tabBarTheme: TabBarTheme(
          indicatorColor: Colors.deepPurple,
          labelColor: const Color(0xff8b7e66),
          tabAlignment: TabAlignment.start,
          unselectedLabelStyle:
              TextStyle(fontSize: (width * 0.01) * (height * 0.0025)),
          labelStyle: TextStyle(fontSize: (width * 0.01) * (height * 0.0025)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          iconColor: ColorConstants.ionicBlue,
          contentPadding: EdgeInsets.symmetric(
            horizontal: width * 0.0025,
            vertical: height * 0.0025,
          ),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          labelStyle: TextStyle(
              fontSize: (width * 0.01) * (height * 0.002),
              color: Colors.deepPurple),
          alignLabelWithHint: true,
          hintStyle: TextStyle(fontSize: (width * 0.01) * (height * 0.002)),
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
            fontSize: (width * 0.01) * (height * 0.002),
          ),
          titleSmall: _themeData.textTheme.titleSmall?.copyWith(
            color: Colors.white,
          ),
        ),
      );
}
