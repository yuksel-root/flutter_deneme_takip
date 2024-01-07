import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';

class SignButton extends StatelessWidget {
  final Function onPressFunct;
  final ButtonStyle style;
  final String labelText;
  final TextStyle labelStyle;
  final bool isGreyPng;
  const SignButton(
      {super.key,
      required this.onPressFunct,
      required this.style,
      required this.labelText,
      required this.labelStyle,
      required this.isGreyPng});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressFunct();
      },
      style: style,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/img/icon/login.png',
            width: context.dynamicW(0.1),
            height: context.dynamicH(0.0714),
            color: isGreyPng ? Colors.grey : null,
          ),
          SizedBox(
            width: context.dynamicW(0.05),
          ),
          Text(
            labelText,
            style: labelStyle,
          ),
        ],
      ),
    );
  }
}
