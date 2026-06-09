import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/multiple_product_option_widget.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';

class MultipleProductOptionListWidget extends StatefulWidget {
  final List<ProductDto> products;
  final bool showAddToCart;
  final bool showAddToReturn;
  const MultipleProductOptionListWidget(
      {super.key,
      required this.products,
      this.showAddToCart = true,
      this.showAddToReturn = false});

  @override
  State<MultipleProductOptionListWidget> createState() =>
      _MultipleProductOptionListWidgetState();
}

class _MultipleProductOptionListWidgetState
    extends State<MultipleProductOptionListWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: _buildBackButton(),
        title: _buildTitle(),
      ),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return MultipleProductOptionWidget(
              product: widget.products[index],
              showAddToCart: widget.showAddToCart,
              showAddToReturn: widget.showAddToReturn,
            );
          },
          separatorBuilder: (context, index) {
            return const Divider(
              indent: 20.0,
              endIndent: 20.0,
            );
          },
          itemCount: widget.products.length),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Image.asset(
        'assets/images/mandel_angle_left.png',
        width: 25,
        height: 24,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Multiple selling packs avilable',
      style: TextStyle(fontSize: 18),
    );
  }
}
