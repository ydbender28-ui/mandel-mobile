import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/multi_action_confirmation_widget.dart';
import 'package:mandel_mobile_app/layout/return_line_item_widget.dart';
import 'package:mandel_mobile_app/model/product_details_options.dart';
import 'package:mandel_mobile_app/model/product_search_arguments.dart';
import 'package:mandel_mobile_app/model/scanner_arguments.dart';
import 'package:mandel_mobile_app/utility/barcode_scanner_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';

class ReturnScreenWidget extends StatefulWidget {
  final bool isFromHomePage;

  const ReturnScreenWidget({super.key, required this.isFromHomePage});

  @override
  State<ReturnScreenWidget> createState() => _ReturnScreenWidgetState();
}

class _ReturnScreenWidgetState extends State<ReturnScreenWidget>
    with BarcodeScannerUtility {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 5,
        child: Scaffold(
          body: const TabBarView(children: [
            ReturnLineItemWidget(status: 'ALL'),
            ReturnLineItemWidget(status: 'PENDING'),
            ReturnLineItemWidget(status: 'APPROVED'),
            ReturnLineItemWidget(status: 'DECLINE'),
            ReturnLineItemWidget(status: 'RECEIVED'),
          ]),
          appBar: AppBar(
            title: const Text('My Returns'),
            automaticallyImplyLeading: !widget.isFromHomePage,
            bottom: const TabBar(
                labelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        CommonCustomColor.defaultTextColor), //For Selected tab
                unselectedLabelStyle: TextStyle(
                    fontSize: 14,
                    color:
                        CommonCustomColor.menuItemColor), //For Un-selected Tabs
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Submitted'),
                  Tab(text: 'Approved'),
                  Tab(text: 'Decline'),
                  Tab(text: 'Received'),
                ]),
          ),
          floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                _buildOptionBottomSheet();
              },
              backgroundColor: CommonCustomColor.defaultTextColor,
              icon: const Icon(
                Icons.reply_rounded,
                color: Colors.white,
              ),
              label: const Text(
                "Create Return",
                style: TextStyle(color: Colors.white, fontSize: 18),
              )),
        ));
  }

  void _buildOptionBottomSheet() {
    final List<ConfirmationAction> actions = [
      ConfirmationAction(
          text: "Search Products",
          onSelect: () {
            final ProductSearchArguments searchArguments =
                ProductSearchArguments(
                    filters: {},
                    startingIndex: 0,
                    productDetailsOptions: ProductDetailsOptions(
                        showAddToCart: false, showReturn: true));
            Navigator.pop(context);
            Navigator.of(context).popAndPushNamed(
                CommonConstants.searchScreenUrl,
                arguments: searchArguments);
          }),
      ConfirmationAction(
          text: "Scan Barcodes",
          onSelect: () {
            final ScannerArguments arguments = ScannerArguments(
                enableRapidMode: false,
                productDetailsOptions: ProductDetailsOptions(
                    showAddToCart: false, showReturn: true));
            // Navigator.of(context).pushNamed(
            //     CommonConstants.productScannerScreenUrl,
            //     arguments: arguments);
            Navigator.pop(context);
            navigateToDefaultScanner(context, arguments);
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
                title: "Return Products Effortlessly!",
                description:
                    "Returning products is a breeze—search for what you need to return or scan barcodes with your phone's camera or a Bluetooth scanner.",
                actions: actions);
          });
        });
  }
}
