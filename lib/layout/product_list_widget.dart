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

  // Store the category future so it's only created once (not on every rebuild)
  late Future<List<CategoryDto>> _categoryFuture;

  @override
  void initState() {
    super.initState();
    filters.addAll(widget.initialFilters);
    _initializeSharedPreferences();
    _setScrollListener();
    _categoryFuture = _loadCategoryList();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadProductList();
    });
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
        FutureBuilder(
          future: _categoryFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Load error: ${snapshot.error}', style: const TextStyle(color: Colors.red, fontSize: 12)));
            }
            if (snapshot.hasData) {
              return DefaultTabController(
                  length: snapshot.data!.length,
                  initialIndex: widget.startingTab,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTabList(snapshot.data),
                      Flexible(
                          child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              children: _buildTabView(snapshot.data)))
                    ],
                  ));
            } else {
              return Column(
                children: [
                  _buildShimmerTabView(),
                  Flexible(
                    child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: _buildShimmerListView()),
                  )
                ],
              );
            }
          },
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

  _buildTabView(List<CategoryDto>? categoryList) {
    List<Tab> tabList = [];
    // ignore: unused_local_variable
    for (var element in categoryList!) {
      tabList.add(Tab(
        child: _buildProductList(),
      ));
    }

    return tabList;
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
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
      child: InkWell(
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
    final String imageUrl = productDt.productImages!.isNotEmpty
        ? productDt.productImages!.first.url!
        : '';
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
            CommonConstants.mandelImageBaseUrl + imageUrl,
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
