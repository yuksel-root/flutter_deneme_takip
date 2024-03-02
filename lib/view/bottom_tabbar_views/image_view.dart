// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/custom_painter/custom_painter.dart';
import 'package:flutter_deneme_takip/components/indicator_alert/loading_indicator_alert.dart';
import 'package:flutter_deneme_takip/core/constants/app_data.dart';
import 'package:flutter_deneme_takip/core/constants/app_theme.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key});

  @override
  Widget build(BuildContext context) {
    final painterProv = Provider.of<CustomWidgetPainter>(context);
    final denemeProv = Provider.of<DenemeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: [
          ElevatedButton(
              onPressed: () {
                painterProv.setNavText = "orjPng";
              },
              child: const Text("Orj PNG")),
          ElevatedButton(
            onPressed: () async {
              Directory directoryPath =
                  await getApplicationDocumentsDirectory();
              painterProv.deleteImages(directoryPath);
              painterProv.setNavText = "showPng";
              painterProv.setWidth =
                  AppTheme.dynamicSize(dynamicHSize: 0.014, dynamicWSize: 0.02);
              painterProv.setHeight = 160;
              painterProv.setCenterScaleX = 10;
              painterProv.setCenterScaleY = 2;
              painterProv.generateAndSaveImage(denemeProv);
            },
            child: const Text('Show PNG'),
          ),
          ElevatedButton(
            onPressed: () async {
              Directory directoryPath =
                  await getApplicationDocumentsDirectory();
              painterProv.deleteImages(directoryPath);
              painterProv.setNavText = "createPng";
              painterProv.setWidth = 250;
              painterProv.setHeight = 150;
              painterProv.setCenterScaleX = 10;
              painterProv.setCenterScaleY = 2;
              painterProv.generateAndSaveImage(denemeProv);
            },
            child: const Text('Create PNG'),
          ),
          ElevatedButton(
            onPressed: () async {
              Directory directoryPath =
                  await getApplicationDocumentsDirectory();

              await painterProv.deleteImages(directoryPath);
            },
            child: const Text('Delete All Png'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            const Divider(
              color: Colors.black,
              height: 5,
              thickness: 5,
            ),
            for (int j = 0; j < 3; j++)
              Column(
                children: [
                  const Divider(
                    color: Colors.black,
                    height: 5,
                    thickness: 5,
                  ),
                  Row(
                    children: [
                      for (int i = 1; i < 10; i++)
                        painterProv.getNavText == "showPng"
                            ? FutureBuilder(
                                future: Future.delayed(Duration.zero, () {
                                  painterProv.setSubjectText =
                                      painterProv.getText(denemeProv, j, i);
                                }),
                                builder: (context, snapshot) {
                                  return Container(
                                    height: painterProv.getHeight,
                                    width: painterProv.getWidth,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                          left: BorderSide(
                                        color: Colors.white,
                                        width: 3.0,
                                      )),
                                    ),
                                    child: CustomPaint(
                                      willChange: true,
                                      painter: painterProv,
                                    ),
                                  );
                                })
                            : painterProv.getNavText == "orjPng"
                                ? Container(
                                    height: painterProv.getHeight,
                                    width: painterProv.getWidth,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1C0F45),
                                      border: const Border(
                                          left: BorderSide(
                                        color: Colors.white,
                                        width: 3.0,
                                      )),
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/img/table_columns/${AppData.lessonPng[j]}/$i.png'),
                                        fit: BoxFit.fill,
                                        alignment: Alignment.center,
                                        repeat: ImageRepeat.noRepeat,
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: painterProv.getHeight,
                                    width: painterProv.getWidth,
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            left: BorderSide(
                                      color: Colors.white,
                                      width: 3.0,
                                    ))),
                                    child: FutureBuilder<bool>(
                                        future:
                                            Future.delayed(Duration.zero, () {
                                          return File(
                                                  '/data/user/0/com.example.flutter_deneme_takip/app_flutter/${j == 0 ? 'Vatandaşlık' : j == 1 ? 'Coğrafya' : 'Tarih'}$i.png')
                                              .exists();
                                        }),
                                        builder: (context, snapshot) {
                                          return snapshot.hasData &&
                                                  snapshot.data!
                                              ? Image.file(
                                                  File(
                                                      '/data/user/0/com.example.flutter_deneme_takip/app_flutter/${j == 0 ? 'Vatandaşlık' : j == 1 ? 'Coğrafya' : 'Tarih'}$i.png'),
                                                  fit: BoxFit.fill,
                                                  alignment: Alignment.center,
                                                  repeat: ImageRepeat.noRepeat,
                                                  isAntiAlias: true,
                                                  filterQuality:
                                                      FilterQuality.high,
                                                )
                                              : const LoadingAlert(
                                                  title: 'Loading...');
                                        }),
                                  ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
