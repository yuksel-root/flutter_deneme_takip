import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';

class AlertView extends StatelessWidget {
  final String title;
  final String content;
  final Function? noFunction;
  final Function yesFunction;
  final bool isOneButton;
  const AlertView(
      {super.key,
      required this.title,
      required this.content,
      required this.yesFunction,
      this.noFunction,
      required this.isOneButton});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1), //add blur
        child: AlertDialog(
          title: Center(
            child: Text(
              title,
              maxLines: 1,
            ),
          ),
          content: Text(
            content,
            maxLines: 3,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          actions: <Widget>[
            isOneButton
                ? Center(
                    child: ElevatedButton(
                      child: const FittedBox(
                        child: Text(
                          "Tamam",
                        ),
                      ),
                      onPressed: () {
                        yesFunction();
                      },
                    ),
                  )
                : Center(
                    child: Wrap(
                      spacing: context.dynamicW(0.15),
                      children: [
                        ElevatedButton(
                          child: const FittedBox(
                            child: Text(
                              "Evet",
                            ),
                          ),
                          onPressed: () {
                            yesFunction();
                          },
                        ),
                        ElevatedButton(
                          child: const FittedBox(
                            child: Text(
                              "Hayır",
                            ),
                          ),
                          onPressed: () {
                            noFunction!() ?? () {};
                          },
                        ),
                      ],
                    ),
                  )
          ],
        ));
  }
}
