import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  final double? dynamicPreferredSize;
  const CustomAppBar(
      {Key? key, required this.appBar, required this.dynamicPreferredSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.mediaQuery.size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF00bfff),
            Color(0xFFbdc3c7),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 1.0],
          tileMode: TileMode.repeated,
        ),
      ),
      child: appBar,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(dynamicPreferredSize!);
}
