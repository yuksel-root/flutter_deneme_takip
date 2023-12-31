// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/alert_dialog.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/components/utils.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:provider/provider.dart';

class DenemeView extends StatefulWidget {
  final String? lessonName;

  const DenemeView({Key? key, this.lessonName}) : super(key: key);

  @override
  State<DenemeView> createState() => _DenemeViewState();
}

class _DenemeViewState extends State<DenemeView> {
  late String _lessonName;

  bool _isAlertOpen = false;
  late String _lessonTableName;
  late List<dynamic> rowData;
  late List<dynamic> columnData;
  late List<Map<String, dynamic>> denemelerData;

  @override
  void initState() {
    print('initDeneme');
    super.initState();
    _lessonName = widget.lessonName ?? 'Tarih';
    _lessonTableName =
        LessonList.tableNames[_lessonName] ?? DenemeTables.historyTableName;

    columnData = List.of(findList(_lessonName));
    rowData = [];
    denemelerData = [];
  }

  String initTable() {
    String tableName =
        LessonList.tableNames[_lessonName] ?? DenemeTables.historyTableName;
    return tableName;
  }

  String initPng(String lessonName) {
    String? png =
        LessonList.lessonPngList[lessonName] ?? LessonList.lessonPngList[0];
    return png!;
  }

  List<Map<String, dynamic>> filterByDenemeId(List<Map<String, dynamic>> data) {
    Map<int, List<Map<String, dynamic>>> groupedData = {};
    List<Map<String, dynamic>> group = [];

    group.clear();
    groupedData.clear();
    denemelerData.clear();
    for (var item in data) {
      final denemeId = item['denemeId'] as int;
      if (!groupedData.containsKey(denemeId)) {
        groupedData[denemeId] = [];
      }
      groupedData[denemeId]!.add(item);
    }

    //_lastDenemeId =
    //  (await DenemeDbProvider.db.getFindLastId(initTable(), "denemeId"))!;
    //print(_lastDenemeId);
    // group = groupedData[1]!;

    group.addAll(groupedData.values.expand((items) => items));

    return group;
  }

  void convertToRow(List<Map<String, dynamic>> data) async {
    Map<int, List<Map<String, dynamic>>> idToRowMap = {};

    for (var item in filterByDenemeId(data)) {
      int id = item['id'];
      if (idToRowMap[id] == null) {
        idToRowMap[id] = [];
      }
      idToRowMap[id]!.add(item);
    }

    for (var entry in idToRowMap.entries) {
      Map<String, dynamic> rowItem = {"row": entry.value};
      denemelerData.add(rowItem);
    }

    //print('denemelerData');
    //print(denemelerData);
    // print('denemelerData');
  }

  Map<int, List<int>> falseCountsByDenemeId(
      List<Map<String, dynamic>> denemelerData) {
    Map<int, List<int>> falseCountsByDenemeId = {};

    for (var item in denemelerData) {
      var row = item['row'] as List<dynamic>;
      if (row.isNotEmpty) {
        var denemeId = row[0]['denemeId'] as int;
        var falseCount = row[0]['falseCount'] as int;

        if (!falseCountsByDenemeId.containsKey(denemeId)) {
          falseCountsByDenemeId[denemeId] = [];
        }

        falseCountsByDenemeId[denemeId]!.add(falseCount);
      }
    }
    return falseCountsByDenemeId;
  }

  void insertRowData(List<Map<String, dynamic>> denemelerData) {
    int i = 0;
    rowData.clear();

    falseCountsByDenemeId(denemelerData).forEach((denemeId, falseCounts) {
      List<dynamic> arr = List.generate(columnData.length, (index) => 0);
      print(falseCounts);
      for (int j = 0; j < (falseCounts.length); j++) {
        arr[0] = "Deneme$denemeId";
        arr[j] = falseCounts[j];
      }

      rowData.add({'row': List.from(arr)});

      i++;
      arr.clear();
    });

    rowData.sort((a, b) {
      print("Sorted");
      String aTitle = a['row'][0].toString();
      String bTitle = b['row'][0].toString();

      // "Deneme" ifadesini atarak sadece sayısal değerleri alıyoruz
      int aNumber = int.parse(aTitle.replaceAll("Deneme", ""));
      int bNumber = int.parse(bTitle.replaceAll("Deneme", ""));

      return aNumber.compareTo(bNumber);
    });
    // print("rowData");
    // print(rowData);
    // print("rowData");
  }

  List<dynamic> sumByFiveGroups(List<List<int>> inputList) {
    List<List<int>> resultList = [];

    for (int i = 0; i < inputList.length; i += 5) {
      List<int> sumList = List.filled(inputList[i].length, 0);

      for (int j = i; j < i + 5 && j < inputList.length; j++) {
        for (int k = 0; k < inputList[j].length; k++) {
          sumList[k] += inputList[j][k];
        }
      }

      resultList.add(sumList);
    }

    return resultList;
  }

  List<String> findList(String lessonName) {
    return LessonList.lessonListMap[lessonName] ?? [];
  }

  Future<List<Map<String, dynamic>>> initData() async {
    String tableName =
        LessonList.tableNames[_lessonName] ?? DenemeTables.historyTableName;

    return await DenemeDbProvider.db.getLessonDeneme(tableName);
  }

  @override
  Widget build(BuildContext context) {
    final denemeProv = Provider.of<DenemeViewModel>(context);
    return buildFutureView(denemeProv);
  }

  FutureBuilder<List<Map<String, dynamic>>> buildFutureView(
      DenemeViewModel denemeProv) {
    return FutureBuilder(
      future: initData(),
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style: TextStyle(
                    fontSize:
                        context.dynamicW(0.01) * context.dynamicH(0.005))),
          );
        } else {
          convertToRow(snapshot.data!);
          insertRowData(denemelerData);

          /*     print("coldata len  ${columnData.length}");
        print("rowdata  len  ${rowData.length}"); */

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
                        child: buildDataTable(denemeProv),
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

  Widget buildDataTable(DenemeViewModel denemelerProv) {
    return Center(
        child: Column(children: <Widget>[
      SizedBox(
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          defaultColumnWidth: FixedColumnWidth(context.dynamicW(0.16)),
          border: TableBorder.all(
              color: Colors.black, style: BorderStyle.solid, width: 1),
          children: [
            getColumns(),
            ...getRows(denemelerProv),
          ],
        ),
      ),
    ]));
  }

  TableRow getColumns() {
    return TableRow(
      children: List.generate(
        columnData.length,
        (index) => getColumnCell(index),
      ),
    );
  }

  TableCell getColumnCell(int index) {
    String pngx = initPng(_lessonName);
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(0.4),
        child: Column(
          children: [
            index == 0
                ? Container(
                    height: 100,
                    width: 200,
                    decoration: const BoxDecoration(
                      color: Color(0xff1c0f45),
                    ),
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
                : Container(
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
          ],
        ),
      ),
    );
  }

  Widget getRowCell(int i, dynamic cell, DenemeViewModel denemeProv) {
    return TableCell(
      child: Ink(
        color: i != 0 ? Colors.white : const Color(0xff060644),
        child: InkWell(
          onLongPress: () {
            Future.delayed(const Duration(milliseconds: 100), () {
              _showDialog(
                context,
                'UYARI',
                '${extractNumber(cell)}.Denemeyi silmek istediğinize emin misiniz?',
                denemeProv,
                cell,
              );
            });
          },
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: context.dynamicH(0.00714)),
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
      ),
    );
  }

  List<TableRow> getRows(DenemeViewModel denemeProv) {
    List<Map<String, dynamic>> rowXdata = List.from(rowData);

    return rowXdata.map((row) {
      return TableRow(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            style: BorderStyle.solid,
            width: 0.5,
          ),
        ),
        children: Utils.modelBuilder(row['row'], (i, cell) {
          return getRowCell(i, cell, denemeProv);
        }),
      );
    }).toList();
  }

  int? extractNumber(String text) {
    String aStr = text.replaceAll(RegExp(r'[^0-9]'), '');
    int? result = 1;
    if (aStr.isNotEmpty) {
      result = int.parse(aStr);
    }

    return result;
  }

  _showDialog(
    BuildContext context,
    String title,
    String content,
    DenemeViewModel denemeProv,
    dynamic itemDeneme,
  ) async {
    AlertView alert = AlertView(
      title: title,
      content: content,
      isAlert: false,
      noFunction: () => {
        _isAlertOpen = false,
        Navigator.of(context).pop(),
      },
      yesFunction: () async => {
        print("cell ${extractNumber(itemDeneme)}"),
        itemDeneme = extractNumber(itemDeneme),
        denemeProv.deleteItemById(_lessonTableName, itemDeneme, 'denemeId'),
        convertToRow(await initData()),
        _isAlertOpen = false,
        Navigator.of(context).pop(),
      },
    );

    if (_isAlertOpen == false) {
      _isAlertOpen = true;
      await showDialog(
          barrierDismissible: false,
          barrierColor: const Color(0x66000000),
          context: context,
          builder: (BuildContext context) {
            return alert;
          }).then((value) => _isAlertOpen = false);
    }
  }
}
