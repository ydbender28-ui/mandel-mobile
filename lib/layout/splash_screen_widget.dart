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

    // Skip 3-second delay — go straight to session check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(CommonConstants.configurationScreenUrl);
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
