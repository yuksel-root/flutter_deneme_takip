import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/faded_insert_form.dart';
import 'package:flutter_deneme_takip/components/insert_widgets/insert_deneme_text_field.dart';

class CustomShimmerLoading extends StatefulWidget {
  const CustomShimmerLoading({Key? key}) : super(key: key);

  @override
  _CustomShimmerLoadingState createState() => _CustomShimmerLoadingState();
}

class _CustomShimmerLoadingState extends State<CustomShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Form(
      autovalidateMode: AutovalidateMode.disabled,
      child: FadedForm(),
    );
  }
}
