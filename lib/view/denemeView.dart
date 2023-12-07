import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:intl/intl.dart';

class DenemeView extends StatefulWidget {
  DenemeView({Key? key}) : super(key: key);

  @override
  State<DenemeView> createState() => _DenemeViewState();
}

class _DenemeViewState extends State<DenemeView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate =
        DateFormat('HH:mm:ss | d MMMM EEEE', 'tr_TR').format(now).toString();
    print(formattedDate);
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: LessonList.denemeTarih.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: 4.0,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Deneme ${LessonList.denemeTarih[index]["denemeId"][0]} - ${LessonList.denemeTarih[index]["denemeId"].last}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8.0),
                Expanded(
                  flex: 50,
                  child: ListView.builder(
                    itemCount: LessonList.denemeTarih[index]["subjects"].length,
                    itemBuilder: (BuildContext context, int subIndex) {
                      return ListTile(
                        title: Text(
                          LessonList.denemeTarih[index]["subjects"][subIndex],
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'False Count: ${LessonList.denemeTarih[index]["falseCount"][subIndex]}',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                ' => $formattedDate',
                                style:
                                    TextStyle(fontSize: 15, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
