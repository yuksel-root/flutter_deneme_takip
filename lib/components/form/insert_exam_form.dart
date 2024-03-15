import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/text_field/insert_exam_text_field.dart';

import 'package:flutter_deneme_takip/view_model/edit_exam_view_model.dart';

import 'package:provider/provider.dart';

class InsertExamForm extends StatefulWidget {
  const InsertExamForm({super.key});

  @override
  State<InsertExamForm> createState() => _InsertExamFormState();
}

class _InsertExamFormState extends State<InsertExamForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final EditExamViewModel editexamProv =
        Provider.of<EditExamViewModel>(context, listen: true);

    editexamProv.setFormKey = _formKey;
    editexamProv.setLoading = true;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: const SingleChildScrollView(
        child: InsertExamTextField(),
      ),
    );
  }
}
