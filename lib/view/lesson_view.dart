import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class LessonView extends StatelessWidget {
  const LessonView({super.key});
  static const Color titleColor1 = Color.fromRGBO(28, 15, 69, 1);
  static const Color subTitleColor1 = Color.fromARGB(220, 92, 0, 92);
  static const Color contentColor1 = Color.fromARGB(255, 122, 0, 0);

  @override
  Widget build(BuildContext context) {
    final lessonProv = Provider.of<LessonViewModel>(context);
    final lessonData = context.read<LessonViewModel>().listDeneme;

    Map<String, List<Map<String, dynamic>>> groupedData =
        lessonProv.groupBySubjects(lessonData!);
    return futureListSubjectName(context, lessonProv, lessonData, groupedData);
  }

  FutureBuilder futureListSubjectName(BuildContext context,
      LessonViewModel lessonProv, lessonData, groupedData) {
    return FutureBuilder(
      future: Future.delayed(Duration.zero, () => lessonData),
      builder: (context, _) {
        if (context.watch<LessonViewModel>().state == LessonState.loading) {
          return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: listSubjects(context, groupedData, lessonProv));
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

          Map<String, List<Map<String, dynamic>>> groupedData =
              lessonProv.groupBySubjects(data);

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

          List<int> falseCounts = lessonProv.groupBySumFalseCounts(group);
          Map<String, int> totalFalseM = lessonProv.sumSubjectFalseCount(group);

          return expansionTileSubjectDetail(context, subjectName, totalFalseM,
              falseCounts, group, lessonProv);
        });
  }

  ExpansionTile expansionTileSubjectDetail(
      BuildContext context,
      String subjectName,
      Map<String, int> totalSubjectFalse,
      List<int> denemeFalseCounts,
      List<Map<String, dynamic>> group,
      LessonViewModel lessonProv) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.all(5),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Konu: $subjectName  ',
            style: TextStyle(
                color: titleColor1,
                fontSize: context.dynamicW(0.01) * context.dynamicH(0.0052),
                fontWeight: FontWeight.bold),
            maxLines: 1,
          ),
          Text(
            'Toplam Yanlış = ${totalSubjectFalse[subjectName]}',
            style: TextStyle(
                color: contentColor1,
                fontSize: context.dynamicW(0.01) * context.dynamicH(0.0052),
                fontWeight: FontWeight.bold),
            maxLines: 3,
          ),
        ],
      ),
      children: [
        for (var i = 0; i < denemeFalseCounts.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
            child: Row(
              children: [
                Text(
                    i == 0
                        ? ('Deneme 1-5 :  ')
                        : 'Deneme: ${((i * 5) + 1)}- ${((i * 5)) + 5}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          context.dynamicW(0.01) * context.dynamicH(0.0048),
                      color: const Color.fromARGB(255, 0, 0, 0),
                    )),
                Text(
                  i == 0
                      ? ('Toplam Yanlış => ${denemeFalseCounts[i]}')
                      : 'Toplam Yanlış => ${denemeFalseCounts[i]}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: context.dynamicW(0.01) * context.dynamicH(0.0048),
                    color: const Color.fromARGB(255, 161, 0, 0),
                  ),
                ),
              ],
            ),
          ),
        ExpansionTile(
          title: Text(
            "Denemeler",
            style: TextStyle(
              color: subTitleColor1,
              fontWeight: FontWeight.bold,
              fontSize: context.dynamicW(0.01) * context.dynamicH(0.0055),
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

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        '${item['denemeId']}.Deneme :  ',
                        style: TextStyle(
                            color: const Color(0xff1c0f45),
                            fontWeight: FontWeight.bold,
                            fontSize: context.dynamicW(0.01) *
                                context.dynamicH(0.0046)),
                      ),
                      Text(
                        'Yanlış Sayısı = ${item['falseCount']}',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff6f0000),
                            fontSize: context.dynamicW(0.01) *
                                context.dynamicH(0.0046)),
                      ),
                    ],
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
              Row(
                children: [
                  Text(
                    'Tarih: ${item['denemeDate']}',
                    style: TextStyle(
                      color: Color.fromARGB(255, 87, 27, 0),
                      fontWeight: FontWeight.bold,
                      fontSize:
                          context.dynamicW(0.01) * context.dynamicH(0.0044),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        );
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
