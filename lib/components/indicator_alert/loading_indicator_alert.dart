// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'dart:async';

Future<T?> showLoadingAlertDialog<T>(
  BuildContext context, {
  required String title,
}) async {
  await showDialog<T>(
    barrierDismissible: false,
    context: context,
    useRootNavigator: true,
    builder: (context) => LoadingAlert(
      title: title,
    ),
  );

  return null;
}

class LoadingAlert extends StatelessWidget {
  final String title;
  const LoadingAlert({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return buildAlertDialog(context);
  }

  Padding buildAlertDialog(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dynamicH(0.0714)),
      child: Center(
        child: AlertDialog(
            backgroundColor: Colors.transparent,
            alignment: Alignment.center,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.dynamicH(0.0714)),
            ),
            actions: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildLoadingIndicator(context),
                    SizedBox(height: context.mediaQuery.size.height / 500),
                    buildLoadingInfo(context),
                  ],
                ),
              ),
            ]),
      ),
    );
  }

  Center buildLoadingInfo(BuildContext context) {
    return Center(
      child: Text(
        style: TextStyle(
            color: Colors.white,
            fontSize: context.dynamicW(0.01) * context.dynamicH(0.005)),
        textAlign: TextAlign.center,
        title,
      ),
    );
  }

  Padding buildLoadingIndicator(BuildContext context) {
    return Padding(
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}
