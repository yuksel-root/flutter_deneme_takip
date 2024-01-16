import 'package:flutter/material.dart';
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
            print("a");
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
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          textAlign: TextAlign.center,
          autofocus: false,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            if (int.parse(value) != 0) {
              editProv.setIsDiffZero = true;
            } else {
              editProv.setIsDiffZero = false;
            }
          },
          style: TextStyle(
              color: Colors.black,
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
                  editProv.getFormKey.currentState!.reset();
                },
              );

              return 'Sadece Sayı giriniz!';
            }

            return null;
          },
        ),
      ),
      actions: [
        ElevatedButton(
          child: const Text('Onayla'),
          onPressed: () {
            denemeProv.setAlert = false;
            saveData(context, editProv, denemeProv);
          },
        )
      ],
    );
  }

  Future<void> saveData(BuildContext context, EditDenemeViewModel editProv,
      DenemeViewModel denemeProv) async {
    if (_formKey.currentState?.validate() != null &&
        editProv.getIsDiffZero == true) {
      editProv.getIsLoading
          ? editProv.buildLoadingAlert(context)
          : const SizedBox();
      editProv.getFalseCountsIntegers![widget.index] =
          int.parse(controller.text);
      Future.delayed(const Duration(milliseconds: 200), () {
        editProv.setLoading = false;
      });
      await editProv.saveButton(context,
          isUpdate: true, updateId: widget.rowIndex);
    } else if (editProv.getIsDiffZero == false) {
      Future.delayed(const Duration(milliseconds: 100), () {
        denemeProv.errorAlert(
            context, "HATA", "En az bir değer giriniz", denemeProv);
      });
    } else {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          denemeProv.errorAlert(
              context, 'HATA', 'Sadece Tam sayı giriniz!', denemeProv);
        },
      );
    }
    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        editProv.setLoading = true;
        _formKey.currentState!.reset();
        editProv.setFalseControllers = editProv.getFalseCountsIntegers!.length;
      },
    );
  }
}
