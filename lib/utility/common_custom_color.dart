import 'dart:ui';

import 'package:flutter/material.dart';

class CommonCustomColor {
  static const MaterialColor mandelPrimaryColor =
      MaterialColor(_mandelPrimaryColorValue, <int, Color>{
    50: Color(0xFFE3F2E9),
    100: Color(0xFFB9DEC8),
    200: Color(0xFF8AC8A3),
    300: Color(0xFF5BB27E),
    400: Color(0xFF37A262),
    500: Color(_mandelPrimaryColorValue),
    600: Color(0xFF12893F),
    700: Color(0xFF0E7E37),
    800: Color(0xFF0B742F),
    900: Color(0xFF066220),
  });
  static const int _mandelPrimaryColorValue = 0xFF149146;

  static const MaterialColor mSuccessColor =
      MaterialColor(_successColorValue, <int, Color>{
    50: Color(0xFFE3F7EB),
    100: Color(0xFFB8EBCC),
    200: Color(0xFF89DDAB),
    300: Color(0xFF5ACF89),
    400: Color(0xFF36C56F),
    500: Color(_successColorValue),
    600: Color(0xFF11B54F),
    700: Color(0xFF0EAC45),
    800: Color(0xFF0BA43C),
    900: Color(0xFF06962B),
  });
  static const int _successColorValue = 0xFF13BB56;

  static const MaterialColor mPendingColor =
      MaterialColor(_pendingColorValue, <int, Color>{
    50: Color(0xFFFFF3E2),
    100: Color(0xFFFFE2B6),
    200: Color(0xFFFFCE85),
    300: Color(0xFFFFBA54),
    400: Color(0xFFFFAC2F),
    500: Color(_pendingColorValue),
    600: Color(0xFFFF9509),
    700: Color(0xFFFF8B07),
    800: Color(0xFFFF8105),
    900: Color(0xFFFF6F03),
  });
  static const int _pendingColorValue = 0xFFFF9D0A;

  static const MaterialColor mDraftColor =
      MaterialColor(_draftColorValue, <int, Color>{
    50: Color(0xFFF7F7F7),
    100: Color(0xFFECECEC),
    200: Color(0xFFE0E0E0),
    300: Color(0xFFD3D3D3),
    400: Color(0xFFC9C9C9),
    500: Color(_draftColorValue),
    600: Color(0xFFBABABA),
    700: Color(0xFFB2B2B2),
    800: Color(0xFFAAAAAA),
    900: Color(0xFF9C9C9C),
  });
  static const int _draftColorValue = 0xFFC0C0C0;

  static const Color defaultsScaffoldColor = Color(0xFFFFFFFF);
  static const Color defaultTextColor = Color(0xFF2B2B2B);
  static const Color filterButtonColor = Color(0xFFDDE2EB);
  static const Color fieldColor = Color(0xFFEEEEEE);
  static const Color menuItemColor = Color(0xFF6C6C6C);
  static const Color warningColor = Color(0xFFDD4747);
  static const Color imageCardColor = Color(0xFFFFFFFF);
  static const Color pendingColor = Color(0xFFFF9D0A);
  static const Color dealColor = Color(0xFFFEF4E5);
  static const Color successColor = Color(0xFF13BB56);
  static const Color draftColor = Color(0xFFC0C0C0);
  static const Color recivedColor = Color(0xFF03bafc);
}
