import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';
import 'package:provider/provider.dart';

class LessonView extends StatelessWidget {
  const LessonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lessonProv = Provider.of<LessonViewModel>(context);
    final lessonData = context.read<LessonViewModel>().listDeneme;

    return futureListSubjectName(context, lessonProv, lessonData);
  }

  FutureBuilder futureListSubjectName(
      BuildContext context, LessonViewModel lessonProv, lessonData) {
    return FutureBuilder(
      future: Future.delayed(Duration.zero, () => lessonData),
      builder: (context, _) {
        if (context.watch<LessonViewModel>().state == LessonState.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (context.watch<LessonViewModel>().listDeneme!.isEmpty) {
          return Center(
              child: Text(
                  style: TextStyle(
                      color: const Color(0xff1c0f45),
                      fontSize:
                          context.dynamicW(0.01) * context.dynamicH(0.005)),
                  'Gösterilecek veri yok'));
        } else {
          List<Map<String, dynamic>> data = lessonData;
          Map<String, List<Map<String, dynamic>>> groupedData = {};

          for (var item in data) {
            String subjectName = item['subjectName'];
            if (!groupedData.containsKey(subjectName)) {
              groupedData[subjectName] = [];
            }
            groupedData[subjectName]!.add(item);
          }

          return listSubjects(context, groupedData, lessonProv);
        }
      },
    );
  }

  ListView listSubjects(
      BuildContext context,
      Map<String, List<Map<String, dynamic>>> groupedData,
      LessonViewModel lessonProv) {
    return ListView.builder(
      itemCount: groupedData.length,
      itemBuilder: (BuildContext context, int index) {
        String subjectName = groupedData.keys.elementAt(index);
        List<Map<String, dynamic>> group = groupedData[subjectName]!;

        Map<String, int> totalFalseM = {};

        for (var data in group) {
          String subName = data['subjectName'];
          int falseCount = data['falseCount'];

          if (!totalFalseM.containsKey(subName)) {
            totalFalseM[subName] = 0;
          }
          totalFalseM[subName] = totalFalseM[subName]! + falseCount;
        }
        group.removeWhere((item) => item['falseCount'] == 0);
        if (group.any((item) => item['falseCount'] != 0)) {
          group.sort((a, b) => a["denemeId"].compareTo(b["denemeId"]));
          List<int> falseCounts = [];
          int totalFalse = 0;

          for (int i = 0; i < group.length; i++) {
            totalFalse += group[i]['falseCount'] as int;

            if ((i + 1) % 5 == 0 || i == group.length - 1) {
              falseCounts.add(totalFalse);
              totalFalse = 0;
            }
          }

          return expansionTileSubjectDetail(context, subjectName, totalFalseM,
              falseCounts, group, lessonProv);
        } else {
          return const SizedBox();
        }
      },
    );
  }

  ExpansionTile expansionTileSubjectDetail(
      BuildContext context,
      String subjectName,
      Map<String, int> totalFalseM,
      List<int> falseCounts,
      List<Map<String, dynamic>> group,
      LessonViewModel lessonProv) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.all(5),
      title: Text(
        'Konu: $subjectName  Toplam Yanlış = ${totalFalseM[subjectName]}',
        style: TextStyle(
            fontSize: context.dynamicW(0.01) * context.dynamicH(0.0052),
            fontWeight: FontWeight.bold),
        maxLines: 2,
      ),
      children: [
        for (var i = 0; i < falseCounts.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
            child: Text(
              i == 0
                  ? ('Deneme 1-5  Toplam yanlış: ${falseCounts[i]}')
                  : 'Deneme ${((i * 5) + 1)}- ${((i * 5)) + 5}  Toplam Yanlış: ${falseCounts[i]}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: context.dynamicW(0.01) * context.dynamicH(0.004),
                color: const Color(0xff1c0f45),
              ),
            ),
          ),
        ExpansionTile(
          title: Text(
            "Denemeler",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: context.dynamicW(0.01) * context.dynamicH(0.0052),
            ),
          ),
          children: [
            listDenemeDetail(group, lessonProv),
          ],
        ),
      ],
    );
  }

  ListView listDenemeDetail(
      List<Map<String, dynamic>> group, LessonViewModel lessonProv) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: group.length,
      itemBuilder: (BuildContext context, int index) {
        var item = group[index];
        if (item['falseCount'] != 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Deneme${item['denemeId']} :  Yanlış Sayısı = ${item['falseCount']}',
                      style: TextStyle(
                          fontSize:
                              context.dynamicW(0.01) * context.dynamicH(0.005)),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 25,
                        color: Color.fromARGB(255, 54, 31, 129),
                      ),
                      onPressed: () {
                        Future.delayed(const Duration(milliseconds: 200), () {
                          dialogremoveClickedDeneme(context, item, lessonProv);
                        });
                      },
                      style: IconButton.styleFrom(),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Tarih: ${item['denemeDate']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: context.dynamicW(0.01) * context.dynamicH(0.004),
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  dialogremoveClickedDeneme(BuildContext context, Map<String, dynamic> item,
      LessonViewModel lessonProv) {
    lessonProv.removeAlert(
      context,
      'UYARI',
      '${item['denemeId']}. Denemeyi silmek istediğinize emin misiniz?',
      lessonProv,
      item['denemeId'],
    );
  }
}
