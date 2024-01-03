import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_deneme_view_model.dart';
import 'package:provider/provider.dart';

class InsertDenemeForm extends StatefulWidget {
  const InsertDenemeForm({Key? key}) : super(key: key);

  @override
  State<InsertDenemeForm> createState() => _InsertDenemeFormState();
}

class _InsertDenemeFormState extends State<InsertDenemeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<TextEditingController> _falseCountControllers = List.generate(
      EditDenemeViewModel().getFalseCountsIntegers!.length,
      (index) => TextEditingController(text: '0'));

  @override
  Widget build(BuildContext context) {
    final EditDenemeViewModel editDenemeProv =
        Provider.of<EditDenemeViewModel>(context, listen: true);

    editDenemeProv.setFormKey = _formKey;
    editDenemeProv.setLoading = true;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 1;
                i < editDenemeProv.getFalseCountsIntegers!.length;
                i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: inputFalseCount(
                        context,
                        i,
                        editDenemeProv,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: context.dynamicH(0.0428),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  TextFormField inputFalseCount(
    BuildContext context,
    int index,
    EditDenemeViewModel editProv,
  ) {
    return TextFormField(
      controller: _falseCountControllers[index],
      autofocus: false,
      keyboardType: TextInputType.number,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen boş bırakmayın';
        }
        final isNumeric = RegExp(r'^-?[0-9]+$').hasMatch(value);
        if (!isNumeric) {
          Future.delayed(
            const Duration(milliseconds: 180500),
            () {
              _formKey.currentState!.reset();
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
          editProv.getFalseCountsIntegers![index] = int.parse(value);
        } catch (e) {
          DenemeViewModel().printFunct("onChanged catch", e);
        }
      },
      decoration: InputDecoration(
        hintText: "Konu Yanlış Sayısı",
        label: Text(
          editProv.getSubjectList[index],
          style: TextStyle(
              fontSize: context.dynamicW(0.01) * context.dynamicH(0.005)),
        ),
        icon: buildContaierIconField(
            context, Icons.assignment_rounded, Colors.purple),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
        border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
      ),
    );
  }

  Container buildContaierIconField(
      BuildContext context, IconData icon, Color iconColor) {
    return Container(
      height: context.dynamicW(0.05),
      width: context.dynamicW(0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(context.dynamicW(0.0025)),
      child: Icon(icon, color: iconColor),
    );
  }
}
