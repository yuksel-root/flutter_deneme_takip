import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';

class MathView extends StatefulWidget {
  const MathView({Key? key}) : super(key: key);

  @override
  State<MathView> createState() => _TarihViewState();
}

class _TarihViewState extends State<MathView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: LessonList.tarihKonular.length,
        itemBuilder: (BuildContext context, int index) {
          List<dynamic> mathArr = LessonList.matKonular;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mathArr.length,
                itemBuilder: (BuildContext context, int idx) {
                  return Card(
                      child: ListTile(
                          title: Text(mathArr[idx]),
                          subtitle: const Text(
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
