import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/model/deal_dto.dart';
import 'package:mandel_mobile_app/model/deal_search_result_dto.dart';
import 'package:mandel_mobile_app/service/deals_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class DealsListWidget extends StatefulWidget {
  const DealsListWidget({super.key});

  @override
  State<DealsListWidget> createState() => _DealsListWidgetState();
}

class _DealsListWidgetState extends State<DealsListWidget> {
  final _dealService = DealsService();

  Map<String, dynamic> filters = <String, dynamic>{"page": 0, "pageSize": 100};

  final _scrollController = ScrollController();
  bool _hasMore = true;
  bool _initLoad = true;
  bool _initFetch = true;

  late SharedPreferences localStorage;

  List<DealDto> _dealList = [];

  @override
  void initState() {
    _setScrollListener();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(),
        leading: _buildBackButton(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [_buildDealsList()],
      ),
    );
  }

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

  Future<List<DealDto>> _getDeals() async {
    Response response = await _dealService.getDealList(filters);
    if (response.statusCode == 200) {
      final result = DealSearchResultDto.fromJson(response.data);
      _dealList.addAll(result.results!);
      _hasMore = result.meta!.totalCount! > _dealList.length;
    }
    return _dealList;
  }

  Future _refreshList() async {
    setState(() {
      _dealList.clear();
      _hasMore = true;
    });
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

  _buildTitle() {
    return const Text(
      'Deals',
      style: TextStyle(fontSize: 24),
    );
  }

  Widget _buildDealsList() {
    return FutureBuilder(
        future: _getDeals(),
        builder: (BuildContext context, AsyncSnapshot<List<DealDto>> results) {
          if (results.hasData) {
            if (results.data!.isEmpty) {
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
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Text(
                    'Try reset the filters and apply.!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  )
                ],
              );
            } else {
              return Expanded(
                  child: RefreshIndicator(
                onRefresh: _refreshList,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  itemCount: results.data!.length + 1,
                  itemBuilder: (BuildContext context, index) {
                    if (index < results.data!.length) {
                      return _buildListItem(results.data![index], index);
                    } else {
                      return Visibility(
                        visible: _hasMore,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ));
            }
          } else {
            return Flexible(
              child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: _buildShimmerListView()),
            );
          }
        });
  }

  Widget _buildListItem(DealDto dealDto, int index) {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
      child: InkWell(
        onTap: null,
        child: Card(
          child: Container(
            margin: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          dealDto.title!,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        )
                      ],
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
