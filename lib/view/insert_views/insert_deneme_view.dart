import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/insert_widgets/faded_insert_form.dart';
import 'package:flutter_deneme_takip/components/insert_widgets/insert_deneme_button.dart';
import 'package:flutter_deneme_takip/components/insert_widgets/insert_deneme_form.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_deneme_view_model.dart';
import 'package:provider/provider.dart';

class InsertDeneme extends StatelessWidget {
  const InsertDeneme({super.key});

  @override
  Widget build(BuildContext context) {
    final editDenemeProv =
        Provider.of<EditDenemeViewModel>(context, listen: true);
    final denemeProv = Provider.of<DenemeViewModel>(context, listen: true);
    final denemeData = denemeProv.listDeneme ?? []; //fake data for loading

    return FutureBuilder(
      future:
          Future.delayed(const Duration(milliseconds: 300), () => denemeData),
      builder: (context, snapshot) {
        if (context.watch<DenemeViewModel>().getDenemeState ==
            DenemeState.loading) {
          return const FadedLoadingForm();
        } else {
          return buildScaffold(editDenemeProv, context);
        }
      },
    );
  }

  Scaffold buildScaffold(
      EditDenemeViewModel editDenemeProv, BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF00bfff),
                Color(0xFFbdc3c7),
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceEvenly,
            spacing: 10,
            children: [
              Text(
                '${editDenemeProv.getLessonName} Dersi Girişi',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: context.dynamicW(0.01) * context.dynamicH(0.005)),
              ),
              SizedBox(
                  height: context.dynamicH(0.0571),
                  child: const InsertDenemeButton()),
            ],
          ),
        ),
        const Expanded(
          flex: 50,
          child: InsertDenemeForm(),
        ),
      ],
    ));
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
}
