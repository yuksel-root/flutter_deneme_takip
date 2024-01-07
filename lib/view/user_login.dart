import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/bottom_tabbar_view.dart';
import 'package:flutter_deneme_takip/view_model/deneme_login_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';

class UserLoginView extends StatelessWidget {
  const UserLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProv = Provider.of<DenemeLoginViewModel>(context, listen: false);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Deneme Takip Giriş'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  height: 100,
                  width: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/icon/login.png'),
                      fit: BoxFit.fill,
                      alignment: Alignment.center,
                      repeat: ImageRepeat.noRepeat,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    if (context.read<DenemeLoginViewModel>().getState ==
                        LoginState.notLoggedIn) {
                      loginProv.loginWithGoogle(context);
                    } else if (context.read<DenemeLoginViewModel>().getState ==
                        LoginState.loginError) {
                      loginProv.errorAlert(
                          context, "Uyarı", loginProv.getError, loginProv);
                      loginProv.setState = LoginState.notLoggedIn;
                    } else {
                      if (context.read<DenemeLoginViewModel>().getState ==
                          LoginState.loggedIn) {
                        loginProv.errorAlert(
                            context, "Uyarı", loginProv.getError, loginProv);
                        navigation.navigateToPage(
                            path: NavigationConstants.homeView, data: []);
                      }
                      loginProv.errorAlert(context, "Uyarı", "ELSE", loginProv);
                    }
                    loginProv.errorAlert(
                        context, "Uyarı", loginProv.getError, loginProv);
                  },
                  child: const Text('Google ile Giriş'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
