import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/services/auth_service.dart';

class UserLogin extends StatelessWidget {
  const UserLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Responsive Resim ve Buton'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex:
                    2, // Resmin genişliğini belirlemek için esneklik (flex) ekleyin
                child: Image.network(
                  'https://via.placeholder.com/350x150',
                  width: 350,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(flex: 1),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final user = await AuthService().signInWithGoogle();
                      if (user != null) {
                        Navigator.pushReplacementNamed(
                            context, NavigationConstants.homeView);
                      }
                    } on FirebaseAuthException catch (error) {
                      print("Login firebase catch error ${error.message}");
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(error.message ?? "Giriş yapılamadı")));
                    } catch (e) {
                      print("Login catch error $e");
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: Text('Google ile Giriş'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
