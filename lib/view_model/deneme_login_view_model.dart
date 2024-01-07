import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deneme_takip/components/alert_dialog.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/core/local_storage/local_storage_manager.dart';
import 'package:flutter_deneme_takip/services/auth_service.dart';
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

  Future<void> loginWithGoogle(
      BuildContext context, DenemeLoginViewModel loginProv) async {
    _currentUser = AuthService().fAuth.currentUser;
    print("newUser $_currentUser");

    if (_currentUser == null &&
        getState == LoginState.notLoggedIn &&
        await loginProv.getIsAnonymous == false) {
      setState = LoginState.authenticating;
      try {
        _currentUser = await AuthService().signInWithGoogle();
        if (_currentUser != null) {
          setState = LoginState.loggedIn;
          navigation.navigateToPageClear(path: NavigationConstants.homeView);
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
    } else {
      print("CURRENTUserViewModel else  $_currentUser");
      setState = LoginState.loggedIn;
      navigation.navigateToPageClear(path: NavigationConstants.homeView);
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
      navigation.navigateToPageClear(path: NavigationConstants.loginView);
    }
  }

  Future<void> errorAlert(BuildContext context, String title, String content,
      DenemeLoginViewModel loginProv) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isAlert: true,
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
