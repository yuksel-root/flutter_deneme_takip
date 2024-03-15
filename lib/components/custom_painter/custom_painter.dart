// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/view_model/exam_table_view_model.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

import 'dart:io';

class CustomWidgetPainter extends CustomPainter with ChangeNotifier {
  late Paint? _paint;

  late double _containerHeight;
  late double _containerWidth;

  late double _textWidth;
  late double _textHeight;
  late double _offsetX;
  late double _offsetY;
  late double _scaleCenterX;
  late double _scaleCenterY;

  late String _fileName;
  late String _subjectText;
  late String _filePath;
  late String _navString;

  late ui.PictureRecorder? _recorder;
  late ui.Paragraph? _paragraph;
  late ui.ParagraphBuilder? _paragraphBuilder;
  late ui.Canvas? _canvas;

  late Map<String, List<String>> _mapSubjectText;

  CustomWidgetPainter() {
    _containerHeight = 150;
    _containerWidth = 200;

    _textWidth = 0;
    _textHeight = 0;
    _offsetX = 0;
    _offsetY = 0;
    _scaleCenterX = 0;
    _scaleCenterY = 0;

    _paragraph = null;
    _paragraphBuilder = null;

    _mapSubjectText = {};

    _canvas = null;
    _paint = null;
    _recorder = null;
    _navString = 'orjPng';
    _fileName = "";
    _filePath = '';
    _subjectText = "";
  }

  set setSubjectText(String newText) {
    _subjectText = newText;
    notifyListeners();
  }

  set setNavText(String newText) {
    _navString = newText;
    notifyListeners();
  }

  get getNavText => _navString;

  set setParagraph(ui.Paragraph newPr) {
    _paragraph = newPr;
    notifyListeners();
  }

  get getParagraph => _paragraph;

  set setPrBuilder(ui.ParagraphBuilder newPr) {
    _paragraphBuilder = newPr;
    notifyListeners();
  }

  get getPrBuilder => _paragraphBuilder;

  set setCanvas(ui.Canvas newCanvas) {
    _canvas = newCanvas;
    notifyListeners();
  }

  set setRecorder(ui.PictureRecorder newRecord) {
    _recorder = newRecord;
    notifyListeners();
  }

  get getRecorder => _recorder;

  set setPaint(Paint newPaint) {
    _paint = newPaint;
    notifyListeners();
  }

  set setFileName(String newS) {
    _fileName = newS;
    notifyListeners();
  }

  set setFilePath(String newPath) {
    _filePath = newPath;
    notifyListeners();
  }

  set setHeight(double newH) {
    _containerHeight = newH;
    notifyListeners();
  }

  set setWidth(double newWidth) {
    _containerWidth = newWidth;
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

  set setCenterScaleX(double newX) {
    _scaleCenterX = newX;
    notifyListeners();
  }

  set setCenterScaleY(double newX) {
    _scaleCenterY = newX;
    notifyListeners();
  }

  set setOffsetY(double newY) {
    _offsetY = newY;
    notifyListeners();
  }

  set setTextHeight(double newWidth) {
    _textHeight = newWidth;
    notifyListeners();
  }

  get getCanvas => _canvas;
  get getPaint => _paint;
  get getFileName => _fileName;
  get getSubjectText => _subjectText;
  get getOffsetX => _offsetX;
  get getCenterScaleX => _scaleCenterX;
  get getCenterScaleY => _scaleCenterY;
  get getOffsetY => _offsetY;
  get getFilePath => _filePath;
  get getHeight => _containerHeight;
  get getWidth => _containerWidth;
  get getTextWidth => _textWidth;
  get getTextHeight => _textHeight;

  Future<void> deleteImages(Directory directoryPath) async {
    if (directoryPath.existsSync()) {
      List<FileSystemEntity> files = directoryPath.listSync();

      for (FileSystemEntity file in files) {
        if (file is File) {
          Future.sync(() => file.deleteSync());
          notifyListeners();
        }
      }

      print('Dosyalar silindi.');
    } else {
      print('Belirtilen dizin bulunamadı.');
    }
  }

  String getText(ExamTableViewModel examProv, int k, int i) {
    List<String> list = examProv.findList(k == 0
        ? "Vatandaşlık"
        : k == 1
            ? 'Coğrafya'
            : k == 2
                ? 'Tarih'
                : 'aaaa');
    if (k == 0) {
      _mapSubjectText = {'Vatandaşlık': list};
      return _mapSubjectText['Vatandaşlık']![i];
    }
    if (k == 1) {
      _mapSubjectText = {'Coğrafya': list};
      return _mapSubjectText['Coğrafya']![i];
    }
    if (k == 2) {
      _mapSubjectText = {'Tarih': list};
      return _mapSubjectText['Tarih']![i];
    }

    return _mapSubjectText['Vatandaşlık']![i];
  }

  Future<void> generateAndSaveImage(examProv) async {
    for (int k = 0; k < 3; k++) {
      for (int i = 1; i < 11; i++) {
        try {
          final CustomPainter painter = CustomWidgetPainter();
          final Directory appDocDir = await getApplicationDocumentsDirectory();
          if (k == 0) {
            setFileName = 'Vatandaşlık$i.png';
          }
          if (k == 1) {
            setFileName = 'Coğrafya$i.png';
          }
          if (k == 2) {
            setFileName = 'Tarih$i.png';
          }

          setSubjectText = getText(examProv, k, i);
          //painter.shouldRepaint(painter);
          ui.PictureRecorder recorder = ui.PictureRecorder();

          Canvas canvas = Canvas(recorder);

          painter.paint(canvas, Size(getWidth, getHeight));

          drawText(canvas, getCenterScaleX, getCenterScaleY, getSubjectText);

          ui.Picture picture = recorder.endRecording();

          ui.Image image =
              await picture.toImage(getWidth.toInt(), getHeight.toInt());

          ByteData? byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);

          List<int> pngBytes = byteData!.buffer.asUint8List();

          setFilePath = '${appDocDir.path}/$getFileName';
          File(getFilePath).writeAsBytesSync(pngBytes, flush: true);
        } catch (error) {
          print('Hata oluştu: $error');
        }
      }
    }
    notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) async {
    var paint = Paint()
      ..color = const Color(0xFF1C0F45)
      ..blendMode = BlendMode.src;
    Rect rect = Rect.fromPoints(
      const Offset(0.0, 0.0),
      Offset(getWidth, getHeight),
    );

    canvas.drawRect(rect, paint);
    drawText(canvas, getCenterScaleX, getCenterScaleY, getSubjectText);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  Future<void> drawText(Canvas canvas, double centerScaleX, double centerScaleY,
      String text) async {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: getSubjectText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w100,
          fontFamily: 'Calibri',
          fontStyle: FontStyle.normal,
          fontSize: 20,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      textWidthBasis: TextWidthBasis.longestLine,
    );
    textPainter.layout(maxWidth: getWidth);

    double setTextWidth = textPainter.width;
    double setTextHeight = textPainter.height;

    double setOffsetX = (getWidth - setTextWidth) / centerScaleX;
    double setOffsetY = (getHeight - setTextHeight) / centerScaleY;

    ui.ParagraphBuilder prB = ui.ParagraphBuilder(
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
      ..addText(
        "Anayasa Hukukuna Giriş Temel Kavramlar Ve Türk Anayasa Tarihi Tarihleri",
      );
    ui.Paragraph pr = prB.build()
      ..layout(ui.ParagraphConstraints(width: getWidth));

    canvas.drawParagraph(pr, Offset(setOffsetX, setOffsetY));
    //double difX = (getWidth - getTextWidth);
    // double difY = (getHeight - getTextHeight);
    /* print(
        "{W $getWidth}  - {textW $getTextWidth}=>  $difX / $getCenterScaleX  = {OffSetX $getOffsetX} ");
    print(
        "{H $getHeight} - {TextH $getTextHeight}=> $difY / $getCenterScaleY = {OffSetY $getOffsetY}");
 */
  }
}
