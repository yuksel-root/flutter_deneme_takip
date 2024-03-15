// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:flutter_deneme_takip/view_model/edit_exam_view_model.dart';

import 'package:flutter_deneme_takip/view_model/subject_view_model.dart';
import 'package:provider/provider.dart';

class UpdateSubjectTextField extends StatefulWidget {
  const UpdateSubjectTextField({
    super.key,
  });

  @override
  State<UpdateSubjectTextField> createState() => _UpdateSubjectTextFieldState();
}

class _UpdateSubjectTextFieldState extends State<UpdateSubjectTextField> {
  late FocusNode _focusNode;

  int i = 0;
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
    final SubjectViewModel subjectProv =
        Provider.of<SubjectViewModel>(context, listen: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextFormField(
                controller:
                    subjectProv.getUpdateController[subjectProv.getUpdateIndex],
                focusNode: _focusNode,
                canRequestFocus: true,
                autofocus: true,
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
                  context.read<EditExamViewModel>().setKeyboardVisibility =
                      false;
                  FocusScope.of(context).unfocus();
                },
                onEditingComplete: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Future.delayed(const Duration(milliseconds: 2), () {
                      if (WidgetsBinding.instance.platformDispatcher.views.last
                              .viewInsets.bottom ==
                          0) {
                        context
                            .read<EditExamViewModel>()
                            .setKeyboardVisibility = false;
                      } else {
                        context
                            .read<EditExamViewModel>()
                            .setKeyboardVisibility = true;
                      }
                    });
                  });
                  subjectProv.setOnEditText = false;
                  subjectProv.getUpdateKey.currentState!.reset();
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
                    subjectProv.setSubjectName = value;
                  } catch (e) {
                    print(e);
                  }
                },
                decoration: const InputDecoration(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
