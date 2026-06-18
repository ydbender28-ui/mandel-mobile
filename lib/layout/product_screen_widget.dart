import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/layout/product_list_widget.dart';
import 'package:mandel_mobile_app/model/product_details_options.dart';
import 'package:mandel_mobile_app/model/product_search_arguments.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

class ProductScreenWidget extends StatefulWidget {
  final ProductDetailsOptions? productDetailsOptions;
  final Map<String, dynamic>? initialFilters;
  final int startingIndex;
  const ProductScreenWidget({
    super.key,
    this.productDetailsOptions,
    this.initialFilters,
    this.startingIndex = 0,
  });
  @override
  State<ProductScreenWidget> createState() => _ProductScreenWidgetState();
}

class _ProductScreenWidgetState extends State<ProductScreenWidget> {

  final _searchCtrl   = TextEditingController();
  final _listKey      = GlobalKey<ProductListWidgetState>();

  static const _h1     = Color(0xFF0C0F1E);
  static const _h2     = Color(0xFF1B2860);
  static const _indigo = Color(0xFF4F46E5);
  static const _bg     = Color(0xFFEEF0FA);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final argsFromRoute = routeArgs is ProductSearchArguments ? routeArgs : null;
    final options = widget.productDetailsOptions
        ?? argsFromRoute?.productDetailsOptions
        ?? ProductDetailsOptions(showAddToCart: true, showReturn: false);
    final filters = widget.initialFilters ?? argsFromRoute?.filters ?? {};
    final startingTab = argsFromRoute?.startingIndex ?? widget.startingIndex;

    return Scaffold(
      backgroundColor: const Color(0xFF07091A),
      body: Column(children: [
        _header(context),
        Expanded(
          child: ProductListWidget(
            key: _listKey,
            startingTab: startingTab,
            initialFilters: filters,
            productDetailsOptions: options,
          ),
        ),
      ]),
    );
  }

  Widget _header(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // title row
              Row(children: [
                const Expanded(
                  child: Text('Products',
                    style: TextStyle(color: Colors.white, fontSize: 22,
                        fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                ),
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
              const SizedBox(height: 14),
              // search bar embedded in header
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.15), width: 1)),
                child: Row(children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search_rounded, size: 18,
                      color: Colors.white.withOpacity(0.6)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                      cursorColor: Colors.white70,
                      decoration: InputDecoration(
                        hintText: 'Search products…',
                        hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.45),
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
                            size: 16, color: Colors.white.withOpacity(0.6)),
                      ),
                    )
                  else
                    const SizedBox(width: 10),
                ]),
              ),
              const SizedBox(height: 10),
              // Search by Barcode button
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context,
                    kIsWeb
                        ? CommonConstants.cameraBrcodeScannerUrl
                        : CommonConstants.productScannerScreenUrl),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.15), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner_rounded,
                          size: 16, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 7),
                      Text('Search by Barcode',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
