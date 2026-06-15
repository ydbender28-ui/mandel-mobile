import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/multiple_product_option_list_widget.dart';
import 'package:mandel_mobile_app/layout/order_and_return_screen_widget.dart';
import 'package:mandel_mobile_app/model/barcode_scan_results.dart';
import 'package:mandel_mobile_app/model/barcode_scan_status.dart';
import 'package:mandel_mobile_app/model/product_details_options.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/model/product_search_result_dto.dart';
import 'package:mandel_mobile_app/model/scanner_arguments.dart';
import 'package:mandel_mobile_app/service/product_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/mpr_barcode_utility.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';

class CameraScanner extends StatefulWidget {
  const CameraScanner({super.key});

  @override
  State<CameraScanner> createState() => _CameraScannerState();
}

class _CameraScannerState extends State<CameraScanner> {
  final _productService = ProductService();
  late final MobileScannerController _scannerController;
  StreamController<BarcodeScanResult> barcodeResultsController =
      BehaviorSubject();
  late StreamSubscription<BarcodeScanResult> _barcodeResultSubscription;
  Map<String, dynamic>? filters = <String, dynamic>{"page": 0, "pageSize": 5};
  ScannerArguments arguments = ScannerArguments(
      enableRapidMode: false,
      productDetailsOptions:
          ProductDetailsOptions(showAddToCart: true, showReturn: false));

  bool _isProcessing = false;
  // On web (Safari) the camera requires an explicit user tap to start.
  bool _cameraStarted = !kIsWeb;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _barcodeResultSubscription =
        barcodeResultsController.stream.listen((BarcodeScanResult result) {
      if (BarcodeScanStatus.productFound == result.status) {
        final ProductDto? product = result.products?.first;
        if (product == null) return;
        product.tempQty = 1;

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
                      ))).then((_) => _resumeScanning());
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
                        showReturn: arguments.productDetailsOptions.showReturn,
                      ))).then((_) => _resumeScanning());
        }
      }
    });
    barcodeResultsController
        .add(BarcodeScanResult(code: "", status: BarcodeScanStatus.awaitingScan));
  }

  void _resumeScanning() {
    setState(() => _isProcessing = false);
    barcodeResultsController
        .add(BarcodeScanResult(code: "", status: BarcodeScanStatus.awaitingScan));
  }

  @override
  void dispose() {
    _barcodeResultSubscription.cancel();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)?.settings.arguments != null) {
      arguments =
          ModalRoute.of(context)!.settings.arguments as ScannerArguments;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Image.asset('assets/images/mandel_angle_left.png',
              width: 25, height: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Scan Products', style: TextStyle(fontSize: 24)),
        actions: [
          PopupMenuButton(
              onSelected: _handleMenuClick,
              itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'BLE_SCANNER',
                        child: Text("Bluetooth Scanner")),
                    const PopupMenuItem(
                        value: 'SETTINGS', child: Text('Settings')),
                  ])
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _cameraStarted
                ? Stack(
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: (BarcodeCapture capture) {
                          if (_isProcessing) return;
                          for (final Barcode barcode in capture.barcodes) {
                            final String? code = barcode.rawValue;
                            if (code != null && code.isNotEmpty) {
                              setState(() => _isProcessing = true);
                              _handleScanResult(code);
                              break;
                            }
                          }
                        },
                        errorBuilder: (context, error, child) =>
                            _buildCameraError(error.toString()),
                      ),
                      _buildScanOverlay(),
                    ],
                  )
                : _buildStartCameraButton(),
          ),
          Expanded(
            flex: 2,
            child: _buildResultPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildResultPanel() {
    return StreamBuilder(
        stream: barcodeResultsController.stream,
        builder:
            (BuildContext context, AsyncSnapshot<BarcodeScanResult> snapshot) {
          if (!snapshot.hasData) return _buildAwaitingMessage();
          switch (snapshot.data!.status) {
            case BarcodeScanStatus.awaitingProductInfo:
              return _buildLoadingMessage();
            case BarcodeScanStatus.productNotFound:
              return _buildProductNotFoundMessage(snapshot.data!.code);
            default:
              return _buildAwaitingMessage();
          }
        });
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

  Future<void> _handleScanResult(String barcode) async {
    barcodeResultsController.add(BarcodeScanResult(
        code: barcode, status: BarcodeScanStatus.awaitingProductInfo));
    try {
      final mprId = parseMprProductId(barcode);
      ProductSearchResultDto output;
      if (mprId != null) {
        output = await _productService.getProductById(mprId);
      } else {
        filters!['barcode'] = barcode;
        output = await _productService.searchProduct(filters, 0, 10);
      }
      if (output.results != null && output.results!.isNotEmpty) {
        barcodeResultsController.add(BarcodeScanResult(
            code: barcode,
            status: BarcodeScanStatus.productFound,
            products: output.results));
      } else {
        barcodeResultsController.add(BarcodeScanResult(
            code: barcode, status: BarcodeScanStatus.productNotFound));
        setState(() => _isProcessing = false);
      }
    } catch (_) {
      barcodeResultsController.add(BarcodeScanResult(
          code: barcode, status: BarcodeScanStatus.productNotFound));
      setState(() => _isProcessing = false);
    }
  }

  Widget _buildStartCameraButton() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 56, color: Colors.grey),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => setState(() => _cameraStarted = true),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Start Camera'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Allow camera access when prompted',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCameraError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_enhance, size: 48, color: Colors.orange),
          const SizedBox(height: 12),
          const Text('Camera unavailable',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Make sure you allowed camera access in Safari.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cameraStarted = false;
              });
              Future.microtask(() => setState(() => _cameraStarted = true));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAwaitingMessage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('Point camera at a barcode',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildProductNotFoundMessage(String code) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.orange),
          const SizedBox(height: 8),
          const Text('Product not found',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          Text(code,
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 200, height: 12,
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 8),
            Container(
                width: 140, height: 12,
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 12),
            const Text('Looking up product…',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
