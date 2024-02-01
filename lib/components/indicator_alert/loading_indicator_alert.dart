import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'dart:async';

Future<T?> showLoadingAlertDialog<T>(
  BuildContext context, {
  required String title,
  required bool alert,
}) =>
    alert == false
        ? showDialog<T>(
            context: context,
            builder: (context) => LoadingAlert(
              title: title,
              alert: alert,
            ),
          )
        : Future.delayed(Duration.zero, () {
            return null;
          });

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
            backgroundColor: Color(0xff),
            alignment: Alignment.center,
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
                                AlwaysStoppedAnimation<Color>(Colors.green),
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.mediaQuery.size.height / 500),
                    Center(
                      child: Text(
                        style: TextStyle(
                            color: const Color(0xff1c0f45),
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
