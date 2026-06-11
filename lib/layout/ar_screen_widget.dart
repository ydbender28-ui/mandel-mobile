import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/invoice_screen_widget.dart';
import 'package:mandel_mobile_app/model/invoice_dto.dart';
import 'package:mandel_mobile_app/model/ledger_row_dto.dart';
import 'package:mandel_mobile_app/service/ar_service.dart';
import 'package:mandel_mobile_app/service/invoice_service.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:shimmer/shimmer.dart';

class ArScreenWidget extends StatefulWidget {
  const ArScreenWidget({super.key});

  @override
  State<ArScreenWidget> createState() => _ArScreenWidgetState();
}

class _ArScreenWidgetState extends State<ArScreenWidget> {
  final _arService = ArService();
  final _invoiceService = InvoiceService();
  late Future<void> _loadFuture;
  List<LedgerRowDto> _rows = [];
  double _balance = 0;
  String _filterType = '';

  final List<String> _filterLabels = ['All', 'Invoices', 'Payments', 'Credits'];
  final List<String> _filterValues = ['', 'invoice', 'payment', 'credit'];

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<void> _load() async {
    final res = await _arService.getLedger();
    if (res.statusCode == 200) {
      final data = res.data as Map<String, dynamic>;
      final rawRows = (data['rows'] as List?)
              ?.map((r) => LedgerRowDto.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [];
      _rows = rawRows;
      _balance = rawRows.isNotEmpty ? rawRows.first.runningBalance : 0;
    }
  }

  Future<void> _reload() async {
    final future = _load();
    setState(() {
      _rows = [];
      _balance = 0;
      _loadFuture = future;
    });
    await future;
    setState(() {});
  }

  List<LedgerRowDto> get _filtered {
    if (_filterType.isEmpty) return _rows;
    return _rows.where((r) {
      if (_filterType == 'invoice') return r.isInvoice;
      if (_filterType == 'payment') return r.isPayment;
      if (_filterType == 'credit') return r.isCredit;
      return true;
    }).toList();
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final datePart = raw.split('T').first;
    final parts = datePart.split('-');
    if (parts.length != 3) return datePart;
    return '${parts[1]}/${parts[2]}/${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Image.asset('assets/images/mandel_angle_left.png',
              width: 25, height: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Account (AR)', style: TextStyle(fontSize: 24)),
      ),
      body: Column(
        children: [
          _buildBalanceCard(),
          _buildFilterRow(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return FutureBuilder(
      future: _loadFuture,
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: CommonCustomColor.mandelPrimaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Outstanding Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  SizedBox(height: 2),
                  Text('Current AR',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
              snapshot.connectionState != ConnectionState.done
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(
                      '\$${_balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: List.generate(_filterLabels.length, (i) {
          final selected = _filterType == _filterValues[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_filterLabels[i],
                  style: TextStyle(
                      fontSize: 13,
                      color: selected ? CommonCustomColor.mandelPrimaryColor : null)),
              selected: selected,
              onSelected: (_) =>
                  setState(() => _filterType = _filterValues[i]),
              selectedColor:
                  CommonCustomColor.mandelPrimaryColor.withOpacity(0.15),
              checkmarkColor: CommonCustomColor.mandelPrimaryColor,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildList() {
    return FutureBuilder(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: _buildShimmer(),
          );
        }
        final rows = _filtered;
        if (rows.isEmpty) {
          return const Center(
            child: Text('No transactions found.',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          );
        }
        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) => _buildRow(rows[index]),
          ),
        );
      },
    );
  }

  Widget _buildRow(LedgerRowDto row) {
    final date = _formatDate(row.txDate);
    final isPayment = row.isPayment;
    final isCredit = row.isCredit;

    Color iconBg;
    Color iconColor;
    IconData icon;
    Color amountColor;
    String amountPrefix;

    if (isPayment) {
      iconBg = Colors.green.shade50;
      iconColor = Colors.green.shade700;
      icon = Icons.payments_outlined;
      amountColor = Colors.green.shade700;
      amountPrefix = '-';
    } else if (isCredit) {
      iconBg = Colors.orange.shade50;
      iconColor = Colors.orange.shade700;
      icon = Icons.undo_outlined;
      amountColor = Colors.orange.shade700;
      amountPrefix = '-';
    } else {
      iconBg = Colors.blue.shade50;
      iconColor = Colors.blue.shade700;
      icon = Icons.receipt_outlined;
      amountColor = Colors.black87;
      amountPrefix = '';
    }

    String subtitle = date;
    if (isPayment) {
      final method = row.payMethod ?? '';
      if (row.checkNum != null && row.checkNum!.isNotEmpty) {
        subtitle += '  •  $method #${row.checkNum}';
      } else if (method.isNotEmpty) {
        subtitle += '  •  $method';
      }
      if (row.isOpen != null) {
        subtitle += row.isOpen! ? '  •  Unapplied' : '  •  Applied';
      }
    } else if (isCredit) {
      if (row.invoice != null) subtitle += '  •  - #${row.invoice}';
      if (row.isOpen != null) {
        subtitle += row.isOpen! ? '  •  Available' : '  •  Applied';
      }
    } else {
      if (row.invoice != null) subtitle += '  •  Inv #${row.invoice}';
      if (row.isPDC && row.postDate != null) {
        subtitle += '  •  Post Date: ${_formatDate(row.postDate)}';
      }
    }

    return ListTile(
      onTap: row.isInvoice && row.id != null
          ? () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => InvoiceDetailScreen(
                  invoice: InvoiceDto(
                    arhId: row.id,
                    number: row.invoice,
                    amount: row.amount,
                    invoiceDate: row.txDate,
                    isOpen: true,
                    status: 'OPEN',
                  ),
                  invoiceService: _invoiceService,
                  formatDate: _formatDate,
                ),
              ))
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(row.txType ?? '',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          Text(
            '$amountPrefix\$${row.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: amountColor),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(subtitle,
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Text(
            'Bal: \$${row.runningBalance.toStringAsFixed(2)}',
            style:
                TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (_, __) => ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
        ),
        title: Container(
            height: 14, width: 200, color: Colors.white),
        subtitle: Container(
            margin: const EdgeInsets.only(top: 6),
            height: 12,
            width: 140,
            color: Colors.white),
      ),
    );
  }
}
