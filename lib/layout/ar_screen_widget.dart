import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandel_mobile_app/layout/invoice_screen_widget.dart';
import 'package:mandel_mobile_app/model/invoice_dto.dart';
import 'package:mandel_mobile_app/model/ledger_row_dto.dart';
import 'package:mandel_mobile_app/service/ar_service.dart';
import 'package:mandel_mobile_app/service/invoice_service.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:shimmer/shimmer.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
class _C {
  static const bg         = Color(0xFFF1F4F8);
  static const surface    = Colors.white;
  static const textHi     = Color(0xFF0D1B2A);
  static const textMid    = Color(0xFF4A5568);
  static const textLo     = Color(0xFF9AA5B4);

  static const invoice    = Color(0xFF2563EB);
  static const invoiceBg  = Color(0xFFEFF6FF);
  static const pay        = Color(0xFF16A34A);
  static const payBg      = Color(0xFFF0FDF4);
  static const credit     = Color(0xFFEA580C);
  static const creditBg   = Color(0xFFFFF7ED);
  static const pdc        = Color(0xFF7C3AED);
  static const pdcBg      = Color(0xFFF5F3FF);
  static const warning    = Color(0xFFD97706);
  static const warningBg  = Color(0xFFFFFBEB);
}

class ArScreenWidget extends StatefulWidget {
  const ArScreenWidget({super.key});

  @override
  State<ArScreenWidget> createState() => _ArScreenWidgetState();
}

class _ArScreenWidgetState extends State<ArScreenWidget>
    with SingleTickerProviderStateMixin {
  final _arService     = ArService();
  final _invoiceService = InvoiceService();
  late Future<void> _loadFuture;
  List<LedgerRowDto> _rows   = [];
  double             _balance = 0;
  String             _filter  = '';
  late TabController  _tab;

  static const _labels = ['All', 'Invoices', 'Payments', 'Credits'];
  static const _values = ['',    'invoice',  'payment',  'credit' ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _labels.length, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) {
        setState(() => _filter = _values[_tab.index]);
      }
    });
    _loadFuture = _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final res = await _arService.getLedger();
    if (res.statusCode == 200) {
      final data    = res.data as Map<String, dynamic>;
      final rawRows = (data['rows'] as List?)
              ?.map((r) => LedgerRowDto.fromJson(r as Map<String, dynamic>))
              .toList() ?? [];
      _rows    = rawRows;
      _balance = rawRows.isNotEmpty ? rawRows.first.runningBalance : 0;
    }
  }

  Future<void> _reload() async {
    final future = _load();
    setState(() { _rows = []; _balance = 0; _loadFuture = future; });
    await future;
    setState(() {});
  }

  List<LedgerRowDto> get _filtered => _filter.isEmpty ? _rows : _rows.where((r) {
    if (_filter == 'invoice') return r.isInvoice;
    if (_filter == 'payment') return r.isPayment;
    if (_filter == 'credit')  return r.isCredit;
    return true;
  }).toList();

  String _fmt(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final d = raw.split('T').first.split('-');
    return d.length == 3 ? '${d[1]}/${d[2]}/${d[0]}' : raw.split('T').first;
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      backgroundColor: _C.bg,
      body: Column(children: [
        _header(),
        _tabs(),
        Expanded(child: _list()),
      ]),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────
  Widget _header() {
    return FutureBuilder(
      future: _loadFuture,
      builder: (context, snap) {
        final loading = snap.connectionState != ConnectionState.done;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CommonCustomColor.mandelPrimaryColor,
                CommonCustomColor.mandelPrimaryColor[700]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(children: [
            // decorative circles
            Positioned(right: -40, top: -40,
              child: Container(width: 160, height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06)))),
            Positioned(right: 40, bottom: -20,
              child: Container(width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04)))),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // back + title row
                    Row(children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text('Account (AR)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2)),
                    ]),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Outstanding Balance',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2)),
                          const SizedBox(height: 6),
                          loading
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white))
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '\$${_balance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.5,
                                    height: 1.0),
                                )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  // ─── Tabs ────────────────────────────────────────────────────────────────────
  Widget _tabs() {
    return Container(
      color: _C.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: _C.bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tab,
          indicator: BoxDecoration(
            color: CommonCustomColor.mandelPrimaryColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(
              color: CommonCustomColor.mandelPrimaryColor.withOpacity(0.4),
              blurRadius: 8, offset: const Offset(0, 2))],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(3),
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: _C.textMid,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
    );
  }

  // ─── List ────────────────────────────────────────────────────────────────────
  Widget _list() {
    return FutureBuilder(
      future: _loadFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Shimmer.fromColors(
            baseColor: const Color(0xFFE8ECF0),
            highlightColor: const Color(0xFFF8FAFB),
            child: _shimmer());
        }
        final rows = _filtered;
        if (rows.isEmpty) return _empty();
        return RefreshIndicator(
          onRefresh: _reload,
          color: CommonCustomColor.mandelPrimaryColor,
          strokeWidth: 2.5,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: rows.length,
            itemBuilder: (_, i) => _card(rows[i]),
          ),
        );
      },
    );
  }

  // ─── Transaction card ────────────────────────────────────────────────────────
  Widget _card(LedgerRowDto row) {
    final isPayment = row.isPayment;
    final isCredit  = row.isCredit;
    final isPDCInv  = !isPayment && row.isPDC;

    Color accent, accentBg;
    IconData icon;

    if (isPayment) {
      accent = _C.pay; accentBg = _C.payBg; icon = Icons.south_west_rounded;
    } else if (isCredit) {
      accent = _C.credit; accentBg = _C.creditBg; icon = Icons.undo_rounded;
    } else if (isPDCInv) {
      accent = _C.pdc; accentBg = _C.pdcBg; icon = Icons.event_available_rounded;
    } else {
      accent = _C.invoice; accentBg = _C.invoiceBg; icon = Icons.north_east_rounded;
    }

    final amtAbs    = row.amount.abs();
    final amtStr    = '\$${amtAbs.toStringAsFixed(2)}';
    final amtColor  = (isPayment || isCredit) ? _C.pay : _C.textHi;
    final amtPrefix = (isPayment || isCredit) ? '−' : '+';

    // build chip list
    final chips = <Widget>[];
    _payChips(row, chips);
    _invoiceChips(row, chips, isPayment, isCredit);

    final tappable = row.isInvoice && row.id != null;

    return GestureDetector(
      onTap: tappable ? () => _openInvoice(row) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.055),
              blurRadius: 12,
              offset: const Offset(0, 3)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // left accent bar
                Container(width: 4, color: accent),
                // content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // icon circle
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: accentBg,
                                borderRadius: BorderRadius.circular(12)),
                              child: Icon(icon, color: accent, size: 20)),
                            const SizedBox(width: 12),
                            // title + date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(row.txType ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _C.textHi)),
                                  const SizedBox(height: 2),
                                  Text(_fmt(row.txDate),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _C.textLo,
                                      fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // amount + balance
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$amtPrefix$amtStr',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: amtColor,
                                    letterSpacing: -0.3)),
                                const SizedBox(height: 2),
                                Text(
                                  'Bal \$${row.runningBalance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: _C.textLo,
                                    fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                        // chips
                        if (chips.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(spacing: 6, runSpacing: 5, children: chips),
                        ],
                        // tap hint
                        if (tappable) ...[
                          const SizedBox(height: 8),
                          Row(children: [
                            Text('View details',
                              style: TextStyle(
                                fontSize: 11,
                                color: accent,
                                fontWeight: FontWeight.w600)),
                            const SizedBox(width: 2),
                            Icon(Icons.chevron_right_rounded,
                              size: 14, color: accent),
                          ]),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _payChips(LedgerRowDto row, List<Widget> out) {
    if (!row.isPayment) return;
    final method   = row.payMethod ?? '';
    final checkNum = (row.checkNum != null && row.checkNum!.isNotEmpty) ? row.checkNum : null;
    final isPostDated = row.postDate != null;

    if (isPostDated) {
      if (checkNum != null) {
        out.add(_chip('$method #$checkNum', _C.pdc, _C.pdcBg));
      }
      out.add(_chip(
        'Post-Dated  \$${row.amount.abs().toStringAsFixed(2)}',
        _C.pdc, _C.pdcBg,
        icon: Icons.event_note_rounded));
      out.add(_chip(
        'Deposit ${_fmt(row.postDate)}',
        _C.pdc, _C.pdcBg,
        icon: Icons.calendar_today_rounded));
    } else if (checkNum != null) {
      out.add(_chip('$method #$checkNum', _C.invoice, _C.invoiceBg));
    } else if (method.isNotEmpty) {
      out.add(_chip(method, _C.invoice, _C.invoiceBg));
    }

    if (row.isOpen != null) {
      if (row.isOpen!) {
        out.add(_chip('Unapplied', _C.warning, _C.warningBg,
            icon: Icons.hourglass_top_rounded));
      } else {
        out.add(_chip('Applied', _C.pay, _C.payBg,
            icon: Icons.check_circle_outline_rounded));
      }
    }
  }

  void _invoiceChips(LedgerRowDto row, List<Widget> out,
      bool isPayment, bool isCredit) {
    if (isPayment) return;
    if (isCredit) {
      if (row.invoice != null) {
        out.add(_chip('Cr #${row.invoice}', _C.credit, _C.creditBg));
      }
      if (row.isOpen != null) {
        if (row.isOpen!) {
          out.add(_chip('Available', _C.invoice, _C.invoiceBg,
              icon: Icons.wallet_rounded));
        } else {
          out.add(_chip('Applied', _C.pay, _C.payBg,
              icon: Icons.check_circle_outline_rounded));
        }
      }
    } else {
      if (row.invoice != null) {
        out.add(_chip('Inv #${row.invoice}', _C.invoice, _C.invoiceBg));
      }
      if (row.isPDC && row.postDate != null) {
        out.add(_chip(
          'Post Date ${_fmt(row.postDate)}',
          _C.pdc, _C.pdcBg,
          icon: Icons.calendar_today_rounded));
      }
    }
  }

  Widget _chip(String label, Color fg, Color bg, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.fromLTRB(icon != null ? 6 : 8, 4, 9, 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.18), width: 1)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
        ],
        Text(label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: fg,
            letterSpacing: 0.1)),
      ]),
    );
  }

  void _openInvoice(LedgerRowDto row) {
    Navigator.of(context).push(MaterialPageRoute(
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
        formatDate: _fmt,
      ),
    ));
  }

  // ─── Empty state ─────────────────────────────────────────────────────────────
  Widget _empty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: _C.invoiceBg,
            borderRadius: BorderRadius.circular(24)),
          child: const Icon(Icons.receipt_long_outlined,
              size: 36, color: _C.invoice)),
        const SizedBox(height: 16),
        const Text('No transactions',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _C.textHi)),
        const SizedBox(height: 6),
        const Text('Nothing to show for this filter.',
          style: TextStyle(fontSize: 13, color: _C.textLo)),
      ]),
    );
  }

  // ─── Shimmer skeleton ────────────────────────────────────────────────────────
  Widget _shimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: 7,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 82,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(children: [
            Container(width: 4, color: const Color(0xFFE0E0E0)),
            const SizedBox(width: 14),
            Container(width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12))),
            const SizedBox(width: 12),
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 13, width: 110, color: const Color(0xFFE0E0E0)),
                const SizedBox(height: 6),
                Container(height: 10, width: 70, color: const Color(0xFFE0E0E0)),
              ],
            )),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(height: 14, width: 60, color: const Color(0xFFE0E0E0)),
                  const SizedBox(height: 5),
                  Container(height: 10, width: 40, color: const Color(0xFFE0E0E0)),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
