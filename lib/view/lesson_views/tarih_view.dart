import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';

class TarihView extends StatefulWidget {
  const TarihView({Key? key}) : super(key: key);

  @override
  State<TarihView> createState() => _TarihViewState();
}

class _TarihViewState extends State<TarihView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: LessonList.tarihKonular.length,
        itemBuilder: (BuildContext context, int index) {
          List<dynamic> tarihArr = LessonList.tarihKonular;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: tarihArr.length,
                itemBuilder: (BuildContext context, int idx) {
                  return Card(
                      child: ListTile(
                          title: Text(tarihArr[idx]),
                          subtitle: Text(
                            'Doğru: 5 - Yanlış: 10',
                          )));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
