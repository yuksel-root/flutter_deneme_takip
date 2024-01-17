// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/gradient_widget.dart';
import 'package:flutter_deneme_takip/components/text_dialog_widget.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_deneme_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DenemeView extends StatelessWidget {
  const DenemeView({super.key});

  @override
  Widget build(BuildContext context) {
    final denemeProv = Provider.of<DenemeViewModel>(context);
    final editProv = Provider.of<EditDenemeViewModel>(context);
    final denemeData = context.read<DenemeViewModel>().listDeneme ?? [];

    return buildFutureView(denemeProv, denemeData, editProv);
  }

  FutureBuilder buildFutureView(
      DenemeViewModel denemeProv, denemeData, EditDenemeViewModel editProv) {
    return FutureBuilder(
        future: Future.delayed(Duration.zero, () async {
          return denemeData;
        }),
        builder: (BuildContext context, _) {
          if (context.watch<DenemeViewModel>().getDenemeState ==
              DenemeState.loading) {
            return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: buildDataTable(context, denemeProv, editProv));
          } else if (context.watch<DenemeViewModel>().listDeneme!.isEmpty) {
            return Center(
                child: Text(
                    style: TextStyle(
                        color: const Color(0xff1c0f45),
                        fontSize:
                            context.dynamicW(0.01) * context.dynamicH(0.005)),
                    'Gösterilecek veri yok'));
          } else {
            denemeProv.convertToRow(denemeData);
            if (denemeProv.getIsTotal == false) {
              denemeProv.insertRowData(denemeProv.denemelerData);
            } else {
              denemeProv.totalInsertRowData(denemeProv.denemelerData);
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
                            child:
                                buildDataTable(context, denemeProv, editProv)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }

  Widget buildDataTable(BuildContext context, DenemeViewModel denemeProv,
      EditDenemeViewModel editProv) {
    return Center(
        child: Column(children: <Widget>[
      SizedBox(
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          defaultColumnWidth: FixedColumnWidth(context.dynamicW(0.16)),
          border: TableBorder.all(
              color: Colors.black, style: BorderStyle.solid, width: 1),
          children: [
            getColumns(context, denemeProv),
            ...getRows(context, denemeProv, editProv),
          ],
        ),
      ),
    ]));
  }

  TableRow getColumns(BuildContext context, DenemeViewModel denemeProv) {
    return TableRow(
      children: List.generate(
        denemeProv.columnData.length,
        (index) => getColumnCell(context, denemeProv, index),
      ),
    );
  }

  TableCell getColumnCell(
      BuildContext context, DenemeViewModel denemeProv, int index) {
    return TableCell(
        child: Padding(
      padding: const EdgeInsets.all(0.4),
      child: Column(
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
                  height: 100,
                  width: 200,
                  child: Center(
                    child: Text(
                      "Deneme Sıra No",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            context.dynamicW(0.01) * context.dynamicH(0.004),
                      ),
                    ),
                  ),
                )
              : GradientWidget(
                  blendModes: BlendMode.srcOut,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff1c0f45),
                      Color(0xff191970),
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  widget: Container(
                    height: 100,
                    width: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/img/table_columns/${denemeProv.getInitPng}/$index.png'),
                        fit: BoxFit.fill,
                        alignment: Alignment.center,
                        repeat: ImageRepeat.noRepeat,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    ));
  }

  Widget getRowCell(BuildContext context, int i, dynamic cell,
      DenemeViewModel denemeProv, EditDenemeViewModel editProv, int rowIndex) {
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
                  onLongPress: denemeProv.getIsTotal != true
                      ? () async {
                          await Future.delayed(const Duration(milliseconds: 50),
                              () {
                            denemeProv.removeAlert(
                              context,
                              'UYARI',
                              '${denemeProv.extractNumber(cell)}.Denemeyi silmek istediğinize emin misiniz?',
                              denemeProv,
                              cell,
                            );
                          });
                        }
                      : () {},
                  child: Center(
                    child: Padding(
                      padding:
                          EdgeInsets.only(bottom: context.dynamicH(0.00714)),
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
                                        fontSize: context.dynamicW(0.01) *
                                            context.dynamicH(0.005))
                                    : TextStyle(
                                        color: Colors.white,
                                        fontSize: context.dynamicW(0.01) *
                                            context.dynamicH(0.005)),
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
                width: context.dynamicW(0.13),
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
                    denemeProv.setAlert = false;
                    print(rowIndex + 1);
                    await showTextDialog(context,
                        title: 'Yanlış Sayısını Değiştir',
                        value: cell.toString(),
                        index: i,
                        rowIndex: (rowIndex + 1),
                        alert: denemeProv.getIsAlertOpen);
                  },
                  child: Center(
                    child: Padding(
                      padding:
                          EdgeInsets.only(bottom: context.dynamicH(0.00714)),
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
                                      fontSize: context.dynamicW(0.01) *
                                          context.dynamicH(0.005))
                                  : TextStyle(
                                      color: Colors.white,
                                      fontSize: context.dynamicW(0.01) *
                                          context.dynamicH(0.005)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }

  Widget getRowCell2(BuildContext context, int i, dynamic cell,
      DenemeViewModel denemeProv, int rowIndex) {
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
                  onLongPress: () async {
                    await Future.delayed(const Duration(milliseconds: 50), () {
                      denemeProv.removeAlert(
                        context,
                        'UYARI',
                        '${denemeProv.extractNumber(cell)}.Denemeyi silmek istediğinize emin misiniz?',
                        denemeProv,
                        cell,
                      );
                    });
                  },
                  child: Center(
                    child: Padding(
                      padding:
                          EdgeInsets.only(bottom: context.dynamicH(0.00714)),
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
                                      color: Colors.black,
                                      fontSize: context.dynamicW(0.01) *
                                          context.dynamicH(0.005))
                                  : TextStyle(
                                      color: Colors.white,
                                      fontSize: context.dynamicW(0.01) *
                                          context.dynamicH(0.005)),
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
                width: context.dynamicW(0.13),
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
                    denemeProv.setAlert = false;

                    await showTextDialog(context,
                            title: 'Yanlış Sayısı Değiştir',
                            value: cell.toString(),
                            index: i,
                            rowIndex: (rowIndex + 1),
                            alert: denemeProv.getIsAlertOpen)
                        .then((value) {
                      denemeProv.initDenemeData(denemeProv.getLessonName);
                    });
                  },
                  child: Center(
                    child: Padding(
                      padding:
                          EdgeInsets.only(bottom: context.dynamicH(0.00714)),
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
                                      fontSize: context.dynamicW(0.01) *
                                          context.dynamicH(0.005))
                                  : TextStyle(
                                      color: Colors.white,
                                      fontSize: context.dynamicW(0.01) *
                                          context.dynamicH(0.005)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }

  List<TableRow> getRows(BuildContext context, DenemeViewModel denemeProv,
      EditDenemeViewModel editProv) {
    int k = -1;
    List<Map<String, dynamic>> rowXdata = List.from(denemeProv.rowData);

    return rowXdata.map((row) {
      k++;
      List<Widget> cells = List.generate(
        row['row'].length,
        (i) {
          dynamic cell = row['row'][i];
          if (((k % 2) == 0)) {
            return getRowCell(context, i, cell, denemeProv, editProv, k);
          } else {
            return getRowCell2(context, i, cell, denemeProv, k);
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
}
