// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/form/update_subject_form.dart';
import 'package:flutter_deneme_takip/components/indicator_alert/loading_indicator_alert.dart';
import 'package:provider/provider.dart';
import 'package:flutter_deneme_takip/components/text_field/insert_subject_text_field.dart';
import 'package:flutter_deneme_takip/core/local_database/exam_db_provider.dart';
import 'package:flutter_deneme_takip/view_model/subject_view_model.dart';

class SubjectView extends StatelessWidget {
  const SubjectView({super.key});

  @override
  Widget build(BuildContext context) {
    final subjectProv = Provider.of<SubjectViewModel>(context);

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Card(
                child: ListTile(
              title: const InsertSubjectTextField(),
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
                      await ExamDbProvider.db.insertSubject(
                          subjectProv.getInsertController.text,
                          subjectProv.getLessonId!);

                      Future.delayed(Duration.zero, () {
                        subjectProv.getInsertController.clear();
                      });

                      subjectProv.initSubjectData(subjectProv.getLessonId);
                      subjectProv.setUpdateController();
                      subjectProv.getInsertKey.currentState!.reset();
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      subjectProv.getInsertController.clear();
                    },
                  ),
                ],
              ),
            )),
            Expanded(
              child: FutureBuilder(
                future: Future.delayed(Duration.zero, () {
                  subjectProv.initSubjectData(subjectProv.getLessonId);
                }),
                builder: (context, snapshot) {
                  if (context.read<SubjectViewModel>().state ==
                      SubjectState.loading) {
                    return const LoadingAlert(title: "Yükleniyor");
                  } else if (subjectProv.getLessonId == null) {
                    return const SizedBox();
                  } else {
                    return ReorderableListView.builder(
                      itemCount: subjectProv.getSubjectData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return subjectProv.getSubjectData[index].subjectName !=
                                null
                            ? buildItemCard(
                                index, oddItemColor, evenItemColor, subjectProv)
                            : Card(
                                key: Key('$index'),
                              );
                      },
                      onReorder: (int oldIndex, int newIndex) {
                        subjectProv.updateItems(oldIndex, newIndex);
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
      SubjectViewModel subjectProv) {
    subjectProv.setUpdateIndex(index);

    // print(
    //  "subId ${subjectProv.getSubjectData[index].subjectId} subName  ${subjectProv.getSubjectData[index].subjectName} ");
    return InkWell(
      key: Key('$index'),
      onDoubleTap: () async {
        subjectProv.setClickIndex(index);

        subjectProv.setOnEditText = true;
        subjectProv.setUpdateController(
            index: subjectProv.getClickIndex,
            initString: subjectProv
                .getSubjectData[subjectProv.getClickIndex].subjectName!);
      },
      child: Card(
        child: ListTile(
            tileColor: index.isOdd ? oddItemColor : evenItemColor,
            title: subjectProv.getOnEditText &&
                    (index == subjectProv.getClickIndex)
                ? (UpdateSubjectForm(key: Key('$index')))
                : Text(subjectProv.getSubjectData[index].subjectName!),
            trailing: Wrap(
              spacing: 10,
              children: [
                subjectProv.getOnEditText &&
                        (index == subjectProv.getClickIndex)
                    ? InkWell(
                        onTap: () {
                          ExamDbProvider.db.updateSubject(
                            subjectProv
                                .getSubjectData[subjectProv.getClickIndex]
                                .subjectId!,
                            subjectProv
                                .getUpdateController[subjectProv.getClickIndex]
                                .text,
                            1,
                          );
                          subjectProv.setOnEditText = false;
                        },
                        child: const Icon(
                          Icons.check,
                          color: Colors.greenAccent,
                        ),
                      )
                    : const SizedBox(),
                InkWell(
                  onTap: () async {
                    subjectProv.setClickIndex(index);
                    subjectProv.setOnEditText = true;
                    Future.delayed(Duration.zero, () {
                      subjectProv.setUpdateController(
                          index: subjectProv.getClickIndex,
                          initString: subjectProv
                              .getSubjectData[subjectProv.getClickIndex]
                              .subjectName!);
                    });
                  },
                  child: const Icon(
                    Icons.edit,
                    color: Colors.orangeAccent,
                  ),
                ),
                InkWell(
                  onTap: () {
                    subjectProv.removeSubject(
                        subjectProv.getSubjectData[index].subjectId!,
                        subjectProv.getLessonId!);
                    subjectProv.initSubjectData(subjectProv.getLessonId);
                    subjectProv.setOnEditText = false;
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
