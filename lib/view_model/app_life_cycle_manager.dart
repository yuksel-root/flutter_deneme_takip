// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';

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
    DenemeDbProvider.db.closeDatabase();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
        print('LifeCycleState = $state');
        break;
      case AppLifecycleState.inactive:
        DenemeDbProvider.db.closeDatabase();
        print('LifeCycleState = $state');
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        print('LifeCycleState = $state');

        break;

      default:
    }
  }
}
