import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/order_detail_widget.dart';
import 'package:mandel_mobile_app/model/order_dto.dart';
import 'package:mandel_mobile_app/model/order_search_result_dto.dart';
import 'package:mandel_mobile_app/service/order_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:shimmer/shimmer.dart';

class OrderLineItemWidget extends StatefulWidget {
  final String status;
  const OrderLineItemWidget({super.key, required this.status});

  @override
  State<OrderLineItemWidget> createState() => _OrderLineItemWidgetState();
}

class _OrderLineItemWidgetState extends State<OrderLineItemWidget>
    with CommonUtility {
  ///
  Map<String, dynamic> filters = <String, dynamic>{"page": 0, "pageSize": 20};

  ///
  final _scrollController = ScrollController();

  ///
  bool _hasMore = true;

  ///
  List<OrderDto> _orderList = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _setScrollListener();
    super.initState();
  }

  //
  ///This method can be used for set listener to list scroll
  void _setScrollListener() {
    _scrollController.addListener(() {
      var maxScrollExtent = double.parse(
          (_scrollController.position.maxScrollExtent).toStringAsFixed(2));
      var offset = double.parse((_scrollController.offset).toStringAsFixed(2));
      if (maxScrollExtent == offset) {
        setState(() {
          filters['page'] = filters['page'] + 1;
        });
      }
    });
  }

  Future<List<OrderDto>> _getOrderList() async {
    if (CommonConstants.statusAll == widget.status) {
      filters.remove('orderState');
    } else {
      final statusFilter = <String, String>{'orderState': widget.status};
      filters.addEntries(statusFilter.entries);
    }
    Response response = await OrderService().getOrderList(filters);
    if (response.statusCode == 200) {
      final result = OrderSearchResultDto.fromJson(response.data);
      _orderList.addAll(result.results!);
      _hasMore = result.meta!.totalCount! > _orderList.length;
    }
    return _orderList;
  }

  //
  ///This method can be used for refresh list
  Future _refreshList() async {
    setState(() {
      _orderList.clear();
      _hasMore = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildOrderList(),
      ],
    ));
  }

  Widget _buildOrderList() {
    return FutureBuilder(
      future: _getOrderList(),
      builder: (BuildContext context, AsyncSnapshot<List<OrderDto>> result) {
        if (result.hasData) {
          if (result.data!.isEmpty) {
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

          return Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshList,
              child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  itemCount: result.data!.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index < result.data!.length) {
                      return _buildListItem(result.data![index], index);
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
          return Flexible(
            child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: _buildShimmerListView()),
          );
        }
      },
    );
  }

  Widget _buildListItem(OrderDto orderDto, int index) {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderDetailWidget(orderDto: orderDto)));
        },
        child: Card(
          child: Container(
            margin: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Order No.#',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${orderDto.id}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: CommonCustomColor.menuItemColor),
                        )
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 5),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: buildItemColor(orderDto.orderState ?? 'PENDING'),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(100)),
                            )),
                        Text(
                          '${orderDto.orderState ?? 'PENDING'}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: buildItemColor(orderDto.orderState ?? 'PENDING')),
                        )
                      ],
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 5),
                  child: Row(
                    children: [
                      Text(
                        getFormattedTimeStamp(orderDto.deliveryDate),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      const Text(
                        'Item count: ',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Text('${(orderDto.orderItems?.length ?? 0)}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500))
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      child: Row(
                        children: [
                          Text(
                            'Total: ${orderDto.total}',
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700),
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  MaterialColor buildItemColor(String status) {
    if (CommonConstants.statusComplete == status) {
      return CommonCustomColor.mSuccessColor;
    }
    if (CommonConstants.statusPending == status) {
      return CommonCustomColor.mPendingColor;
    }
    return CommonCustomColor.mDraftColor;
  }

  Widget _buildShimmerListView() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 5,
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
}
