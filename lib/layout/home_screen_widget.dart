import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/common_nav_option.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/message_utility.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget>
    with
        MessageUtility,
        WidgetsBindingObserver,
        CommonUtility,
        BarcodeScannerUtility {
  final OrderMasterRepository orderMasterRepo = OrderMasterRepository();
  final OrderRepository orderRepo = OrderRepository();
  final UserMasterRepository userRepo = UserMasterRepository();
  bool isCatalogueSyncMessageSown = false;

  Future<String> _getCustomerName() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('mandel_portal_token') ?? '';
    if (token.isEmpty) return 'Customer';
    try {
      // Decode JWT payload (base64)
      final parts = token.split('.');
      if (parts.length < 2) return 'Customer';
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> data = json.decode(decoded);
      return data['customerName'] ?? 'Customer';
    } catch (_) { return 'Customer'; }
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // No product sync needed — loading live from API
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    // No product sync needed — loading live from API
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.only(top: 40, left: 20),
                child: const Text('Welcome Back,',
                    style: TextStyle(fontSize: 24))),
            Container(
                margin: const EdgeInsets.only(top: 0, left: 20, bottom: 25),
                child: FutureBuilder(
                  future: _getCustomerName(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? '',
                      style: const TextStyle(fontSize: 20),
                    );
                  },
                )),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, CommonConstants.searchScreenUrl,
                      arguments: ProductSearchArguments(
                          filters: {},
                          productDetailsOptions: ProductDetailsOptions(
                              showAddToCart: true, showReturn: false)));
                },
                child: const TextField(
                  enabled: false,
                  decoration: InputDecoration(
                      hintText: 'Search product by name or category',
                      hintStyle: TextStyle(
                          color: CommonCustomColor.menuItemColor, fontSize: 14),
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Color(0xFFEEEEEE),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0)),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                  top: 20, left: 20, right: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CommonNavOption().getNavOption(
                      onSelect: (String routeName) async {
                        // Navigator.pushNamed(context, routeName);
                        // _buildNewOrderBottomSheet();
                        var orderDetails =
                            await orderMasterRepo.getLastUpdatedTimeStamp();
                        print(orderDetails);
                        if (orderDetails.isNotEmpty) {
                          _buildConfirmNewOrderBottomSheet();
                        } else {
                          _buildScanningOrSearchingBottomSheet();
                        }
                      },
                      context: context)[0],
                  CommonNavOption().getNavOption(
                      onSelect: (String routeName) {
                        Navigator.pushNamed(context, routeName);
                      },
                      context: context)[3],
                  CommonNavOption().getNavOption(
                      onSelect: (String routeName) {
                        Navigator.pushNamed(context, routeName);
                      },
                      context: context)[4],
                  CommonNavOption().getSeeAllNavOption(
                      onSelect: () {
                        _buildFunctionsBottomSheet(context);
                      },
                      context: context)
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: const Text('Deals',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2B2B2B))),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 0),
              child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.4,
                child: const DealSwiperWidget(),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 20, top: 20),
              child: const Text('Recent Orders',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2B2B2B))),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 50),
              child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.4,
                child: const RecentOrderSwiper(),
              ),
            )
          ],
        ),
      ),
    ));
  }

  // Product sync removed — loading live from API

  void _buildFunctionsBottomSheet(BuildContext pageContext) {
    CommonNavOption navOption = CommonNavOption();

    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
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
                    children: navOption.getNavOption(
                        onSelect: (String routeName) {
                          Navigator.pushNamed(context, routeName);
                        },
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
            /////
            showInProgressMessage(
                message: "Saving your current order. Hold tight",
                context: context);
            final userId = await userRepo.getUserId();
            final total = await orderRepo.getPeoGrandTotal();
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
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return MultiActionConfirmationWidget(
              title: 'Keep Going or Start Fresh?',
              actions: actions,
              description:
                  "You've got items in your cart that aren't saved yet. Want to keep adding more or start fresh?",
            );
          });
        });
  }

  void _handleScanBarcodeAction() async {
    final ScannerArguments arguments = ScannerArguments(
        enableRapidMode: true,
        productDetailsOptions:
            ProductDetailsOptions(showAddToCart: true, showReturn: false));
    // ConfigsEntity config = await configsRepository
    //     .getSingleConfigByKey(CommonConstants.defaultBarcodeScannerConfigKey);
    // if (CommonConstants.cammeraScanner == config.value) {
    //   Navigator.of(context)
    //       .popAndPushNamed(CommonConstants.cameraBrcodeScannerUrl);
    // } else {
    //   Navigator.of(context)
    //       .popAndPushNamed(CommonConstants.productScannerScreenUrl);
    // }
    Navigator.of(context).pop();
    navigateToDefaultScanner(context, arguments);
  }

  void _buildScanningOrSearchingBottomSheet() {
    final List<ConfirmationAction> actions = [
      ConfirmationAction(
          text: 'Scan Barcodes',
          onSelect: () {
            // Navigator.of(context)
            //     .popAndPushNamed(CommonConstants.productScannerScreenUrl);
            _handleScanBarcodeAction();
          }),
      ConfirmationAction(
          text: 'Search Products',
          onSelect: () {
            // Navigator.pop(context);
            // Navigator.pushNamed(context, CommonConstants.searchScreenUrl);
            final ProductSearchArguments searchArguments =
                ProductSearchArguments(
                    filters: {},
                    startingIndex: 0,
                    productDetailsOptions: ProductDetailsOptions(
                        showAddToCart: true, showReturn: false));
            Navigator.of(context).popAndPushNamed(
                CommonConstants.searchScreenUrl,
                arguments: searchArguments);
          })
    ];

    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return MultiActionConfirmationWidget(
              title: 'Add Products Effortlessly!',
              actions: actions,
              description:
                  "Adding products is a breeze—search for what you need or scan barcodes with your phone's camera or a Bluetooth scanner. Take your pick and make adding items a snap!",
            );
          });
        });
  }
}
