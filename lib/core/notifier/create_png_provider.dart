// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/app_theme.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

class CreatePngProvider with ChangeNotifier {
  late String _filePath;

  late double _h;
  late double _w;

  late double _textWidth;
  late double _textHeight;

  late double _offsetX;
  late double _offsetY;

  late double _scaleCenterX;
  late double _scaleCenterY;

  CreatePngProvider() {
    _filePath = '';
    _h = 150;
    _w = 120;
    _textWidth = 0;
    _textHeight = 0;
    _scaleCenterX = 0;
    _scaleCenterY = 0;
    _offsetX = 0;
    _offsetY = 0;
  }

  set setFilePath(String newPath) {
    _filePath = newPath;
    notifyListeners();
  }

  set setHeight(double newH) {
    _h = newH;
    notifyListeners();
  }

  set setWidth(double newWidth) {
    _w = newWidth;
    notifyListeners();
  }

  set setTextWidth(double newWidth) {
    _textWidth = newWidth;
    notifyListeners();
  }

  set setOffsetX(double newX) {
    _offsetX = newX;
    notifyListeners();
  }

  get getOffsetX {
    return _offsetX;
  }

  set setCenterScaleX(double newX) {
    _scaleCenterX = newX;
    notifyListeners();
  }

  get getCenterScaleX {
    return _scaleCenterX;
  }

  set setCenterScaleY(double newX) {
    _scaleCenterY = newX;
    notifyListeners();
  }

  get getCenterScaleY {
    return _scaleCenterY;
  }

  set setOffsetY(double newY) {
    _offsetY = newY;
    notifyListeners();
  }

  set setTextHeight(double newWidth) {
    _textHeight = newWidth;
    notifyListeners();
  }

  get getOffsetY {
    return _offsetY;
  }

  get getFilePath {
    return _filePath;
  }

  get getHeight {
    return _h;
  }

  get getWidth {
    return _w;
  }

  get getTextWidth {
    return _textWidth;
  }

  get getTextHeight {
    return _textHeight;
  }

  void deleteImages(Directory directoryPath) {
    if (directoryPath.existsSync()) {
      List<FileSystemEntity> files = directoryPath.listSync();

      for (FileSystemEntity file in files) {
        if (file is File) {
          file.deleteSync();
        }
      }

      print('Dosyalar silindi.');
    } else {
      print('Belirtilen dizin bulunamadı.');
    }
    notifyListeners();
  }

  void generateAndSaveImage(denemeProv) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();

    setCenterScaleX = 3;
    setCenterScaleY = 3;
    setOffsetX = (getWidth - getTextWidth) / getCenterScaleX;
    setOffsetY = (getHeight - getTextHeight) / getCenterScaleY;

    double difX = (getWidth - getTextWidth);
    double difY = (getHeight - getTextHeight);
    print(
        "{W $getWidth}  - {textW $getTextWidth}=>  $difX / $getCenterScaleX  = {OffSetX $getOffsetX}");
    print(
        "{H $getHeight} - {TextH $getTextHeight}=> $difY / $getCenterScaleY = {OffSetY $getOffsetY}");

    print("Drawing {X = $getOffsetX} {Y = $getOffsetY}");

    for (int k = 0; k < 3; k++) {
      try {
        for (int i = 1; i < 10; i++) {
          String appDocPath = appDocDir.path;
          String fileName = 'output$i$k.png';
          ui.PictureRecorder recorder = ui.PictureRecorder();
          Paint paint = Paint()
            ..color = const Color(0xFF1C0F45)
            ..filterQuality = FilterQuality.high
            ..isAntiAlias = true
            ..blendMode = BlendMode.color;

          // Resmi oluştur
          ui.Canvas canvas = ui.Canvas(
            recorder,
            ui.Rect.fromPoints(
              const ui.Offset(0.0, 0.0),
              ui.Offset(getWidth, getHeight),
            ),
          );

          // Resmi çiz
          canvas.drawRect(
            Rect.fromPoints(
              const Offset(0.0, 0.0),
              Offset(getWidth, getHeight),
            ),
            paint,
          );
          drawText(
            canvas,
            denemeProv.findList(k == 0
                ? "Vatandaşlık"
                : k == 1
                    ? 'Coğrafya'
                    : k == 2
                        ? 'Tarih'
                        : 'aaaa')[i],
            0.0,
            0.0,
            getWidth,
            getHeight,
            1,
            denemeProv,
          );
          ui.Picture picture = recorder.endRecording();

          // Resmi PNG formatına dönüştür
          ui.Image img =
              await picture.toImage(getWidth.toInt(), getHeight.toInt());

          ByteData? byteData =
              await img.toByteData(format: ui.ImageByteFormat.png);
          // ByteData'ı dosyaya kaydet

          setFilePath = '$appDocPath/$fileName';
          //   print(filePath);
          List<int> pngBytes = byteData!.buffer.asUint8List();
          File(getFilePath).writeAsBytesSync(pngBytes);
        }
      } catch (error) {
        print('Hata oluştu: $error');
      }
    }
    notifyListeners();
  }

  void drawText(ui.Canvas canvas, String text, double x, double y,
      double maxWidth, double maxHeight, double wordSpacing, denemeProv) {
    findTextSize(denemeProv, text);
    final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 20,
        textDirection: TextDirection.ltr,
      ),
    )
      ..pushStyle(ui.TextStyle(
        color: Colors.white,
        fontFamily: 'Calibri',
        fontWeight: FontWeight.w100,
        fontStyle: FontStyle.normal,
        fontSize: 20,
      ))
      ..addText(text);

    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: maxWidth));

    canvas.drawParagraph(paragraph, Offset(x + getOffsetX, y + getOffsetY));

    notifyListeners();
  }

  findTextSize(denemeProv, text) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w100,
          fontFamily: 'Calibri',
          fontStyle: FontStyle.normal,
          fontSize:
              AppTheme.dynamicSize(dynamicHSize: 0.005, dynamicWSize: 0.009),
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      textWidthBasis: TextWidthBasis.longestLine,
    );
    textPainter.layout(maxWidth: getWidth);

    setTextWidth = textPainter.width;
    setTextHeight = textPainter.height;

    //print("Width $textWidth height $textHeight");
    notifyListeners();
  }
}
