// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/components/utils.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:provider/provider.dart';

class TotalDenemeView extends StatefulWidget {
  final String? lessonName;

  const TotalDenemeView({Key? key, this.lessonName}) : super(key: key);

  @override
  State<TotalDenemeView> createState() => _DenemeViewState();
}

class _DenemeViewState extends State<TotalDenemeView> {
  late String _lessonName;
  late int _groupSize;

  late List<dynamic> rowData;
  late List<dynamic> columnData;
  late List<Map<String, dynamic>> denemelerData;
  final List<List<int>> _listFalseCounts = [];

  @override
  void initState() {
    print('initTotal');
    super.initState();
    _lessonName = widget.lessonName ?? 'Tarih';
    _groupSize = 0;
    print("total $_groupSize");
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

  void insertRowData(
      List<Map<String, dynamic>> denemelerData, DenemeViewModel denemeProv) {
    rowData.clear();
    _listFalseCounts.clear();

    falseCountsByDenemeId(denemelerData).forEach((denemeId, falseCounts) {
      _listFalseCounts.add(falseCounts);
    });

    List<dynamic> sumList =
        List.from(sumByGroups(_listFalseCounts, _groupSize));
    List<dynamic> sumArr = List.generate(columnData.length, (index) => 0);
    List<dynamic> totalSum = List.of(sumAllLists(_listFalseCounts));

    for (int j = 0; j < sumList.length; j++) {
      if (j == 0) {
        sumArr[0] = "Deneme 1-$_groupSize";
      } else {
        if (_groupSize == 5) {
          sumArr[0] = "Deneme ${(j * 5) + 1}-${(j * 5) + 5}";
        } else {
          sumArr[0] =
              "Deneme ${(j * _groupSize)}-${(j * _groupSize) + _groupSize}";
        }
      }

      for (int k = 1; k < columnData.length; k++) {
        sumArr[k] = sumList[j][k];
      }
      rowData.add({'row': List.from(sumArr)});
    }

    if (compareLists(sumArr, totalSum) == false) {
      print("sumAr $sumArr totalSum $totalSum");
      totalSum[0] = "Toplam";
      rowData.add({'row': List.from(totalSum)});
    }

    // print("rowData");
    // print(rowData);
    // print("rowData");
  }

  bool compareLists(List<dynamic> list1, List<dynamic> list2) {
    if (list1.length != list2.length) {
      return false;
    }

    for (int i = 1; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }

    return true;
  }

  List<dynamic> sumByGroups(List<List<int>> inputList, int groupSize) {
    List<List<int>> resultList = [];

    for (int i = 0; i < inputList.length; i += groupSize) {
      List<int> sumList = List.filled(inputList[i].length, 0);

      for (int j = i; j < i + groupSize && j < inputList.length; j++) {
        for (int k = 0; k < inputList[j].length; k++) {
          sumList[k] += inputList[j][k];
        }
      }

      resultList.add(sumList);
    }

    return resultList;
  }

  List<dynamic> sumAllLists(List<List<int>> inputList) {
    if (inputList.isEmpty) return [];

    List<dynamic> sumList = List.filled(columnData.length, 0);

    for (int i = 0; i < inputList.length; i++) {
      for (int j = 0; j < inputList[i].length; j++) {
        if (j < sumList.length) {
          sumList[j] += inputList[i][j];
        } else {
          sumList.add(inputList[i][j]);
        }
      }
    }

    return sumList;
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
    _groupSize = denemeProv.getSelectedGroupSize!;
    return buildFutureView(denemeProv);
  }

  FutureBuilder<List<Map<String, dynamic>>> buildFutureView(
      DenemeViewModel denemeProv) {
    return buildTDenemeFutureView(denemeProv);
  }

  FutureBuilder<List<Map<String, dynamic>>> buildTDenemeFutureView(
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
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          convertToRow(snapshot.data!);
          insertRowData(denemelerData, denemeProv);

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
                        child: buildDataTable(),
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

  Widget buildDataTable() {
    return Center(
        child: Column(children: <Widget>[
      SizedBox(
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          defaultColumnWidth: FixedColumnWidth(context.dynamicW(0.20)),
          border: TableBorder.all(
              color: Colors.black, style: BorderStyle.solid, width: 1),
          children: [
            getColumns(),
            ...getRows(),
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
                    child: const Center(
                      child: Text(
                        "Deneme Sıra No",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
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

  Widget getRowCell(int i, dynamic cell) {
    return TableCell(
      child: Ink(
        color: i != 0 ? Colors.white : const Color(0xff060644),
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
                          ? const TextStyle(color: Colors.black)
                          : const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<TableRow> getRows() {
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
          return getRowCell(i, cell);
        }),
      );
    }).toList();
  }
}
