import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/services/auth_service.dart';
import 'package:flutter_deneme_takip/view_model/deneme_login_view_model.dart';
import 'package:provider/provider.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProv = Provider.of<DenemeLoginViewModel>(context, listen: false);
    return ElevatedButton.icon(
        icon: const Icon(color: Colors.green, Icons.home_work),
        label: Text(" Çıkış ",
            style: TextStyle(
                color: Colors.white,
                fontSize: context.dynamicH(0.00571) * context.dynamicW(0.01))),
        onPressed: () async {
          if (AuthService().fAuth.currentUser != null) {
            AuthService().signOut();
            loginProv.setState = LoginState.notLoggedIn;
            Navigator.of(context).pushNamedAndRemoveUntil(
                NavigationConstants.loginView, (route) => false);
          } else {}
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: const StadiumBorder(),
          foregroundColor: Colors.black,
        ));
  }
}
