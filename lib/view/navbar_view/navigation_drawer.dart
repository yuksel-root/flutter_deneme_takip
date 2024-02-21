// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/indicator_alert/loading_indicator_alert.dart';
import 'package:flutter_deneme_takip/components/utils/gradient_widget.dart';
import 'package:flutter_deneme_takip/core/constants/app_theme.dart';
import 'package:flutter_deneme_takip/core/constants/color_constants.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/notifier/bottom_navigation_notifier.dart';
import 'package:flutter_deneme_takip/services/auth_service.dart';
import 'package:flutter_deneme_takip/view_model/deneme_login_view_model.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_deneme_view_model.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';
import 'package:provider/provider.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final denemeProv = Provider.of<DenemeViewModel>(context, listen: false);
    final lessonProv = Provider.of<LessonViewModel>(context, listen: false);
    final loginProv = Provider.of<DenemeLoginViewModel>(context, listen: true);
    final editProv = Provider.of<EditDenemeViewModel>(context, listen: true);
    final bottomProv =
        Provider.of<BottomNavigationProvider>(context, listen: false);
    final currentUser = loginProv.getCurrentUser;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade400, Colors.grey.shade500],
        ),
      ),
      width: context.mediaQuery.size.width / 1.5,
      height: context.mediaQuery.size.height,
      child: Drawer(
        backgroundColor: Colors.transparent,
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 18,
                child: buildListTileHeader(
                    context, loginProv, currentUser, denemeProv)),
            Expanded(
                flex: 55,
                child: buildListTiles(currentUser, bottomProv, context,
                    denemeProv, loginProv, lessonProv, editProv)),
          ],
        ),
      ),
    );
  }
}

Column buildListTileHeader(BuildContext context, DenemeLoginViewModel loginProv,
    User? currentUser, DenemeViewModel denemeProv) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.max,
    children: [
      GradientWidget(
        blendModes: BlendMode.color,
        gradient: ColorConstants.secondaryGradient,
        widget: UserAccountsDrawerHeader(
          accountName: Text(currentUser?.displayName ?? "Çevrimdışı kullanıcı",
              style: TextStyle(
                  fontSize: AppTheme.dynamicSize(
                      dynamicHSize: 0.005, dynamicWSize: 0.01))),
          accountEmail: Text(
              currentUser?.email ?? "Lütfen Yedekleme için  giriş yapınız.",
              style: TextStyle(
                  fontSize: AppTheme.dynamicSize(
                      dynamicHSize: 0.004, dynamicWSize: 0.01))),
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
      denemeProv.isOnline(currentUser.uid);
      if (denemeProv.getOnline) {
        return Image.network(currentUser.photoURL!);
      }
    }
  } catch (e) {
    print("Error loading image: $e");
  }

  return FlutterLogo(
      size: AppTheme.dynamicSize(dynamicHSize: 0.01, dynamicWSize: 0.014));
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
    flex: flex ?? 1,
    child: Card(
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(
                    AppTheme.dynamicSize(
                        dynamicHSize: 0.005, dynamicWSize: 0.006))),
                gradient: cardGradient,
              ),
              child: ListTile(
                leading: GradientWidget(
                    blendModes: BlendMode.srcIn,
                    gradient: iconGradient,
                    widget: Icon(icon,
                        size: AppTheme.dynamicSize(
                            dynamicHSize: 0.005, dynamicWSize: 0.01))),
                title: GradientWidget(
                    blendModes: BlendMode.srcIn,
                    gradient: textGradient,
                    widget: Text(title,
                        style: TextStyle(
                            fontSize: AppTheme.dynamicSize(
                                dynamicHSize: 0.005, dynamicWSize: 0.01)))),
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
    LessonViewModel lessonProv,
    EditDenemeViewModel editProv) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      currentUser == null
          ? drawerCardMenu(
              context,
              iconGradient:
                  const LinearGradient(colors: [Colors.white, Colors.white]),
              cardGradient: ColorConstants.navCardGradient,
              textGradient: ColorConstants.navTextGradient,
              title: "Giriş Yap",
              icon: Icons.account_circle_rounded,
              onTap: () async {
                editProv.setLoading = true;
                Navigator.of(context, rootNavigator: true)
                    .pushNamed(NavigationConstants.homeView);

                await Future.delayed(const Duration(milliseconds: 10), () {
                  showLoadingAlertDialog(
                    context,
                    title: 'Giriş Yapılıyor...',
                  );
                });
                await Future.delayed(const Duration(milliseconds: 1500),
                    () async {
                  Navigator.of(context, rootNavigator: true)
                      .pushNamed(NavigationConstants.homeView);
                });
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
                      Navigator.of(context, rootNavigator: true)
                          .pushNamed(NavigationConstants.homeView);
                    }

                    loginProv.errorAlert(context, "Uyarı",
                        loginProv.getState.toString(), loginProv);
                  }
                });
              },
            )
          : const SizedBox(),
      drawerCardMenu(
        context,
        iconGradient:
            const LinearGradient(colors: [Colors.white, Colors.white]),
        cardGradient: ColorConstants.navCardGradient,
        textGradient: ColorConstants.navTextGradient,
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
        cardGradient: ColorConstants.navCardGradient,
        textGradient: ColorConstants.navTextGradient,
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
        cardGradient: ColorConstants.navCardGradient,
        textGradient: ColorConstants.navTextGradient,
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
            ? ColorConstants.navCardGradient
            : LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.55)
                ],
              ),
        textGradient: currentUser != null
            ? ColorConstants.navTextGradient
            : LinearGradient(
                colors: [
                  Colors.grey.shade300.withOpacity(0.9),
                  Colors.grey.shade200.withOpacity(0.99),
                ],
              ),
        title: "Verileri Yedekle",
        icon: Icons.replay_circle_filled,
        onTap: () {
          denemeProv.setAlert = false;
          backUpFunction(context, denemeProv, currentUser, loginProv);
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
            ? ColorConstants.navCardGradient
            : LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.55)
                ],
              ),
        textGradient: currentUser != null
            ? ColorConstants.navTextGradient
            : LinearGradient(
                colors: [
                  Colors.grey.shade300.withOpacity(0.9),
                  Colors.grey.shade200.withOpacity(0.99),
                ],
              ),
        title: "Verileri Yükle",
        icon: Icons.upload,
        onTap: () {
          denemeProv.setAlert = false;
          restoreDataFunction(
              context, loginProv, denemeProv, lessonProv, currentUser);
        },
      ),
      currentUser != null
          ? drawerCardMenu(
              context,
              iconGradient:
                  const LinearGradient(colors: [Colors.white, Colors.white]),
              cardGradient: ColorConstants.navCardGradient,
              textGradient: ColorConstants.navTextGradient,
              title: "Çıkış",
              icon: Icons.logout,
              onTap: () {
                denemeProv.showAlert(context,
                    isOneButton: false,
                    title: "Uyarı",
                    content: "Mevcut hesaptan çıkış yapmak ister misiniz?",
                    yesFunction: () async {
                  Navigator.of(context, rootNavigator: true)
                      .pushNamed(NavigationConstants.homeView);
                  await Future.delayed(const Duration(milliseconds: 10), () {
                    showLoadingAlertDialog(
                      context,
                      title: 'Çıkış Yapılıyor...',
                    );
                  });
                  Future.delayed(const Duration(seconds: 1), () {
                    AuthService().signOut();

                    loginProv.setState = LoginState.notLoggedIn;
                    loginProv.setCurrentUser = null;
                    Navigator.of(context, rootNavigator: true)
                        .pushNamed(NavigationConstants.homeView);
                  });
                }, noFunction: () {
                  Navigator.of(context, rootNavigator: true).pop();
                });
              },
            )
          : drawerCardMenu(context,
              title: "Uygulamadan Çıkış",
              icon: Icons.exit_to_app,
              textGradient: ColorConstants.navTextGradient,
              cardGradient: ColorConstants.navCardGradient,
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
      const GradientWidget(
          blendModes: BlendMode.color,
          gradient: ColorConstants.bottomGradient,
          widget: Divider()),
      drawerCardMenu(
        context,
        iconGradient: const LinearGradient(colors: [
          Color(0xFF000000),
          Color(0xFF000000),
        ]),
        cardGradient: ColorConstants.navCardGradient,
        textGradient: const LinearGradient(colors: [
          Color(0xFF000000),
          Color(0xFF000000),
        ]),
        title: "Tüm Verileri Temizle",
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
            Future.delayed(Duration.zero, () {
              Navigator.of(context, rootNavigator: true)
                  .pushNamed(NavigationConstants.homeView);
            });
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
            ? ColorConstants.navCardGradient
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
  currentUser != null
      ? denemeProv.showAlert(context,
          isOneButton: false,
          title: "Uyarı",
          content: "Şu anki veriler yedeklensin mi? ", yesFunction: () async {
          Navigator.of(context, rootNavigator: true)
              .pushNamed(NavigationConstants.homeView);
          denemeProv.setFirebaseState = FirebaseState.loading;
          await Future.delayed(const Duration(milliseconds: 20), () {
            showLoadingAlertDialog(
              context,
              title: 'Yedekleniyor...',
            );
          });
          await Future.delayed(const Duration(milliseconds: 1500), () async {
            await denemeProv
                .backUpAllTablesData(
                    context, currentUser.uid, denemeProv, loginProv)
                .then((value) {
              Navigator.of(context, rootNavigator: true)
                  .pushNamed(NavigationConstants.homeView);
            });
          });
        }, noFunction: () {
          Navigator.of(context, rootNavigator: true).pop();
        })
      : currentUserNullAlert(context, denemeProv);
}

Future<void> restoreDataFunction(
    BuildContext context,
    DenemeLoginViewModel loginProv,
    DenemeViewModel denemeProv,
    LessonViewModel lessonProv,
    User? currentUser) async {
  try {
    currentUser != null
        ? denemeProv.showAlert(context,
            isOneButton: false,
            title: "Uyarı",
            content: "Şu anki veriler yedeklenen veri ile değiştirilecektir",
            yesFunction: () async {
            Navigator.of(context, rootNavigator: true)
                .pushNamed(NavigationConstants.homeView);

            await Future.delayed(const Duration(milliseconds: 20), () {
              showLoadingAlertDialog(
                context,
                title: 'Yükleniyor...',
              );
            });
            await Future.delayed(const Duration(seconds: 1), () async {
              Navigator.of(context, rootNavigator: true)
                  .pushNamed(NavigationConstants.homeView);
              await denemeProv.restoreData(
                  context, currentUser.uid, denemeProv, lessonProv);
            });
          }, noFunction: () {
            Navigator.of(context, rootNavigator: true).pop();
          })
        : currentUserNullAlert(context, denemeProv);
  } catch (e) {
    print("restoreData catch drawer $e");
  }
}
