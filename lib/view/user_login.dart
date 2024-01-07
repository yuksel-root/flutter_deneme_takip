import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
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
          title: Text(
            'Deneme Takip Google Giriş',
            style: TextStyle(
                color: Colors.white,
                fontSize: context.dynamicW(0.01) * context.dynamicH(0.0065)),
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1c0f45),
                  ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/img/icon/login.png',
                        width: context.dynamicW(0.1),
                        height: context.dynamicH(0.0714),
                      ),
                      SizedBox(
                        width: context.dynamicW(0.05),
                      ),
                      Text(
                        'Google ile Giriş',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: context.dynamicW(0.01) *
                                context.dynamicH(0.005)),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }
}
