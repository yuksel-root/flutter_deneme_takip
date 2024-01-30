import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/button/insert_deneme_button.dart';
import 'package:flutter_deneme_takip/components/form/faded_insert_form.dart';
import 'package:flutter_deneme_takip/components/form/insert_deneme_form.dart';
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
    final fakeData = denemeProv.fakeData ?? []; //fake data for loading

    return FutureBuilder(
      future: Future.delayed(Duration.zero, () => fakeData),
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
}
