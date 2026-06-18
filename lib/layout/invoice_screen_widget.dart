import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/model/invoice_dto.dart';
import 'package:mandel_mobile_app/model/invoice_line_item_dto.dart';
import 'package:mandel_mobile_app/model/invoice_search_result_dto.dart';
import 'package:mandel_mobile_app/model/media_dto.dart';
import 'package:mandel_mobile_app/service/invoice_service.dart';
import 'package:mandel_mobile_app/utility/auth_support_utility.dart';
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
    with MessageUtility, CommonUtility, AuthSupportUtility {
  final _invoiceService = InvoiceService();
  final _scrollController = ScrollController();
  bool _hasMore = true;
  List<InvoiceDto> _invoiceList = [];
  late Future<void> _invoiceData;
  Map<String, dynamic> filters = <String, dynamic>{'page': 0, 'pageSize': 100};
  final _searchFieldController = TextEditingController();
  bool _hasFilterData = true;

  Future<void> _loadInvoices() async {
    try {
      Response response = await _invoiceService.getInvoices(filters);
      if (response.statusCode == 200) {
        final results = InvoiceSearchResultDto.fromJson(response.data);
        _invoiceList.addAll(results.results!);
        _hasMore = results.meta!.totalCount! > _invoiceList.length;
      }
    } catch (e) {
      debugPrint('Invoice load error: $e');
      rethrow;
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

  Future<void> _downloadPdf(int arhId) async {
    final token = await getTokenFromSession();
    final url = '${CommonConstants.mandelBaseUrl}/invoice/$arhId/pdf?token=${Uri.encodeComponent(token)}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
      'Invoices v2',
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
                    if (snapshot.hasError) {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off_rounded, size: 52, color: Color(0xFF9AA3C2)),
                              const SizedBox(height: 14),
                              const Text('Unable to load invoices',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0D1135))),
                              const SizedBox(height: 6),
                              const Text('Check your connection and try again',
                                  style: TextStyle(fontSize: 13, color: Colors.grey)),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text('Retry'),
                                onPressed: () => setState(() {
                                  _invoiceList.clear();
                                  _invoiceData = _loadInvoices();
                                }),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
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
                if (invoice.arhId != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadPdf(invoice.arhId!),
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Download PDF',
                          style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
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

  String _ptypeLabel(String? ptype) {
    if (ptype == null || ptype.isEmpty) return 'Non-Tobacco';
    final p = ptype.toUpperCase().trim();
    const cigTypes = {'CIG', 'ECG'};
    const tobTypes = {'TOB', 'TOBACCO ACCESSORIES', 'WRAPS/PAPERS/CONES', 'KRATOM', 'THCA', 'ADULT PILLS'};
    if (cigTypes.contains(p)) return 'Cigs';
    if (tobTypes.contains(p)) return 'Tobacco';
    return 'Non-Tobacco';
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;
    final isOpen = inv.isOpen ?? (inv.due != null && inv.due! > 0);
    return Column(
      children: [
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
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(inv, isOpen),
                const SizedBox(height: 16),
                FutureBuilder<List<InvoiceLineItemDto>>(
                  future: _itemsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'Error loading items: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text('No line items found.',
                              style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildItemsTable(items),
                        const SizedBox(height: 16),
                        _buildSummary(items, inv),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(InvoiceDto inv, bool isOpen) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDE3ED)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('MANDEL WHOLESALE',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A3A5C),
                      letterSpacing: 0.5)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOpen ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: isOpen
                          ? Colors.red.shade300
                          : Colors.green.shade300),
                ),
                child: Text(
                  isOpen ? 'OPEN' : 'PAID',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isOpen
                          ? Colors.red.shade700
                          : Colors.green.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('INVOICE',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1)),
                    Text('#${inv.number ?? ''}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A3A5C))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (inv.invoiceDate != null) ...[
                    const Text('Date',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(widget.formatDate(inv.invoiceDate),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                  if (inv.dueDate != null) ...[
                    const SizedBox(height: 4),
                    const Text('Due',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(widget.formatDate(inv.dueDate),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _amountChip('Invoice Total', inv.amount),
              _amountChip('Paid', inv.paid, color: Colors.green.shade700),
              _amountChip('Balance Due', inv.due,
                  color: (inv.due ?? 0) > 0
                      ? Colors.red.shade700
                      : Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountChip(String label, double? value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text('\$${(value ?? 0).toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color ?? Colors.black87)),
      ],
    );
  }

  Widget _buildItemsTable(List<InvoiceLineItemDto> items) {
    const hStyle = TextStyle(
        fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white);
    const cStyle = TextStyle(fontSize: 11);
    const dStyle = TextStyle(fontSize: 11, color: Colors.grey);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: const Color(0xFF1A3A5C),
                child: Row(children: [
                  _tc('#', 28, style: hStyle),
                  _tc('Code', 52, style: hStyle),
                  _tc('Description', 180, style: hStyle),
                  _tc('UPC', 98, style: hStyle),
                  _tc('Qty', 38, style: hStyle, align: TextAlign.center),
                  _tc('Price', 62, style: hStyle, align: TextAlign.right),
                  _tc('Ext', 68, style: hStyle, align: TextAlign.right),
                ]),
              ),
              ...items.asMap().entries.map((e) {
                final idx = e.key;
                final item = e.value;
                return Container(
                  color: idx.isOdd
                      ? const Color(0xFFF7F9FC)
                      : Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _tc('${item.rowNum ?? idx + 1}', 28, style: dStyle),
                      _tc(item.code ?? '', 52, style: dStyle),
                      _tc(item.name ?? '', 180, style: cStyle),
                      _tc(item.upc ?? '', 98, style: dStyle),
                      _tc(
                        item.qty % 1 == 0
                            ? item.qty.toInt().toString()
                            : item.qty.toStringAsFixed(1),
                        38,
                        style: cStyle,
                        align: TextAlign.center,
                      ),
                      _tc('\$${item.price.toStringAsFixed(2)}', 62,
                          style: cStyle, align: TextAlign.right),
                      _tc('\$${item.total.toStringAsFixed(2)}', 68,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600),
                          align: TextAlign.right),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tc(String text, double width,
      {TextStyle? style, TextAlign? align}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
        child: Text(text,
            style: style,
            textAlign: align,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _buildSummary(List<InvoiceLineItemDto> items, InvoiceDto inv) {
    final Map<String, double> qtyByType = {'Cigs': 0, 'Tobacco': 0, 'Non-Tobacco': 0};
    for (final item in items) {
      final key = _ptypeLabel(item.ptype);
      qtyByType[key] = (qtyByType[key] ?? 0) + item.qty;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FC),
            border: Border.all(color: const Color(0xFFDDE3ED)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SUMMARY BY TYPE',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                      letterSpacing: 1)),
              const SizedBox(height: 8),
              ...['Cigs', 'Tobacco', 'Non-Tobacco'].map((label) {
                final qty = qtyByType[label] ?? 0;
                final qtyStr = qty % 1 == 0
                    ? qty.toInt().toString()
                    : qty.toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 12)),
                      Text(qtyStr,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A3A5C),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${items.length} line items',
                  style: const TextStyle(
                      fontSize: 13, color: Colors.white70)),
              Text('\$${(inv.amount ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypeTotals {
  double qty = 0;
  double total = 0;
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
