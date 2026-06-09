import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';

class ProductAddToCartWidget extends StatefulWidget {
  final ProductDto productDto;

  const ProductAddToCartWidget({super.key, required this.productDto});

  @override
  State<ProductAddToCartWidget> createState() => _ProductAddToCartWidgetState();
}

class _ProductAddToCartWidgetState extends State<ProductAddToCartWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
