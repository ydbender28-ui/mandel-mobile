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
import 'package:mandel_mobile_app/layout/product_sync.dart';
import 'package:mandel_mobile_app/layout/recent_orders_swiper_widget.dart';
import 'package:mandel_mobile_app/model/order_dto.dart';
import 'package:mandel_mobile_app/model/product_details_options.dart';
import 'package:mandel_mobile_app/model/product_search_arguments.dart';
import 'package:mandel_mobile_app/model/scanner_arguments.dart';
import 'package:mandel_mobile_app/model/user_dto.dart';
import 'package:mandel_mobile_app/service/order_service.dart';
import 'package:mandel_mobile_app/utility/barcode_scanner_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_nav_option.dart';
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
  static const _textLo = Color(0xFF9AA3C2);

  Future<String> _getCustomerName() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('mandel_portal_token') ?? '';
    if (token.isEmpty) return 'Customer';
    try {
      final parts     = token.split('.');
      if (parts.length < 2) return 'Customer';
      final payload   = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded   = utf8.decode(base64Url.decode(normalized));
      final data      = json.decode(decoded) as Map<String, dynamic>;
      return data['customerName'] ?? 'Customer';
    } catch (_) { return 'Customer'; }
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
            _searchBar(),
            _quickActions(),
            _section('Deals'),
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.4,
                child: const DealSwiperWidget()),
            ),
            _section('Recent Orders'),
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.4,
                child: const RecentOrderSwiper()),
            ),
          ],
        ),
      ),
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
        Positioned(right: -40, top: -40,
          child: Container(width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _indigo.withOpacity(0.1)))),
        Positioned(left: -20, bottom: 10,
          child: Container(width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0EA5E9).withOpacity(0.07)))),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                  Text(snap.data ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, CommonConstants.searchScreenUrl,
            arguments: ProductSearchArguments(
                filters: {},
                productDetailsOptions: ProductDetailsOptions(
                    showAddToCart: true, showReturn: false))),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDDE0F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D1135).withOpacity(0.04),
                blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded, size: 18, color: Color(0xFF9AA3C2)),
            const SizedBox(width: 10),
            const Text('Search products…',
              style: TextStyle(fontSize: 13, color: Color(0xFF9AA3C2))),
          ]),
        ),
      ),
    );
  }

  Widget _quickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CommonNavOption().getNavOption(
              onSelect: (String routeName) async {
                var orderDetails = await orderMasterRepo.getLastUpdatedTimeStamp();
                if (orderDetails.isNotEmpty) {
                  _buildConfirmNewOrderBottomSheet();
                } else {
                  _buildScanningOrSearchingBottomSheet();
                }
              },
              context: context)[0],
          CommonNavOption().getNavOption(
              onSelect: (String routeName) => Navigator.pushNamed(context, routeName),
              context: context)[3],
          CommonNavOption().getNavOption(
              onSelect: (String routeName) => Navigator.pushNamed(context, routeName),
              context: context)[4],
          CommonNavOption().getSeeAllNavOption(
              onSelect: () => _buildFunctionsBottomSheet(context),
              context: context),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: _textHi,
          letterSpacing: -0.3)),
    );
  }

  void _buildFunctionsBottomSheet(BuildContext pageContext) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 400,
                child: GridView.count(
                    crossAxisCount: 3,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: CommonNavOption().getNavOption(
                        onSelect: (String routeName) =>
                            Navigator.pushNamed(context, routeName),
                        context: context)),
              ),
            );
          });
        });
  }

  void _buildConfirmNewOrderBottomSheet() {
    final List<ConfirmationAction> actions = [
      ConfirmationAction(
          text: 'Keep Going',
          onSelect: () {
            Navigator.pop(context);
            _buildScanningOrSearchingBottomSheet();
          }),
      ConfirmationAction(
          text: 'Start Fresh',
          onSelect: () async {
            Navigator.pop(context);
            showInProgressMessage(
                message: "Saving your current order. Hold tight",
                context: context);
            final userId     = await userRepo.getUserId();
            final total      = await orderRepo.getPeoGrandTotal();
            final orderItems = await orderRepo.getOrderItemList();
            OrderDto orderDto = OrderDto(
                user: UserDto(id: userId),
                orderState: 'DRAFT',
                orderSource: 'MOBILE',
                deliveryDate: DateTime.now(),
                total: total,
                orderItems: orderItems);
            Response response = await OrderService().postOrder(orderDto);
            if (!context.mounted) return;
            if (response.statusCode == 201) {
              showSuccessMessage(
                  message: "Your order saved in drafts", context: context);
              orderRepo.clearOrderItems();
              orderMasterRepo.clearOrderMaster();
            } else {
              showErrorMessage(message: "Could not saved", context: context);
            }
            _buildScanningOrSearchingBottomSheet();
          })
    ];
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
              builder: (BuildContext context, setState) =>
                  MultiActionConfirmationWidget(
                    title: 'Keep Going or Start Fresh?',
                    actions: actions,
                    description:
                        "You've got items in your cart that aren't saved yet. Want to keep adding more or start fresh?",
                  ),
            ));
  }

  void _handleScanBarcodeAction() async {
    final ScannerArguments arguments = ScannerArguments(
        enableRapidMode: true,
        productDetailsOptions:
            ProductDetailsOptions(showAddToCart: true, showReturn: false));
    Navigator.of(context).pop();
    navigateToDefaultScanner(context, arguments);
  }

  void _buildScanningOrSearchingBottomSheet() {
    final List<ConfirmationAction> actions = [
      ConfirmationAction(
          text: 'Scan Barcodes',
          onSelect: () => _handleScanBarcodeAction()),
      ConfirmationAction(
          text: 'Search Products',
          onSelect: () {
            final ProductSearchArguments searchArguments = ProductSearchArguments(
                filters: {},
                startingIndex: 0,
                productDetailsOptions:
                    ProductDetailsOptions(showAddToCart: true, showReturn: false));
            Navigator.of(context)
                .popAndPushNamed(CommonConstants.searchScreenUrl, arguments: searchArguments);
          })
    ];
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
              builder: (BuildContext context, setState) =>
                  MultiActionConfirmationWidget(
                    title: 'Add Products Effortlessly!',
                    actions: actions,
                    description:
                        "Adding products is a breeze—search for what you need or scan barcodes with your phone's camera or a Bluetooth scanner.",
                  ),
            ));
  }
}
