import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/button/insert_deneme_button.dart';

import 'package:flutter_deneme_takip/components/form/faded_insert_form.dart';
import 'package:flutter_deneme_takip/components/form/insert_exam_form.dart';

import 'package:flutter_deneme_takip/core/constants/color_constants.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view_model/exam_table_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_exam_view_model.dart';

import 'package:provider/provider.dart';

class InsertExam extends StatelessWidget {
  const InsertExam({super.key});

  @override
  Widget build(BuildContext context) {
    final editProv = Provider.of<EditExamViewModel>(context, listen: true);
    final examProv = Provider.of<ExamTableViewModel>(context, listen: true);
    final fakeData = examProv.fakeData ?? []; //fake data for loading

    return FutureBuilder(
      future: Future.delayed(Duration.zero, () => fakeData),
      builder: (context, snapshot) {
        if (context.watch<ExamTableViewModel>().getexamState ==
            ExamState.loading) {
          return const FadedLoadingForm();
        } else {
          return InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              editProv.setKeyboardVisibility = false;
            },
            child: buildScaffold(editProv, context),
          );
        }
      },
    );
  }

  Scaffold buildScaffold(EditExamViewModel editexamProv, BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: ColorConstants.secondaryGradient,
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceEvenly,
            spacing: 10,
            children: [
              Text(
                '${"Tarih"} Dersi Girişi',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: context.dynamicW(0.01) * context.dynamicH(0.005)),
              ),
              SizedBox(
                  height: context.dynamicH(0.0571),
                  child: const InsertExamButton()),
            ],
          ),
        ),
        const Expanded(
          flex: 50,
          child: InsertExamForm(),
        ),
      ],
    ));
  }
}
