import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/model/return_dto.dart';
import 'package:mandel_mobile_app/model/return_item_dto.dart';
import 'package:mandel_mobile_app/model/return_search_result_dto.dart';
import 'package:mandel_mobile_app/service/return_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:shimmer/shimmer.dart';

class ReturnLineItemWidget extends StatefulWidget {
  final String status;
  const ReturnLineItemWidget({super.key, required this.status});

  @override
  State<ReturnLineItemWidget> createState() => _ReturnLineItemWidgetState();
}

class _ReturnLineItemWidgetState extends State<ReturnLineItemWidget>
    with CommonUtility {
  ///
  Map<String, dynamic> filters = <String, dynamic>{"page": 0, "pageSize": 20};

  ///
  final _scrollController = ScrollController();

  ///
  bool _hasMore = true;

  ///
  List<ReturnItemDto> _returnList = [];

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

  Future<List<ReturnItemDto>> _getReturnList() async {
    if (CommonConstants.statusAll == widget.status) {
      filters.remove('returnStatus');
    } else {
      final statusFilter = <String, String>{'returnStatus': widget.status};
      filters.addEntries(statusFilter.entries);
    }
    Response response = await ReturnService().getOrderList(filters);
    if (response.statusCode == 200) {
      final result = ReturnSearchResultDto.fromJson(response.data);

      for (var element in result.results!) {
        _returnList.addAll(element.returnItems as Iterable<ReturnItemDto>);
      }
      // _returnList.addAll(result.results!.returnItems);
      _hasMore = result.meta!.totalCount! > _returnList.length;
    }
    return _returnList;
  }

  //
  ///This method can be used for refresh list
  Future _refreshList() async {
    setState(() {
      _returnList.clear();
      _hasMore = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildReturnList(),
      ],
    ));
  }

  Widget _buildReturnList() {
    return FutureBuilder(
      future: _getReturnList(),
      builder:
          (BuildContext context, AsyncSnapshot<List<ReturnItemDto>> result) {
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

  Widget _buildListItem(ReturnItemDto returnDto, int index) {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
      child: InkWell(
        onTap: () {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => OrderDetailWidget(orderDto: orderDto)));
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
                        SizedBox(
                          width: 193,
                          child: Text(
                            returnDto.product!.getProductName(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
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
                              color: buildItemColor(returnDto.returnStatus!),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(100)),
                            )),
                        Text(
                          '${returnDto.returnStatus}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: buildItemColor(returnDto.returnStatus!)),
                        )
                      ],
                    ),
                  ],
                ),
                if (returnDto.order != null)
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 5),
                    child: Row(
                      children: [
                        const Text(
                          'Order No.#',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${returnDto.order!.id}',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: CommonCustomColor.menuItemColor),
                        )
                      ],
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      const Text(
                        'Price: ',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Text('${returnDto.returnPrice} ',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Text(
                        '${returnDto.quantity} ',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const Text('x ',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      Text('${returnDto.returnType} ',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Text(
                        '${returnDto.returnReason} ',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color buildItemColor(String status) {
    if (CommonConstants.statusDecline == status) {
      return CommonCustomColor.warningColor;
    }

    if (CommonConstants.statusPending == status) {
      return CommonCustomColor.mPendingColor;
    }

    if (CommonConstants.statusComplete == status) {
      return CommonCustomColor.mSuccessColor;
    }

    if (CommonConstants.statusReceived == status) {
      return CommonCustomColor.recivedColor;
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
