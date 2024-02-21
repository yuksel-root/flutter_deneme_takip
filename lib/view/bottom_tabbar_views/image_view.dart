import 'package:flutter/material.dart';

import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

class ImageView extends StatefulWidget {
  const ImageView({super.key});

  @override
  ImageViewState createState() => ImageViewState();
}

class ImageViewState extends State<ImageView> {
  String filePath = '';
  double h = 200;
  double w = 100;
  @override
  Widget build(BuildContext context) {
    final denemeProv = Provider.of<DenemeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: [
          ElevatedButton(
              onPressed: () {
                setState(() {
                  filePath = '';
                });
              },
              child: const Text("Orj resim")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                generateAndSaveImage(w, h);
              });
            },
            child: const Text('Resmi Oluştur ve Göster'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            filePath.isNotEmpty
                ? Container(
                    height: 200,
                    width: 200,
                    child: Image.file(
                      File(filePath),
                      fit: BoxFit.fill,
                      repeat: ImageRepeat.noRepeat,
                    ),
                  )
                : Container(
                    height: 100,
                    width: 200,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      image: DecorationImage(
                        image: AssetImage('assets/img/table_columns/vt/3.png'),
                        fit: BoxFit.fill,
                        alignment: Alignment.center,
                        repeat: ImageRepeat.noRepeat,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> generateAndSaveImage(double w, double h) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String fileName = 'output.png';
      ui.PictureRecorder recorder = ui.PictureRecorder();
      Paint paint = Paint()..color = Colors.blue;
      setState(() {
        // Resmi oluştur

        ui.Canvas canvas = ui.Canvas(
          recorder,
          ui.Rect.fromPoints(
            const ui.Offset(0.0, 0.0),
            ui.Offset(w, h),
          ),
        );

        // Resmi çiz

        canvas.drawRect(
          Rect.fromPoints(
            const Offset(0.0, 0.0),
            Offset(w, h),
          ),
          paint,
        );

        drawTextWithSpacing(
            canvas,
            "Anayasa \n Hukukuna \nGiriş Temel \nKavramlar Ve \nTürk Anayasa \nTarihi",
            1.0,
            1.0,
            w,
            h,
            2);
      });
      ui.Picture picture = recorder.endRecording();

      // Resmi PNG formatına dönüştür
      ui.Image img = await picture.toImage(w.toInt(), h.toInt());
      ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      // ByteData'ı dosyaya kaydet
      setState(() {
        filePath = '$appDocPath/$fileName';
        List<int> pngBytes = byteData!.buffer.asUint8List();
        File(filePath).writeAsBytesSync(pngBytes);
      });
    } catch (error) {
      print('Hata oluştu: $error');
    }
  }

  void drawTextWithSpacing(ui.Canvas canvas, String text, double x, double y,
      double maxWidth, double maxHeight, double wordSpacing) {
    final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 20,
        textDirection: TextDirection.ltr,
      ),
    )
      ..pushStyle(ui.TextStyle(
        color: Colors.white,
        wordSpacing: wordSpacing,
        fontFamily: 'Calibri',
        letterSpacing: 0.3,
      ))
      ..addText(text);

    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: maxWidth));

    canvas.drawParagraph(paragraph, Offset(x, y));
  }
}
