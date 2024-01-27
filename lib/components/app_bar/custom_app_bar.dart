import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  final double dynamicPreferredSize;
  final Gradient gradients;
  const CustomAppBar(
      {super.key,
      required this.appBar,
      required this.dynamicPreferredSize,
      required this.gradients});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        backgroundBlendMode: BlendMode.srcIn,
        gradient: gradients,
      ),
      child: appBar,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(dynamicPreferredSize);
}
