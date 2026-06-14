import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandel_mobile_app/db/entity/order_item_entity.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/layout/product_list_widget.dart';
import 'package:mandel_mobile_app/model/product_details_options.dart';
import 'package:mandel_mobile_app/model/product_search_arguments.dart';
import 'package:mandel_mobile_app/model/scanner_arguments.dart';
import 'package:mandel_mobile_app/utility/barcode_scanner_utility.dart';
import 'package:mandel_mobile_app/utility/cart_state.dart';

class QuickOrderScreen extends StatefulWidget {
  /// Set to true when embedded as a bottom-nav tab (hides back button, title = "Products").
  final bool isTab;
  const QuickOrderScreen({super.key, this.isTab = false});

  @override
  State<QuickOrderScreen> createState() => _QuickOrderScreenState();
}

class _QuickOrderScreenState extends State<QuickOrderScreen>
    with BarcodeScannerUtility {
  final _searchCtrl = TextEditingController();
  final _listKey = GlobalKey<ProductListWidgetState>();

  static const _dark1 = Color(0xFF0C0F1E);
  static const _dark2 = Color(0xFF1B2860);
  static const _accent = Color(0xFF818CF8);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));

    return Scaffold(
      backgroundColor: const Color(0xFF07091A),
      body: Column(
        children: [
          _buildHeader(context),
          // ── Top 60%: product list with quick-add ──
          Expanded(
            flex: 60,
            child: ProductListWidget(
              key: _listKey,
              initialFilters: {},
              productDetailsOptions:
                  ProductDetailsOptions(showAddToCart: true, showReturn: false),
              showCartOverlay: false,
            ),
          ),
          // ── Divider with drag handle ──
          _buildDivider(),
          // ── Bottom 40%: live cart panel ──
          Expanded(
            flex: 40,
            child: StreamBuilder<void>(
              stream: CartState.changes,
              builder: (context, _) => _buildCartPanel(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_dark1, _dark2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        Positioned(
          right: -20, top: -20,
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accent.withOpacity(0.08)),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  if (!widget.isTab) ...[
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(widget.isTab ? 'Products' : 'Quick Order',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3)),
                  ),
                  // Scanner button
                  GestureDetector(
                    onTap: () => navigateToDefaultScanner(
                      context,
                      ScannerArguments(
                        enableRapidMode: true,
                        productDetailsOptions: ProductDetailsOptions(
                            showAddToCart: true, showReturn: false)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _accent.withOpacity(0.35), width: 1)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_scanner_rounded,
                              color: _accent, size: 16),
                          SizedBox(width: 6),
                          Text('Scan',
                            style: TextStyle(
                              color: _accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                // Embedded search bar
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.14), width: 1)),
                  child: Row(children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search_rounded,
                        size: 18, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        cursorColor: Colors.white70,
                        decoration: InputDecoration(
                          hintText: 'Search products…',
                          hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.40),
                              fontSize: 13),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (v) {
                          _listKey.currentState?.filter(v);
                          setState(() {});
                        },
                      ),
                    ),
                    if (_searchCtrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          _listKey.currentState?.filter('');
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(Icons.close_rounded,
                              size: 16, color: Colors.white.withOpacity(0.5)),
                        ),
                      )
                    else
                      const SizedBox(width: 10),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF07091A),
        border: Border.symmetric(
          horizontal: BorderSide(
              color: Colors.white.withOpacity(0.08), width: 0.5)),
      ),
      child: Center(
        child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.20),
            borderRadius: BorderRadius.circular(2)),
        ),
      ),
    );
  }

  Widget _buildCartPanel(BuildContext context) {
    final items = CartState.items;
    if (items.isEmpty) return _buildEmptyCart();

    return Column(
      children: [
        _buildCartHeader(items),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            itemCount: items.length,
            itemBuilder: (_, i) => _buildCartItem(items[i]),
          ),
        ),
        _buildPlaceOrderButton(context),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 36, color: Colors.white.withOpacity(0.18)),
          const SizedBox(height: 8),
          Text('Cart is empty',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 13,
              fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text('Add items using + on cards above',
            style: TextStyle(
              color: Colors.white.withOpacity(0.22),
              fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildCartHeader(List<OrderItemEntity> items) {
    final total = CartState.grandTotal;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8)),
            child: Text('${items.length} item${items.length == 1 ? '' : 's'}',
              style: const TextStyle(
                color: _accent, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          Text('\$${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3)),
        ],
      ),
    );
  }

  Widget _buildCartItem(OrderItemEntity item) {
    final pid = item.productId;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          // Name + brand
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName ?? '',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 12,
                    fontWeight: FontWeight.w700)),
                if ((item.brandName ?? '').isNotEmpty)
                  Text(item.brandName!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.40),
                      fontSize: 10)),
              ],
            ),
          ),
          // Qty controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SmallQtyBtn(
                icon: Icons.remove,
                onTap: () {
                  if (pid != null) CartState.updateQty(pid, (item.qty ?? 1) - 1);
                },
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 28),
                alignment: Alignment.center,
                child: Text('${item.qty ?? 0}',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w800)),
              ),
              _SmallQtyBtn(
                icon: Icons.add,
                onTap: () {
                  if (pid != null) CartState.updateQty(pid, (item.qty ?? 0) + 1);
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Sub-total
          SizedBox(
            width: 56,
            child: Text(
              '\$${(item.subTotal ?? 0).toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white, fontSize: 12,
                fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 6, 16, MediaQuery.of(context).padding.bottom + 10),
      child: GestureDetector(
        onTap: () {
          // Navigate to the full cart screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => const MainScreenWidget(defaultIndex: 3)),
            (r) => false,
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF818CF8).withOpacity(0.35),
                blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_checkout_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Review Cart  •  \$${CartState.grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallQtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SmallQtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.14)),
        ),
        child: Icon(icon, color: Colors.white, size: 13),
      ),
    );
  }
}
