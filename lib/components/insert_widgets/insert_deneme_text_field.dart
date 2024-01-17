import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_deneme_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';

class InsertDenemeTextField extends StatelessWidget {
  const InsertDenemeTextField({super.key});

  @override
  Widget build(BuildContext context) {
    final EditDenemeViewModel editProv =
        Provider.of<EditDenemeViewModel>(context, listen: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 1; i < editProv.getFalseCountsIntegers!.length; i++)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: editProv.getFalseControllers[i],
                      autofocus: false,
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize:
                              context.dynamicW(0.01) * context.dynamicH(0.004)),
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
                        } else if (int.parse(value) > 99) {
                          try {
                            editProv.getFalseControllers[i].clear();
                          } catch (e) {
                            print(e);
                          }
                          return "Yanlış sayısı 99'dan büyük olamaz!";
                        } else {
                          return null;
                        }

                        return "Sadece Sayı Giriniz";
                      },
                      onChanged: (value) {
                        if (int.parse(value) != 0) {
                          editProv.setIsDiffZero = true;
                        } else if (int.parse(value) > 99) {
                          editProv.getFalseControllers[i].clear();
                        } else {
                          editProv.setIsDiffZero = false;
                        }

                        try {
                          editProv.getFalseCountsIntegers![i] =
                              int.parse(value);
                        } catch (e) {
                          DenemeViewModel().printFunct("onChanged catch", e);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Konu Yanlış Sayısı",
                        label: Text(
                          editProv.getSubjectList[i],
                          style: TextStyle(
                              fontSize: context.dynamicW(0.01) *
                                  context.dynamicH(0.005)),
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
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: context.dynamicH(0.0428),
              ),
            ],
          ),
      ],
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
