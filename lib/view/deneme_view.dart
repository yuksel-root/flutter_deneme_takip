import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/components/utils.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';

class DenemeView extends StatefulWidget {
  final String? lessonName;

  const DenemeView({Key? key, this.lessonName}) : super(key: key);

  @override
  State<DenemeView> createState() => _DenemeViewState();
}

class _DenemeViewState extends State<DenemeView> {
  late String _lessonName;

  late List<dynamic> rowData;
  late List<dynamic> columnData;
  Map<int, List<Map<String, dynamic>>> idToRowMap = {};
  List<Map<String, dynamic>> modifiedData = [];
  late int k;
  @override
  void initState() {
    print('init');
    super.initState();

    _lessonName = widget.lessonName!;

    columnData = List.of(findList(_lessonName));
    rowData = List.generate(columnData.length,
        (index) => {'row': List.filled(columnData.length, 0)});
    k = -1;
  }

  void processData(List<Map<String, dynamic>> data) {
/*     Map<int, List<Map<String, dynamic>>> groupedData = {};
    print(data);
    for (var item in data) {
      final denemeId = item['denemeId'] as int;
      if (!groupedData.containsKey(denemeId)) {
        groupedData[denemeId] = [];
      }
      groupedData[denemeId]!.add(item);
    }

    int denemeId = groupedData.keys.elementAt(1);
    List<Map<String, dynamic>> group = groupedData[denemeId]!; //still progress */

    for (var item in data) {
      int id = item['id'];
      if (idToRowMap[id] == null) {
        idToRowMap[id] = [];
      }
      idToRowMap[id]!.add(item);
    }

    for (var entry in idToRowMap.entries) {
      Map<String, dynamic> rowItem = {"row": entry.value};
      modifiedData.add(rowItem);
    }
    print('modifiedData');
    print(modifiedData);
    print('modifiedData');
  }

  initRowData(List<Map<String, dynamic>> modifiedData) {
    print("rowDataModifyx");

    int i = 1;
    print(modifiedData.length);
    List<dynamic> arr = List.generate(columnData.length, (index) => 0);

    modifiedData.expand((item) {
      return item["row"];
    }).map((item) {
      if (i <= 9) {
        // print(item['falseCount']);
        arr[i] = (item['falseCount']);
        rowData[i] = {'row': arr};
        i++;
      }
    }).toList();
    print(rowData);
    rowData.map(
      (row) {
        print("a");
        print(row);
        print("a");
      },
    );
    print("rowDataModify");
  }

  List<String> findList(String lessonName) {
    return LessonList.lessonListMap[lessonName] ?? [];
  }

  Future<List<Map<String, dynamic>>> initData() async {
    String tableName =
        LessonList.tableNames[_lessonName] ?? DenemeTables.tarihTableName;

    // DenemeViewModel().getAllData(tableName);

    return await DenemeDbProvider.db.getDeneme(tableName);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initData(),
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          processData(snapshot.data!);
          initRowData(modifiedData);

          return Scaffold(
            body: Container(
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
      Container(
        child: Table(
          defaultColumnWidth: FixedColumnWidth(55.0),
          border: TableBorder.all(
              color: Colors.black, style: BorderStyle.solid, width: 1),
          children: [getColumns(), ...getRows()],
        ),
      ),
    ]));
  }

  String truncateString(String input, {int maxWords = 2}) {
    List<String> words = input.split(' ');

    if (words.isEmpty) {
      return ''; // Boş string durumu
    }

    String firstWord = words.first;
    String lastWord = words.last;

    if (firstWord == lastWord) {
      return '$firstWord';
    }

    return '$firstWord $lastWord';
  }

  TableRow getColumns() {
    return TableRow(
      decoration: BoxDecoration(),
      children: Utils.modelBuilder(
        columnData,
        (i, column) {
          return Padding(
            padding: const EdgeInsets.all(0.4),
            child: Column(
              children: [
                Container(
                    height: 100,
                    width: 200,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/img/table_columns/hs/$i.png'),
                      fit: BoxFit.fill,
                      repeat: ImageRepeat.noRepeat,
                    ))),
              ],
            ),
          );
        },
      ),
    );
  }

  List<TableRow> getRows() => rowData.map((row) {
        return TableRow(
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.black, style: BorderStyle.solid, width: 0.5),
          ),
          children: Utils.modelBuilder(row['row'], (i, cell) {
            k >= 99 ? k = -1 : k;
            k++;
            return Center(
              child: Column(children: [
                i == 0
                    ? Center(
                        child: Container(
                          color: Color(0xff060644),
                          child: Text(
                            k == 0
                                ? 'Deneme 1-5'
                                : 'Deneme ${((k + 5) + 1) - 10}-${(((k + 5) + 1) + 5) - 10}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                backgroundColor: Color(0xff060644)),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          cell.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
              ]),
            );
          }),
        );
      }).toList();
}
