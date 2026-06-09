import 'package:mandel_mobile_app/model/product_details_options.dart';

class ProductSearchArguments {
  Map<String, dynamic> filters;
  int startingIndex;
  final ProductDetailsOptions productDetailsOptions;
  ProductSearchArguments({
    required this.filters,
    required this.productDetailsOptions,
    this.startingIndex = 0,
  });
}
