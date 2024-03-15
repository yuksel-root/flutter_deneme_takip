import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/text_field/update_subject_text_field.dart';
import 'package:flutter_deneme_takip/view_model/subject_view_model.dart';
import 'package:provider/provider.dart';

class UpdateSubjectForm extends StatefulWidget {
  const UpdateSubjectForm({super.key});

  @override
  State<UpdateSubjectForm> createState() => _UpdateSubjectFormState();
}

class _UpdateSubjectFormState extends State<UpdateSubjectForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final subjectProv = Provider.of<SubjectViewModel>(context, listen: false);
    subjectProv.setUpdateFormKey = _formKey;

    return Form(
      key: subjectProv.getUpdateKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: SingleChildScrollView(
          child: UpdateSubjectTextField(
              key: Key("${subjectProv.getUpdateIndex}"))),
    );
  }
}
