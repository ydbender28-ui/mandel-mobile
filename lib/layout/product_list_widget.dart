import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/layout/order_and_return_screen_widget.dart';
import 'package:mandel_mobile_app/layout/view_cart_widget.dart';
import 'package:mandel_mobile_app/model/category_dto.dart';
import 'package:mandel_mobile_app/model/product_details_options.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/model/product_search_result_dto.dart';
import 'package:mandel_mobile_app/service/category_service.dart';
import 'package:mandel_mobile_app/service/last_order_service.dart';
import 'package:mandel_mobile_app/service/product_service.dart';
import 'package:mandel_mobile_app/model/portal_deal_dto.dart';
import 'package:mandel_mobile_app/model/portal_sale_dto.dart';
import 'package:mandel_mobile_app/service/ads_service.dart';
import 'package:mandel_mobile_app/service/sales_service.dart';
import 'package:mandel_mobile_app/utility/cart_state.dart';
import 'package:mandel_mobile_app/utility/common_cart_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ProductListWidget extends StatefulWidget {
  final int startingTab;
  final Map<String, dynamic> initialFilters;
  final ProductDetailsOptions productDetailsOptions;
  final bool showCartOverlay;
  const ProductListWidget(
      {super.key,
      required this.initialFilters,
      required this.productDetailsOptions,
      this.startingTab = 0,
      this.showCartOverlay = true});

  @override
  State<ProductListWidget> createState() => ProductListWidgetState();
}

class ProductListWidgetState extends State<ProductListWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _productService = ProductService();

  ///
  Map<String, dynamic> filters = <String, dynamic>{"page": 0, "pageSize": 5000};

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

  // Last order history: productId → {qty, date}
  Map<int, LastOrderInfo> _lastOrders = {};

  // Per-product qty currently in cart (for quick-add controls)
  final Map<int, int> _cartQtys = {};

  // Version counter — discard responses from superseded search calls
  int _loadVersion = 0;

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
    // Load last-order history (best-effort, non-blocking)
    LastOrderService().getLastOrders().then((m) { if (mounted) setState(() => _lastOrders = m); });
    // Seed quick-add qtys from existing cart
    for (final item in CartState.items) {
      if (item.productId != null && item.qty != null) {
        _cartQtys[item.productId!] = item.qty!;
      }
    }
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
    final shouldClear = _initProductLoad;
    final myVersion = ++_loadVersion;
    try {
      ProductSearchResultDto output = await _productService.searchProduct(
          filters, filters['page'], filters['pageSize']);
      if (!mounted || myVersion != _loadVersion) return;
      setState(() {
        if (shouldClear) productList.clear();
        productList.addAll(output.results ?? []);
        _hasMore = (output.meta?.totalCount ?? 0) > productList.length;
        _initProductFetching = false;
      });
    } catch (e) {
      debugPrint('Product load error: $e');
      if (!mounted || myVersion != _loadVersion) return;
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

  // Quick-add: set qty for a product in the cart
  void _setQty(ProductDto product, int qty) {
    final pid = product.id;
    if (pid == null) return;
    setState(() {
      if (qty <= 0) {
        _cartQtys.remove(pid);
        CartState.removeItem(pid);
      } else {
        _cartQtys[pid] = qty;
        CommonCartUtility().addToCart(productDto: product, qty: qty);
      }
    });
    _streamControllers.sink.add('done');
  }

  // Format last-ordered date as a short relative string
  String _formatLastOrderDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final d = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(d).inDays;
      if (diff == 0) return 'today';
      if (diff == 1) return 'yesterday';
      if (diff < 7) return '${diff}d ago';
      if (diff < 30) return '${(diff / 7).floor()}w ago';
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[d.month - 1]} ${d.day}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!widget.showCartOverlay) {
      return Column(children: [
        FutureBuilder(
          future: _categoryFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) return _buildTabListOnly(snapshot.data);
            return _buildShimmerTabView();
          },
        ),
        Flexible(child: _buildProductList()),
      ]);
    }
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
      color: const Color(0xFF07091A),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  color: isSelected
                      ? Colors.white.withOpacity(0.92)
                      : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white.withOpacity(0.14),
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.white.withOpacity(0.15),
                          blurRadius: 8, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Text(
                  cat.name ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF07091A)
                        : Colors.white.withOpacity(0.55),
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
    return Container(
      color: const Color(0xFF07091A),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF1A2455),
        highlightColor: const Color(0xFF2A3870),
        child: Row(
          children: List.generate(5, (i) => Container(
            margin: const EdgeInsets.only(right: 8),
            width: 70, height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)),
          )),
        ),
      ),
    );
  }

  static const _bgGrad = LinearGradient(
    colors: [Color(0xFF07091A), Color(0xFF111B4A), Color(0xFF07091A)],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );

  Widget _buildProductList() {
    if (_initProductFetching) {
      return Container(
        decoration: const BoxDecoration(gradient: _bgGrad),
        child: Shimmer.fromColors(
          baseColor: const Color(0xFF1A2455),
          highlightColor: const Color(0xFF2A3870),
          child: _buildShimmerListView()),
      );
    }

    if (productList.isNotEmpty) {
      return Container(
        decoration: const BoxDecoration(gradient: _bgGrad),
        child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 80,
            ),
            controller: _scrollController,
            itemCount: productList.length + 1,
            separatorBuilder: (_, __) => const SizedBox.shrink(),
            itemBuilder: (BuildContext context, int index) {
              if (index < productList.length) {
                return _buildListItem(productList[index], index);
              }
              return Visibility(
                visible: _hasMore,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white.withOpacity(0.5))),
                ),
              );
            }),
      );
    } else {
      return Container(
        decoration: const BoxDecoration(gradient: _bgGrad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/mandel_empty_state.png',
              width: 180, height: 180, color: Colors.white.withOpacity(0.25),
              colorBlendMode: BlendMode.modulate),
            const SizedBox(height: 12),
            const Text('No products found.',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 6),
            Text('Try resetting your filters',
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5))),
          ],
        ),
      );
    }
  }

  Widget _buildListItem(ProductDto productDto, int index) {
    final int currentQty = _cartQtys[productDto.id] ?? 0;
    final lastOrder = productDto.id != null ? _lastOrders[productDto.id!] : null;

    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(currentQty > 0 ? 0.18 : 0.14),
                  Colors.white.withOpacity(currentQty > 0 ? 0.10 : 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: currentQty > 0
                    ? const Color(0xFF818CF8).withOpacity(0.5)
                    : Colors.white.withOpacity(0.20),
                width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: currentQty > 0
                      ? const Color(0xFF818CF8).withOpacity(0.28)
                      : const Color(0xFF4F46E5).withOpacity(0.18),
                  blurRadius: 24, offset: const Offset(0, 8)),
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.white.withOpacity(0.08),
              highlightColor: Colors.white.withOpacity(0.04),
              onTap: () {
                _storeSearchHistory();
                final sEntry = _saleEntryFor(productDto);
                final dEntry = sEntry == null ? _dealFor(productDto) : null;
                double? discountedPrice;
                if (sEntry != null) {
                  discountedPrice = sEntry.salePrice;
                } else if (dEntry != null && dEntry.type != 'BULK' && dEntry.discountAmount > 0) {
                  final base = productDto.getNonFormatPrice();
                  discountedPrice = dEntry.discountType == 'PERCENT'
                      ? base * (1 - dEntry.discountAmount / 100)
                      : (base - dEntry.discountAmount).clamp(0.0, double.infinity);
                }
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => OrderAndReturnScreenWidget(
                    productDto: productDto,
                    index: index,
                    fromOrder: false,
                    showAddToCart: widget.productDetailsOptions.showAddToCart,
                    showReturn: widget.productDetailsOptions.showReturn,
                    discountedPrice: discountedPrice,
                    onClose: () { _streamControllers.sink.add('done'); },
                  ),
                ));
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildImageView(productDto),
                        _buildInformation(productDto),
                        const Spacer(flex: 1),
                        _buildPricing(productDto),
                      ],
                    ),
                    _buildDealList(productDto),
                    const SizedBox(height: 10),
                    // Quick-add controls + last order info
                    Row(
                      children: [
                        // +/- controls
                        _buildQuickAdd(productDto, currentQty),
                        const Spacer(),
                        // Last ordered info (right-aligned)
                        if (lastOrder != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.history_rounded,
                                size: 11,
                                color: Colors.white.withOpacity(0.38)),
                              const SizedBox(width: 4),
                              Text(
                                'Last: ${lastOrder.qty}× · ${_formatLastOrderDate(lastOrder.date)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.38),
                                  fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAdd(ProductDto product, int qty) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (qty > 0) ...[
          _QtyBtn(
            icon: Icons.remove,
            onTap: () => _setQty(product, qty - 1),
            filled: true,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800),
            ),
          ),
        ],
        _QtyBtn(
          icon: Icons.add,
          onTap: () => _setQty(product, qty + 1),
          filled: qty > 0,
          highlight: qty == 0,
        ),
        if (qty > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF818CF8).withOpacity(0.18),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF818CF8).withOpacity(0.35)),
            ),
            child: Text(
              'in cart',
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFF818CF8).withOpacity(0.9),
                fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ],
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
                ? const Color(0xFFdc2626).withOpacity(0.6)
                : Colors.white.withOpacity(0.18),
            width: 1.5),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8, offset: const Offset(0, 3))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: 70,
          height: 70,
          color: Colors.white.withOpacity(0.08),
          child: Stack(
            children: [
              hasImage
                ? Image.network(imageUrl,
                    width: 70, height: 70, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/mandel_no_image.jpg',
                      width: 70, height: 70, fit: BoxFit.cover))
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
            style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: Colors.white, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            productDt.getCategoryName(),
            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.55)),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Flexible(
                child: Text(productDt.getBrandName(),
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.45)),
                  softWrap: false, overflow: TextOverflow.ellipsis),
              ),
              Text(productDt.getSize(),
                style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.45)),
                softWrap: false, overflow: TextOverflow.ellipsis),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPricing(ProductDto productDto) {
    final saleEntry = _saleEntryFor(productDto);
    final hasSale   = saleEntry != null;
    final dealEntry = !hasSale ? _dealFor(productDto) : null;
    final hasDealDiscount = dealEntry != null && dealEntry.type != 'BULK' && dealEntry.discountAmount > 0;
    final showStrike = hasSale || hasDealDiscount;
    final regularPrice = productDto.getUnitPrice();
    final regularPriceDouble = productDto.getNonFormatPrice();

    final String displayPrice;
    if (hasSale) {
      displayPrice = saleEntry!.salePrice.toStringAsFixed(2);
    } else if (hasDealDiscount) {
      final disc = dealEntry!.discountType == 'PERCENT'
          ? regularPriceDouble * (1 - dealEntry.discountAmount / 100)
          : (regularPriceDouble - dealEntry.discountAmount).clamp(0.0, double.infinity);
      displayPrice = disc.toStringAsFixed(2);
    } else {
      displayPrice = regularPrice;
    }

    final priceColor = hasSale
        ? const Color(0xFFFC8181)
        : hasDealDiscount ? const Color(0xFFfb923c) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showStrike)
          Text(regularPrice,
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.35),
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.white.withOpacity(0.35))),
        Text('\$$displayPrice',
          style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w800,
            color: priceColor,
            shadows: (hasSale || hasDealDiscount) ? [Shadow(color: priceColor.withOpacity(0.5), blurRadius: 10)] : null)),
        if (productDto.expiryDate != null && productDto.expiryDate!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFdc2626).withOpacity(0.22),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFFC8181).withOpacity(0.45))),
            child: Text('EXP ${productDto.expiryDate!}',
              style: const TextStyle(
                fontSize: 9, fontWeight: FontWeight.w700,
                color: Color(0xFFFC8181))),
          ),
      ],
    );
  }

  Widget _buildShimmerListView() {
    return ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
        itemCount: 10,
        separatorBuilder: (_, __) => const SizedBox.shrink(),
        itemBuilder: (_, __) => _buildShimmerLineItem());
  }

  Widget _buildShimmerLineItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 94,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
    );
  }

  Widget _buildDealList(ProductDto productDto) {
    List<Widget> deals = [];

    if (null != productDto.deal) {
      for (var element in productDto.deal!) {
        deals.add(Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFf0560f).withOpacity(0.18),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFf0560f).withOpacity(0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_offer_rounded,
                color: Color(0xFFfb923c), size: 11),
              const SizedBox(width: 5),
              Text(element.description!,
                style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: Color(0xFFfb923c))),
            ],
          ),
        ));
      }
    }

    return Visibility(
      visible: productDto.isDealExist(),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [...deals]),
        ),
      ),
    );
  }
}

// Small circular +/- button for quick-add
class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final bool highlight;
  const _QtyBtn({required this.icon, required this.onTap, this.filled = false, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: highlight
              ? const Color(0xFF818CF8).withOpacity(0.25)
              : filled
                  ? Colors.white.withOpacity(0.18)
                  : Colors.white.withOpacity(0.10),
          shape: BoxShape.circle,
          border: Border.all(
            color: highlight
                ? const Color(0xFF818CF8).withOpacity(0.5)
                : Colors.white.withOpacity(0.15),
            width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 15),
      ),
    );
  }
}
