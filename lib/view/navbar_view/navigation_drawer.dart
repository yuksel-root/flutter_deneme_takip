// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/utils/gradient_widget.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/notifier/bottom_navigation_notifier.dart';
import 'package:flutter_deneme_takip/services/auth_service.dart';
import 'package:flutter_deneme_takip/services/firebase_service.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/bottom_tabbar_view.dart';
import 'package:flutter_deneme_takip/view_model/deneme_login_view_model.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';
import 'package:provider/provider.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final denemeProv = Provider.of<DenemeViewModel>(context, listen: false);
    final lessonProv = Provider.of<LessonViewModel>(context, listen: false);
    final loginProv = Provider.of<DenemeLoginViewModel>(context, listen: true);
    final bottomProv =
        Provider.of<BottomNavigationProvider>(context, listen: false);
    final currentUser = loginProv.getCurrentUser;
    //print(currentUser);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green, Colors.yellow]),
      ),
      width: context.mediaQuery.size.width / 1.5,
      height: context.mediaQuery.size.height,
      child: Drawer(
        backgroundColor: Colors.transparent,
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 21,
                child: buildListTileHeader(
                    context, loginProv, currentUser, denemeProv)),
            Expanded(
                flex: 50,
                child: buildListTiles(currentUser, bottomProv, context,
                    denemeProv, loginProv, lessonProv)),
          ],
        ),
      ),
    );
  }
}

Column buildListTileHeader(BuildContext context, DenemeLoginViewModel loginProv,
    User? currentUser, DenemeViewModel denemeProv) {
  return Column(
    children: [
      GradientWidget(
        blendModes: BlendMode.hue,
        gradient:
            const LinearGradient(colors: [Colors.blue, Colors.purpleAccent]),
        widget: UserAccountsDrawerHeader(
          accountName: Text(currentUser?.displayName ?? "Çevrimdışı kullanıcı",
              style: TextStyle(
                  fontSize: context.dynamicW(0.01) * context.dynamicH(0.005))),
          accountEmail: Text(
              currentUser?.email ?? "Lütfen Yedekleme için  giriş yapınız.",
              style: TextStyle(
                  fontSize: context.dynamicW(0.01) * context.dynamicH(0.004))),
          currentAccountPicture: Row(
            children: [
              Expanded(
                  child: ClipOval(
                child: buildProfileImage(context, denemeProv, currentUser),
              )),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget buildProfileImage(
    BuildContext context, DenemeViewModel denemeProv, User? currentUser) {
  try {
    if (currentUser != null) {
      return Image.network(currentUser.photoURL!);
    }
  } catch (e) {
    print("Error loading image: $e");
  }

  return FlutterLogo(size: context.dynamicW(0.13));
}

Expanded drawerCardMenu(BuildContext context,
    {required String title,
    int? flex,
    required IconData icon,
    required Gradient textGradient,
    required Gradient cardGradient,
    required Gradient iconGradient,
    required Function onTap}) {
  return Expanded(
    flex: flex ?? 2,
    child: Card(
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                gradient: cardGradient,
              ),
              child: ListTile(
                leading: GradientWidget(
                    blendModes: BlendMode.srcIn,
                    gradient: iconGradient,
                    widget: Icon(
                      icon,
                      size: context.dynamicW(0.01) * context.dynamicH(0.005),
                    )),
                title: GradientWidget(
                    blendModes: BlendMode.srcIn,
                    gradient: textGradient,
                    widget: Text(
                      title,
                      style: TextStyle(
                          fontSize:
                              context.dynamicW(0.01) * context.dynamicH(0.005)),
                    )),
                onTap: () {
                  onTap();
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Column buildListTiles(
    User? currentUser,
    BottomNavigationProvider bottomProv,
    BuildContext context,
    DenemeViewModel denemeProv,
    DenemeLoginViewModel loginProv,
    LessonViewModel lessonProv) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      currentUser == null
          ? drawerCardMenu(
              context,
              iconGradient:
                  const LinearGradient(colors: [Colors.white, Colors.white]),
              cardGradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purpleAccent]),
              textGradient:
                  const LinearGradient(colors: [Colors.white, Colors.white]),
              title: "Giriş Yap",
              icon: Icons.account_circle_rounded,
              onTap: () async {
                navigation.navigateToPage(
                    path: NavigationConstants.homeView, data: []);
                await Future.delayed(const Duration(milliseconds: 50), () {
                  if (context.read<DenemeLoginViewModel>().getState ==
                      LoginState.notLoggedIn) {
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
                      navigation.navigateToPage(
                          path: NavigationConstants.homeView, data: []);
                    }

                    loginProv.errorAlert(context, "Uyarı",
                        loginProv.getState.toString(), loginProv);
                  }
                  // print(loginProv.getState);
                  Navigator.of(context, rootNavigator: true)
                      .pushNamed(NavigationConstants.homeView);
                });
              },
            )
          : const SizedBox(),
      drawerCardMenu(
        context,
        iconGradient:
            const LinearGradient(colors: [Colors.white, Colors.white]),
        cardGradient:
            const LinearGradient(colors: [Colors.blue, Colors.purpleAccent]),
        textGradient:
            const LinearGradient(colors: [Colors.white, Colors.white]),
        title: "Dersler",
        icon: Icons.library_books,
        onTap: () async {
          bottomProv.setCurrentIndex = 0;

          Navigator.of(context, rootNavigator: true)
              .pushNamed(NavigationConstants.homeView);
        },
      ),
      drawerCardMenu(
        context,
        iconGradient:
            const LinearGradient(colors: [Colors.white, Colors.white]),
        cardGradient:
            const LinearGradient(colors: [Colors.blue, Colors.purpleAccent]),
        textGradient:
            const LinearGradient(colors: [Colors.white, Colors.white]),
        title: "Denemeler",
        icon: Icons.group_work_rounded,
        onTap: () async {
          bottomProv.setCurrentIndex = 1;
          Navigator.of(context, rootNavigator: true)
              .pushNamed(NavigationConstants.homeView);
        },
      ),
      drawerCardMenu(
        context,
        iconGradient:
            const LinearGradient(colors: [Colors.white, Colors.white]),
        cardGradient:
            const LinearGradient(colors: [Colors.blue, Colors.purpleAccent]),
        textGradient:
            const LinearGradient(colors: [Colors.white, Colors.white]),
        title: "Yeni Deneme Ekle",
        icon: Icons.assured_workload,
        onTap: () async {
          bottomProv.setCurrentIndex = 2;
          Navigator.of(context, rootNavigator: true)
              .pushNamed(NavigationConstants.homeView);
        },
      ),
      drawerCardMenu(
        context,
        iconGradient: currentUser != null
            ? const LinearGradient(colors: [Colors.white, Colors.white])
            : LinearGradient(
                colors: [
                  Colors.grey.shade300.withOpacity(0.7),
                  Colors.grey.shade200.withOpacity(0.66)
                ],
              ),
        cardGradient: currentUser != null
            ? const LinearGradient(colors: [Colors.blue, Colors.purpleAccent])
            : LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.55)
                ],
              ),
        textGradient: currentUser != null
            ? const LinearGradient(colors: [Colors.white, Colors.white])
            : LinearGradient(
                colors: [
                  Colors.grey.shade300.withOpacity(0.9),
                  Colors.grey.shade200.withOpacity(0.99),
                ],
              ),
        title: "Verileri Yedekle",
        icon: Icons.replay_circle_filled,
        onTap: () {
          currentUser != null
              ? denemeProv.showAlert(context,
                  isOneButton: false,
                  title: "Uyarı",
                  content: "Şu anki veriler yedeklensin mi? ", yesFunction: () {
                  backUpFunction(context, denemeProv, currentUser, loginProv);
                }, noFunction: () {
                  Navigator.of(context, rootNavigator: true).pop();
                })
              : currentUserNullAlert(context, denemeProv);
        },
      ),
      drawerCardMenu(
        context,
        iconGradient: currentUser != null
            ? const LinearGradient(colors: [Colors.white, Colors.white])
            : LinearGradient(
                colors: [
                  Colors.grey.shade300.withOpacity(0.7),
                  Colors.grey.shade200.withOpacity(0.66)
                ],
              ),
        cardGradient: currentUser != null
            ? const LinearGradient(colors: [Colors.blue, Colors.purpleAccent])
            : LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.55)
                ],
              ),
        textGradient: currentUser != null
            ? const LinearGradient(colors: [Colors.white, Colors.white])
            : LinearGradient(
                colors: [
                  Colors.grey.shade300.withOpacity(0.9),
                  Colors.grey.shade200.withOpacity(0.99),
                ],
              ),
        title: "Verileri Yükle",
        icon: Icons.upload,
        onTap: () {
          currentUser != null
              ? denemeProv.showAlert(context,
                  isOneButton: false,
                  title: "Uyarı",
                  content:
                      "Şu anki veriler yedeklenen veri ile değiştirilecektir",
                  yesFunction: () async {
                  Future.delayed(Duration.zero, () async {
                    await restoreData(context, loginProv, denemeProv,
                            lessonProv, currentUser)
                        .then((value) {
                      lessonProv.initLessonData(lessonProv.getLessonName);
                      denemeProv.initDenemeData(denemeProv.getLessonName);
                    });
                  });
                }, noFunction: () {
                  Navigator.of(context, rootNavigator: true).pop();
                })
              : currentUserNullAlert(context, denemeProv);
        },
      ),
      currentUser != null
          ? drawerCardMenu(
              context,
              iconGradient:
                  const LinearGradient(colors: [Colors.white, Colors.white]),
              cardGradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purpleAccent]),
              textGradient:
                  const LinearGradient(colors: [Colors.white, Colors.white]),
              title: "Çıkış",
              icon: Icons.logout,
              onTap: () {
                denemeProv.showAlert(context,
                    isOneButton: false,
                    title: "Uyarı",
                    content: "Mevcut hesaptan çıkış yapmak ister misiniz?",
                    yesFunction: () async {
                  AuthService().signOut();

                  loginProv.setState = LoginState.notLoggedIn;
                  loginProv.setCurrentUser = null;
                  navigation.navigateToPageClear(
                      path: NavigationConstants.homeView);
                }, noFunction: () {
                  Navigator.of(context, rootNavigator: true).pop();
                });
              },
            )
          : drawerCardMenu(context,
              title: "Uygulamadan Çıkış",
              icon: Icons.exit_to_app,
              textGradient:
                  const LinearGradient(colors: [Colors.white, Colors.white]),
              cardGradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purpleAccent]),
              iconGradient:
                  const LinearGradient(colors: [Colors.white, Colors.white]),
              onTap: () {
              denemeProv.showAlert(context,
                  isOneButton: false,
                  title: "Uyarı",
                  content: "Uygulamadan Çıkmak istiyor musunuz?",
                  yesFunction: () {
                exit(0);
              }, noFunction: () {
                Navigator.of(context, rootNavigator: true)
                    .pushNamed(NavigationConstants.homeView);
              });
            }),
      const Divider(),
      drawerCardMenu(
        context,
        iconGradient: const LinearGradient(colors: [Colors.red, Colors.red]),
        cardGradient:
            const LinearGradient(colors: [Colors.white, Colors.white]),
        textGradient: const LinearGradient(colors: [Colors.red, Colors.red]),
        title: "Tüm Verileri Yok Et",
        icon: Icons.delete,
        onTap: () {
          denemeProv.showAlert(context,
              isOneButton: false,
              title: "Uyarı",
              content: "Tüm verileri silmek istiyor musunuz?",
              yesFunction: () async {
            await DenemeDbProvider.db.clearDatabase();
            lessonProv.initLessonData(lessonProv.getLessonName);
            denemeProv.initDenemeData(denemeProv.getLessonName);
            navigation.navigateToPageClear(path: NavigationConstants.homeView);
          }, noFunction: () {
            Navigator.of(context, rootNavigator: true).pop();
          });
        },
      ),
      drawerCardMenu(
        context,
        iconGradient: currentUser != null
            ? const LinearGradient(colors: [Colors.white, Colors.white])
            : LinearGradient(
                colors: [
                  Colors.grey.shade300.withOpacity(0.7),
                  Colors.grey.shade200.withOpacity(0.66)
                ],
              ),
        cardGradient: currentUser != null
            ? const LinearGradient(colors: [Colors.blue, Colors.purpleAccent])
            : LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.55)
                ],
              ),
        textGradient: currentUser != null
            ? const LinearGradient(colors: [Colors.white, Colors.white])
            : LinearGradient(
                colors: [
                  Colors.grey.shade300.withOpacity(0.9),
                  Colors.grey.shade200.withOpacity(0.99),
                ],
              ),
        title: "Kullanıcı Hesabını Sil",
        icon: Icons.remove_circle,
        onTap: () async {
          currentUser != null
              ? denemeProv.showAlert(context,
                  isOneButton: false,
                  title: "Uyarı",
                  content: "Mevcut kullanıcı hesabı silinecektir ?",
                  yesFunction: () async {
                  await denemeProv
                      .deleteUserInFirebase(
                          context, currentUser.uid, denemeProv, loginProv)
                      .then((value) async {
                    await Future.delayed(const Duration(milliseconds: 100),
                        () async {
                      await AuthService().signOut();
                      loginProv.setAnonymousLogin = false;
                      loginProv.setState = LoginState.notLoggedIn;
                      loginProv.setCurrentUser = null;
                    });
                  });

                  Future.delayed(Duration.zero, () {
                    Navigator.of(context, rootNavigator: true)
                        .pushNamed(NavigationConstants.homeView);
                    denemeProv.setAlert = false;
                  });
                }, noFunction: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  denemeProv.setAlert = false;
                })
              : currentUserNullAlert(context, denemeProv);
        },
      ),
    ],
  );
}

void currentUserNullAlert(BuildContext context, DenemeViewModel denemeProv) {
  denemeProv.showAlert(context,
      isOneButton: true,
      title: "Uyarı",
      content: "Bu özellik için Lütfen giriş yapınız!", yesFunction: () {
    Navigator.of(context, rootNavigator: true)
        .pushNamed(NavigationConstants.homeView);
  }, noFunction: () {
    Navigator.of(context, rootNavigator: true)
        .pushNamed(NavigationConstants.homeView);
  });
}

Future<void> backUpFunction(BuildContext context, DenemeViewModel denemeProv,
    User? currentUser, loginProv) async {
  await denemeProv.backUpAllTablesData(
      context, currentUser!.uid, denemeProv, loginProv);
}

Future<void> restoreData(
    BuildContext context,
    DenemeLoginViewModel loginProv,
    DenemeViewModel denemeProv,
    LessonViewModel lessonProv,
    User? currentUser) async {
  try {
    print("abb");
    if (currentUser != null) {
      final isOnline =
          await FirebaseService().isFromCache(currentUser.uid) ?? {};
      final denemePostData =
          await denemeProv.getTablesFromFirebase(currentUser.uid) ?? {};
      print("abcccb");

      if (isOnline.isEmpty) {
        Future.delayed(Duration.zero, () {
          navigation.navigateToPage(path: NavigationConstants.homeView);

          denemeProv.errorAlert(
              context, "Uyarı", "İnternet olduğundan emin olunuz!", denemeProv);
        });
      } else {
        await DenemeDbProvider.db.clearDatabase();
        await denemeProv.sendFirebaseToSqlite(denemePostData);
        navigation.navigateToPage(path: NavigationConstants.homeView);
      }
    }
  } catch (e) {
    print("restoreData catch drawer $e");
  }
}
