import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/sign_button.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/services/auth_service.dart';
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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff1c0f45),
          title: Center(
            child: Text(
              'Deneme Takip Giriş',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: context.dynamicW(0.01) * context.dynamicH(0.0065)),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 40,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/icon/login.png'),
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      repeat: ImageRepeat.noRepeat,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1),
              Expanded(
                  flex: 5,
                  child: buildSignWithGoogleButton(context, loginProv)),
              const Spacer(flex: 1),
              Expanded(
                  flex: 5, child: buildSignWithOutGoogle(context, loginProv)),
              const Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }

  SignButton buildSignWithGoogleButton(
      BuildContext context, DenemeLoginViewModel loginProv) {
    return SignButton(
        isGreyPng: false,
        onPressFunct: () async {
          if (context.read<DenemeLoginViewModel>().getState ==
                  LoginState.notLoggedIn ||
              loginProv.getIsAnonymous == false) {
            loginProv.loginWithGoogle(context, loginProv);
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
              navigation
                  .navigateToPage(path: NavigationConstants.homeView, data: []);
            }
            print("CURRENTUserLOGİN  ${AuthService().fAuth.currentUser}");

            loginProv.errorAlert(
                context, "Uyarı", loginProv.getState.toString(), loginProv);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff1c0f45),
        ),
        labelText: "Google Girişi",
        labelStyle: TextStyle(
            color: Colors.white,
            fontSize: context.dynamicW(0.01) * context.dynamicH(0.005)));
  }

  SignButton buildSignWithOutGoogle(
      BuildContext context, DenemeLoginViewModel loginProv) {
    return SignButton(
        isGreyPng: true,
        onPressFunct: () {
          loginProv.loginWithOutGoogle(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff1c0f45),
        ),
        labelText: "Google olmadan  giriş",
        labelStyle: TextStyle(
            color: Colors.white,
            fontSize: context.dynamicW(0.01) * context.dynamicH(0.005)));
  }
}
