import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/model/invoice_dto.dart';
import 'package:mandel_mobile_app/model/invoice_line_item_dto.dart';
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
                    if (_invoiceList.isEmpty) {
                      return const Expanded(
                        child: Center(child: Text('No invoices found.')),
                      );
                    }
                    return Expanded(
                      child: RefreshIndicator(
                        onRefresh: _reload,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: _invoiceList
                                .map((inv) => _buildListItem(context, inv))
                                .toList(),
                          ),
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
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => InvoiceDetailScreen(
            invoice: invoice,
            invoiceService: _invoiceService,
            formatDate: _formatDate,
          ),
        )),
        child: Container(
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
        )));
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

class _InvoiceDetailSheet extends StatefulWidget {
  final InvoiceDto invoice;
  final InvoiceService invoiceService;
  final String Function(String?) formatDate;

  const _InvoiceDetailSheet({
    required this.invoice,
    required this.invoiceService,
    required this.formatDate,
  });

  @override
  State<_InvoiceDetailSheet> createState() => _InvoiceDetailSheetState();
}

class _InvoiceDetailSheetState extends State<_InvoiceDetailSheet> {
  late Future<List<InvoiceLineItemDto>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
  }

  Future<List<InvoiceLineItemDto>> _loadItems() async {
    final arhId = widget.invoice.arhId;
    if (arhId == null) return [];
    final res = await widget.invoiceService.getInvoiceItems(arhId);
    if (res.statusCode == 200) {
      final raw = (res.data['items'] as List?) ?? [];
      return raw
          .map((i) => InvoiceLineItemDto.fromJson(i as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;
    final isOpen = inv.isOpen ?? (inv.due != null && inv.due! > 0);
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 4),
          child: Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invoice #${inv.number}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        if (inv.invoiceDate != null)
                          Text(
                            '${widget.formatDate(inv.invoiceDate)}'
                            '${inv.dueDate != null ? "  •  Due ${widget.formatDate(inv.dueDate)}" : ""}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isOpen
                              ? Colors.red.shade300
                              : Colors.green.shade300),
                    ),
                    child: Text(
                      isOpen ? 'OPEN' : 'PAID',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isOpen
                              ? Colors.red.shade700
                              : Colors.green.shade700),
                    ),
                  ),
                ],
              ),
            ),
            // Totals row
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _summaryCell('Total',
                      '\$${(inv.amount ?? 0).toStringAsFixed(2)}', Colors.black87),
                  _divider(),
                  _summaryCell('Paid',
                      '\$${(inv.paid ?? 0).toStringAsFixed(2)}', Colors.green.shade700),
                  _divider(),
                  _summaryCell('Balance',
                      '\$${(inv.due ?? 0).toStringAsFixed(2)}',
                      (inv.due ?? 0) > 0 ? Colors.red.shade700 : Colors.grey),
                ],
              ),
            ),
            // Items header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              color: CommonCustomColor.mandelPrimaryColor.withOpacity(0.08),
              child: const Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Text('Item',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey))),
                  SizedBox(
                      width: 50,
                      child: Text('Qty',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey))),
                  SizedBox(
                      width: 70,
                      child: Text('Price',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey))),
                  SizedBox(
                      width: 80,
                      child: Text('Total',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey))),
                ],
              ),
            ),
            // Items list
            Expanded(
              child: FutureBuilder<List<InvoiceLineItemDto>>(
                future: _itemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Center(
                        child: Text('No line items found.',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 14)));
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 20, endIndent: 20),
                    itemBuilder: (context, index) =>
                        _buildItemRow(items[index]),
                  );
                },
              ),
            ),
          ],
        );
  }

  Widget _buildItemRow(InvoiceLineItemDto item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name ?? '',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                if (item.code != null)
                  Text('#${item.code}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              item.qty % 1 == 0
                  ? item.qty.toInt().toString()
                  : item.qty.toStringAsFixed(1),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text('\$${item.price.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13)),
          ),
          SizedBox(
            width: 80,
            child: Text('\$${item.total.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _summaryCell(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: valueColor)),
      ],
    );
  }

  Widget _divider() {
    return Container(
        width: 1, height: 30, color: Colors.grey.shade300);
  }
}

class InvoiceDetailScreen extends StatelessWidget {
  final InvoiceDto invoice;
  final InvoiceService invoiceService;
  final String Function(String?) formatDate;

  const InvoiceDetailScreen({
    super.key,
    required this.invoice,
    required this.invoiceService,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #${invoice.number}'),
      ),
      body: _InvoiceDetailSheet(
        invoice: invoice,
        invoiceService: invoiceService,
        formatDate: formatDate,
      ),
    );
  }
}
