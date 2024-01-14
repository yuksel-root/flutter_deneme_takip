// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/gradient_widget.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/notifier/bottom_navigation_notifier.dart';

import 'package:flutter_deneme_takip/services/auth_service.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/bottom_tabbar_view.dart';
import 'package:flutter_deneme_takip/view_model/deneme_login_view_model.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';
import 'package:provider/provider.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().fAuth.currentUser;

    final denemeProv = Provider.of<DenemeViewModel>(context, listen: false);
    final lessonProv = Provider.of<LessonViewModel>(context, listen: false);
    final loginProv = Provider.of<DenemeLoginViewModel>(context, listen: false);
    final bottomProv =
        Provider.of<BottomNavigationProvider>(context, listen: false);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green, Colors.yellow]),
      ),
      width: context.mediaQuery.size.width / 1.5,
      child: Drawer(
        backgroundColor: Colors.transparent,
        child: Column(
          children: [
            Expanded(flex: 10, child: buildListTileHeader(currentUser)),
            Expanded(
                flex: 30,
                child: buildListTiles(
                    bottomProv, context, denemeProv, loginProv, lessonProv)),
          ],
        ),
      ),
    );
  }
}

GradientWidget buildListTileHeader(User? currentUser) {
  return GradientWidget(
    blendModes: BlendMode.hue,
    gradient: const LinearGradient(colors: [Colors.blue, Colors.purpleAccent]),
    widget: UserAccountsDrawerHeader(
        accountName: Text(currentUser?.displayName ?? "Offline kullanıcı"),
        accountEmail: Text(currentUser?.email ??
            "Lütfen Yedekleme için google ile giriş yapınız."),
        currentAccountPicture:
            ClipOval(child: Image.network(currentUser?.photoURL ?? "null"))),
  );
}

Widget drawerCardMenu(
    {required String title,
    required IconData icon,
    required Color iconColor,
    required Function onTap}) {
  return Card(
    child: ListTile(
      leading: GradientWidget(
          blendModes: BlendMode.srcIn,
          gradient:
                const LinearGradient(colors: [Colors.blue, Colors.purpleAccent]),
          widget: Icon(icon, color: iconColor)),
      title: GradientWidget(
          blendModes: BlendMode.srcIn,
          gradient:
              const LinearGradient(colors: [Colors.blue, Colors.purpleAccent]),
          widget: Text(title)),
      onTap: () => onTap(),
    ),
  );
}

Expanded buildListTiles(
    BottomNavigationProvider bottomProv,
    BuildContext context,
    DenemeViewModel denemeProv,
    DenemeLoginViewModel loginProv,
    LessonViewModel lessonProv) {
  return Expanded(
    flex: 30,
    child: Column(
      children: [
        drawerCardMenu(
          title: "Anasayfa",
          icon: Icons.home,
          iconColor: Colors.green,
          onTap: () async {
            bottomProv.setCurrentIndex = 0;

            Navigator.of(context, rootNavigator: true)
                .pushNamed(NavigationConstants.homeView);
          },
        ),
        drawerCardMenu(
          title: "Verileri Yedekle",
          icon: Icons.replay_circle_filled,
          iconColor: Colors.grey,
          onTap: () {
            denemeProv.showAlert(context,
                isOneButton: false,
                title: "Uyarı",
                content: "Şu anki veriler yedeklensin mi? ", yesFunction: () {
              backUpFunction(context, denemeProv);
            }, noFunction: () {
              Navigator.of(context, rootNavigator: true).pop();
            });
          },
        ),
        drawerCardMenu(
          title: "Verileri Yükle",
          icon: Icons.upload,
          iconColor: Colors.grey,
          onTap: () {
            denemeProv.showAlert(context,
                isOneButton: false,
                title: "Uyarı",
                content:
                    "Şu anki veriler yedeklenen veri ile değiştirilecektir",
                yesFunction: () async {
              await DenemeDbProvider.db.clearDatabase();
              restoreData(loginProv, denemeProv, lessonProv).then((value) {
                lessonProv.initLessonData(lessonProv.getLessonName);
                denemeProv.initDenemeData(denemeProv.getLessonName);

                navigation.navigateToPageClear(
                    path: NavigationConstants.homeView);
              });
            }, noFunction: () {
              Navigator.of(context, rootNavigator: true).pop();
            });
          },
        ),
        const Divider(),
        drawerCardMenu(
          title: "Verileri Temizle",
          icon: Icons.delete,
          iconColor: Colors.grey,
          onTap: () {
            denemeProv.showAlert(context,
                isOneButton: false,
                title: "Uyarı",
                content: "Tüm verileri silmek istiyor musunuz?",
                yesFunction: () async {
              await DenemeDbProvider.db.clearDatabase();
              lessonProv.initLessonData(lessonProv.getLessonName);
              denemeProv.initDenemeData(denemeProv.getLessonName);
              navigation.navigateToPageClear(
                  path: NavigationConstants.homeView);
            }, noFunction: () {
              Navigator.of(context, rootNavigator: true).pop();
            });
          },
        ),
        drawerCardMenu(
          title: "Çıkış",
          icon: Icons.logout,
          iconColor: Colors.grey,
          onTap: () {
            denemeProv.showAlert(context,
                isOneButton: false,
                title: "Uyarı",
                content: "Mevcut hesaptan çıkış yapmak ister misiniz?",
                yesFunction: () async {
              if (AuthService().fAuth.currentUser != null ||
                  await loginProv.getIsAnonymous == true) {
                AuthService().signOut();
                loginProv.setAnonymousLogin = false;
                loginProv.setState = LoginState.notLoggedIn;
                navigation.navigateToPageClear(
                    path: NavigationConstants.homeView);
              } else {}
            }, noFunction: () {
              Navigator.of(context, rootNavigator: true).pop();
            });
          },
        ),
        const Divider(),
        drawerCardMenu(
          title: "Kullanıcı hesabını sil",
          icon: Icons.delete,
          iconColor: Colors.grey,
          onTap: () {
            denemeProv.showAlert(context,
                isOneButton: false,
                title: "Uyarı",
                content: "Mevcut kullanıcı hesabı silinecektir ?",
                yesFunction: () async {
              if (AuthService().fAuth.currentUser != null ||
                  await loginProv.getIsAnonymous == true) {
                denemeProv
                    .deleteUserInFirebase(AuthService().fAuth.currentUser!.uid);
                loginProv.setAnonymousLogin = false;
                loginProv.setState = LoginState.notLoggedIn;

                Navigator.of(context, rootNavigator: true)
                    .pushNamed(NavigationConstants.homeView);
              } else {}
            }, noFunction: () {
              Navigator.of(context, rootNavigator: true).pop();
            });
          },
        ),
      ],
    ),
  );
}

void backUpFunction(BuildContext context, DenemeViewModel denemeProv) {
  try {
    String? userId = AuthService().fAuth.currentUser?.uid;

    if (userId != null) {
      denemeProv.removeUserPostData(userId).then((value) {
        denemeProv
            .backUpAllTablesData(context, userId, denemeProv)
            .then((value) async {
          Future.delayed(const Duration(milliseconds: 10), () async {
            //   final tables = await denemeProv.getTablesFromFirebase(userId);
            //  print(tables);
            Navigator.of(context, rootNavigator: true).pop();
            denemeProv.errorAlert(
                context, "Bilgi", "Veriler başarıyla yedeklendi..", denemeProv);
          });
        });
      });
    } else {
      denemeProv.errorAlert(context, "Uyarı",
          "Lütfen google girişi yaparak tekrar deneyiniz.", denemeProv);
    }
  } on FirebaseAuthException catch (error) {
    print(error);
    denemeProv.errorAlert(context, "Uyarı",
        "Lütfen google girişi yaparak tekrar deneyiniz.", denemeProv);
  } catch (e) {
    denemeProv.errorAlert(context, "Uyarı",
        "Lütfen google girişi yaparak tekrar deneyiniz.", denemeProv);
  }
}

Future<void> restoreData(DenemeLoginViewModel loginProv,
    DenemeViewModel denemeProv, LessonViewModel lessonProv) async {
  if (AuthService().fAuth.currentUser != null ||
      await loginProv.getIsAnonymous == true) {
    String? userId = AuthService().fAuth.currentUser?.uid;

    final denemePostData =
        await denemeProv.getTablesFromFirebase(userId!) ?? {};

    denemeProv.sendFirebaseToSqlite(denemePostData);
  }
}
