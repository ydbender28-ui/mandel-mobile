import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandel_mobile_app/db/repository/order_master_repository.dart';
import 'package:mandel_mobile_app/db/repository/user_master_repository.dart';
import 'package:mandel_mobile_app/db/repository/order_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/multi_action_confirmation_widget.dart';
import 'package:mandel_mobile_app/layout/deal_swiper_widget.dart';
import 'package:mandel_mobile_app/layout/recent_orders_swiper_widget.dart';
import 'package:mandel_mobile_app/model/order_dto.dart';
import 'package:mandel_mobile_app/model/product_details_options.dart';
import 'package:mandel_mobile_app/model/product_search_arguments.dart';
import 'package:mandel_mobile_app/model/scanner_arguments.dart';
import 'package:mandel_mobile_app/model/user_dto.dart';
import 'package:mandel_mobile_app/service/order_service.dart';
import 'package:mandel_mobile_app/utility/barcode_scanner_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/message_utility.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});
  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget>
    with MessageUtility, WidgetsBindingObserver, CommonUtility, BarcodeScannerUtility {

  final OrderMasterRepository orderMasterRepo = OrderMasterRepository();
  final OrderRepository orderRepo             = OrderRepository();
  final UserMasterRepository userRepo         = UserMasterRepository();

  static const _h1     = Color(0xFF0C0F1E);
  static const _h2     = Color(0xFF1B2860);
  static const _indigo = Color(0xFF4F46E5);
  static const _bg     = Color(0xFFEEF0FA);
  static const _textHi = Color(0xFF0D1135);

  Future<String> _getCustomerName() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('mandel_portal_token') ?? '';
    if (token.isEmpty) return '';
    try {
      final parts      = token.split('.');
      if (parts.length < 2) return '';
      final normalized = base64Url.normalize(parts[1]);
      final decoded    = utf8.decode(base64Url.decode(normalized));
      final data       = json.decode(decoded) as Map<String, dynamic>;
      return data['customerName']?.toString() ?? '';
    } catch (_) { return ''; }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            _quickActions(context),
            _section('Deals'),
            SizedBox(
              height: 160,
              child: const DealSwiperWidget()),
            _section('Recent Orders'),
            SizedBox(
              height: 160,
              child: const RecentOrderSwiper()),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
          ],
        ),
      ),
    );
  }

  // ── dark gradient header ─────────────────────────────────────────────────

  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_h1, _h2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: FutureBuilder<String>(
            future: _getCustomerName(),
            builder: (ctx, snap) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                if ((snap.data ?? '').isNotEmpty)
                  Text(snap.data!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── quick action grid (2 × 2 responsive) ─────────────────────────────────

  Widget _quickActions(BuildContext context) {
    final actions = [
      _QA(icon: Icons.add_shopping_cart_rounded, label: 'New Order',
          color: _indigo, onTap: _handleNewOrder),
      _QA(icon: Icons.storefront_rounded,        label: 'Products',
          color: const Color(0xFF0EA5E9),
          onTap: () => Navigator.pushNamed(context, CommonConstants.searchScreenUrl,
              arguments: ProductSearchArguments(filters: {},
                  productDetailsOptions: ProductDetailsOptions(showAddToCart: true, showReturn: false)))),
      _QA(icon: Icons.receipt_long_rounded,       label: 'My Orders',
          color: const Color(0xFF10B981),
          onTap: () => Navigator.pushNamed(context, CommonConstants.categoryScreenWidget)),
      _QA(icon: Icons.grid_view_rounded,          label: 'Categories',
          color: const Color(0xFFF59E0B),
          onTap: () => Navigator.pushNamed(context, CommonConstants.categoryScreenWidget)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        children: actions.map((a) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _qaCard(a, context),
          ),
        )).toList(),
      ),
    );
  }

  Widget _qaCard(_QA a, BuildContext context) {
    return GestureDetector(
      onTap: a.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
            color: const Color(0xFF0D1135).withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: a.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
              child: Icon(a.icon, color: a.color, size: 20)),
            const SizedBox(height: 8),
            Text(a.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: _textHi),
              overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ── section header ────────────────────────────────────────────────────────

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(title,
        style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w800,
          color: _textHi, letterSpacing: -0.3)),
    );
  }

  // ── new order flow ────────────────────────────────────────────────────────

  void _handleNewOrder() async {
    final orderDetails = await orderMasterRepo.getLastUpdatedTimeStamp();
    if (orderDetails.isNotEmpty) {
      _confirmNewOrder();
    } else {
      _showAddProductSheet();
    }
  }

  void _confirmNewOrder() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      builder: (ctx) => MultiActionConfirmationWidget(
        title: 'Keep Going or Start Fresh?',
        description: "You've got items in your cart that aren't saved yet.",
        actions: [
          ConfirmationAction(
            text: 'Keep Going',
            onSelect: () { Navigator.pop(context); _showAddProductSheet(); }),
          ConfirmationAction(
            text: 'Start Fresh',
            onSelect: () async {
              Navigator.pop(context);
              showInProgressMessage(message: 'Saving your current order…', context: context);
              final userId     = await userRepo.getUserId();
              final total      = await orderRepo.getPeoGrandTotal();
              final orderItems = await orderRepo.getOrderItemList();
              final dto = OrderDto(
                user: UserDto(id: userId),
                orderState: 'DRAFT', orderSource: 'MOBILE',
                deliveryDate: DateTime.now(), total: total, orderItems: orderItems);
              final Response resp = await OrderService().postOrder(dto);
              if (!context.mounted) return;
              if (resp.statusCode == 201) {
                showSuccessMessage(message: 'Order saved in drafts', context: context);
                orderRepo.clearOrderItems();
                orderMasterRepo.clearOrderMaster();
              } else {
                showErrorMessage(message: 'Could not save', context: context);
              }
              _showAddProductSheet();
            }),
        ],
      ),
    );
  }

  void _showAddProductSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      builder: (ctx) => MultiActionConfirmationWidget(
        title: 'Add Products',
        description: 'Search for products or scan barcodes to build your order.',
        actions: [
          ConfirmationAction(
            text: 'Scan Barcodes',
            onSelect: () {
              Navigator.of(context).pop();
              navigateToDefaultScanner(context, ScannerArguments(
                enableRapidMode: true,
                productDetailsOptions: ProductDetailsOptions(showAddToCart: true, showReturn: false)));
            }),
          ConfirmationAction(
            text: 'Search Products',
            onSelect: () => Navigator.of(context).popAndPushNamed(
              CommonConstants.searchScreenUrl,
              arguments: ProductSearchArguments(
                filters: {}, startingIndex: 0,
                productDetailsOptions: ProductDetailsOptions(showAddToCart: true, showReturn: false)))),
        ],
      ),
    );
  }
}

class _QA {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QA({required this.icon, required this.label, required this.color, required this.onTap});
}
