// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deneme_takip/components/alert_dialog.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/core/local_storage/local_storage_manager.dart';
import 'package:flutter_deneme_takip/services/auth_service.dart';
import 'package:flutter_deneme_takip/services/firebase_service.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/bottom_tabbar_view.dart';

enum LoginState {
  notLoggedIn,
  authenticating,
  loggedIn,
  loggedOut,
  loginError,
}

class DenemeLoginViewModel extends ChangeNotifier {
  LoginState? _loggedInStatus;
  User? _currentUser;
  bool? _isAnonymous;
  String? _error;
  late bool _isAlertOpen;
  final LocalStorageManager _storageManager = LocalStorageManager.instance;

  DenemeLoginViewModel() {
    _loggedInStatus = LoginState.notLoggedIn;
    _isAlertOpen = false;
    _isAnonymous = false;

    _currentUser = AuthService().fAuth.currentUser;
  }

  set setAnonymousLogin(bool newBool) {
    _isAnonymous = newBool;
    isAnonymousSave(_isAnonymous!);
    notifyListeners();
  }

  Future<bool?> get getIsAnonymous async {
    bool? isAnonymous = await _storageManager.getBool('isAnonymous');

    return Future.value(isAnonymous);
  }

  Future<void> isAnonymousSave(bool newBool) async {
    _storageManager.setBool("isAnonymous", newBool);
    //print(await _storageManager.getAllValues);
  }

  bool get getIsAlertOpen => _isAlertOpen;

  set setAlert(bool newBool) {
    _isAlertOpen = newBool;
  }

  LoginState get getState => _loggedInStatus!;
  set setState(LoginState newState) {
    _loggedInStatus = newState;
    notifyListeners();
  }

  String get getError => _error ?? 'Bİlinmeyen hata';
  set setError(String newError) {
    _error = newError;
  }

  Stream<User?> get userChanges => AuthService().fAuth.authStateChanges();

  set setUser(User? newUser) {
    try {
      _currentUser = newUser;
    } on FirebaseAuthException catch (e) {
      print(e);
      print("USER CATCH");
      _currentUser = null;
    }
  }

  User? get getCurrentUser {
    return _currentUser;
  }

  Future<void> loginWithGoogle(
      BuildContext context, DenemeLoginViewModel loginProv) async {
    setState = LoginState.notLoggedIn;
    setUser = await AuthService().signInWithGoogle();
    setState = LoginState.authenticating;
    try {
      if (getCurrentUser != null) {
        setState = LoginState.loggedIn;
        navigation.navigateToPageClear(path: NavigationConstants.homeView);

        FirebaseService().addUserToCollection(getCurrentUser!.displayName!,
            getCurrentUser!.email!, getCurrentUser!.uid);
      }
    } on FirebaseAuthException catch (error) {
      print("Login FIREBASE CATCH ERROR ${error.message}");
      setState = LoginState.loginError;
      setError = "İnternet bağlantısı yok!";
      SystemNavigator.pop();
    } catch (e) {
      print("Login CATCH ERROR $e");
      setState = LoginState.loginError;
      setError = e.toString();
    }
  }

  Future<void> loginWithOutGoogle(BuildContext context) async {
    setAnonymousLogin = true;
    if (await getIsAnonymous == true) {
      navigation.navigateToPageClear(path: NavigationConstants.homeView);
      setState = LoginState.loggedIn;
    } else {
      setState = LoginState.notLoggedIn;
      setAnonymousLogin = false;
      navigation.navigateToPageClear(path: NavigationConstants.homeView);
    }
  }

  Future<void> errorAlert(BuildContext context, String title, String content,
      DenemeLoginViewModel loginProv) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isOneButton: true,
      noFunction: () => {
        loginProv.setAlert = false,
        Navigator.of(context, rootNavigator: true).pop(),
      },
      yesFunction: () async => {
        loginProv.setAlert = false,
        Navigator.of(context, rootNavigator: true).pop(),
      },
    );

    if (loginProv.getIsAlertOpen == false) {
      loginProv.setAlert = true;
      await showDialog(
          barrierDismissible: false,
          barrierColor: const Color(0x66000000),
          context: context,
          builder: (BuildContext context) {
            return alert;
          }).then(
        (value) => loginProv.setAlert = false,
      );
    }
  }
}
