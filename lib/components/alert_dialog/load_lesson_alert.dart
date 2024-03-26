import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/shader_mask/gradient_widget.dart';
import 'package:flutter_deneme_takip/core/constants/app_data.dart';
import 'package:flutter_deneme_takip/core/constants/app_theme.dart';
import 'package:flutter_deneme_takip/core/constants/color_constants.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';
import 'package:provider/provider.dart';

class LoadLessonAlert extends StatelessWidget {
  const LoadLessonAlert({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final lessonProv = Provider.of<LessonViewModel>(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
      child: AlertDialog(
        alignment: Alignment.center,
        scrollable: true,
        title: Text(
          textAlign: TextAlign.center,
          "Eklemek İstediğiniz Dersleri Seçiniz",
          style: TextStyle(
              fontSize: AppTheme.dynamicSize(
                  dynamicHSize: 0.006, dynamicWSize: 0.01)),
        ),
        content: alertContent(lessonProv, context),
        actions: [
          ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.cancel),
              label: const Text("İptal")),
          ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send),
              label: const Text("Onayla"))
        ],
      ),
    );
  }

  SingleChildScrollView alertContent(
      LessonViewModel lessonProv, BuildContext context) {
    return SingleChildScrollView(
      child: ListBody(
        children: List.generate(
            AppData.examNames.length,
            (index) => Column(
                  children: [
                    const SizedBox(height: 3),
                    checkListTile(
                      lessonProv,
                      context,
                      index,
                      title: Text(AppData.examNames[index],
                          style: TextStyle(
                              fontSize: AppTheme.dynamicSize(
                                  dynamicHSize: 0.005, dynamicWSize: 0.01))),
                      icon: Icons.list_alt_rounded,
                      textGradient: ColorConstants.navTextGradient,
                      cardGradient: ColorConstants.examCheckGradient,
                      iconGradient: const LinearGradient(colors: [
                        Colors.grey,
                        Colors.grey,
                      ]),
                      onTap: () {},
                    ),
                  ],
                )),
      ),
    );
  }

  Container checkListTile(
    LessonViewModel lessonProv,
    BuildContext context,
    int index, {
    required Widget title,
    required IconData icon,
    required Gradient textGradient,
    required Gradient cardGradient,
    required Gradient iconGradient,
    required Function onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(
            AppTheme.dynamicSize(dynamicHSize: 0.005, dynamicWSize: 0.006))),
        gradient: cardGradient,
      ),
      child: CheckboxListTile(
        value: lessonProv.getCheckList[index],
        onChanged: (value) {
          lessonProv.checkedItemChange(index, value!);
        },
        controlAffinity: ListTileControlAffinity.trailing,
        secondary: GradientWidget(
            blendModes: BlendMode.srcIn,
            gradient: iconGradient,
            widget: Icon(icon,
                size: AppTheme.dynamicSize(
                    dynamicHSize: 0.005, dynamicWSize: 0.01))),
        title: GradientWidget(
          blendModes: BlendMode.srcIn,
          gradient: textGradient,
          widget: title,
        ),
      ),
    );
  }
}
