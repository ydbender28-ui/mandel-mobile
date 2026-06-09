import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/layout/order_and_return_screen_widget.dart';
import 'package:mandel_mobile_app/layout/view_cart_widget.dart';
import 'package:mandel_mobile_app/model/brand_dto.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/model/product_search_result_dto.dart';
import 'package:mandel_mobile_app/service/product_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:shimmer/shimmer.dart';

class BrandProductScreenWidget extends StatefulWidget {
  final BrandDto brandDto;

  const BrandProductScreenWidget({super.key, required this.brandDto});

  @override
  State<BrandProductScreenWidget> createState() =>
      _BrandProductScreenWidgetState();
}

class _BrandProductScreenWidgetState extends State<BrandProductScreenWidget> {
  //
  final _productService = ProductService();

  ///
  final _searchFieldController = TextEditingController();
  final _scrollController = ScrollController();

  late final StreamController<String> _streamControllers;

  ///
  Map<String, dynamic> filters = <String, dynamic>{"page": 0, "pageSize": 20};
  List<ProductDto> productList = [];

  ///
  bool _hasMore = true;
  bool _initProductLoad = true;
  bool _initProductFetching = true;

  ///

  @override
  void initState() {
    _setScrollListener();
    _streamControllers = StreamController.broadcast();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadProductList();
    });
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    _scrollController.dispose();
    _streamControllers.close();
    super.dispose();
  }

  Future<void> _loadProductList() async {
    if (_initProductLoad) {
      productList.clear();
    }

    filters['brand'] = widget.brandDto.name;

    try {
      ProductSearchResultDto output = await _productService.searchProduct(
          filters, filters['page'], filters['pageSize']);
      setState(() {
        productList.addAll(output.results ?? []);
        _hasMore = (output.meta?.totalCount ?? 0) > productList.length;
        _initProductFetching = false;
      });
    } catch (e) {
      debugPrint('Brand product load error: $e');
      setState(() { _initProductFetching = false; });
    }
  }

  //
  ///This method can be used for set listener to list scroll
  void _setScrollListener() {
    _scrollController.addListener(() {
      var maxScrollExtent = double.parse(
          (_scrollController.position.maxScrollExtent).toStringAsFixed(2));
      var offset = double.parse((_scrollController.offset).toStringAsFixed(2));
      if (maxScrollExtent == offset) {
        _initProductLoad = false;
        filters['page'] = filters["page"] + 1;
        _loadProductList();
      }
    });
  }

  //
  ///This method can be used for refresh list
  Future _refreshList() async {
    _hasMore = true;
    _initProductLoad = true;
    _initProductFetching = true;
    _loadProductList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(widget.brandDto.name!),
              _buildFilterField(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_buildBrandProductList()],
                ),
              )
            ],
          ),
          ViewCartWidget(
            controller: _streamControllers,
            viewCart: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) {
                  return const MainScreenWidget(
                    defaultIndex: 2,
                  );
                },
              ), (route) => false);
            },
          )
        ],
      ),
    );
  }

  Widget _buildTitle(String brandName) {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 54, bottom: 20),
      child: Text(
        brandName,
        style: const TextStyle(
          color: CommonCustomColor.defaultTextColor,
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFilterField() {
    return Container(
      margin: const EdgeInsets.only(right: 20, bottom: 10),
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
                Navigator.of(context).pop();
              },
            ),
          ),
          Flexible(
            child: TextFormField(
              enabled: true,
              controller: _searchFieldController,
              onChanged: (value) {
                if (_searchFieldController.text.isNotEmpty) {
                  filters['productName'] = _searchFieldController.text;
                } else {
                  filters.remove('productName');
                }
                _initProductLoad = true;
                _initProductFetching = true;
                _loadProductList();
              },
              decoration: InputDecoration(
                hintText: 'Search for product',
                hintStyle: const TextStyle(
                    color: CommonCustomColor.menuItemColor, fontSize: 14),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFEEEEEE),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                suffixIcon: IconButton(
                  onPressed: _searchFieldController.clear,
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

  //
  ///This method can be used for build bill list
  Widget _buildBrandProductList() {
    if (_initProductFetching) {
      return Flexible(
        child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: _buildShimmerListView()),
      );
    }

    if (productList.isNotEmpty) {
      return Expanded(
        child: RefreshIndicator(
          onRefresh: _refreshList,
          child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              itemCount: productList.length + 1,
              separatorBuilder: (context, index) {
                return const Divider(
                  indent: 20.0,
                  endIndent: 20.0,
                );
              },
              itemBuilder: (BuildContext context, int index) {
                if (index < productList.length) {
                  return _buildListItem(productList[index], index);
                } else {
                  return Visibility(
                    visible: _hasMore,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
              }),
        ),
      );
    } else {
      return Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/mandel_empty_state.png',
              width: 200,
              height: 200,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            child: const Text(
              'No data Found!',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          const Text(
            'Try reset the filters and apply.!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          )
        ],
      );
    }
  }

  Widget _buildListItem(ProductDto productDto, int index) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderAndReturnScreenWidget(
                productDto: productDto,
                index: index,
                fromOrder: false,
                showAddToCart: true,
                showReturn: false,
                onClose: () {
                  _streamControllers.sink.add('done');
                },
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildImageView(productDto),
                _buildInformation(productDto),
                const Spacer(flex: 1),
                _buildPricing(productDto)
              ],
            ),
            _buildDealList(productDto)
          ],
        ),
      ),
    );
  }

  Widget _buildImageView(ProductDto productDt) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
          border: Border.all(
              color: CommonCustomColor.menuItemColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          margin: const EdgeInsets.all(3),
          child: Center(
              child: Image.network(
            CommonConstants.mandelImageBaseUrl +
                productDt.productImages![0].url!,
            errorBuilder: (context, error, stackTrace) {
              return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 57,
                    height: 57,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  ));
            },
            fit: BoxFit.cover,
            height: 57,
            width: 57,
          )),
        ),
      ),
    );
  }

  Widget _buildInformation(ProductDto productDt) {
    return SizedBox(
      width: 193,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productDt.getProductName(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            productDt.getCategoryName(),
            style: const TextStyle(fontSize: 12),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Text(productDt.getBrandName(),
                  style: const TextStyle(fontSize: 12),
                  softWrap: false,
                  overflow: TextOverflow.ellipsis),
              Text(productDt.getSize(),
                  style: const TextStyle(fontSize: 12),
                  softWrap: false,
                  overflow: TextOverflow.ellipsis)
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPricing(ProductDto productDto) {
    return Column(
      children: [
        Visibility(
          visible: productDto.isDealExist(),
          child: Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: Center(
                child: Text(productDto.getNonDiscountedUnitPrice(),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CommonCustomColor.pendingColor,
                        decoration: TextDecoration.lineThrough))),
          ),
        ),
        Center(
          child: Text(productDto.getUnitPrice(),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        )
      ],
    );
  }

  Widget _buildShimmerListView() {
    return ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: 15,
        separatorBuilder: (context, index) {
          return const Divider(
            indent: 15.0,
            endIndent: 15.0,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          return _buildShimmerLineItem();
        });
  }

  Widget _buildShimmerLineItem() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            width: 57,
            height: 57,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
          ),
          SizedBox(
            width: 193,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0, top: 5.0),
                  decoration: const BoxDecoration(color: Colors.white),
                  width: 200,
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  decoration: const BoxDecoration(color: Colors.white),
                  width: 120,
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  decoration: const BoxDecoration(color: Colors.white),
                  width: 50,
                  height: 30,
                )
              ],
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildDealList(ProductDto productDto) {
    List<Widget> deals = [];

    if (null != productDto.deal) {
      for (var element in productDto.deal!) {
        deals.add(DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(8),
          color: CommonCustomColor.pendingColor,
          strokeWidth: 1,
          child: Container(
            decoration: BoxDecoration(
                color: CommonCustomColor.dealColor,
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(
                        left: 15, right: 2.5, top: 10, bottom: 10),
                    child: const Icon(
                      Icons.local_offer_outlined,
                      color: CommonCustomColor.pendingColor,
                    )),
                Container(
                  margin: const EdgeInsets.all(12.5),
                  child: Text(
                    element.description!,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: CommonCustomColor.menuItemColor),
                  ),
                )
              ],
            ),
          ),
        ));
      }
    }

    return Visibility(
      visible: productDto.isDealExist(),
      child: Container(
        margin: const EdgeInsets.only(top: 15),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [...deals],
          ),
        ),
      ),
    );
  }
}
