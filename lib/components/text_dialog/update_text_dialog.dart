// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/indicator_alert/loading_indicator_alert.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_deneme_view_model.dart';
import 'package:provider/provider.dart';

Future<T?> showTextDialog<T>(
  BuildContext context, {
  required String title,
  required String value,
  required int index,
  required int rowIndex,
  required bool alert,
}) =>
    alert == false
        ? showDialog<T>(
            barrierDismissible: false,
            context: context,
            builder: (context) => TextDialogWidget(
              title: title,
              value: value,
              index: index,
              rowIndex: rowIndex,
              alert: alert,
            ),
          )
        : Future.delayed(Duration.zero, () {
            return null;
          });

class TextDialogWidget extends StatefulWidget {
  final String title;
  final String value;
  final int index;
  final int rowIndex;
  final bool alert;

  const TextDialogWidget({
    super.key,
    required this.title,
    required this.value,
    required this.index,
    required this.rowIndex,
    required this.alert,
  });

  @override
  TextDialogWidgetState createState() => TextDialogWidgetState();
}

class TextDialogWidgetState extends State<TextDialogWidget> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: widget.value);
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final EditDenemeViewModel editProv =
        Provider.of<EditDenemeViewModel>(context, listen: true);
    final DenemeViewModel denemeProv =
        Provider.of<DenemeViewModel>(context, listen: false);
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
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onChanged: (value) async {
                  final isNumeric = RegExp(r'^-?[0-9]+$').hasMatch(value);
                  try {
                    if (isNumeric) {
                      editProv.setIsDiffZero = true;
                    } else if (int.parse(value) > 99) {
                      editProv.setIsNumberBig = true;
                    } else {
                      editProv.setIsDiffZero = false;
                      editProv.setIsNumberBig = false;
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                style: TextStyle(
                    color: Colors.white,
                    fontSize: context.dynamicW(0.01) * context.dynamicH(0.005)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen boş bırakmayın';
                  }

                  final isNumeric = RegExp(r'^-?[0-9]+$').hasMatch(value);
                  if (!isNumeric) {
                    Future.delayed(
                      const Duration(milliseconds: 200),
                      () {
                        _formKey.currentState!.reset();
                      },
                    );
                  } else if (int.parse(value) > 99) {
                    controller.clear();
                    return '99 dan büyük olamaz!';
                  } else {
                    return null;
                  }

                  return "Sadece Sayı Giriniz";
                },
              ),
            ),
            actions: [
              ElevatedButton(
                child: const Text('Onayla'),
                onPressed: () {
                  saveData(context, editProv, denemeProv).then((value) {
                    denemeProv.initDenemeData(denemeProv.getLessonName);
                  });
                  denemeProv.setAlert = false;
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> saveData(BuildContext context, EditDenemeViewModel editProv,
      DenemeViewModel denemeProv) async {
    if (_formKey.currentState?.validate() != false &&
        editProv.getIsDiffZero &&
        editProv.getIsNumberBig == false) {
      editProv.getIsLoading
          ? showLoadingAlertDialog(
              context,
              title: 'Güncelleniyor...',
              alert: !editProv.getIsLoading,
            )
          : const SizedBox();

      await Future.delayed(const Duration(milliseconds: 50), () {
        editProv.setLoading = false;
      });
      await editProv.saveButton(
        isUpdate: true,
        updatingDenemeId: widget.rowIndex,
        cellId: widget.index,
        updateVal: controller.text,
      );
    } else if (editProv.getIsDiffZero == false) {
      await Future.delayed(const Duration(milliseconds: 50), () {
        denemeProv.errorAlert(
            context, "HATA", "En az bir sayı giriniz", denemeProv);
      });
    } else if (editProv.getIsNumberBig == true) {
      await Future.delayed(const Duration(milliseconds: 50), () {
        denemeProv.errorAlert(
            context, "HATA", "Yanlış sayısı 99'dan büyük olamaz", denemeProv);
      });
    } else {
      await Future.delayed(
        const Duration(milliseconds: 50),
        () {
          denemeProv.errorAlert(
              context, 'HATA', 'Sadece Tam sayı giriniz!', denemeProv);
        },
      );
    }

    editProv.setLoading = true;
    _formKey.currentState!.reset();
  }
}
