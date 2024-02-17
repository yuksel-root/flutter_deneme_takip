import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/indicator_alert/loading_indicator_alert.dart';
import 'package:flutter_deneme_takip/view_model/edit_deneme_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';

class InsertDenemeButton extends StatelessWidget {
  const InsertDenemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final EditDenemeViewModel editProv =
        Provider.of<EditDenemeViewModel>(context, listen: true);

    return ElevatedButton.icon(
      icon: const Icon(color: Colors.green, Icons.save),
      label: Text(" Kaydet ",
          style: TextStyle(
              color: Colors.white,
              fontSize: context.dynamicH(0.00571) * context.dynamicW(0.01))),
      onPressed: () async {
        if (editProv.getFormKey.currentState?.validate() == true &&
            editProv.getIsDiffZero == true) {
          showLoadingAlertDialog(
            context,
            title: "Kaydediliyor...",
          );

          await Future.delayed(const Duration(seconds: 1), () {
            editProv.saveButton(isUpdate: false);
            Navigator.of(context, rootNavigator: true).pop();
            editProv.getFormKey.currentState!.reset();
          });
        } else if (editProv.getIsDiffZero == false) {
          Future.delayed(const Duration(milliseconds: 20), () {
            editProv.errorAlert(
                context, "HATA", "En az bir değer giriniz", editProv);
          });
          editProv.getFormKey.currentState!.reset();
        } else {
          Future.delayed(
            const Duration(milliseconds: 20),
            () {
              editProv.errorAlert(
                  context, 'HATA', 'Sadece Tam sayı giriniz!', editProv);
              editProv.getFormKey.currentState!.reset();
            },
          );
        }
      },
    );
  }
}
