// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/indicator_alert/loading_indicator_alert.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view_model/exam_table_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_exam_view_model.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';
import 'package:provider/provider.dart';

Future<T?> showLessonDialog<T>(BuildContext context,
        {required String title,
        required String value,
        required bool alert,
        required Function onPressFunc}) =>
    alert == false
        ? showDialog<T>(
            barrierDismissible: false,
            context: context,
            builder: (context) => LessonTextDialog(
              title: title,
              value: value,
              alert: alert,
              onPressFunc: onPressFunc,
            ),
          )
        : Future.delayed(Duration.zero, () {
            return null;
          });

class LessonTextDialog extends StatefulWidget {
  final String title;
  final String value;
  final bool alert;
  final Function onPressFunc;

  const LessonTextDialog({
    super.key,
    required this.title,
    required this.value,
    required this.alert,
    required this.onPressFunc,
  });

  @override
  LessonTextDialogState createState() => LessonTextDialogState();
}

class LessonTextDialogState extends State<LessonTextDialog> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: widget.value);
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final lessonProv = Provider.of<LessonViewModel>(context);
    return Column(
      children: [
        Expanded(
          child: AlertDialog(
            title: Text(widget.title),
            content: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: TextFormField(
                controller: controller,
                maxLines: 1,
                textAlign: TextAlign.center,
                autofocus: true,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                onChanged: (value) async {},
                style: TextStyle(
                    color: Colors.white,
                    fontSize: context.dynamicW(0.01) * context.dynamicH(0.005)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen boş bırakmayın';
                  }

                  return null;
                },
              ),
            ),
            actions: [
              ElevatedButton(
                child: const Text('Onayla'),
                onPressed: () async {
                  lessonProv.setLessonname = controller.text;
                  widget.onPressFunc();
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> saveData(BuildContext context, EditExamViewModel editProv,
      ExamTableViewModel examProv) async {
    if (_formKey.currentState?.validate() != false &&
        editProv.getIsDiffZero &&
        editProv.getIsNumberBig == false) {
      showLoadingAlertDialog(
        context,
        title: 'Ekleniyor...',
      );
      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(seconds: 1), () async {
        Navigator.of(context, rootNavigator: true).pop();

        await editProv.saveButton(
          isUpdate: true,
          updateVal: controller.text,
          lessonName: "null", //examProv.getLessonName,
        );
      });
    } else if (editProv.getIsDiffZero == false) {
      await Future.delayed(const Duration(milliseconds: 50), () {
        examProv.errorAlert(context, "HATA", "Ders ismi giriniz.", examProv);
      });
    } else if (editProv.getIsNumberBig == true) {
      await Future.delayed(const Duration(milliseconds: 50), () {
        examProv.errorAlert(
            context, "HATA", "Yanlış sayısı 99'dan büyük olamaz", examProv);
      });
    } else {
      await Future.delayed(
        const Duration(milliseconds: 50),
        () {
          examProv.errorAlert(
              context, 'HATA', 'Sadece Tam sayı giriniz!', examProv);
        },
      );
    }

    _formKey.currentState!.reset();
  }
}
