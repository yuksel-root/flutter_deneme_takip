// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/local_database/exam_db_provider.dart';
import 'package:flutter_deneme_takip/view_model/edit_exam_view_model.dart';
import 'package:provider/provider.dart';

class AppLifeCycleManager extends StatefulWidget {
  final Widget child;
  const AppLifeCycleManager({super.key, required this.child});

  @override
  State<AppLifeCycleManager> createState() => _AppLifeCycleManagerState();
}

class _AppLifeCycleManagerState extends State<AppLifeCycleManager>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    ExamDbProvider.db.closeDatabase();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    final double bottomInset =
        WidgetsBinding.instance.platformDispatcher.views.last.viewInsets.bottom;

    if (bottomInset != 0.0) {
      context.read<EditExamViewModel>().setKeyboardVisibility = true;
    } else {
      context.read<EditExamViewModel>().setKeyboardVisibility = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
        print('LifeCycleState = $state');
        break;
      case AppLifecycleState.inactive:
        ExamDbProvider.db.closeDatabase();
        print('LifeCycleState = $state');
        break;
      case AppLifecycleState.paused:
        print('LifeCycleState = $state');
        break;
      case AppLifecycleState.resumed:
        print('LifeCycleState = $state');

        break;

      default:
    }
  }
}
