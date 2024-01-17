import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_deneme_view_model.dart';
import 'package:provider/provider.dart';

class TextFieldCell extends StatefulWidget {
  final int index;
  final String initValue;
  const TextFieldCell(
      {super.key, required this.index, required this.initValue});

  @override
  State<TextFieldCell> createState() => _TextFieldCellState();
}

class _TextFieldCellState extends State<TextFieldCell> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final EditDenemeViewModel editProv =
        Provider.of<EditDenemeViewModel>(context, listen: true);
    final DenemeViewModel denemeProv =
        Provider.of<DenemeViewModel>(context, listen: false);
    return Form(
      key: _formKey,
      child: TextFormField(
        textAlign: TextAlign.center,
        autofocus: false,
        initialValue: widget.initValue,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(),
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
                editProv.getFormKey.currentState!.reset();
              },
            );

            return 'Sadece Sayı giriniz!';
          }

          return null;
        },
        onChanged: (value) {
          if (int.parse(value) != 0) {
            editProv.setIsDiffZero = true;
          } else {
            editProv.setIsDiffZero = false;
          }

          try {
            editProv.getFalseCountsIntegers![widget.index] = int.parse(value);
            saveData(context, editProv, denemeProv);
          } catch (e) {
            DenemeViewModel().printFunct("onChanged catch", e);
          }
        },
      ),
    );
  }

  Future<void> saveData(BuildContext context, EditDenemeViewModel editProv,
      DenemeViewModel denemeProv) async {
    if (_formKey.currentState?.validate() != null &&
        editProv.getIsDiffZero == true) {
      editProv.getIsLoading
          ? editProv.buildLoadingAlert(context)
          : const SizedBox();

      Future.delayed(const Duration(milliseconds: 200), () {
        editProv.setLoading = false;
      });
      await editProv.saveButton(isUpdate: true);
    } else if (editProv.getIsDiffZero == false) {
      Future.delayed(const Duration(milliseconds: 100), () {
        //  denemeProv.errorAlert(
        //       context, "HATA", "En az bir değer giriniz", denemeProv);
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
        //    _formKey.currentState!.reset();
        editProv.setFalseControllers = editProv.getFalseCountsIntegers!.length;
      },
    );
  }
}
