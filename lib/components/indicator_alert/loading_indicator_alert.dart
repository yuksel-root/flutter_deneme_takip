import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'dart:async';

Future<Object?> showLoadingAlertDialog<T>(
  BuildContext context, {
  required String title,
  required bool alert,
}) async {
  if (alert == false) {
    await showDialog<T>(
      barrierDismissible: false,
      context: context,
      builder: (context) => LoadingAlert(
        title: title,
        alert: alert,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.of(context).pop();
    });

    return null;
  } else {
    return null;
  }
}

class LoadingAlert extends StatelessWidget {
  final String title;
  final bool alert;

  const LoadingAlert({super.key, required this.title, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: AlertDialog(
            backgroundColor: Colors.transparent,
            alignment: Alignment.center,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            actions: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(context.dynamicH(0.0714)),
                      child: Transform.scale(
                        scale: 2,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeAlign: BorderSide.strokeAlignCenter,
                            strokeWidth: 5,
                            strokeCap: StrokeCap.round,
                            value: null,
                            backgroundColor: Colors.blueGrey,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white12),
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.mediaQuery.size.height / 500),
                    Center(
                      child: Text(
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: context.dynamicW(0.01) *
                                context.dynamicH(0.005)),
                        textAlign: TextAlign.center,
                        title,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
