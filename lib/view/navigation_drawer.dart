import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';
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
    return SizedBox(
      width: context.mediaQuery.size.width / 1.5,
      child: Drawer(
        child: Column(
          children: [
            Expanded(
              flex: 10,
              child: UserAccountsDrawerHeader(
                accountName:
                    Text(currentUser?.displayName ?? "Offline kullanıcı"),
                accountEmail: Text(currentUser?.email ??
                    "Lütfen Yedekleme için google ile giriş yapınız."),
                currentAccountPicture: ClipOval(
                    child: Image.network(currentUser?.photoURL ?? "null")),
              ),
            ),
            Expanded(
              flex: 30,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home, color: Colors.green),
                    title: const Text("Anasayfa"),
                    onTap: () {
                      bottomProv.setCurrentIndex = 0;
                      Navigator.of(context, rootNavigator: true)
                          .pushNamed(NavigationConstants.homeView);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.replay_circle_filled,
                        color: Colors.grey),
                    title: const Text("Verileri Yedekle"),
                    onTap: () {
                      denemeProv.showAlert(context,
                          isOneButton: false,
                          title: "Uyarı",
                          content: "Şu anki veriler yedeklensin mi? ",
                          yesFunction: () {
                        backUpFunction(context, denemeProv);
                      }, noFunction: () {
                        Navigator.of(context, rootNavigator: true)
                            .pushNamed(NavigationConstants.homeView);
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.upload, color: Colors.grey),
                    title: const Text("Verileri Yükle"),
                    onTap: () {
                      denemeProv.showAlert(context,
                          isOneButton: false,
                          title: "Uyarı",
                          content:
                              "Şu anki veriler yedeklenen veri ile değiştirilecektir",
                          yesFunction: () {
                        restoreData(loginProv, denemeProv, lessonProv)
                            .then((value) {
                          Navigator.of(context, rootNavigator: true)
                              .pushNamed(NavigationConstants.homeView);
                        });
                      }, noFunction: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      });
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.grey),
                    title: const Text("Verileri Temizle"),
                    onTap: () async {
                      denemeProv.showAlert(context,
                          isOneButton: false,
                          title: "Uyarı",
                          content: "Tüm verileri silmek istiyor musunuz?",
                          yesFunction: () async {
                        await DenemeDbProvider.db.clearDatabase();
                        lessonProv.initLessonData(lessonProv.getLessonName);
                        denemeProv.initData(denemeProv.getLessonName);
                        navigation.navigateToPageClear(
                            path: NavigationConstants.homeView);
                      }, noFunction: () {
                        Navigator.of(context, rootNavigator: true)
                            .pushNamed(NavigationConstants.homeView);
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.grey),
                    title: const Text("Çıkış"),
                    onTap: () {
                      AuthService().signOut().then((value) {
                        navigation.navigateToPageClear(
                            path: NavigationConstants.loginView);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
              denemeProv.errorAlert(context, "Bilgi",
                  "Veriler başarıyla yedeklendi..", denemeProv);
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

      var table = await denemeProv.getTablesFromFirebase(userId!);

      final hTable = table![DenemeTables.historyTableName];
      final gTable = table[DenemeTables.geographyTable];
      final cTable = table[DenemeTables.citizenTable];

      List<Map<String, dynamic>>? historyTable =
          denemeProv.convertFirebaseToSqliteData(hTable!, denemeProv);
      List<Map<String, dynamic>>? citizenTable =
          denemeProv.convertFirebaseToSqliteData(gTable!, denemeProv);
      List<Map<String, dynamic>>? geographyTable =
          denemeProv.convertFirebaseToSqliteData(cTable!, denemeProv);

      List<dynamic> denemePostData = [
        historyTable,
        geographyTable,
        citizenTable,
      ];

      denemeProv.sendFirebaseToSqlite(denemePostData);
    }
    lessonProv.initLessonData(lessonProv.getLessonName);
    denemeProv.initData(denemeProv.getLessonName);
  }
}
