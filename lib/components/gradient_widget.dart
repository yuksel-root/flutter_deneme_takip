import 'package:flutter/material.dart';

class GradientWidget extends StatelessWidget {
  const GradientWidget({
    Key? key,
    required this.gradient,
    required this.widget,
    required this.blendModes,
  }) : super(key: key);

  final Widget widget;
  final Gradient gradient;
  final BlendMode blendModes;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: blendModes,
      shaderCallback: (bounds) => gradient
          .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: widget,
    );
  }
}
