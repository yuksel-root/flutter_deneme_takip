import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/shader_mask/gradient_widget.dart';
import 'package:flutter_deneme_takip/core/constants/app_data.dart';
import 'package:flutter_deneme_takip/core/constants/color_constants.dart';
import 'package:flutter_deneme_takip/core/notifier/bottom_navigation_notifier.dart';
import 'package:flutter_deneme_takip/core/notifier/tabbar_navigation_notifier.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/exam_table_tabbar.dart.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/exam_list_tabbar.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/lesson_tabbar_view.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/subjects_tabbar.view.dart';
import 'package:flutter_deneme_takip/view_model/exam_table_view_model.dart';
import 'package:flutter_deneme_takip/view_model/edit_exam_view_model.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';
import 'package:flutter_deneme_takip/view_model/subject_view_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class BottomTabbarView extends StatelessWidget {
  const BottomTabbarView({super.key});

  final List<Widget> currentScreen = const [
    ExamListTabbarView(),
    ExamTableTabbarView(),
    SubjectsTabbarView(),
    LessonTabbarView(),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomProv = Provider.of<BottomNavigationProvider>(context);
    final tabbarNavProv = Provider.of<TabbarNavigationProvider>(context);
    final examListProv = Provider.of<ExamTableViewModel>(context);
    final examTableProv = Provider.of<ExamTableViewModel>(context);
    final editProv = Provider.of<EditExamViewModel>(context);

    final lessonProv = Provider.of<LessonViewModel>(context);
    final subjectProv = Provider.of<SubjectViewModel>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          body: currentScreen[bottomProv.getCurrentIndex],
          bottomNavigationBar: Visibility(
            visible: editProv.getKeyboardVisibility == false,
            child: GradientWidget(
              blendModes: BlendMode.color,
              gradient: ColorConstants.bottomGradient,
              widget: Row(
                children: [
                  Expanded(
                    child: BottomNavigationBar(
                      currentIndex: bottomProv.getCurrentIndex,
                      onTap: (index) {
                        examTableProv.listContHeights.clear();
                        bottomProv.setCurrentIndex = index;
                        subjectProv.initSubjectData(1);
                        lessonProv.setOnEditText = false;

                        //        examTableProv.setLessonName = AppData
                        //          .lessonNameList[tabbarNavProv.getCurrentexamIndex];
                        //     examTableProv.initExamData(AppData
                        //          .lessonNameList[tabbarNavProv.getExamTableIndex]);

                        // lessonProv.initExamListData(AppData.lessonNameList[
                        //   tabbarNavProv.getLessonCurrentIndex]);

                        editProv.setFalseControllers =
                            editProv.getFalseCountsIntegers!.length;

                        editProv.setLoading = true;
                      },
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(
                            FontAwesomeIcons.house,
                          ),
                          label: "Denemeler",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            FontAwesomeIcons.house,
                          ),
                          label: "DenemeTablo",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            FontAwesomeIcons.house,
                          ),
                          label: "Konular",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            FontAwesomeIcons.house,
                          ),
                          label: "Dersler",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
