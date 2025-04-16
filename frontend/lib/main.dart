import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'fetch_token_task_callback.dart';
import 'foofini.dart';

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
    // Android/iOS
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    await Workmanager().registerPeriodicTask(
      "refreshAccessTokenTask",
      fetchTokenTask,
      frequency: Duration(minutes: 25),
      initialDelay: Duration(minutes: 25),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  } else {
    // Web
    Timer.periodic(const Duration(seconds: 25), (timer) async {
      await fetchTokenTaskCallback();
    });
  }

  runApp(const Foodini());
}
