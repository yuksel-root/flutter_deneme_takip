import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_deneme_takip/components/text_field/update_lesson_text_field.dart';
import 'package:flutter_deneme_takip/view_model/lesson_view_model.dart';
import 'package:provider/provider.dart';

class UpdateLessonForm extends StatefulWidget {
  const UpdateLessonForm({super.key});

  @override
  State<UpdateLessonForm> createState() => _InsertExamFormState();
}

class _InsertExamFormState extends State<UpdateLessonForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final lessonProv = Provider.of<LessonViewModel>(context, listen: false);
    Provider.of<LessonViewModel>(context, listen: false).setUpdateFormKey =
        _formKey;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: UpdateLessonTextField(key: Key("${lessonProv.getUpdateIndex}")),
    );
  }
}
