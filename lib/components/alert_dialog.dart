import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';

class AlertView extends StatelessWidget {
  final String title;
  final String content;
  final Function noFunction;
  final Function yesFunction;
  final bool isAlert;
  const AlertView(
      {Key? key,
      required this.title,
      required this.content,
      required this.yesFunction,
      required this.noFunction,
      required this.isAlert})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1), //add blur
        child: AlertDialog(
          backgroundColor: const Color(0xff1c0f45),
          title: Center(
            child: Text(
              title,
              maxLines: 1,
              style: TextStyle(
                  fontSize: context.dynamicW(0.01) * context.dynamicH(0.005),
                  fontFamily: "Greycliff CF Bold",
                  color: Colors.white),
            ),
          ),
          content: Text(
            content,
            maxLines: 3,
            style: TextStyle(
                fontSize: context.dynamicW(0.01) * context.dynamicH(0.0045),
                fontFamily: "Greycliff CF Medium",
                color: const Color.fromARGB(255, 0, 255, 8)),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          actions: <Widget>[
            isAlert
                ? Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: const StadiumBorder(),
                        foregroundColor: Colors.white,
                        animationDuration: const Duration(milliseconds: 250),
                        alignment: Alignment.center,
                      ),
                      child: FittedBox(
                        child: Text(
                          "Tamam",
                          style: TextStyle(
                              fontSize: context.dynamicW(0.01) *
                                  context.dynamicH(0.004),
                              fontFamily: "Greycliff CF Bold",
                              color: Colors.white),
                        ),
                      ),
                      onPressed: () {
                        noFunction();
                      },
                    ),
                  )
                : Center(
                    child: Wrap(
                      spacing: context.dynamicW(0.15),
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: const StadiumBorder(),
                            foregroundColor: Colors.white,
                            animationDuration:
                                const Duration(milliseconds: 250),
                            alignment: Alignment.center,
                          ),
                          child: FittedBox(
                            child: Text(
                              "Evet",
                              style: TextStyle(
                                  fontSize: context.dynamicW(0.01) *
                                      context.dynamicH(0.004),
                                  fontFamily: "Greycliff CF Bold",
                                  color: Colors.white),
                            ),
                          ),
                          onPressed: () {
                            yesFunction();
                          },
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: const StadiumBorder(),
                            foregroundColor: Colors.white,
                            animationDuration:
                                const Duration(milliseconds: 250),
                            alignment: Alignment.center,
                          ),
                          child: FittedBox(
                            child: Text(
                              "Hayır",
                              style: TextStyle(
                                  fontSize: context.dynamicW(0.01) *
                                      context.dynamicH(0.004),
                                  fontFamily: "Greycliff CF Bold",
                                  color: Colors.white),
                            ),
                          ),
                          onPressed: () {
                            noFunction();
                          },
                        ),
                      ],
                    ),
                  )
          ],
        ));
  }
}
