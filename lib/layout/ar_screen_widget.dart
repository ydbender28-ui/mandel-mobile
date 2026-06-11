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

  static const _bg = Color(0xFFF4F6FA);

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
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: CommonCustomColor.mandelPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Account (AR)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildBalanceCard(),
          _buildFilterTabs(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return FutureBuilder(
      future: _loadFuture,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CommonCustomColor.mandelPrimaryColor,
                CommonCustomColor.mandelPrimaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Outstanding Balance',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                      letterSpacing: 0.5)),
              const SizedBox(height: 6),
              loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : Text(
                      '\$${_balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: CommonCustomColor.mandelPrimaryColor.withOpacity(0.04),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: List.generate(_filterLabels.length, (i) {
          final selected = _filterType == _filterValues[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _filterType = _filterValues[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? CommonCustomColor.mandelPrimaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                              color: CommonCustomColor.mandelPrimaryColor
                                  .withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ]
                      : [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1))
                        ],
                ),
                child: Text(
                  _filterLabels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : Colors.grey.shade600,
                  ),
                ),
              ),
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
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: _buildShimmer(),
          );
        }
        final rows = _filtered;
        if (rows.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('No transactions found',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade400)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _reload,
          color: CommonCustomColor.mandelPrimaryColor,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: rows.length,
            itemBuilder: (context, index) => _buildCard(rows[index]),
          ),
        );
      },
    );
  }

  Widget _buildCard(LedgerRowDto row) {
    final isPayment = row.isPayment;
    final isCredit = row.isCredit;

    // Colors & icons
    Color accent;
    Color iconBg;
    IconData icon;

    if (isPayment) {
      accent = const Color(0xFF22C55E);
      iconBg = const Color(0xFFDCFCE7);
      icon = Icons.payments_rounded;
    } else if (isCredit) {
      accent = const Color(0xFFF97316);
      iconBg = const Color(0xFFFFF0E6);
      icon = Icons.undo_rounded;
    } else if (row.isPDC) {
      accent = const Color(0xFF8B5CF6);
      iconBg = const Color(0xFFF3EDFF);
      icon = Icons.event_note_rounded;
    } else {
      accent = const Color(0xFF3B82F6);
      iconBg = const Color(0xFFEFF6FF);
      icon = Icons.receipt_rounded;
    }

    final amountPositive = row.amount >= 0;
    final amountColor = isPayment || isCredit
        ? const Color(0xFF22C55E)
        : amountPositive
            ? const Color(0xFF1E293B)
            : const Color(0xFF22C55E);
    final amountPrefix = (isPayment || isCredit) ? '-' : (amountPositive ? '' : '-');

    // Detail chips
    final chips = <_ChipData>[];

    if (isPayment) {
      final method = row.payMethod ?? '';
      final checkNum = (row.checkNum != null && row.checkNum!.isNotEmpty) ? row.checkNum : null;
      final isPostDated = row.postDate != null;

      if (isPostDated) {
        chips.add(_ChipData(
            'Post-Dated  \$${row.amount.abs().toStringAsFixed(2)}',
            const Color(0xFF8B5CF6),
            const Color(0xFFF3EDFF)));
        chips.add(_ChipData(
            'Deposit: ${_formatDate(row.postDate)}',
            const Color(0xFF6D28D9),
            const Color(0xFFEDE9FE)));
      } else if (checkNum != null) {
        chips.add(_ChipData('$method #$checkNum', const Color(0xFF3B82F6), const Color(0xFFEFF6FF)));
      } else if (method.isNotEmpty) {
        chips.add(_ChipData(method, const Color(0xFF3B82F6), const Color(0xFFEFF6FF)));
      }

      if (row.isOpen != null) {
        if (row.isOpen!) {
          chips.add(_ChipData('Unapplied', const Color(0xFFF97316), const Color(0xFFFFF0E6)));
        } else {
          chips.add(_ChipData('Applied', const Color(0xFF22C55E), const Color(0xFFDCFCE7)));
        }
      }
    } else if (isCredit) {
      if (row.invoice != null) {
        chips.add(_ChipData('- #${row.invoice}', const Color(0xFFF97316), const Color(0xFFFFF0E6)));
      }
      if (row.isOpen != null) {
        if (row.isOpen!) {
          chips.add(_ChipData('Available', const Color(0xFF3B82F6), const Color(0xFFEFF6FF)));
        } else {
          chips.add(_ChipData('Applied', const Color(0xFF22C55E), const Color(0xFFDCFCE7)));
        }
      }
    } else {
      if (row.invoice != null) {
        chips.add(_ChipData('Inv #${row.invoice}', const Color(0xFF3B82F6), const Color(0xFFEFF6FF)));
      }
      if (row.isPDC && row.postDate != null) {
        chips.add(_ChipData(
            'Post Date: ${_formatDate(row.postDate)}',
            const Color(0xFF8B5CF6),
            const Color(0xFFF3EDFF)));
      }
    }

    return GestureDetector(
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            row.txType ?? '',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$amountPrefix\$${row.amount.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: amountColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatDate(row.txDate),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ),
                        Text(
                          'Bal: \$${row.runningBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    if (chips.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: chips
                            .map((c) => _buildChip(c.label, c.textColor, c.bgColor))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 8,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 120, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 11, width: 80, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 20, width: 60, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipData {
  final String label;
  final Color textColor;
  final Color bgColor;
  const _ChipData(this.label, this.textColor, this.bgColor);
}
