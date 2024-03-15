// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/indicator_alert/loading_indicator_alert.dart';
import 'package:flutter_deneme_takip/components/shader_mask/gradient_widget.dart';
import 'package:flutter_deneme_takip/core/constants/app_theme.dart';
import 'package:flutter_deneme_takip/core/constants/color_constants.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/local_database/exam_db_provider.dart';
import 'package:flutter_deneme_takip/core/notifier/bottom_navigation_notifier.dart';
import 'package:flutter_deneme_takip/services/auth_service.dart';
import 'package:flutter_deneme_takip/view_model/exam_table_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_exam_view_model.dart';

import 'package:flutter_deneme_takip/view_model/exam_list_view_model.dart';
import 'package:flutter_deneme_takip/view_model/login_view_model.dart';
import 'package:provider/provider.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final examProv = Provider.of<ExamTableViewModel>(context, listen: false);
    final lessonProv = Provider.of<ExamListViewModel>(context, listen: false);
    final loginProv = Provider.of<LoginViewModel>(context, listen: true);
    final editProv = Provider.of<EditExamViewModel>(context, listen: true);
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
                    context, loginProv, currentUser, examProv)),
            Expanded(
                flex: 55,
                child: buildListTiles(currentUser, bottomProv, context,
                    examProv, loginProv, lessonProv, editProv)),
          ],
        ),
      ),
    );
  }
}

Column buildListTileHeader(BuildContext context, LoginViewModel loginProv,
    User? currentUser, ExamTableViewModel examProv) {
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
                child: buildProfileImage(context, examProv, currentUser),
              )),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget buildProfileImage(
    BuildContext context, ExamTableViewModel examProv, User? currentUser) {
  try {
    if (currentUser != null) {
      examProv.isOnline(currentUser.uid);
      if (examProv.getOnline) {
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
    ExamTableViewModel examProv,
    LoginViewModel loginProv,
    ExamListViewModel examListProv,
    EditExamViewModel editProv) {
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
                  if (context.read<LoginViewModel>().getState ==
                      LoginState.notLoggedIn) {
                    loginProv.loginWithGoogle(context, loginProv);
                  } else if (context.read<LoginViewModel>().getState ==
                      LoginState.loginError) {
                    loginProv.errorAlert(
                        context, "Uyarı", loginProv.getError, loginProv);
                    loginProv.setState = LoginState.notLoggedIn;
                  } else {
                    if (context.read<LoginViewModel>().getState ==
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
        title: "Denemeler",
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
        title: "Denemeler Tablosu",
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
          examProv.setAlert = false;
          backUpFunction(context, examProv, currentUser, loginProv);
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
          examProv.setAlert = false;
          restoreDataFunction(
              context, loginProv, examProv, examListProv, currentUser);
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
                examProv.showAlert(context,
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
              examProv.showAlert(context,
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
          examProv.showAlert(context,
              isOneButton: false,
              title: "Uyarı",
              content: "Tüm verileri silmek istiyor musunuz?",
              yesFunction: () async {
            await ExamDbProvider.db.clearDatabase();
            //  examListProv.initExamListData(examListProv.getLessonName);
            // examProv.initExamData(examProv.getLessonName);
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
              ? examProv.showAlert(context,
                  isOneButton: false,
                  title: "Uyarı",
                  content: "Mevcut kullanıcı hesabı silinecektir ?",
                  yesFunction: () async {
                  await examProv
                      .deleteUserInFirebase(
                          context, currentUser.uid, examProv, loginProv)
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
                    examProv.setAlert = false;
                  });
                }, noFunction: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  examProv.setAlert = false;
                })
              : currentUserNullAlert(context, examProv);
        },
      ),
    ],
  );
}

void currentUserNullAlert(BuildContext context, ExamTableViewModel examProv) {
  examProv.showAlert(context,
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

Future<void> backUpFunction(BuildContext context, ExamTableViewModel examProv,
    User? currentUser, loginProv) async {
  currentUser != null
      ? examProv.showAlert(context,
          isOneButton: false,
          title: "Uyarı",
          content: "Şu anki veriler yedeklensin mi? ", yesFunction: () async {
          Navigator.of(context, rootNavigator: true)
              .pushNamed(NavigationConstants.homeView);
          examProv.setFirebaseState = FirebaseState.loading;
          await Future.delayed(const Duration(milliseconds: 20), () {
            showLoadingAlertDialog(
              context,
              title: 'Yedekleniyor...',
            );
          });
          await Future.delayed(const Duration(milliseconds: 1500), () async {
            await examProv
                .backUpAllTablesData(
                    context, currentUser.uid, examProv, loginProv)
                .then((value) {
              Navigator.of(context, rootNavigator: true)
                  .pushNamed(NavigationConstants.homeView);
            });
          });
        }, noFunction: () {
          Navigator.of(context, rootNavigator: true).pop();
        })
      : currentUserNullAlert(context, examProv);
}

Future<void> restoreDataFunction(
    BuildContext context,
    LoginViewModel loginProv,
    ExamTableViewModel examProv,
    ExamListViewModel lessonProv,
    User? currentUser) async {
  try {
    currentUser != null
        ? examProv.showAlert(context,
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
              await examProv.restoreData(
                  context, currentUser.uid, examProv, lessonProv);
            });
          }, noFunction: () {
            Navigator.of(context, rootNavigator: true).pop();
          })
        : currentUserNullAlert(context, examProv);
  } catch (e) {
    print("restoreData catch drawer $e");
  }
}
