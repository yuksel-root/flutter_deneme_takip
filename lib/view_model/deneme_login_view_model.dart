import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/alert_dialog.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
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
  String? _error;
  late bool _isAlertOpen;

  DenemeLoginViewModel() {
    _loggedInStatus = LoginState.notLoggedIn;
    _isAlertOpen = false;
    _currentUser = AuthService().fAuth.currentUser;
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

  String get getError => _error!;
  set setError(String newError) {
    _error = newError;
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    print("oldUser $_currentUser");
    _currentUser = AuthService().fAuth.currentUser;
    print("newUser $_currentUser");

    if (_currentUser == null && getState == LoginState.notLoggedIn) {
      setState = LoginState.authenticating;
      try {
        _currentUser = await AuthService().signInWithGoogle();
        if (_currentUser != null) {
          setState = LoginState.loggedIn;
          navigation.navigateToPage(path: NavigationConstants.homeView);
        }
      } on FirebaseAuthException catch (error) {
        print("Login FIREBASE CATCH ERROR ${error.message}");
        setState = LoginState.loginError;
        setError = "İnternet bağlantısı yok!";
      } catch (e) {
        print("Login CATCH ERROR $e");
        setState = LoginState.loginError;
        setError = e.toString();
      }
    } else {
      print("CURRENTUser not null error $_currentUser");
      setState = LoginState.loginError;
      setError = "CURRENTUser Not Null Error";
      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Kullanıcı verisi  zaten var")));
        }
      });
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
        Navigator.of(context).pop(),
      },
      yesFunction: () async => {
        loginProv.setAlert = false,
        Navigator.of(context).pop(),
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
