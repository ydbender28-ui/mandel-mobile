import 'package:mandel_mobile_app/model/product_details_options.dart';

class ScannerArguments {
  final ProductDetailsOptions productDetailsOptions;
  final bool enableRapidMode;

  ScannerArguments(
      {required this.productDetailsOptions, this.enableRapidMode = false});
}
