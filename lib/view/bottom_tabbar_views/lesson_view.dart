// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_deneme_takip/components/form/update_lesson_form.dart';
import 'package:flutter_deneme_takip/components/indicator_alert/loading_indicator_alert.dart';
import 'package:flutter_deneme_takip/components/text_field/insert_lesson_text_field.dart';
import 'package:flutter_deneme_takip/core/local_database/exam_db_provider.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';

class LessonView extends StatelessWidget {
  const LessonView({super.key});

  @override
  Widget build(BuildContext context) {
    final lessonProv = Provider.of<LessonViewModel>(context);

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);

    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Card(
                child: ListTile(
              title: const InsertLessonTextField(),
              trailing: Wrap(
                spacing: -5,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.check,
                      color: Colors.greenAccent,
                    ),
                    onPressed: () async {
                      await ExamDbProvider.db
                          .insertLesson(lessonProv.getLessonName!);

                      Future.delayed(Duration.zero, () {
                        lessonProv.getInsertController.clear();
                      });
                      lessonProv.initLessonData();
                      lessonProv.getInsertKey.currentState!.reset();
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      lessonProv.getInsertController.clear();
                    },
                  ),
                ],
              ),
            )),
            Expanded(
              child: FutureBuilder(
                future: Future.delayed(Duration.zero, () {
                  lessonProv.initLessonData();
                }),
                builder: (context, snapshot) {
                  if (context.read<LessonViewModel>().state ==
                      LessonState.loading) {
                    return const LoadingAlert(title: "Yükleniyor");
                  } else if (lessonProv.getLessonData[0].lessonName == null) {
                    return const SizedBox();
                  } else {
                    return ReorderableListView.builder(
                      itemCount: lessonProv.getLessonData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return lessonProv.getLessonData[index].lessonName !=
                                null
                            ? buildItemCard(
                                index, oddItemColor, evenItemColor, lessonProv)
                            : Card(
                                key: Key('$index'),
                              );
                      },
                      onReorder: (int oldIndex, int newIndex) {
                        lessonProv.updateItems(oldIndex, newIndex);
                        for (var e in lessonProv.getLessonData) {
                          print(
                              'Lesson Name: ${e.lessonName}, Lesson Index: ${e.lessonIndex}');
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ));
  }

  InkWell buildItemCard(int index, Color oddItemColor, Color evenItemColor,
      LessonViewModel lessonProv) {
    lessonProv.setUpdateIndex(index);

    return InkWell(
      key: Key('$index'),
      onDoubleTap: () async {
        lessonProv.setClickIndex(index);

        lessonProv.setOnEditText = true;
        lessonProv.setUpdateController(
            index: lessonProv.getClickIndex,
            initString:
                lessonProv.getLessonData[lessonProv.getClickIndex].lessonName!);
      },
      child: Card(
        child: ListTile(
            tileColor: index.isOdd ? oddItemColor : evenItemColor,
            title: lessonProv.getOnEditText && index == lessonProv.getClickIndex
                ? UpdateLessonForm(key: Key('$index'))
                : Text(lessonProv.getLessonData[index].lessonName!),
            trailing: Wrap(
              spacing: 10,
              children: [
                lessonProv.getOnEditText && index == lessonProv.getClickIndex
                    ? InkWell(
                        onTap: () {
                          ExamDbProvider.db.updateLesson(
                            lessonId: lessonProv
                                .getLessonData[lessonProv.getClickIndex]
                                .lessonId!,
                            lessonName: lessonProv
                                .getUpdateController[lessonProv.getClickIndex]
                                .text,
                            lessonIndex: index,
                          );
                          lessonProv.setOnEditText = false;
                        },
                        child: const Icon(
                          Icons.check,
                          color: Colors.greenAccent,
                        ),
                      )
                    : const SizedBox(),
                InkWell(
                  onTap: () async {
                    lessonProv.setClickIndex(index);

                    lessonProv.setOnEditText = true;
                    lessonProv.setUpdateController(
                        index: lessonProv.getClickIndex,
                        initString: lessonProv
                            .getLessonData[lessonProv.getClickIndex]
                            .lessonName!);
                  },
                  child: const Icon(
                    Icons.edit,
                    color: Colors.orangeAccent,
                  ),
                ),
                InkWell(
                  onTap: () {
                    lessonProv.removeLesson(
                        lessonProv.getLessonData[index].lessonId!);
                    lessonProv.initLessonData();
                    lessonProv.setOnEditText = false;
                  },
                  child: const Icon(
                    Icons.clear,
                    color: Colors.redAccent,
                  ),
                ),
                const Icon(Icons.drag_handle),
              ],
            )),
      ),
    );
  }
}
