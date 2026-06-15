import 'dart:async';
import 'dart:js' as js;

Future<String?> scanBarcodeFromPhoto() {
  final completer = Completer<String?>();
  bool done = false;

  js.context.callMethod('scanBarcodeFromPhoto', [
    js.allowInterop((dynamic result) {
      if (!done) {
        done = true;
        completer.complete(result?.toString());
      }
    })
  ]);

  // Safety net: if cancel fires without a 'cancel' event (older iOS) the
  // completer would hang forever. Resolve as null after 90 s.
  Future.delayed(const Duration(seconds: 90), () {
    if (!done) {
      done = true;
      completer.complete(null);
    }
  });

  return completer.future;
}
