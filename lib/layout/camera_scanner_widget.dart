import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mandel_mobile_app/layout/bottom_sheet_dialog/add_to_cart_dialog.dart';
import 'package:mandel_mobile_app/layout/multiple_product_option_list_widget.dart';
import 'package:mandel_mobile_app/layout/multiple_product_option_widget.dart';
import 'package:mandel_mobile_app/layout/order_and_return_screen_widget.dart';
import 'package:mandel_mobile_app/model/barcode_scan_results.dart';
import 'package:mandel_mobile_app/model/barcode_scan_status.dart';
import 'package:mandel_mobile_app/model/product_details_options.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/model/product_search_result_dto.dart';
import 'package:mandel_mobile_app/model/scanner_arguments.dart';
import 'package:mandel_mobile_app/service/product_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';

class CameraScanner extends StatefulWidget {
  const CameraScanner({super.key});

  @override
  State<CameraScanner> createState() => _CameraScannerState();
}

class _CameraScannerState extends State<CameraScanner> {
  final _productService = ProductService();
  StreamController<BarcodeScanResult> barcodeResultsController =
      BehaviorSubject();
  late StreamSubscription<BarcodeScanResult> _barcodeResultSubscription;
  Map<String, dynamic>? filters = <String, dynamic>{"page": 0, "pageSize": 5};
  bool _rapidMode = false;
  ScannerArguments arguments = ScannerArguments(
      enableRapidMode: false,
      productDetailsOptions:
          ProductDetailsOptions(showAddToCart: true, showReturn: false));
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _barcodeResultSubscription =
        barcodeResultsController.stream.listen((BarcodeScanResult result) {
      if (BarcodeScanStatus.productFound == result.status) {
        ProductDto? product = result.products?.first;
        product!.tempQty = 1;
        if (_rapidMode) {
          //TODO add product to cart automatically
        } else {
          // AddToCartDialog(
          //         context: context, productDto: product, onChange: () {})
          //     .buildAddToCartBottomSheet();

          if (result.products != null && result.products!.length > 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    settings: RouteSettings(arguments: arguments),
                    builder: (context) => MultipleProductOptionListWidget(
                          products: result.products!,
                          showAddToCart:
                              arguments.productDetailsOptions.showAddToCart,
                          showAddToReturn:
                              arguments.productDetailsOptions.showReturn,
                        )));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderAndReturnScreenWidget(
                          index: 0,
                          fromOrder: false,
                          onClose: () {},
                          productDto: product,
                          showAddToCart:
                              arguments.productDetailsOptions.showAddToCart,
                          showReturn:
                              arguments.productDetailsOptions.showReturn,
                        )));
          }
        }

        barcodeResultsController.add(BarcodeScanResult(
            code: "", status: BarcodeScanStatus.awaitingScan));
      }
    });
    barcodeResultsController.add(
        BarcodeScanResult(code: "", status: BarcodeScanStatus.awaitingScan));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _barcodeResultSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final args =
          ModalRoute.of(context)!.settings.arguments as ScannerArguments;

      setState(() {
        arguments = args;
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: _buildBackButton(),
        title: _buildTitle(),
        actions: [
          PopupMenuButton(
              onSelected: _handleMenuClick,
              itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'BLE_SCANNER', child: Text("Bluetooth Scanner")),
                    const PopupMenuItem(
                        value: 'SETTINGS', child: Text('Settings'))
                  ])
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [_buildBarcodeScanResults()],
      ),
    );
  }

  void _handleMenuClick(dynamic target) {
    switch (target) {
      case "BLE_SCANNER":
        Navigator.of(context).popAndPushNamed(
            CommonConstants.productScannerScreenUrl,
            arguments: arguments);
        break;
      case 'SETTINGS':
        Navigator.of(context)
            .popAndPushNamed(CommonConstants.bluetoothDeviceManagement);
        break;
    }
  }

  Future<void> startScan() async {
    if (!mounted) return;

    try {
      barcodeResultsController.add(BarcodeScanResult(
          code: "", status: BarcodeScanStatus.awaitingProductInfo));

      if (_rapidMode) {
        FlutterBarcodeScanner.getBarcodeStreamReceiver(
                "#ff6666", "BACK", true, ScanMode.BARCODE)
            ?.listen((event) {
          print('rapid mode barcode $event');
          _handleScanResult(event);
        });
      } else {
        String scannerResults = await FlutterBarcodeScanner.scanBarcode(
            "#ff6666", 'BACK', true, ScanMode.BARCODE);
        print(scannerResults);
        _handleScanResult(scannerResults);
      }
    } catch (error) {
      print('Error ${error}');
    }
  }

  Future<void> _handleScanResult(String barcode) async {
    if (barcode.isEmpty || "-1" == barcode) {
      barcodeResultsController.add(
          BarcodeScanResult(code: "", status: BarcodeScanStatus.awaitingScan));
      return;
    }

    filters!['barcode'] = barcode;

    barcodeResultsController.add(BarcodeScanResult(
        code: barcode, status: BarcodeScanStatus.awaitingProductInfo));
    ProductSearchResultDto output =
        await _productService.searchProduct(filters, 0, 10);
    if (output.results!.isNotEmpty) {
      barcodeResultsController.add(BarcodeScanResult(
          code: barcode,
          status: BarcodeScanStatus.productFound,
          products: output.results));
    } else {
      barcodeResultsController.add(BarcodeScanResult(
          code: barcode, status: BarcodeScanStatus.productNotFound));
    }
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Image.asset(
        'assets/images/mandel_angle_left.png',
        width: 25,
        height: 24,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Scan Products',
      style: TextStyle(fontSize: 24),
    );
  }

  Widget _buildBarcodeScanResults() {
    return StreamBuilder(
        stream: barcodeResultsController.stream,
        builder:
            (BuildContext context, AsyncSnapshot<BarcodeScanResult> snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data!.status) {
              case BarcodeScanStatus.awaitingProductInfo:
                return _buildLoadingMessage();
              case BarcodeScanStatus.productNotFound:
                return _buildProductNotFoundMessage();
              default:
                return _buildAwaitingBarcodeScanMessage();
            }
          } else {
            return _buildAwaitingBarcodeScanMessage();
          }
        });
  }

  Widget _buildProductNotFoundMessage() {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/mandel_empty_state.png',
            width: 200,
            height: 200,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10, top: 10),
          child: const Text(
            "Product not found",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10, top: 10),
          child: ElevatedButton(
              onPressed: () {
                startScan();
              },
              child: const Text(
                "Scan Again",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              )),
        )
      ],
    );
  }

  Widget _buildAwaitingBarcodeScanMessage() {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Image.asset(
            "assets/images/mandel_animate_barcode.gif",
            width: 200,
            height: 200,
          ),
        ),
        // Container(
        //     margin:
        //         const EdgeInsets.only(top: 50, bottom: 50, left: 20, right: 20),
        //     child: SwitchListTile(
        //       title: const Text(
        //         "Rapid Mode",
        //         style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        //       ),
        //       value: _rapidMode,
        //       onChanged: (bool value) {
        //         setState(() {
        //           _rapidMode = value;
        //         });
        //       },
        //       secondary: const Icon(
        //         Icons.bolt,
        //         size: 42,
        //       ),
        //     )),
        Container(
          margin: const EdgeInsets.only(bottom: 10, top: 10),
          child: ElevatedButton(
              onPressed: () {
                startScan();
              },
              child: const Text(
                "Open Scanner",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              )),
        )
      ],
    );
  }

  Widget _buildLoadingMessage() {
    return Column(
      children: [
        Container(
            alignment: Alignment.center,
            child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 5.0, top: 5.0),
                      decoration: const BoxDecoration(color: Colors.white),
                      width: 50,
                      height: 50,
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 5.0, top: 5.0),
                      decoration: const BoxDecoration(color: Colors.white),
                      width: 200,
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 5.0, top: 5.0),
                      decoration: const BoxDecoration(color: Colors.white),
                      width: 200,
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 5.0, top: 5.0),
                      decoration: const BoxDecoration(color: Colors.white),
                      width: 200,
                      height: 10,
                    ),
                  ],
                ))),
        Container(
          margin: const EdgeInsets.only(bottom: 10, top: 10),
          child: const Text(
            "Loading product ",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        )
      ],
    );
  }
}
