import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/service/navigation_service.dart';
import 'package:mandel_mobile_app/service/telemetry_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/route_generator.dart';

@pragma('vm:entry-point')
void backgroundFetchTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    debugPrint("Background fetch timed out");
    BackgroundFetch.finish(taskId);
  } else {
    debugPrint("Background fetch event ");
    await TelemetryService().sendHeartbeatTelemetry();
    BackgroundFetch.finish(taskId);
  }
}

void main() {
  runApp(const MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchTask);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // const MyApp({super.key});
  bool _enabled = true;
  int _status = 0;
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mandel Distributions',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      theme: ThemeData(
          fontFamily: 'Nunito',
          scaffoldBackgroundColor: CommonCustomColor.defaultsScaffoldColor,
          appBarTheme:
              const AppBarTheme(color: CommonCustomColor.defaultsScaffoldColor),
          colorScheme: ColorScheme.fromSeed(
              seedColor: CommonCustomColor.mandelPrimaryColor),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0XFFEEEEEE),
            labelStyle: TextStyle(color: Color(0XFF555555), fontSize: 13.0),
            hintStyle: TextStyle(fontSize: 13.0),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0, color: Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0, color: Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0, color: Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0, color: Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(10))),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: CommonCustomColor
                  .mandelPrimaryColor, // background (button) color
              foregroundColor: Colors.white, // foreground (text) color
            ),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.white,
            modalBackgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          )),
      initialRoute: CommonConstants.baseUrl,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }

  Future<void> initPlatformState() async {
    int status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 30,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiredNetworkType: NetworkType.NONE,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false), (String taskId) async {
      debugPrint('Background fetch $taskId');

      await TelemetryService().sendHeartbeatTelemetry();

      BackgroundFetch.finish(taskId);
    }, (String taskid) async {
      debugPrint('Background fetch TIMED OUT');
      BackgroundFetch.finish(taskid);
    });
    setState(() {
      _status = status;
    });
    debugPrint('status, $status');
    if (!mounted) return;
  }
}
