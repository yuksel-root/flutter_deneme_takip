import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deneme_takip/core/constants/color_constants.dart';
import 'package:flutter_deneme_takip/main.dart';

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
  double width = MainApp.screenSize.width;
  double height = MainApp.screenSize.height;

  static double calculatedFontSize(
      {required double dynamicHSize, required double dynamicWSize}) {
    WidgetsBinding widgetsBinding = WidgetsBinding.instance;

    Size screenSize =
        widgetsBinding.platformDispatcher.views.last.physicalSize /
            widgetsBinding.platformDispatcher.views.last.devicePixelRatio;

    double calculatedFontSize =
        (screenSize.width * dynamicWSize) * (screenSize.height * dynamicHSize);

    return calculatedFontSize;
  }

  ThemeData get currentTheme => _themeData.copyWith(
        navigationDrawerTheme: const NavigationDrawerThemeData(
          backgroundColor: Colors.transparent,
        ),
        appBarTheme: AppBarTheme(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          centerTitle: true,
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: (calculatedFontSize(
                  dynamicHSize: 0.005, dynamicWSize: 0.01))),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: const Color(0xff1c0f45),
          titleTextStyle: TextStyle(
            fontSize:
                calculatedFontSize(dynamicHSize: 0.005, dynamicWSize: 0.01),
            fontFamily: "Greycliff CF Bold",
          ),
          contentTextStyle: TextStyle(
            fontSize:
                calculatedFontSize(dynamicHSize: 0.005, dynamicWSize: 0.01),
            fontFamily: "Greycliff CF Medium",
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.white,
          unselectedLabelStyle: TextStyle(
              fontSize:
                  calculatedFontSize(dynamicHSize: 0.005, dynamicWSize: 0.01)),
          selectedLabelStyle: TextStyle(
            fontSize:
                calculatedFontSize(dynamicHSize: 0.005, dynamicWSize: 0.01),
          ),
        ),
        primaryTextTheme: TextTheme(
          headlineLarge: ThemeData.dark().textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontSize:
                  calculatedFontSize(dynamicHSize: 0.005, dynamicWSize: 0.01)),
          titleMedium: _themeData.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontSize:
                calculatedFontSize(dynamicHSize: 0.005, dynamicWSize: 0.01),
          ),
          titleSmall: _themeData.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontSize:
                calculatedFontSize(dynamicHSize: 0.005, dynamicWSize: 0.01),
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
        popupMenuTheme: PopupMenuThemeData(
          iconColor: Colors.white,
          surfaceTintColor: const Color(0xFF00008B),
          iconSize: calculatedFontSize(dynamicHSize: 0.005, dynamicWSize: 0.01),
          color: const Color(0xFF1C0F45),
        ),
        tabBarTheme: TabBarTheme(
          indicatorColor: Colors.deepPurple,
          labelColor: const Color(0xff8b7e66),
          tabAlignment: TabAlignment.start,
          unselectedLabelStyle: TextStyle(
              fontSize:
                  calculatedFontSize(dynamicHSize: 0.005, dynamicWSize: 0.01)),
          labelStyle: TextStyle(
              fontSize:
                  calculatedFontSize(dynamicHSize: 0.005, dynamicWSize: 0.01)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          iconColor: ColorConstants.ionicBlue,
          contentPadding: EdgeInsets.symmetric(
            horizontal: width * 0.0005,
            vertical: height * 0.0005,
          ),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          labelStyle: TextStyle(
              fontSize:
                  calculatedFontSize(dynamicHSize: 0.005, dynamicWSize: 0.01),
              color: Colors.deepPurple),
          alignLabelWithHint: true,
          hintStyle: TextStyle(
              fontSize:
                  calculatedFontSize(dynamicHSize: 0.005, dynamicWSize: 0.01)),
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
              fontSize:
                  calculatedFontSize(dynamicHSize: 0.005, dynamicWSize: 0.01)),
          titleMedium: _themeData.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontSize:
                calculatedFontSize(dynamicHSize: 0.005, dynamicWSize: 0.015),
          ),
          titleSmall: _themeData.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontSize:
                calculatedFontSize(dynamicHSize: 0.005, dynamicWSize: 0.01),
          ),
        ),
      );
}
