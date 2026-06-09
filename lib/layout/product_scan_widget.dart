import 'dart:async';
import 'dart:developer';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mandel_mobile_app/db/entity/configs_entity.dart';
import 'package:mandel_mobile_app/db/repository/configs_repository.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/multi_action_confirmation_widget.dart';
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
import 'package:mandel_mobile_app/utility/common_cart_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';

class ProductScanWidget extends StatefulWidget {
  const ProductScanWidget({super.key});

  @override
  State<ProductScanWidget> createState() => _ProductScanWidgetState();
}

class _ProductScanWidgetState extends State<ProductScanWidget> {
  final _productService = ProductService();
  Map<String, dynamic>? filters = <String, dynamic>{"page": 0, "pageSize": 5};
  List<String> _savedBLEDevices = [];
  late StreamSubscription<List<ScanResult>> _scanResultSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  late StreamSubscription<BluetoothConnectionState> _deviceStateSubscription;
  late Timer _timer;
  late dynamic product;
  final List<ScanResult> _scanResults = [];
  StreamController<BarcodeScanResult> barcodeResultsController =
      BehaviorSubject<BarcodeScanResult>();
  late StreamSubscription<BarcodeScanResult> _productSubscription;
  bool _scannerConnected = false;
  final ConfigsRepository configsRepository = ConfigsRepository();
  bool _rapidMode = false;
  final cartUtility = CommonCartUtility();
  ScannerArguments arguments = ScannerArguments(
      enableRapidMode: false,
      productDetailsOptions:
          ProductDetailsOptions(showAddToCart: true, showReturn: false));
  @override
  void initState() {
    super.initState();
    _initializeBLEService();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {});
    _timer.cancel();
    _scanResultSubscription = FlutterBluePlus.scanResults
        .listen(_processBLEScanResults, onDone: () async {
      await FlutterBluePlus.stopScan();
    });
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {});
    _productSubscription =
        barcodeResultsController.stream.listen((BarcodeScanResult results) {
      print(results.status);
      if (BarcodeScanStatus.productFound == results.status) {
        ProductDto? productDto = results.products?.first;
        productDto!.tempQty = 1;
        if (_rapidMode) {
          cartUtility.addToCart(
              productDto: productDto, qty: productDto.tempQty!);
        } else {
          // AddToCartDialog(
          //         context: context, productDto: productDto, onChange: () {})
          //     .buildAddToCartBottomSheet();
          if (results.products != null && results.products!.length > 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    settings: RouteSettings(arguments: arguments),
                    builder: (context) => MultipleProductOptionListWidget(
                          products: results.products!,
                        )));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderAndReturnScreenWidget(
                          productDto: productDto,
                          index: 0,
                          fromOrder: false,
                          showAddToCart:
                              arguments.productDetailsOptions.showAddToCart,
                          showReturn:
                              arguments.productDetailsOptions.showReturn,
                          onClose: () {},
                        )));
          }
        }

        barcodeResultsController.add(BarcodeScanResult(
            code: "", status: BarcodeScanStatus.awaitingScan));
      }
    });
  }

  @override
  void dispose() {
    _scanResultSubscription.cancel();
    _isScanningSubscription.cancel();
    _timer.cancel();
    _productSubscription.cancel();
    if (_scannerConnected) {
      _deviceStateSubscription.cancel();
    }
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
                      value: 'CAM_SCANNER',
                      child: Text('Camera Scanner'),
                    ),
                    const PopupMenuItem(
                      value: 'SETTINGS',
                      child: Text('Settings'),
                    )
                  ])
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_scannerConnected)
            _buildScanResults()
          else
            _buildNoScannerConnectedMessage()
        ],
      ),
      floatingActionButton: _buildLinkDeviceButton(context, _scannerConnected),
    );
  }

  void _handleMenuClick(dynamic target) {
    switch (target) {
      case "CAM_SCANNER":
        Navigator.of(context).popAndPushNamed(
            CommonConstants.cameraBrcodeScannerUrl,
            arguments: arguments);
        break;
      case 'SETTINGS':
        Navigator.of(context)
            .popAndPushNamed(CommonConstants.bluetoothDeviceManagement);
        break;
    }
  }

  void _startPeriodicBLEScan() async {
    debugPrint('Initializing periodic BLE device scan');
    debugPrint('Closing down any existing timers');

    _timer.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      debugPrint('Received timmer event. Starting BLE scan ${timer.tick}');

      await FlutterBluePlus.startScan();
      Timer.periodic(const Duration(seconds: 2), (timer) async {
        await FlutterBluePlus.stopScan();
        timer.cancel();
        debugPrint('Stoping BLE scan after 2 seconds');
        debugPrint('After 2 seconds found ${_scanResults.length} devices');

        if (_scanResults.isNotEmpty) {
          _connectToDevice(_scanResults.first.device);
        }
      });
    });
  }

  void _initializeBLEService() async {
    debugPrint('Initializing BLE service');
    debugPrint('Querying storage for saved BLE devices');

    List<ConfigsEntity> configs = await ConfigsRepository()
        .getConfigsyByKey(CommonConstants.bluetoothScanerConfigKey);
    List<String> savedBLEDevices =
        List.generate(configs.length, (index) => configs[index].value);
    setState(() {
      _savedBLEDevices = savedBLEDevices;
    });
    debugPrint("Query resulted saved BLE devices => $savedBLEDevices");
    if (configs.isNotEmpty) {
      debugPrint('Found ${savedBLEDevices.length} saved BLE devices');
      debugPrint('Looking up for connected devices');
      List<BluetoothDevice> connectedBLEDevices =
          FlutterBluePlus.connectedDevices;
      if (connectedBLEDevices.isEmpty) {
        debugPrint('No connected device were found.');
        _startPeriodicBLEScan();
      } else {
        debugPrint('Found  ${connectedBLEDevices.length} connected devices');
        _startListingToBarcodeReadings(connectedBLEDevices.first);
        _deviceStateSubscription = connectedBLEDevices.first.connectionState
            .listen(_handleBLEDeviceStateChange);
        setState(() {
          _scannerConnected = true;
        });
      }
    } else {
      debugPrint(
          "No saved BLE devices found. Redirecting user to BLE device management");
      if (context.mounted) {
        _scanResultSubscription.cancel();
        _isScanningSubscription.cancel();
        _timer.cancel();
        _productSubscription.cancel();
        // Navigator.of(context)
        //     .pushNamed(CommonConstants.bluetoothDeviceManagement);
        final List<ConfirmationAction> actions = [
          ConfirmationAction(
              text: "Setup Bluetooth Scanner",
              onSelect: () {
                Navigator.popUntil(context,
                    ModalRoute.withName(CommonConstants.mainScreenUrl));
                Navigator.of(context)
                    .pushNamed(CommonConstants.bluetoothDeviceManagement);
              }),
          ConfirmationAction(
              text: "Use Camera Scanner",
              onSelect: () async {
                Navigator.popUntil(context,
                    ModalRoute.withName(CommonConstants.mainScreenUrl));
                Navigator.pushNamed(
                    context, CommonConstants.cameraBrcodeScannerUrl);
                await configsRepository.storeConfigs(ConfigsEntity(
                    id: CommonConstants.defaultBarcodeScannerConfigId,
                    key: CommonConstants.defaultBarcodeScannerConfigKey,
                    value: CommonConstants.cammeraScanner));
              })
        ];
        showModalBottomSheet(
            context: context,
            isDismissible: false,
            builder: (context) {
              return StatefulBuilder(builder: (BuildContext context, setState) {
                return MultiActionConfirmationWidget(
                    title: "No Barcode Scanner Set Up Yet!",
                    description:
                        "You can set up a Bluetooth scanner now or use the camera scanner. You can always change your preference later in the settings.",
                    actions: actions);
              });
            });
      }
    }
  }

  Future<void> _processBLEScanResults(List<ScanResult> results) async {
    debugPrint('BLE scan found ${results.length} devices');
    if (_savedBLEDevices.isNotEmpty && results.isNotEmpty) {
      debugPrint('Matching saved devices with scan results');
      Set<DeviceIdentifier> seen =
          _scanResults.map((e) => e.device.remoteId).toSet();
      for (ScanResult r in results) {
        if (seen.contains(r.device.remoteId) == false &&
            r.device.platformName.isNotEmpty &&
            _savedBLEDevices.contains(r.device.remoteId.str)) {
          _scanResults.add(r);
        }
      }
      setState(() {});
    } else {
      debugPrint('No saved devices or no devices were found during the scan');
      await FlutterBluePlus.stopScan();
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    debugPrint('trying to connect to device ${device.remoteId.str}');
    try {
      await device.connect();
      await _startListingToBarcodeReadings(device);
      _deviceStateSubscription =
          device.connectionState.listen(_handleBLEDeviceStateChange);
    } catch (e) {
      print(e);
    }
  }

  void _handleBLEDeviceStateChange(BluetoothConnectionState state) async {
    if (state == BluetoothConnectionState.disconnected) {
      log('BLE device disconnected');
      _startPeriodicBLEScan();
      await _deviceStateSubscription.cancel();
      setState(() {
        _scannerConnected = false;
      });
    }

    if (state == BluetoothConnectionState.connected) {
      log('a BLE device connected. stopping all scans');
      _timer.cancel();
      await FlutterBluePlus.stopScan();
      setState(() {
        _scannerConnected = true;
      });
    }
  }

  Future<void> _startListingToBarcodeReadings(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((BluetoothService service) async {
      service.characteristics
          .forEach((BluetoothCharacteristic characteristic) async {
        if (device.isConnected && characteristic.properties.notify) {
          await characteristic.setNotifyValue(true);

          final charSubscription =
              characteristic.onValueReceived.listen((event) async {
            String code = utf8.decode(event);
            if (code.isNotEmpty) {
              barcodeResultsController.add(BarcodeScanResult(
                  code: code, status: BarcodeScanStatus.awaitingProductInfo));
              filters!['barcode'] = code.trim();
              ProductSearchResultDto output =
                  await _productService.searchProduct(filters, 0, 10);
              if (output.results!.isNotEmpty) {
                barcodeResultsController.add(BarcodeScanResult(
                    code: code,
                    status: BarcodeScanStatus.productFound,
                    products: output.results!));
              } else {
                barcodeResultsController.add(BarcodeScanResult(
                    code: code, status: BarcodeScanStatus.productNotFound));
              }
            }
          });
          device.cancelWhenDisconnected(charSubscription);
        }
      });
    });
  }

  Widget _buildScanResults() {
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
              case BarcodeScanStatus.productFound:
                return const Text('Product found');
              default:
                return _buildAwaitingBarcodeScanMessage();
            }
          } else if (snapshot.hasError) {
            return const Text("Error");
          } else {
            return _buildAwaitingBarcodeScanMessage();
          }
        });
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
            "Loading product",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        )
      ],
    );
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
        )
      ],
    );
  }

  Widget _buildNoScannerConnectedMessage() {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/mandel_device_not_found.png',
            width: 200,
            height: 200,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10, top: 10),
          child: const Text(
            "Looking for barcode scanner",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
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
        Container(
          margin: const EdgeInsets.only(bottom: 10, top: 10),
          child: const Text(
            "Scan a barcode to begin",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        if (arguments.enableRapidMode)
          Container(
              margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
              child: SwitchListTile(
                title: const Text(
                  "Rapid Mode",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                value: _rapidMode,
                onChanged: (bool value) {
                  setState(() {
                    _rapidMode = value;
                  });
                },
                secondary: const Icon(
                  Icons.bolt,
                  size: 42,
                ),
              )),
      ],
    );
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
}

Widget _buildLinkDeviceButton(BuildContext context, bool scannerConnected) {
  if (scannerConnected) {
    return const SizedBox();
  }
  return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, CommonConstants.bluetoothDeviceManagement);
      },
      backgroundColor: CommonCustomColor.defaultTextColor,
      icon: const Icon(
        Icons.bluetooth_rounded,
        color: Colors.white,
      ),
      label: const Text(
        'Link Device',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ));
}
