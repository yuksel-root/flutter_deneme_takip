// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/app_data.dart';
import 'package:flutter_deneme_takip/core/notifier/create_png_provider.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key});

  @override
  Widget build(BuildContext context) {
    final denemeProv = Provider.of<DenemeViewModel>(context);
    final pngProv = Provider.of<CreatePngProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: [
          ElevatedButton(
              onPressed: () {
                pngProv.setFilePath = '';
              },
              child: const Text("Orj PNG")),
          ElevatedButton(
            onPressed: () {
              pngProv.generateAndSaveImage(denemeProv);
            },
            child: const Text('Create PNG'),
          ),
          ElevatedButton(
            onPressed: () async {
              Directory directoryPath =
                  await getApplicationDocumentsDirectory();

              pngProv.deleteImages(directoryPath);
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
                    children: <Widget>[
                      const SizedBox(height: 20),
                      for (int i = 1; i < 10; i++)
                        pngProv.getFilePath.isNotEmpty
                            ? Container(
                                height: pngProv.getHeight,
                                width: pngProv.getWidth,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                      left: BorderSide(
                                    color: Colors.white,
                                    width: 3.0, // Çizgi kalınlığı
                                  )),
                                ),
                                child: Image.file(
                                  File(
                                      '/data/user/0/com.example.flutter_deneme_takip/app_flutter/output$i$j.png'),
                                  fit: BoxFit.fill,
                                  alignment: Alignment.center,
                                  repeat: ImageRepeat.noRepeat,
                                ),
                              )
                            : Container(
                                height: pngProv.getHeight,
                                width: pngProv.getWidth,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C0F45),
                                  border: const Border(
                                      left: BorderSide(
                                    color: Colors.white,
                                    width: 3.0, // Çizgi kalınlığı
                                  )),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/img/table_columns/${AppData.lessonPng[j]}/$i.png'),
                                    fit: BoxFit.fill,
                                    alignment: Alignment.center,
                                    repeat: ImageRepeat.noRepeat,
                                  ),
                                ),
                              ),
                      const Divider(
                        color: Colors.black,
                        height: 5,
                        thickness: 5,
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
