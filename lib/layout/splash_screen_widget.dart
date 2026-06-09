import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

class SplashScreenWidget extends StatefulWidget {
  const SplashScreenWidget({super.key});

  @override
  State<SplashScreenWidget> createState() => _SplashScreenWidgetState();
}

class _SplashScreenWidgetState extends State<SplashScreenWidget> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () async {
      Navigator.of(context).pushNamed(CommonConstants.configurationScreenUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/logo/mandel_logo_wide.png',
          width: 400,
          height: 150,
        ),
      ),
    );
  }
}
