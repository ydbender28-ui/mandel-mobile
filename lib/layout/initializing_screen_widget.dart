import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mandel_mobile_app/utility/auth_support_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';

class InitializingWaitScreenWidget extends StatefulWidget {
  const InitializingWaitScreenWidget({super.key});

  @override
  State<InitializingWaitScreenWidget> createState() =>
      _InitializingWaitScreenWidgetState();
}

class _InitializingWaitScreenWidgetState
    extends State<InitializingWaitScreenWidget> with AuthSupportUtility {
  final _streamController = StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _streamController.sink.add('Loading...');
      await _checkSession();
    });
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Future<void> _checkSession() async {
    _streamController.sink.add('Checking session...');
    final navigator = Navigator.of(context);
    bool isSignedIn = await checkSessionIsExist();
    if (isSignedIn) {
      navigator.pushNamed(CommonConstants.mainScreenUrl);
    } else {
      navigator.pushNamed(CommonConstants.loginScreenUrl);
    }
    _streamController.sink.add('Done!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Stack(
          children: [
            const Positioned.fill(
                child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 50,
                height: 50,
                child: LoadingIndicator(
                    indicatorType: Indicator.lineScale,
                    colors: [CommonCustomColor.mandelPrimaryColor],
                    strokeWidth: 1,
                    backgroundColor: Colors.transparent,
                    pathBackgroundColor: Colors.transparent),
              ),
            )),
            Positioned.fill(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: StreamBuilder(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) return Text('${snapshot.data}');
                  return const SizedBox();
                },
              ),
            ))
          ],
        ),
      ),
    );
  }
}
