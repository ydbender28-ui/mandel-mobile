import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/layout/product_list_history_widget.dart';
import 'package:mandel_mobile_app/layout/product_list_widget.dart';
import 'package:mandel_mobile_app/model/product_search_arguments.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';

class ProductScreenWidget extends StatefulWidget {
  const ProductScreenWidget({super.key});

  @override
  State<ProductScreenWidget> createState() => _ProductScreenWidgetState();
}

class _ProductScreenWidgetState extends State<ProductScreenWidget> {
  ///
  final _searchFieldController = TextEditingController();
  final _productListKey = GlobalKey<ProductListWidgetState>();

  ///
  bool _hasFilterData = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ProductSearchArguments;

    Map<String, dynamic> filters = args.filters;
    filters['productName'] = _searchFieldController.text;
    return Scaffold(
      body: Column(
        children: [
          _buildFilterField(),
          Flexible(
            child: ProductListWidget(
              key: _productListKey,
              startingTab: args.startingIndex,
              initialFilters: args.filters,
              productDetailsOptions: args.productDetailsOptions,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterField() {
    return Container(
      margin: const EdgeInsets.only(top: 54, bottom: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: IconButton(
              icon: Image.asset(
                'assets/images/mandel_angle_left.png',
                width: 25,
                height: 24,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (context) {
                    return const MainScreenWidget(
                      defaultIndex: 0,
                    );
                  },
                ), (route) => false);
              },
            ),
          ),
          Flexible(
            child: TextFormField(
              enabled: true,
              controller: _searchFieldController,
              onChanged: (value) {
                setState(() {
                  _hasFilterData = _searchFieldController.text.isNotEmpty;
                });
                if (null != _productListKey.currentState) {
                  _productListKey.currentState!.filter(value);
                }
              },
              decoration: InputDecoration(
                hintText: 'Search product by name or category',
                hintStyle: const TextStyle(
                    color: CommonCustomColor.menuItemColor, fontSize: 14),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFEEEEEE),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchFieldController.clear();
                    _productListKey.currentState!.filter("");
                    setState(() {
                      _hasFilterData = false;
                    });
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
