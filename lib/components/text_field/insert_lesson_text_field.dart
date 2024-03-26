// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view_model/edit_exam_view_model.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';

import 'package:provider/provider.dart';

class InsertLessonTextField extends StatefulWidget {
  const InsertLessonTextField({super.key});

  @override
  State<InsertLessonTextField> createState() => _InsertLessonTextFieldState();
}

class _InsertLessonTextFieldState extends State<InsertLessonTextField> {
  late FocusNode _focusNode;
  final GlobalKey<FormState> formKey0 = GlobalKey<FormState>();
  @override
  void initState() {
    _focusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EditExamViewModel editProv =
        Provider.of<EditExamViewModel>(context, listen: true);
    final LessonViewModel lessonProv =
        Provider.of<LessonViewModel>(context, listen: true);

    Provider.of<LessonViewModel>(context, listen: false).setInsertKey =
        formKey0;

    return Form(
      key: lessonProv.getInsertKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: TextFormField(
        controller: lessonProv.getInsertController,
        focusNode: _focusNode,
        canRequestFocus: true,
        autofocus: false,
        keyboardType: TextInputType.text,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onTap: () {
          var focusNode = _focusNode;
          void onFocusChange() {
            if (focusNode.hasFocus) {
              editProv.setKeyboardVisibility = true;
            } else {
              editProv.setKeyboardVisibility = false;
              focusNode.removeListener(onFocusChange);
            }
          }

          focusNode.addListener(onFocusChange);
        },
        onTapOutside: (event) {
          context.read<EditExamViewModel>().setKeyboardVisibility = false;
          FocusScope.of(context).unfocus();
        },
        onEditingComplete: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 2), () {
              if (WidgetsBinding.instance.platformDispatcher.views.last
                      .viewInsets.bottom ==
                  0) {
                context.read<EditExamViewModel>().setKeyboardVisibility = false;
              } else {
                context.read<EditExamViewModel>().setKeyboardVisibility = true;
              }
            });
          });
        },
        style: TextStyle(
            color: Colors.white,
            fontSize: context.dynamicW(0.01) * context.dynamicH(0.004)),
        validator: (value) {
          try {
            if (value == null || value.isEmpty) {
              return 'Lütfen boş bırakmayın';
            }

            return null;
          } catch (e) {
            print(e);
          }
          return null;
        },
        onChanged: (value) {
          try {
            lessonProv.setLessonname = lessonProv.getInsertController.text;
          } catch (e) {
            print(e);
          }
        },
        decoration: const InputDecoration(
          hintText: "Ders Giriniz",
        ),
      ),
    );
  }
}
