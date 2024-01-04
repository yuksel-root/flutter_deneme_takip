import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/view_model/edit_deneme_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';

class InsertDenemeButton extends StatelessWidget {
  const InsertDenemeButton({Key? key}) : super(key: key);

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
          //print(editProv.getFormKey.currentState!.validate());
          if (editProv.getFormKey.currentState!.validate() &&
              editProv.getIsDiffZero == true) {
            editProv.getIsLoading
                ? editProv.buildLoadingAlert(context)
                : const SizedBox();

            Future.delayed(const Duration(milliseconds: 200), () {
              editProv.setLoading = false;
            });
            editProv.saveButton(context);
          } else if (editProv.getIsDiffZero == false) {
            Future.delayed(const Duration(milliseconds: 200), () {
              editProv.valAlert(context, 'HATA', 'En az 1 değer gir!');
            });
          } else {
            Future.delayed(
              const Duration(milliseconds: 200),
              () {
                editProv.valAlert(context, 'HATA', 'Sadece Tam sayı giriniz!');
              },
            );
          }
          Future.delayed(
            const Duration(milliseconds: 200),
            () {
              editProv.setLoading = true;
              editProv.getFormKey.currentState!.reset();
              editProv.setFalseControllers =
                  editProv.getFalseCountsIntegers!.length;
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: const StadiumBorder(),
          foregroundColor: Colors.black,
        ));
  }
}
