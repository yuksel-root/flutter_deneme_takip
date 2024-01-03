import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/custom_app_bar.dart';

import 'package:flutter_deneme_takip/core/notifier/bottom_navigation_notifier.dart';
import 'package:flutter_deneme_takip/view/insert_views/insert_deneme_form.dart';

import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view_model/edit_deneme_view_model.dart';

import 'package:provider/provider.dart';

class InsertDeneme extends StatelessWidget {
  const InsertDeneme({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final denemeProv = Provider.of<DenemeViewModel>(context, listen: true);
    final editDenemeProv =
        Provider.of<EditDenemeViewModel>(context, listen: true);
    final bottomTabProv =
        Provider.of<BottomNavigationProvider>(context, listen: true);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: CustomAppBar(
            dynamicPreferredSize: context.mediaQuery.size.height / 14,
            appBar: AppBar(
                flexibleSpace: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceEvenly,
                    spacing: 10,
                    children: [
                  Text(
                    '${editDenemeProv.getLessonName} Dersi Girişi',
                    style: TextStyle(
                        fontSize:
                            context.dynamicW(0.01) * context.dynamicH(0.005)),
                  ),
                  elevatedButtons(
                      context, denemeProv, editDenemeProv, bottomTabProv),
                ]))),
        body: Padding(
          padding: EdgeInsets.all(context.dynamicW(0.00714)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 50,
                child: InsertDenemeForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> buildLoadingDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: AlertDialog(
                  backgroundColor: Colors.white,
                  alignment: Alignment.center,
                  actions: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(context.dynamicH(0.0714)),
                            child: Transform.scale(
                              scale: 2,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                  strokeWidth: 5,
                                  strokeCap: StrokeCap.round,
                                  value: null,
                                  backgroundColor: Colors.blueGrey,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green),
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height: context.mediaQuery.size.height / 500),
                          Center(
                              child: Text(
                                  style: TextStyle(
                                      color: const Color(0xff1c0f45),
                                      fontSize: context.dynamicW(0.01) *
                                          context.dynamicH(0.005)),
                                  textAlign: TextAlign.center,
                                  ' Kaydediliyor...')),
                        ],
                      ),
                    ),
                  ]),
            ),
          );
        });
  }

  SizedBox elevatedButtons(BuildContext context, DenemeViewModel denemeProv,
      EditDenemeViewModel editProv, BottomNavigationProvider bottomProv) {
    return SizedBox(
        height: context.dynamicH(0.0571), //40px
        child: ElevatedButton.icon(
            icon: const Icon(color: Colors.green, Icons.save),
            label: Text(" Kaydet ",
                style: TextStyle(
                    color: Colors.white,
                    fontSize:
                        context.dynamicH(0.00571) * context.dynamicW(0.01))),
            onPressed: () async {
              //print(editProv.getFormKey.currentState!.validate());
              if (editProv.getFormKey.currentState!.validate() &&
                  editProv.getIsDiffZero == true) {
                editProv.getIsLoading
                    ? editProv.buildLoadingDialog(context)
                    : const SizedBox();

                Future.delayed(const Duration(milliseconds: 250), () {
                  editProv.setLoading = false;
                });
                editProv.saveButton(context);
              } else if (editProv.getIsDiffZero == false) {
                Future.delayed(const Duration(milliseconds: 250), () {
                  editProv.valAlert(context, 'HATA', 'En az 1 değer gir!');
                });
              } else {
                Future.delayed(
                  const Duration(milliseconds: 250),
                  () {
                    editProv.valAlert(
                        context, 'HATA', 'Sadece Tam sayı giriniz!');
                  },
                );
              }
              Future.delayed(
                const Duration(milliseconds: 250),
                () {
                  editProv.getFormKey.currentState!.reset();
                  //  editProv.setFalseControllers =
                  //    editProv.getFalseCountsIntegers!.length;
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: const StadiumBorder(),
              foregroundColor: Colors.black,
            )));
  }
}
