import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/layout/product_list_history_widget.dart';
import 'package:mandel_mobile_app/layout/product_list_widget.dart';
import 'package:mandel_mobile_app/model/product_details_options.dart';
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
    // Handle being used as a tab (no route arguments) or as a pushed route (with arguments)
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final args = routeArgs is ProductSearchArguments
        ? routeArgs
        : ProductSearchArguments(
            filters: {},
            productDetailsOptions: ProductDetailsOptions(showAddToCart: true, showReturn: false),
          );

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
      margin: const EdgeInsets.only(top: 54, bottom: 20, left: 16, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
