// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:flutter_deneme_takip/components/text_dialog/update_text_dialog.dart';
import 'package:flutter_deneme_takip/core/constants/app_theme.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view_model/exam_table_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_exam_view_model.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ExamTableView extends StatelessWidget {
  const ExamTableView({super.key});

  @override
  Widget build(BuildContext context) {
    final examTableProv = Provider.of<ExamTableViewModel>(context);
    final editProv = Provider.of<EditExamViewModel>(context);
    final lessonProv = Provider.of<LessonViewModel>(context);
    final examData = context.read<ExamTableViewModel>().listexam ?? [];

    return buildFutureView(examTableProv, examData, editProv, lessonProv);
  }

  FutureBuilder buildFutureView(ExamTableViewModel examProv, examData,
      EditExamViewModel editProv, LessonViewModel lessonProv) {
    return FutureBuilder(
        future: Future.delayed(Duration.zero, () async {
          return examData;
        }),
        builder: (BuildContext context, _) {
          if (context.watch<ExamTableViewModel>().getexamState ==
              ExamState.loading) {
            return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: buildDataTable(context, examProv, editProv, lessonProv));
          } else if (context.watch<ExamTableViewModel>().listexam!.isEmpty) {
            return Center(
                child: Text(
                    style: TextStyle(
                        color: const Color(0xff1c0f45),
                        fontSize: AppTheme.dynamicSize(
                            dynamicHSize: 0.005, dynamicWSize: 0.01)),
                    'Gösterilecek veri yok'));
          } else {
            examProv.convertToRow(examData);
            if (examProv.getIsTotal == false) {
              examProv.insertRowData(examProv.examlerData);
            } else {
              examProv.totalInsertRowData(examProv.examlerData);
            }

            return Scaffold(
              body: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 20,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: buildDataTable(
                                context, examProv, editProv, lessonProv)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }

  Widget buildDataTable(BuildContext context, ExamTableViewModel examProv,
      EditExamViewModel editProv, LessonViewModel lessonProv) {
    return Center(
        child: Column(children: <Widget>[
      SizedBox(
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          defaultColumnWidth: FixedColumnWidth(
              AppTheme.dynamicSize(dynamicHSize: 0.014, dynamicWSize: 0.02)),
          border: TableBorder.all(
              color: Colors.black, style: BorderStyle.solid, width: 1),
          children: [
            getColumns(context, examProv, lessonProv),
            ...getRows(context, examProv, editProv),
          ],
        ),
      ),
    ]));
  }

  TableRow getColumns(BuildContext context, ExamTableViewModel examProv,
      LessonViewModel lessonProv) {
    return TableRow(
        children: List.generate(examProv.columnData.length,
            (index) => getColumnCell(context, examProv, index, lessonProv)));
  }

  TableCell getColumnCell(BuildContext context, ExamTableViewModel examProv,
      int index, LessonViewModel lessonProv) {
    return TableCell(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        index == 0
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff200122),
                      Color(0xff6f0000),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                  ),
                ),
                height: AppTheme.dynamicSize(
                    dynamicHSize: 0.0117, dynamicWSize: 0.032),
                width: AppTheme.dynamicSize(
                    dynamicHSize: 0.014, dynamicWSize: 0.02),
                child: Center(
                  child: Text(
                    "exam\n Sıra\n No",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTheme.dynamicSize(
                          dynamicHSize: 0.005, dynamicWSize: 0.0095),
                    ),
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1C0F45),
                      Color(0xFF1C0F45),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                  ),
                ),
                height: AppTheme.dynamicSize(
                    dynamicHSize: 0.0117, dynamicWSize: 0.032),
                width: AppTheme.dynamicSize(
                    dynamicHSize: 0.014, dynamicWSize: 0.02),
                child: Center(
                    child: buildResizableText(
                        context, lessonProv, index, examProv))),
      ],
    ));
  }

  Widget buildResizableText(BuildContext context, LessonViewModel lessonProv,
      int index, ExamTableViewModel examProv) {
    return Text(
      examProv.findList(lessonProv.getLessonName ?? "Coğrafya")[index],
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.normal,

        fontFamily: 'Calibri',
        fontStyle: FontStyle.normal,
        fontSize: AppTheme.dynamicSize(
            dynamicHSize: 0.0045, dynamicWSize: 0.0085), //4x4 16px
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
  }
}

double findMax(ExamTableViewModel examProv) {
  double largestH = 0;
  for (double height in examProv.listContHeights) {
    if (height > largestH) {
      largestH = height;
    }
  }
  return largestH;
}

Widget getRowCell(BuildContext context, int i, dynamic cell,
    ExamTableViewModel examProv, EditExamViewModel editProv, int rowIndex) {
  return TableCell(
      child: i == 0
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff283048),
                    Color.fromARGB(255, 0, 187, 255),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                ),
              ),
              child: InkWell(
                onDoubleTap: examProv.getIsTotal != true
                    ? () async {
                        await Future.delayed(const Duration(milliseconds: 0),
                            () {
                          examProv.removeAlert(
                            context,
                            'UYARI',
                            '${examProv.extractNumber(cell)}.denemeyi silmek istediğinize emin misiniz?',
                            examProv,
                            cell,
                          );
                        });
                      }
                    : () {},
                onLongPress: examProv.getIsTotal != true
                    ? () async {
                        await Future.delayed(const Duration(milliseconds: 0),
                            () {
                          examProv.removeAlert(
                            context,
                            'UYARI',
                            '${examProv.extractNumber(cell)}.denemeyi silmek istediğinize emin misiniz?',
                            examProv,
                            cell,
                          );
                        });
                      }
                    : () {},
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: AppTheme.dynamicSize(
                            dynamicHSize: 0.003, dynamicWSize: 0.004)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: InkWell(
                            child: Text(
                              cell.toString(),
                              textAlign: TextAlign.center,
                              style: i != 0
                                  ? TextStyle(
                                      color: Colors.black,
                                      fontSize: AppTheme.dynamicSize(
                                          dynamicHSize: 0.005,
                                          dynamicWSize: 0.01))
                                  : TextStyle(
                                      color: Colors.white,
                                      fontSize: AppTheme.dynamicSize(
                                          dynamicHSize: 0.005,
                                          dynamicWSize: 0.01)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Container(
              height: context.dynamicW(0.13),
              width:
                  AppTheme.dynamicSize(dynamicHSize: 0.014, dynamicWSize: 0.02),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff283048),
                    Color.fromARGB(255, 0, 187, 255),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                ),
              ),
              child: InkWell(
                onDoubleTap: () async {
                  examProv.setAlert = false;
                  editProv.setLoading = true;
                  examProv.getIsTotal == false
                      ? await showTextDialog(context,
                              title: 'Yanlış Sayısı Değiştir',
                              value: cell.toString(),
                              index: i,
                              rowIndex: (rowIndex + 1),
                              alert: examProv.getIsAlertOpen)
                          .then((value) {
                          // examProv.initExamData(lessonProv.getLessonName);
                          examProv.setIsTotal = false;
                        })
                      : () {};
                },
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: AppTheme.dynamicSize(
                            dynamicHSize: 0.003, dynamicWSize: 0.004)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(cell.toString(),
                              textAlign: TextAlign.center,
                              style: i != 0
                                  ? TextStyle(
                                      color: Colors.white,
                                      fontSize: AppTheme.dynamicSize(
                                          dynamicHSize: 0.005,
                                          dynamicWSize: 0.01))
                                  : TextStyle(
                                      color: Colors.white,
                                      fontSize: AppTheme.dynamicSize(
                                          dynamicHSize: 0.005,
                                          dynamicWSize: 0.01))),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
}

Widget getRowCell2(BuildContext context, int i, dynamic cell,
    ExamTableViewModel examProv, int rowIndex) {
  return TableCell(
      child: i == 0
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff283048),
                    Color(0xff859398),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                ),
              ),
              child: InkWell(
                onDoubleTap: examProv.getIsTotal != true
                    ? () async {
                        await Future.delayed(const Duration(milliseconds: 0),
                            () {
                          examProv.removeAlert(
                            context,
                            'UYARI',
                            '${examProv.extractNumber(cell)}.examyi silmek istediğinize emin misiniz?',
                            examProv,
                            cell,
                          );
                        });
                      }
                    : () {},
                onLongPress: () async {
                  examProv.getIsTotal == false
                      ? await Future.delayed(const Duration(milliseconds: 0),
                          () {
                          examProv.removeAlert(
                            context,
                            'UYARI',
                            '${examProv.extractNumber(cell)}.examyi silmek istediğinize emin misiniz?',
                            examProv,
                            cell,
                          );
                        })
                      : () {};
                },
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: AppTheme.dynamicSize(
                            dynamicHSize: 0.003, dynamicWSize: 0.004)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(cell.toString(),
                              textAlign: TextAlign.center,
                              style: i != 0
                                  ? TextStyle(
                                      color: Colors.black,
                                      fontSize: AppTheme.dynamicSize(
                                          dynamicHSize: 0.005,
                                          dynamicWSize: 0.01))
                                  : TextStyle(
                                      color: Colors.white,
                                      fontSize: AppTheme.dynamicSize(
                                          dynamicHSize: 0.005,
                                          dynamicWSize: 0.01))),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Container(
              height: context.dynamicW(0.13),
              width:
                  AppTheme.dynamicSize(dynamicHSize: 0.014, dynamicWSize: 0.02),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff1c0f45),
                    Color.fromARGB(255, 189, 188, 188),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: InkWell(
                onDoubleTap: () async {
                  examProv.setAlert = false;

                  examProv.getIsTotal == false
                      ? await showTextDialog(context,
                              title: 'Yanlış Sayısı Değiştir',
                              value: cell.toString(),
                              index: i,
                              rowIndex: (rowIndex + 1),
                              alert: examProv.getIsAlertOpen)
                          .then((value) {
                          //    examProv.initExamData(examProv.getLessonName);
                          examProv.setIsTotal = false;
                        })
                      : () {};
                },
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: AppTheme.dynamicSize(
                            dynamicHSize: 0.003, dynamicWSize: 0.004)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            cell.toString(),
                            textAlign: TextAlign.center,
                            style: i != 0
                                ? TextStyle(
                                    color: Colors.white,
                                    fontSize: AppTheme.dynamicSize(
                                        dynamicHSize: 0.005,
                                        dynamicWSize: 0.01))
                                : TextStyle(
                                    color: Colors.white,
                                    fontSize: AppTheme.dynamicSize(
                                        dynamicHSize: 0.005,
                                        dynamicWSize: 0.01)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
}

List<TableRow> getRows(BuildContext context, ExamTableViewModel examProv,
    EditExamViewModel editProv) {
  int k = -1;
  List<Map<String, dynamic>> rowXdata = List.from(examProv.rowData);

  return rowXdata.map((row) {
    k++;
    List<Widget> cells = List.generate(
      row['row'].length,
      (i) {
        dynamic cell = row['row'][i];
        if (((k % 2) == 0)) {
          return getRowCell(context, i, cell, examProv, editProv, k);
        } else {
          return getRowCell2(context, i, cell, examProv, k);
        }
      },
    );

    return TableRow(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          style: BorderStyle.solid,
          width: 0.5,
        ),
      ),
      children: cells,
    );
  }).toList();
}
