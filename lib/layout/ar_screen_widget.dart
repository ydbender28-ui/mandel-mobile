import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandel_mobile_app/layout/invoice_screen_widget.dart';
import 'package:mandel_mobile_app/model/invoice_dto.dart';
import 'package:mandel_mobile_app/model/ledger_row_dto.dart';
import 'package:mandel_mobile_app/service/ar_service.dart';
import 'package:mandel_mobile_app/service/invoice_service.dart';
import 'package:shimmer/shimmer.dart';

// ─── Design tokens ─────────────────────────────────────────────────────────
class _T {
  // header gradient stops
  static const h1 = Color(0xFF0C0F1E);
  static const h2 = Color(0xFF111833);
  static const h3 = Color(0xFF1B2860);

  // page & surface
  static const bg      = Color(0xFFEEF0FA);
  static const surface = Colors.white;

  // text
  static const textHi  = Color(0xFF0D1135);
  static const textMid = Color(0xFF4A5272);
  static const textLo  = Color(0xFF9AA3C2);

  // transaction accents
  static const invoice   = Color(0xFF4F46E5);
  static const invoiceBg = Color(0xFFF0EEFF);

  static const payment   = Color(0xFF0EA5E9);
  static const paymentBg = Color(0xFFE0F5FE);

  static const credit    = Color(0xFFF59E0B);
  static const creditBg  = Color(0xFFFFF8E7);

  static const pdc       = Color(0xFFEC4899);
  static const pdcBg     = Color(0xFFFFF0F6);

  // status
  static const applied    = Color(0xFF10B981);
  static const appliedBg  = Color(0xFFECFDF5);
  static const unapplied  = Color(0xFFF97316);
  static const unapplBg   = Color(0xFFFFF4EC);
  static const available  = Color(0xFF6366F1);
  static const availBg    = Color(0xFFF0EEFF);
}

// ─── Curved header clipper ────────────────────────────────────────────────
class _ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final p = Path();
    p.lineTo(0, s.height - 28);
    p.quadraticBezierTo(s.width / 2, s.height + 14, s.width, s.height - 28);
    p.lineTo(s.width, 0);
    p.close();
    return p;
  }
  @override bool shouldReclip(_) => false;
}

// ─── Widget ───────────────────────────────────────────────────────────────
class ArScreenWidget extends StatefulWidget {
  const ArScreenWidget({super.key});
  @override
  State<ArScreenWidget> createState() => _ArScreenWidgetState();
}

class _ArScreenWidgetState extends State<ArScreenWidget>
    with SingleTickerProviderStateMixin {
  final _arSvc  = ArService();
  final _invSvc = InvoiceService();
  late Future<void> _future;
  List<LedgerRowDto> _rows    = [];
  double             _balance = 0;
  late TabController _tab;

  static const _labels = ['All', 'Invoices', 'Payments', 'Credits'];
  static const _values = ['',    'invoice',  'payment',  'credit' ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _labels.length, vsync: this)
      ..addListener(() {
        if (!_tab.indexIsChanging) setState(() {});
      });
    _future = _load();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _load() async {
    final res = await _arSvc.getLedger();
    if (res.statusCode == 200) {
      final data = res.data as Map<String, dynamic>;
      final raw  = (data['rows'] as List?)
          ?.map((r) => LedgerRowDto.fromJson(r as Map<String, dynamic>))
          .toList() ?? [];
      _rows    = raw;
      _balance = raw.isNotEmpty ? raw.first.runningBalance : 0;
    }
  }

  Future<void> _reload() async {
    final f = _load();
    setState(() { _rows = []; _balance = 0; _future = f; });
    await f;
    setState(() {});
  }

  String get _filter => _values[_tab.index];

  List<LedgerRowDto> get _filtered => _filter.isEmpty ? _rows
      : _rows.where((r) {
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

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      backgroundColor: _T.bg,
      body: Column(children: [
        _header(),
        _tabBar(),
        Expanded(child: _list()),
      ]),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _header() {
    return FutureBuilder(
      future: _future,
      builder: (ctx, snap) {
        final loading = snap.connectionState != ConnectionState.done;
        return ClipPath(
          clipper: _ArcClipper(),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_T.h1, _T.h2, _T.h3],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(children: [
              // decorative orbs
              Positioned(right: -50, top: -50,
                child: _orb(200, const Color(0xFF4F46E5), 0.09)),
              Positioned(left: -30, bottom: 30,
                child: _orb(120, const Color(0xFF0EA5E9), 0.07)),
              Positioned(right: 60, bottom: 20,
                child: _orb(70, const Color(0xFFEC4899), 0.07)),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 20, 44),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // back row
                      Row(children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white70, size: 19),
                          onPressed: () => Navigator.of(context).pop()),
                        const Text('Account (AR)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1)),
                      ]),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('OUTSTANDING BALANCE',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.45),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0)),
                            const SizedBox(height: 8),
                            loading
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white60))
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text('\$',
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600))),
                                    const SizedBox(width: 2),
                                    Text(
                                      _balance.abs().toStringAsFixed(2),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 44,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -2,
                                        height: 1.0)),
                                  ],
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _orb(double size, Color color, double opacity) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(opacity)));

  // ── Tab bar ──────────────────────────────────────────────────────────────
  Widget _tabBar() {
    return Container(
      color: _T.bg,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDDE0F0), width: 1),
        ),
        child: TabBar(
          controller: _tab,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF6D63F0)]),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.4),
              blurRadius: 8, offset: const Offset(0, 2))],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(3),
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: _T.textMid,
          labelStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500),
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
    );
  }

  // ── List ─────────────────────────────────────────────────────────────────
  Widget _list() {
    return FutureBuilder(
      future: _future,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Shimmer.fromColors(
            baseColor: const Color(0xFFE2E5F0),
            highlightColor: const Color(0xFFF8F9FF),
            child: _shimmer());
        }
        final rows = _filtered;
        if (rows.isEmpty) return _empty();
        return RefreshIndicator(
          onRefresh: _reload,
          color: _T.invoice,
          strokeWidth: 2.5,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            itemCount: rows.length,
            itemBuilder: (_, i) => _card(rows[i]),
          ),
        );
      },
    );
  }

  // ── Card ─────────────────────────────────────────────────────────────────
  Widget _card(LedgerRowDto row) {
    final isPay    = row.isPayment;
    final isCr     = row.isCredit;
    final isPDCInv = !isPay && row.isPDC;

    Color accent, accentBg;
    IconData icon;

    if (isPay) {
      accent = _T.payment; accentBg = _T.paymentBg;
      icon = Icons.south_west_rounded;
    } else if (isCr) {
      accent = _T.credit; accentBg = _T.creditBg;
      icon = Icons.undo_rounded;
    } else if (isPDCInv) {
      accent = _T.pdc; accentBg = _T.pdcBg;
      icon = Icons.event_available_rounded;
    } else {
      accent = _T.invoice; accentBg = _T.invoiceBg;
      icon = Icons.north_east_rounded;
    }

    final amtAbs   = row.amount.abs();
    final amtStr   = '\$${amtAbs.toStringAsFixed(2)}';
    final amtColor = (isPay || isCr) ? _T.payment : _T.textHi;
    final prefix   = (isPay || isCr) ? '−' : '+';

    final chips = <Widget>[];
    _buildChips(row, chips, isPay, isCr);

    final tappable = row.isInvoice && row.id != null;

    return GestureDetector(
      onTap: tappable ? () => _push(row) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D1135).withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4)),
            BoxShadow(
              color: accent.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // accent bar
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withOpacity(0.5)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                  ),
                ),
                // body
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // icon
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: accentBg,
                                borderRadius: BorderRadius.circular(11)),
                              child: Icon(icon, color: accent, size: 20)),
                            const SizedBox(width: 11),
                            // title + date
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(row.txType ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _T.textHi)),
                                const SizedBox(height: 2),
                                Text(_fmt(row.txDate),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _T.textLo)),
                              ],
                            )),
                            const SizedBox(width: 6),
                            // amount + balance
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$prefix$amtStr',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: amtColor,
                                    letterSpacing: -0.4)),
                                const SizedBox(height: 2),
                                Text('Bal \$${row.runningBalance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: _T.textLo,
                                    fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                        if (chips.isNotEmpty) ...[
                          const SizedBox(height: 9),
                          Wrap(spacing: 6, runSpacing: 5, children: chips),
                        ],
                        if (tappable) ...[
                          const SizedBox(height: 9),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Text('View details',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: accent)),
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

  void _buildChips(LedgerRowDto row, List<Widget> out,
      bool isPay, bool isCr) {
    if (isPay) {
      final method    = row.payMethod ?? '';
      final checkNum  = (row.checkNum != null && row.checkNum!.isNotEmpty)
          ? row.checkNum : null;
      final isPostDated = row.postDate != null;

      if (isPostDated) {
        if (checkNum != null) {
          out.add(_chip('$method #$checkNum', _T.invoice, _T.invoiceBg));
        }
        out.add(_chip(
          'Post-Dated  \$${row.amount.abs().toStringAsFixed(2)}',
          _T.pdc, _T.pdcBg,
          icon: Icons.event_note_rounded));
        out.add(_chip(
          'Deposit ${_fmt(row.postDate)}',
          _T.pdc, _T.pdcBg,
          icon: Icons.calendar_month_rounded));
      } else if (checkNum != null) {
        out.add(_chip('$method #$checkNum', _T.invoice, _T.invoiceBg));
      } else if (method.isNotEmpty) {
        out.add(_chip(method, _T.invoice, _T.invoiceBg));
      }

      if (row.isOpen != null) {
        out.add(row.isOpen!
          ? _chip('Unapplied', _T.unapplied, _T.unapplBg,
              icon: Icons.hourglass_top_rounded)
          : _chip('Applied', _T.applied, _T.appliedBg,
              icon: Icons.check_circle_outline_rounded));
      }
    } else if (isCr) {
      if (row.invoice != null) {
        out.add(_chip('Cr #${row.invoice}', _T.credit, _T.creditBg,
            icon: Icons.receipt_long_rounded));
      }
      if (row.isOpen != null) {
        out.add(row.isOpen!
          ? _chip('Available', _T.available, _T.availBg,
              icon: Icons.account_balance_wallet_outlined)
          : _chip('Applied', _T.applied, _T.appliedBg,
              icon: Icons.check_circle_outline_rounded));
      }
    } else {
      if (row.invoice != null) {
        out.add(_chip('Inv #${row.invoice}', _T.invoice, _T.invoiceBg,
            icon: Icons.receipt_rounded));
      }
      if (row.isPDC && row.postDate != null) {
        out.add(_chip(
          'Post Date ${_fmt(row.postDate)}',
          _T.pdc, _T.pdcBg,
          icon: Icons.calendar_month_rounded));
      }
    }
  }

  Widget _chip(String label, Color fg, Color bg, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.fromLTRB(icon != null ? 6 : 9, 4, 9, 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.2), width: 1)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
        ],
        Text(label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: fg,
            letterSpacing: 0.1)),
      ]),
    );
  }

  void _push(LedgerRowDto row) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => InvoiceDetailScreen(
        invoice: InvoiceDto(
          arhId: row.id, number: row.invoice, amount: row.amount,
          invoiceDate: row.txDate, isOpen: true, status: 'OPEN'),
        invoiceService: _invSvc,
        formatDate: _fmt)));
  }

  // ── Empty ────────────────────────────────────────────────────────────────
  Widget _empty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 68, height: 68,
        decoration: BoxDecoration(
          color: _T.invoiceBg,
          borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.receipt_long_outlined,
            size: 34, color: _T.invoice)),
      const SizedBox(height: 14),
      const Text('No transactions',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _T.textHi)),
      const SizedBox(height: 5),
      const Text('Nothing to show for this filter.',
        style: TextStyle(fontSize: 13, color: _T.textLo)),
    ]));

  // ── Shimmer ───────────────────────────────────────────────────────────────
  Widget _shimmer() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
    itemCount: 7,
    itemBuilder: (_, __) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(children: [
          Container(width: 4, color: const Color(0xFFE2E5F0)),
          const SizedBox(width: 13),
          Container(width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E5F0),
              borderRadius: BorderRadius.circular(11))),
          const SizedBox(width: 11),
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 13, width: 100, color: const Color(0xFFE2E5F0)),
              const SizedBox(height: 6),
              Container(height: 10, width: 65, color: const Color(0xFFE2E5F0)),
            ])),
          Padding(
            padding: const EdgeInsets.only(right: 13),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(height: 14, width: 55, color: const Color(0xFFE2E5F0)),
                const SizedBox(height: 5),
                Container(height: 10, width: 38, color: const Color(0xFFE2E5F0)),
              ])),
        ]))));
}
