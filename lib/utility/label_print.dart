import 'label_print_stub.dart'
    if (dart.library.html) 'label_print_web.dart';

void printLabel({required String productName, required String barcodeValue}) {
  printLabelImpl(productName: productName, barcodeValue: barcodeValue);
}
