import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/service/navigation_service.dart';
import 'package:mandel_mobile_app/service/telemetry_service.dart';
import 'package:mandel_mobile_app/utility/cart_state.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CartState.load();
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
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child!,
      ),
      theme: ThemeData(
          fontFamily: 'Nunito',
          scaffoldBackgroundColor: const Color(0xFFEEF0FA),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4F46E5),
            primary: const Color(0xFF4F46E5),
            secondary: const Color(0xFF0EA5E9),
            surface: Colors.white,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0C0F1E),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            labelStyle: const TextStyle(color: Color(0xFF9AA3C2), fontSize: 13),
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9AA3C2)),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 1, color: Color(0xFFDDE0F0)),
                borderRadius: BorderRadius.circular(12)),
            disabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 1.5, color: Color(0xFF4F46E5)),
                borderRadius: BorderRadius.circular(12)),
            errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 1, color: Color(0xFFEC4899)),
                borderRadius: BorderRadius.circular(12)),
            focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 1.5, color: Color(0xFFEC4899)),
                borderRadius: BorderRadius.circular(12)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.white,
            modalBackgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          )),
      initialRoute: CommonConstants.configurationScreenUrl,
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
