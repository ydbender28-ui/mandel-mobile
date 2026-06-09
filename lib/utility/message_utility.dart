import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';

mixin MessageUtility {
  ///////
  void showSuccessMessage(
      {required String message,
      required BuildContext context,
      Duration duration = const Duration(seconds: 5)}) {
    ScaffoldMessengerState state = ScaffoldMessenger.of(context);
    final snackBar = SnackBar(
      duration: duration,
      backgroundColor: CommonCustomColor.successColor,
      content: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(message),
      ),
      action: SnackBarAction(
        textColor: Colors.white,
        label: 'Dismiss',
        onPressed: () {
          state.hideCurrentSnackBar();
        },
      ),
    );

    state.showSnackBar(snackBar);
  }

  ///////
  void showErrorMessage(
      {required String message,
      required BuildContext context,
      Duration duration = const Duration(seconds: 5)}) {
    ScaffoldMessengerState state = ScaffoldMessenger.of(context);
    final snackBar = SnackBar(
      duration: duration,
      backgroundColor: CommonCustomColor.warningColor,
      content: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(message),
      ),
      action: SnackBarAction(
        textColor: Colors.white,
        label: 'Dismiss',
        onPressed: () {
          state.hideCurrentSnackBar();
        },
      ),
    );

    state.showSnackBar(snackBar);
  }

  ///////
  void showInProgressMessage(
      {required String message, required BuildContext context}) {
    ScaffoldMessengerState state = ScaffoldMessenger.of(context);
    final snackBar = SnackBar(
      backgroundColor: CommonCustomColor.pendingColor,
      content: Text(message),
      action: SnackBarAction(
          label: "Dismiss",
          textColor: Colors.white,
          onPressed: () {
            state.hideCurrentSnackBar();
          }),
    );
    state.showSnackBar(snackBar);
    // final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

    // final ScaffoldMessengerState? state = scaffoldKey.currentState;

    // final snackBar = SnackBar(
    //   backgroundColor: CommonCustomColor.pendingColor,
    //   content: Text(message),
    //   action: SnackBarAction(
    //       label: "Dismiss",
    //       textColor: Colors.white,
    //       onPressed: () {
    //         state?.hideCurrentSnackBar();
    //       }),
    // );

    // state?.showSnackBar(snackBar);
  }
}
