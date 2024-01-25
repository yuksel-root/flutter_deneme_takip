import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/text_field/insert_deneme_text_field.dart';
import 'package:flutter_deneme_takip/view_model/edit_deneme_view_model.dart';
import 'package:provider/provider.dart';

class InsertDenemeForm extends StatefulWidget {
  const InsertDenemeForm({super.key});

  @override
  State<InsertDenemeForm> createState() => _InsertDenemeFormState();
}

class _InsertDenemeFormState extends State<InsertDenemeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final EditDenemeViewModel editDenemeProv =
        Provider.of<EditDenemeViewModel>(context, listen: true);

    editDenemeProv.setFormKey = _formKey;
    editDenemeProv.setLoading = true;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: const SingleChildScrollView(
        child: InsertDenemeTextField(),
      ),
    );
  }
}
