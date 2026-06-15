import 'dart:async';
import 'dart:js' as js;

Future<String?> scanBarcodeFromPhoto() {
  final completer = Completer<String?>();
  js.context.callMethod('scanBarcodeFromPhoto', [
    js.allowInterop((dynamic result) {
      completer.complete(result?.toString());
    })
  ]);
  return completer.future;
}
