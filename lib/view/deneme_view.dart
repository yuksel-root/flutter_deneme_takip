import 'package:flutter/material.dart';

import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';

import 'package:intl/intl.dart';

class DenemeView extends StatefulWidget {
  const DenemeView({Key? key}) : super(key: key);

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
    final Future<List<Map<String, dynamic>>> listDeneme =
        DenemeDbProvider.db.getDeneme();
    DateTime now = DateTime.now();
    String formattedDate =
        DateFormat('HH:mm:ss | d MMMM EEEE', 'tr_TR').format(now).toString();
    print(formattedDate);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: listDeneme,
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Veri getirilirken hata oluştu'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Gösterilecek veri yok'));
        } else {
          List<List<Map<String, dynamic>>> groupedData = [];
          List<Map<String, dynamic>> data = snapshot.data!;

          for (var i = 0; i < data.length; i += 5) {
            List<Map<String, dynamic>> group =
                data.sublist(i, i + 5 > data.length ? data.length : i + 5);
            groupedData.add(group);
          }

          return ListView.builder(
            itemCount: groupedData.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                elevation: 4.0,
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (var item in groupedData[index])
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deneme ID: ${item['denemeId']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8.0),
                            Text('Yanlış Sayısı: ${item['falseCount']}'),
                            const SizedBox(height: 8.0),
                            Text('Konu: ${item['subjectName']}'),
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
