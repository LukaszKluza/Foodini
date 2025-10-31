import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/fetch_token_task_callback.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

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
  Directory? appDir;

  if (!kIsWeb) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    await Workmanager().registerPeriodicTask(
      'refreshAccessTokenTask',
      fetchTokenTask,
      frequency: Duration(minutes: 25),
      initialDelay: Duration(seconds: 0),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  } else {
    Timer.periodic(const Duration(minutes: 25), (timer) async {
      await fetchTokenTaskCallback();
    });
  }

  await fetchTokenTaskCallback();
  await UserStorage().loadUser();

  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    appDir = await getApplicationDocumentsDirectory();
  }

  runApp(
    ScreenUtilInit(
      designSize: Size(Constants.screenWidth, Constants.screenHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => Foodini(appDir),
    ),
  );
}
