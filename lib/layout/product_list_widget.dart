import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/layout/order_and_return_screen_widget.dart';
import 'package:mandel_mobile_app/layout/view_cart_widget.dart';
import 'package:mandel_mobile_app/model/category_dto.dart';
import 'package:mandel_mobile_app/model/price_dto.dart';
import 'package:mandel_mobile_app/model/product_details_options.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/model/product_search_result_dto.dart';
import 'package:mandel_mobile_app/service/category_service.dart';
import 'package:mandel_mobile_app/service/product_service.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/mandel_network_image.dart';
import 'package:mandel_mobile_app/model/portal_deal_dto.dart';
import 'package:mandel_mobile_app/model/portal_sale_dto.dart';
import 'package:mandel_mobile_app/service/ads_service.dart';
import 'package:mandel_mobile_app/service/sales_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ProductListWidget extends StatefulWidget {
  final int startingTab;
  final Map<String, dynamic> initialFilters;
  final ProductDetailsOptions productDetailsOptions;
  const ProductListWidget(
      {super.key,
      required this.initialFilters,
      required this.productDetailsOptions,
      this.startingTab = 0});

  @override
  State<ProductListWidget> createState() => ProductListWidgetState();
}

class ProductListWidgetState extends State<ProductListWidget> {
  final _productService = ProductService();

  ///
  Map<String, dynamic> filters = <String, dynamic>{"page": 0, "pageSize": 20};

  ///
  final _scrollController = ScrollController();

  ///
  bool _hasMore = true;
  bool _initProductLoad = true;
  bool _initProductFetching = true;

  ///
  late SharedPreferences localStorage;

  ///
  final StreamController<String> _streamControllers =
      StreamController.broadcast();

  List<ProductDto> productList = [];

  List<PortalDealDto> _portalDeals = [];
  List<PortalSaleDto> _portalSales = [];

  // Store the category future so it's only created once (not on every rebuild)
  late Future<List<CategoryDto>> _categoryFuture;

  @override
  void initState() {
    super.initState();
    filters.addAll(widget.initialFilters);
    _initializeSharedPreferences();
    _setScrollListener();
    _categoryFuture = _loadCategoryList();
    Future.microtask(() => _loadProductList());
    AdsService().getDeals().then((d) { if (mounted) setState(() => _portalDeals = d); });
    SalesService().getSales().then((s) { if (mounted) setState(() => _portalSales = s); });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _streamControllers.close();
    super.dispose();
  }

  void _initializeSharedPreferences() async {
    localStorage = await SharedPreferences.getInstance();
  }

  Future<void> _loadProductList() async {
    if (_initProductLoad) {
      productList.clear();
    }
    try {
      ProductSearchResultDto output = await _productService.searchProduct(
          filters, filters['page'], filters['pageSize']);
      if (!mounted) return;
      setState(() {
        productList.addAll(output.results ?? []);
        _hasMore = (output.meta?.totalCount ?? 0) > productList.length;
        _initProductFetching = false;
      });
    } catch (e) {
      debugPrint('Product load error: $e');
      if (!mounted) return;
      setState(() { _initProductFetching = false; });
    }
  }

  Future<List<CategoryDto>> _loadCategoryList() async {
    Map<String, dynamic>? categoryFilter = <String, dynamic>{};

    List<CategoryDto> categoryList = [];
    List<CategoryDto> categories =
        await CategoryService().getAllCategoryList(categoryFilter);
    categoryList.add(CategoryDto(id: 0, name: 'ALL'));
    categoryList.add(CategoryDto(id: 0, name: 'Deals Only'));
    categoryList.add(CategoryDto(id: 0, name: 'New Items'));
    categoryList.addAll(categories);
    // if (200 == response.statusCode) {
    //   categoryList.add(CategoryDto(id: 0, name: 'ALL'));
    //   categoryList.addAll((response.data as List)
    //       .map((data) => CategoryDto.fromJson(data))
    //       .toList());
    // }
    return categoryList;
  }

  void filter(String productName) {
    filters['productName'] = productName;
    filters['page'] = 0;
    filters['pageSize'] = 20;
    _initProductLoad = true;
    _initProductFetching = true;
    _loadProductList();
  }

  //
  ///This method can be used for refresh list
  Future _refreshList() async {
    _hasMore = true;
    _initProductLoad = true;
    _initProductFetching = true;
    _loadProductList();
  }

  //
  ///This method can be used for set listener to list scroll
  void _setScrollListener() {
    _scrollController.addListener(() {
      var maxScrollExtent = double.parse(
          (_scrollController.positions.first.maxScrollExtent)
              .toStringAsFixed(2));
      var offset = double.parse((_scrollController.offset).toStringAsFixed(2));

      if (maxScrollExtent == offset) {
        _initProductLoad = false;
        filters['page'] = filters["page"] + 1;
        _loadProductList();
      }
    });
  }

  ///
  /// This method can be used for save item search history
  void _storeSearchHistory() async {
    List<String>? items =
        localStorage.getStringList(CommonConstants.itemFilterHistoryList);

    items ??= [];
    items.insert(0, filters['productName']);

    Set<String> filterHistory = items.toSet();
    await localStorage.setStringList(
        CommonConstants.itemFilterHistoryList, filterHistory.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Category tabs — load async, show shimmer until ready
            FutureBuilder(
              future: _categoryFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _buildTabListOnly(snapshot.data);
                }
                return _buildShimmerTabView();
              },
            ),
            // Products — show immediately, don't wait for categories
            Flexible(child: _buildProductList()),
          ],
        ),
        ViewCartWidget(
          controller: _streamControllers,
          viewCart: () {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder: (context) {
                return const MainScreenWidget(
                  defaultIndex: 3,
                );
              },
            ), (route) => false);
          },
        )
      ],
    );
  }

  Widget _buildTabListOnly(List<CategoryDto>? categoryList) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: List.generate(categoryList!.length, (index) {
            final cat = categoryList[index];
            final isSelected = (filters['category'] == cat.name) ||
                (index == 0 && filters['category'] == null && filters['isOnDeal'] == null && filters['isNewItem'] == null) ||
                (index == 1 && filters['isOnDeal'] == true) ||
                (index == 2 && filters['isNewItem'] == true);
            return GestureDetector(
              onTap: () {
                filters.remove('category');
                filters.remove('isOnDeal');
                filters.remove('isNewItem');
                if (index == 0) {
                  // ALL
                } else if (index == 1) {
                  filters['isOnDeal'] = true;
                } else if (index == 2) {
                  filters['isNewItem'] = true;
                } else {
                  filters['category'] = cat.name;
                }
                filters['page'] = 0;
                _initProductLoad = true;
                _initProductFetching = true;
                _loadProductList();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0D1135) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0D1135) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  cat.name ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  _buildTabList(List<CategoryDto>? categoryList) {
    // DefaultTabController.of(context).addListener(() {
    //   print("Listing to tab change");
    // });
    List<Tab> tabList = [];
    for (var element in categoryList!) {
      tabList.add(Tab(
        text: element.name,
      ));
    }

    return TabBar(
      isScrollable: true,
      tabs: tabList,
      onTap: (index) {
        // _scrollController.position
        filters.remove('category');
        filters.remove('isOnDeal');
        filters.remove('isNewItem');
        if (0 == index) {
          filters['page'] = 0;
        } else if (1 == index) {
          filters['isOnDeal'] = true;
          filters['page'] = 0;
        } else if (2 == index) {
          filters['isNewItem'] = true;
          filters['page'] = 0;
        } else {
          filters['category'] = categoryList[index].name;
          filters['page'] = 0;
        }

        _initProductLoad = true;
        _initProductFetching = true;
        _loadProductList();
      },
    );
  }

  List<Widget> _buildTabView(List<CategoryDto>? categoryList) {
    return List<Widget>.generate(
      categoryList!.length,
      (index) => _buildProductList(),
    );
  }

  Widget _buildShimmerTabView() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: const DefaultTabController(
          length: 4,
          child: Column(
            children: [
              TabBar(tabs: [
                Tab(text: 'ALL'),
                Tab(text: 'SNACK'),
                Tab(text: 'DRINKS'),
                Tab(text: 'ROLLING PAPER'),
              ]),
            ],
          ),
        ));
  }

  //
  ///This method can be used for build bill list
  Widget _buildProductList() {
    if (_initProductFetching) {
      return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: _buildShimmerListView());
    }

    if (productList.isNotEmpty) {
      return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: 6,
            bottom: MediaQuery.of(context).padding.bottom + 80,
          ),
          controller: _scrollController,
          itemCount: productList.length + 1,
          separatorBuilder: (context, index) => const SizedBox.shrink(),
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
          });
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
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
          color: const Color(0xFF0D1135).withOpacity(0.07),
          blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          _storeSearchHistory();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderAndReturnScreenWidget(
                productDto: productDto,
                index: index,
                fromOrder: false,
                showAddToCart: widget.productDetailsOptions.showAddToCart,
                showReturn: widget.productDetailsOptions.showReturn,
                onClose: () {
                  _streamControllers.sink.add('done');
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      ),
    );
  }

  // Returns the sale item (with its salePrice) if this product is in any active sale.
  PortalSaleItemDto? _saleEntryFor(ProductDto p) {
    final pid = p.id ?? -1;
    for (final sale in _portalSales) {
      final entry = sale.salePriceFor(pid);
      if (entry != null) {
        return PortalSaleItemDto(
          id: 0, productId: pid, salePrice: entry);
      }
    }
    return null;
  }

  PortalDealDto? _dealFor(ProductDto p) {
    final pid = p.id ?? -1;
    final brand = p.brand?.name ?? '';
    final cat = p.category?.name ?? '';
    for (final d in _portalDeals) {
      final bool match = d.type == 'BULK'
          // For list view, ignore minQty — show badge to entice the customer
          ? d.items.any((i) => i.productId == pid ||
              (i.refValue != null &&
               i.refValue!.toUpperCase() == brand.toUpperCase()))
          : d.appliesTo(productId: pid, brandName: brand, category: cat);
      if (match) return d;
    }
    return null;
  }

  Widget _buildImageView(ProductDto productDt) {
    final String imageUrl = (productDt.productImages?.isNotEmpty == true)
        ? (productDt.productImages!.first.url ?? '')
        : '';
    final bool hasImage = imageUrl.isNotEmpty && imageUrl.startsWith('http');
    final deal      = _dealFor(productDt);
    final salePriceEntry = _saleEntryFor(productDt);
    final bool onSale = salePriceEntry != null;
    final bool isNew = productDt.isNew == true;
    return Container(
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
          border: Border.all(
            color: onSale
                ? const Color(0xFFdc2626).withOpacity(0.5)
                : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Container(
          width: 70,
          height: 70,
          color: const Color(0xFFF8FAFC),
          child: Stack(
            children: [
              hasImage
                ? MandelNetworkImage(url: imageUrl, width: 70, height: 70)
                : Image.asset('assets/images/mandel_no_image.jpg', width: 70, height: 70, fit: BoxFit.cover),
              // NEW badge (green) — top-left corner
              if (isNew)
                Positioned(
                  top: 0, left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF16a34a),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(11),
                        bottomRight: Radius.circular(7)),
                    ),
                    child: const Text('NEW',
                      style: TextStyle(
                        color: Colors.white, fontSize: 9,
                        fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                  ),
                ),
              // Sale badge (red) takes priority over deal badge (bottom)
              if (onSale)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFdc2626), Color(0xFF991b1b)]),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(11), bottomRight: Radius.circular(11)),
                    ),
                    child: const Text('SALE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white, fontSize: 9,
                        fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                  ),
                )
              else if (deal != null)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFf0560f), Color(0xFFe03a00)]),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(11), bottomRight: Radius.circular(11)),
                    ),
                    child: Text(deal.badge,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white, fontSize: 9,
                        fontWeight: FontWeight.w900, height: 1.2)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformation(ProductDto productDt) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productDt.getProductName(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            maxLines: 2,
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
    final saleEntry = _saleEntryFor(productDto);
    final hasSale   = saleEntry != null;
    final hasDeal   = !hasSale && productDto.isDealExist();
    final showStrike = hasSale || hasDeal;
    final originalPrice = productDto.getNonDiscountedUnitPrice();
    final regularPrice  = productDto.getUnitPrice();
    final displayPrice  = hasSale
        ? saleEntry!.salePrice.toStringAsFixed(2)
        : regularPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Strikethrough original price
        if (showStrike)
          Text(hasSale ? regularPrice : originalPrice,
            style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500,
              color: Color(0xFF9AA3C2),
              decoration: TextDecoration.lineThrough)),
        // Main price (sale price in red, otherwise normal)
        Text('\$$displayPrice',
          style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: hasSale ? const Color(0xFFdc2626) : const Color(0xFF0D1135))),
        // Expiry date chip
        if (productDto.expiryDate != null && productDto.expiryDate!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFFCA5A5))),
            child: Text('EXP ${productDto.expiryDate!}',
              style: const TextStyle(
                fontSize: 9, fontWeight: FontWeight.w700,
                color: Color(0xFFdc2626))),
          ),
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
