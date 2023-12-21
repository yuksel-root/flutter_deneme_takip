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

  @override
  void initState() {
    super.initState();
    _lessonName = widget.lessonName!;

    columnData = List.of(findList(_lessonName));
    rowData = List.generate(columnData.length,
        (index) => {'row': List.filled(columnData.length, 0)});
  }

  void processData(List<Map<String, dynamic>> data) {
    modifiedData.clear();

    Map<int, List<Map<String, dynamic>>> groupedData = {};

    for (var item in data) {
      final denemeId = item['denemeId'] as int;
      if (!groupedData.containsKey(denemeId)) {
        groupedData[denemeId] = [];
      }
      groupedData[denemeId]!.add(item);
    }
    print('groupedData');
    print(groupedData);
    print('groupedData');
    int denemeId = groupedData.keys.elementAt(1);
    List<Map<String, dynamic>> group = groupedData[denemeId]!; //still progress
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
  }

  initRowData(List<Map<String, dynamic>> modifiedData,
      List<Map<String, dynamic>> data) {
    print("rowDataModifyx");
    int i = 0;
    print(modifiedData.length);
    final arr = List.generate(columnData.length, (index) => 0);
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
      future: initData(), // Verilerinizi getiren asenkron işlem
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            // Veriler yüklenirken gösterilecek widget
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            // Hata durumunda gösterilecek widget
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          processData(snapshot.data!); // Veriler geldiğinde işleyin
          initRowData(modifiedData, snapshot.data!); // Satır verilerini işleyin

          // DataTable'ı oluşturun
          return Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FittedBox(
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
        margin: EdgeInsets.all(5),
        child: Table(
          defaultColumnWidth: FixedColumnWidth(35.0),
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
      decoration: BoxDecoration(
        border:
            Border.all(color: Colors.black, style: BorderStyle.solid, width: 1),
      ),
      children: Utils.modelBuilder(
        columnData,
        (i, column) {
          return InkWell(
              customBorder: Border.all(
                  color: Colors.black, style: BorderStyle.solid, width: 0.5),
              highlightColor: Colors.pinkAccent,
              hoverColor: Colors.purpleAccent,
              child: Ink(
                color: Color(0xff00b2ee),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    children: [
                      Text(
                        truncateString(column.toString()),
                        style: TextStyle(
                            fontSize: 15,
                            overflow: TextOverflow.clip,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {});
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
          children: Utils.modelBuilder(row['row'], (index, cell) {
            return Column(children: [
              Text(cell.toString()),
            ]);
          }),
        );
      }).toList();
}
