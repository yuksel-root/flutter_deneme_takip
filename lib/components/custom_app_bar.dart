import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  final double? dynamicPreferredSize;
  final Gradient? gradients;
  const CustomAppBar(
      {Key? key,
      required this.appBar,
      required this.dynamicPreferredSize,
      required this.gradients})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.mediaQuery.size.height,
      decoration: BoxDecoration(
        gradient: gradients!,
      ),
      child: appBar,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(dynamicPreferredSize!);
}
