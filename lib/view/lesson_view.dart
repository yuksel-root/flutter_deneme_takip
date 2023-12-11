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
  late String lessonName;
  late Future<List<Map<String, dynamic>>> listDeneme;

  @override
  void initState() {
    super.initState();
    lessonName = widget.lessonName!;
    listDeneme = initTable();
  }

  Future<List<Map<String, dynamic>>> initTable() async {
    String tableName =
        LessonList.tableNames[lessonName] ?? DenemeTables.tarihTableName;
    return DenemeDbProvider.db.getDeneme(tableName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: listDeneme,
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Veri bulunamadı.'));
          } else {
            List<Map<String, dynamic>> data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    title: Text(data[index]['subjectName'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('False Count: ${data[index]['falseCount'] ?? ''}'),
                        Text('Date: ${data[index]['denemeDate'] ?? ''}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
