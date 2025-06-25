import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/config/constants.dart';
import 'package:workmanager/workmanager.dart';

import 'fetch_token_task_callback.dart';
import 'foodini.dart';

const fetchTokenTask = 'fetchTokenTask';

@pragma('vm:entry-point')
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
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    await fetchTokenTaskCallback();

    await Workmanager().registerPeriodicTask(
      'refreshAccessTokenTask',
      fetchTokenTask,
      frequency: Duration(minutes: 25),
      initialDelay: Duration(seconds: 0),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  } else {
    await fetchTokenTaskCallback();

    Timer.periodic(const Duration(minutes: 25), (timer) async {
      await fetchTokenTaskCallback();
    });
  }

  runApp(
    ScreenUtilInit(
      designSize: Size(Constants.screenWidth, Constants.screenHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const Foodini(),
    ),
  );
}
