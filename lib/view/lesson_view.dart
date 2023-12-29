import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/alert_dialog.dart';
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
  bool _isAlertOpen = false;
  @override
  void initState() {
    super.initState();
    _lessonName = widget.lessonName ?? "Tarih";
    _listDeneme = initTable();
    _lessonTableName =
        LessonList.tableNames[_lessonName] ?? DenemeTables.historyTableName;
    // _listDeneme.then((List<Map<String, dynamic>> data) {
    /*    List<Map<String, dynamic>> dataList = data;
      for (var item in dataList) {
        print(item.toString());
      } */
    // });
  }

  Future<List<Map<String, dynamic>>> initTable() async {
    _lessonTableName =
        LessonList.tableNames[_lessonName] ?? DenemeTables.historyTableName;
    return DenemeDbProvider.db.getLessonDeneme(_lessonTableName);
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
          return const Center(
              child: Text(
                  style: TextStyle(color: Color(0xff1c0f45), fontSize: 15),
                  'Veri getirilirken hata oluştu'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text(
                  style: TextStyle(color: Color(0xff1c0f45), fontSize: 15),
                  'Gösterilecek veri yok'));
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
              //  print(group);

              Map<String, int> totalFalseM = {};

              for (var data in group) {
                String subName = data['subjectName'];
                int falseCount = data['falseCount'];

                if (!totalFalseM.containsKey(subName)) {
                  totalFalseM[subName] = 0;
                }
                totalFalseM[subName] = totalFalseM[subName]! + falseCount;
              }

              if (group.any((item) => item['falseCount'] != 0)) {
                group.sort((a, b) => a["denemeId"].compareTo(b["denemeId"]));
                List<int> totalFalseCounts = [];
                int totalFalse = 0;
                print(group);
                for (var i = 0; i < group.length; i++) {
                  totalFalse += group[i]['falseCount'] as int;
                  if ((i + 1) % 5 == 0 || i == group.length - 1) {
                    totalFalseCounts.add(totalFalse);
                    totalFalse = 0;
                  }
                }

                return ExpansionTile(
                  title: Text(
                    'Konu: $subjectName  Toplam Yanlış = ${totalFalseM[subjectName]}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 2,
                  ),
                  children: [
                    for (var i = 0; i < totalFalseCounts.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 3),
                        child: Text(
                          i == 0
                              ? ('Deneme 1-5  Toplam yanlış: ${totalFalseCounts[i]}')
                              : 'Deneme ${((i * 5) + 1)}- ${((i * 5)) + 5}  Toplam Yanlış: ${totalFalseCounts[i]}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1c0f45),
                          ),
                        ),
                      ),
                    ExpansionTile(
                      title: const Text(
                        "Denemeler",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: group.length,
                          itemBuilder: (BuildContext context, int index) {
                            var item = group[index];
                            if (item['falseCount'] != 0) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 1, horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                            'Deneme${item['denemeId']} :  Yanlış Sayısı: ${item['falseCount']}'),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 25,
                                            color: Color.fromARGB(
                                                255, 54, 31, 129),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 200), () {
                                                _showDialog(
                                                  context,
                                                  'UYARI',
                                                  '${item['denemeId']}. Denemeyi silmek istediğinize emin misiniz?',
                                                  denemeProv,
                                                  item['denemeId'],
                                                );
                                              });
                                            });
                                          },
                                          style: IconButton.styleFrom(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text('Tarih: ${item['denemeDate']}'),
                                    const SizedBox(height: 8.0),
                                  ],
                                ),
                              );
                            } else {
                              return const SizedBox(); // 'falseCount' değeri 0 olan kartları gösterme
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return const SizedBox(); // 'falseCount' değeri 0 olan kartları gösterme
              }
            },
          );
        }
      },
    );
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
      yesFunction: () => {
        denemeProv.deleteItemById(_lessonTableName, itemDeneme, 'denemeId'),
        _listDeneme = initTable(),
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
