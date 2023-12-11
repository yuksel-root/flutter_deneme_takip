import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';

class LessonView extends StatefulWidget {
  final String? lessonName;
  const LessonView({Key? key, this.lessonName}) : super(key: key);

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView> {
  late String _lessonName;
  late Future<List<Map<String, dynamic>>> _listDeneme;

  @override
  void initState() {
    super.initState();
    _lessonName = widget.lessonName!;
    _listDeneme = initTable();
  }

  Future<List<Map<String, dynamic>>> initTable() async {
    String tableName =
        LessonList.tableNames[_lessonName] ?? DenemeTables.tarihTableName;
    return DenemeDbProvider.db.getDeneme(tableName);
  }

  @override
  Widget build(BuildContext context) {
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
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Konu: $subjectName',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      for (var item in group)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                Text('${item['denemeId']}.Deneme'),
                                const SizedBox(width: 8.0),
                                Text('Yanlış Sayısı: ${item['falseCount']}'),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text('Tarih: ${item['denemeDate']}'),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
