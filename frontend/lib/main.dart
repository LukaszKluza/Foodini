import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'fetch_token_task_callback.dart';
import 'foodini.dart';

const fetchTokenTask = 'fetchTokenTask';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == fetchTokenTask) {
      await fetchTokenTaskCallback();
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    await Workmanager().registerPeriodicTask(
      "refreshAccessTokenTask",
      fetchTokenTask,
      frequency: Duration(minutes: 25),
      initialDelay: Duration(seconds: 0),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  } else {
    await fetchTokenTaskCallback();

    Timer.periodic(const Duration(minutes: 25), (timer) async {
      await fetchTokenTaskCallback();
    });
  }

  runApp(const Foodini());
}
