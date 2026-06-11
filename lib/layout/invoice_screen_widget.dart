import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/model/invoice_dto.dart';
import 'package:mandel_mobile_app/model/invoice_search_result_dto.dart';
import 'package:mandel_mobile_app/model/media_dto.dart';
import 'package:mandel_mobile_app/service/invoice_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/message_utility.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with MessageUtility, CommonUtility {
  final _invoiceService = InvoiceService();
  final _scrollController = ScrollController();
  bool _hasMore = true;
  List<InvoiceDto> _invoiceList = [];
  late Future<void> _invoiceData;
  Map<String, dynamic> filters = <String, dynamic>{'page': 0, 'pageSize': 100};
  final _searchFieldController = TextEditingController();
  bool _hasFilterData = true;

  Future<void> _loadInvoices() async {
    Response response = await _invoiceService.getInvoices(filters);
    if (response.statusCode == 200) {
      final results = InvoiceSearchResultDto.fromJson(response.data);
      _invoiceList.addAll(results.results!);
      _hasMore = results.meta!.totalCount! > _invoiceList.length;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setScrollListener();
    _invoiceData = _loadInvoices();
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
      'Invoice',
      style: TextStyle(fontSize: 24),
    );
  }

  Future _reload() async {
    Response response = await _invoiceService.getInvoices(filters);
    List<InvoiceDto> invoices = [];
    if (response.statusCode == 200) {
      final results = InvoiceSearchResultDto.fromJson(response.data);
      invoices.addAll(results.results!);
      //_hasMore = results.meta!.totalCount! > _newsList.length;
    }
    setState(() {
      _invoiceList = invoices;
      _hasMore = true;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: _buildBackButton(),
        title: _buildTitle(),
      ),
      body: _buildBody(),
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

  _buildBody() {
    return Column(
      children: [
        _buildFilterField(),
        FutureBuilder(
            future: _invoiceData,
            builder: (BuildContext context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                  {
                    return Flexible(
                      child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: _buildShimmerListView()),
                    );
                  }
                case ConnectionState.done:
                  {
                    return Expanded(
                      child: RefreshIndicator(
                        onRefresh: _reload,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          itemCount: _invoiceList.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (index < _invoiceList.length) {
                              return _buildListItem(
                                  context, _invoiceList[index]);
                            } else if (_invoiceList.isEmpty) {
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
                                      'Everyting caught up!',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const Text(
                                    'Will let you know if there is anything else.!',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              );
                            } else {
                              return Visibility(
                                  visible: _hasMore,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 32),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ));
                            }
                          },
                        ),
                      ),
                    );
                  }
              }
            })
      ],
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final datePart = raw.split('T').first;
    final parts = datePart.split('-');
    if (parts.length != 3) return datePart;
    return '${parts[1]}/${parts[2]}/${parts[0]}';
  }

  Widget _buildListItem(BuildContext context, InvoiceDto invoice) {
    final isOpen = invoice.isOpen ?? (invoice.due != null && invoice.due! > 0);
    return Container(
        margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
        child: Card(
          child: Container(
            margin: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Invoice #',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${invoice.number}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: CommonCustomColor.menuItemColor),
                        )
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isOpen
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isOpen
                              ? Colors.red.shade300
                              : Colors.green.shade300,
                        ),
                      ),
                      child: Text(
                        isOpen ? 'OPEN' : 'PAID',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isOpen
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (invoice.invoiceDate != null || invoice.dueDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        if (invoice.invoiceDate != null)
                          Text(
                            'Date: ${_formatDate(invoice.invoiceDate)}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                        if (invoice.invoiceDate != null &&
                            invoice.dueDate != null)
                          const Text('  •  ',
                              style: TextStyle(color: Colors.grey)),
                        if (invoice.dueDate != null)
                          Text(
                            'Due: ${_formatDate(invoice.dueDate)}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _amountTile('Total', invoice.amount),
                    _amountTile('Paid', invoice.paid,
                        color: Colors.green.shade700),
                    _amountTile('Balance', invoice.due,
                        color: (invoice.due ?? 0) > 0
                            ? Colors.red.shade700
                            : Colors.grey),
                  ],
                ),
                if (invoice.reference != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                          child: Column(
                              children: [_buildImages(invoice.reference!)]))
                    ],
                  ),
                ]
              ],
            ),
          ),
        ));
  }

  Widget _amountTile(String label, double? value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          '\$${(value ?? 0).toStringAsFixed(2)}',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black87),
        ),
      ],
    );
  }

  _buildImages(MediaDto medila) {
    // List<MediaDto> images =
    //     medila.where((element) => element.type == "IMAGE").toList();
    // return medila.map((e) {
    if (medila.type == 'IMAGE') {
      return Container(
        width: MediaQuery.of(context).size.width * 0.86,
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        child: Center(
          child: Image.network(
            CommonConstants.mandelImageBaseUrl + medila.url!,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/mandel_no_image.jpg',
                fit: BoxFit.fitWidth,
              );
            },
          ),
        ),
      );
    } else if (medila.type == 'PDF') {
      return Container(
        width: MediaQuery.of(context).size.width * 0.86,
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        child: Center(
            child: ElevatedButton(
                onPressed: () async {
                  try {
                    final Uri url = Uri.parse(medila.url!);
                    await launchUrl(url);
                  } catch (error) {
                    debugPrint(error.toString());
                  }
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                child: const Text(
                  "View PDF",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ))),
      );
    }
    // });
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

  Widget _buildFilterField() {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 20, right: 20, left: 20),
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
                // if (null != _productListKey.currentState) {
                //   _productListKey.currentState!.filter(value);
                // }
              },
              decoration: InputDecoration(
                hintText: 'Search by invoice number',
                hintStyle: const TextStyle(
                    color: CommonCustomColor.menuItemColor, fontSize: 14),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFEEEEEE),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                suffixIcon: IconButton(
                  onPressed: () {
                    // _searchFieldController.clear();
                    // _productListKey.currentState!.filter("");
                    // setState(() {
                    //   _hasFilterData = false;
                    // });
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
