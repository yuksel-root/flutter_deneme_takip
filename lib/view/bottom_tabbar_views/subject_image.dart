import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/custom_painter/custom_painter.dart';
import 'package:flutter_deneme_takip/core/constants/app_theme.dart';

import 'package:provider/provider.dart';

class SubjectImage extends StatelessWidget {
  const SubjectImage({super.key});

  @override
  Widget build(BuildContext context) {
    final painterProv = Provider.of<CustomWidgetPainter>(context);

    return CustomPaint(
      willChange: true,
      painter: painterProv,
      child: Center(
          child: Text(
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize:
              AppTheme.dynamicSize(dynamicHSize: 0.004, dynamicWSize: 0.01),
        ),
        painterProv.getSubjectText,
      )),
    );
  }
}
