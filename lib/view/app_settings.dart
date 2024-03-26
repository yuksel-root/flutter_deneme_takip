import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/app_bar/custom_app_bar.dart';
import 'package:flutter_deneme_takip/core/constants/color_constants.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: CustomAppBar(
        appBar: AppBar(
          title: const Text("Uygulama Ayarları"),
        ),
        dynamicPreferredSize: context.dynamicH(0.15),
        gradients: ColorConstants.appBarGradient,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Hesap Ayarları'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Bildirim Ayarları'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
