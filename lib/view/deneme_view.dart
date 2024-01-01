// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/gradient_widget.dart';
import 'package:flutter_deneme_takip/components/utils.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:provider/provider.dart';

class DenemeView extends StatelessWidget {
  const DenemeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final denemeProv = Provider.of<DenemeViewModel>(context);
    final denemeData = context.read<DenemeViewModel>().listDeneme ?? [];
    return buildFutureView(denemeProv, denemeData);
  }

  FutureBuilder buildFutureView(DenemeViewModel denemeProv, denemeData) {
    return FutureBuilder(
      future: Future.delayed(Duration.zero, () => denemeData),
      builder: (BuildContext context, _) {
        if (context.watch<DenemeViewModel>().getDenemeState ==
            DenemeState.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
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
                        child: buildDataTable(context, denemeProv),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildDataTable(BuildContext context, DenemeViewModel denemeProv) {
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
            ...getRows(context, denemeProv),
          ],
        ),
      ),
    ]));
  }

  Widget buildEmptyTable(BuildContext context, DenemeViewModel denemeProv) {
    return Center(
        child: Column(children: <Widget>[
      Column(
        children: [
          SizedBox(
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              defaultColumnWidth: FixedColumnWidth(context.dynamicW(0.20)),
              border: TableBorder.all(
                  color: Colors.black, style: BorderStyle.solid, width: 1),
              children: [
                getColumns(context, denemeProv),
              ],
            ),
          ),
          SizedBox(
            height: 800,
            width: 660,
            child: Text(
              "${xd()} Veri yok xd",
              style: TextStyle(
                fontSize: context.dynamicW(0.01) * context.dynamicH(0.005),
              ),
            ),
          )
        ],
      ),
    ]));
  }

  String xd() {
    List<String> a = [];
    for (int i = 0; i < 8; i++) {
      a.add("\n");
    }
    return a.join();
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
    String pngx = denemeProv.initPng(denemeProv.lessonName ?? 'Tarih');
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
                            'assets/img/table_columns/$pngx/$index.png'),
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

  Widget getRowCell(
      BuildContext context, int i, dynamic cell, DenemeViewModel denemeProv) {
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
                  onLongPress: () {
                    Future.delayed(const Duration(milliseconds: 100), () {
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
                            child: Center(
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
                  onLongPress: () {
                    Future.delayed(const Duration(milliseconds: 100), () {
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
                            child: Center(
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }

  Widget getRowCell2(
      BuildContext context, int i, dynamic cell, DenemeViewModel denemeProv) {
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
                  onLongPress: () {
                    Future.delayed(const Duration(milliseconds: 100), () {
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
                            child: Center(
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
                      Color(0xff1c0f45),
                      Color.fromARGB(255, 189, 188, 188),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: InkWell(
                  onLongPress: () {
                    Future.delayed(const Duration(milliseconds: 100), () {
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
                            child: Center(
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }

  List<TableRow> getRows(BuildContext context, DenemeViewModel denemeProv) {
    int k = -1;
    List<Map<String, dynamic>> rowXdata = List.from(denemeProv.rowData);

    return rowXdata.map((row) {
      k++;
      print("k $k k % 2 ${k % 2}");

      return TableRow(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            style: BorderStyle.solid,
            width: 0.5,
          ),
        ),
        children: Utils.modelBuilder(row['row'], (i, cell) {
          return ((k % 2) == 0)
              ? getRowCell(context, i, cell, denemeProv)
              : getRowCell2(context, i, cell, denemeProv);
        }),
      );
    }).toList();
  }
}
