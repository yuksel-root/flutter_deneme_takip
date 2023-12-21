import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:provider/provider.dart';

class LessonView extends StatefulWidget {
  final String? lessonName;
  const LessonView({Key? key, this.lessonName}) : super(key: key);

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView> {
  late String _lessonName;
  late Future<List<Map<String, dynamic>>> _listDeneme;
  late String _lessonTableName;

  @override
  void initState() {
    super.initState();
    _lessonName = widget.lessonName ?? "Tarih";
    _listDeneme = initTable();
    _lessonTableName =
        LessonList.tableNames[_lessonName] ?? DenemeTables.tarihTableName;
    _listDeneme.then((List<Map<String, dynamic>> data) {
      // Listeyi döngü ile dönüştürme
      List<Map<String, dynamic>> dataList = data;
      dataList.forEach((Map<String, dynamic> item) {
        print(item);
      });
    });
  }

  Future<List<Map<String, dynamic>>> initTable() async {
    _lessonTableName =
        LessonList.tableNames[_lessonName] ?? DenemeTables.tarihTableName;
    return DenemeDbProvider.db.getDeneme(_lessonTableName);
  }

  @override
  Widget build(BuildContext context) {
    final denemeProv = Provider.of<DenemeViewModel>(context);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _listDeneme,
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Veri getirilirken hata oluştu'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Gösterilecek veri yok'));
        } else {
          List<Map<String, dynamic>> data = snapshot.data!;
          Map<String, List<Map<String, dynamic>>> groupedData = {};

          for (var item in data) {
            String subjectName = item['subjectName'];
            if (!groupedData.containsKey(subjectName)) {
              groupedData[subjectName] = [];
            }
            groupedData[subjectName]!.add(item);
          }

          return ListView.builder(
            itemCount: groupedData.length,
            itemBuilder: (BuildContext context, int index) {
              String subjectName = groupedData.keys.elementAt(index);
              List<Map<String, dynamic>> group = groupedData[subjectName]!;

              return Card(
                elevation: 4.0,
                margin: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      children: [
                        Text(
                          'Konu: $subjectName',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    for (var item in group)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('${item['denemeId']}.Deneme'),
                              const SizedBox(width: 8.0),
                              Text('Yanlış Sayısı: ${item['falseCount']}'),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    size: 25, color: Color(0xFFF31101)),
                                onPressed: () {
                                  setState(() {
                                    print("id");
                                    print(item['id']);
                                    print("id");
                                    denemeProv.deleteDeneme(
                                        _lessonTableName, item['id'], 'id');
                                    _listDeneme = initTable();
                                  });
                                },
                                style: IconButton.styleFrom(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Text('Tarih: ${item['denemeDate']}'),
                          const SizedBox(height: 16.0),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
