import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/layout/order_line_item_widger.dart';

class OrderScreenWidget extends StatefulWidget {
  final bool isFromHomePage;
  const OrderScreenWidget({required this.isFromHomePage, super.key});
  @override
  State<OrderScreenWidget> createState() => _OrderScreenWidgetState();
}

class _OrderScreenWidgetState extends State<OrderScreenWidget>
    with SingleTickerProviderStateMixin {

  late final TabController _tab;

  static const _h1     = Color(0xFF0C0F1E);
  static const _h2     = Color(0xFF1B2860);
  static const _indigo = Color(0xFF4F46E5);

  static const _tabs = ['All', 'Submitted', 'Completed', 'Draft'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      backgroundColor: const Color(0xFFEEF0FA),
      body: Column(children: [
        _header(),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: const [
              OrderLineItemWidget(status: 'ALL'),
              OrderLineItemWidget(status: 'PENDING'),
              OrderLineItemWidget(status: 'COMPLETE'),
              OrderLineItemWidget(status: 'DRAFT'),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _header() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_h1, _h2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        Positioned(right: -30, top: -30,
          child: Container(width: 130, height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _indigo.withOpacity(0.1)))),
        SafeArea(
          bottom: false,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                if (!widget.isFromHomePage)
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ),
                const Expanded(
                  child: Text('My Orders',
                    style: TextStyle(color: Colors.white, fontSize: 22,
                        fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                ),
                if (widget.isFromHomePage)
                  GestureDetector(
                    onTap: () => Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(
                          builder: (_) => const MainScreenWidget(defaultIndex: 0)),
                      (r) => false),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: Colors.white),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 16),
            // custom tab bar — scrollable so it never overflows on narrow phones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12)),
                child: TabBar(
                  controller: _tab,
                  isScrollable: true,
                  tabAlignment: TabAlignment.fill,
                  indicator: BoxDecoration(
                    color: _indigo,
                    borderRadius: BorderRadius.circular(10)),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.5),
                  labelStyle: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w500),
                  labelPadding: EdgeInsets.zero,
                  tabs: _tabs.map((t) => Tab(
                    height: 38,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(t, textAlign: TextAlign.center),
                    ),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ]),
        ),
      ]),
    );
  }
}
