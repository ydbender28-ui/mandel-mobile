import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mandel_mobile_app/db/db_helper.dart';
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
  ////
  final _streamController = StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ///
      bool amplifyConfig = await _configureAmplify();
      if (amplifyConfig) {
        _configureDB();
        _checkForSessionIsExpired();
      }
    });
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Future<bool> _configureAmplify() async {
    ////
    _streamController.sink.add('Loading configurations...');

    ///
    String amplifyConfig = await DefaultAssetBundle.of(context)
        .loadString("assets/json/amplify_config.json");

    ///
    _streamController.sink.add('Amplify configuring...');
    try {
      final auth = AmplifyAuthCognito();
      await Amplify.addPlugin(auth);
      await Amplify.configure(amplifyConfig);
      _streamController.sink.add('Amplify configured!');
      return true;
    } on Exception catch (e) {
      _streamController.sink.add('An error occurred configuring Amplify\n $e');
      return false;
    }
  }

  void _configureDB() async {
    _streamController.sink.add('Initialize storage...');
    try {
      await DBHelper.init().database;
    } catch (e) {
      _streamController.sink.add('An error occurred initialize storage\n $e');
    }

    _streamController.sink.add('Storage initialized!');
  }

  _checkForSessionIsExpired() async {
    ////
    _streamController.sink.add('Check for session...');
    ////
    final navigator = Navigator.of(context);
    bool isUserSignedIn = await checkSessionIsExist();
    if (isUserSignedIn) {
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
                  if (snapshot.hasData) {
                    return Text('${snapshot.data}');
                  }
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
