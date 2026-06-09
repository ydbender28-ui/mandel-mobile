import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mandel_mobile_app/db/entity/configs_entity.dart';
import 'package:mandel_mobile_app/db/repository/configs_repository.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';

class BluetoothDevicesScreenWidget extends StatefulWidget {
  const BluetoothDevicesScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _BluetoothDevicesScreenWidgetState();
}

class _BluetoothDevicesScreenWidgetState
    extends State<BluetoothDevicesScreenWidget> {
  List<BluetoothDevice> _connectedDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    _connectedDevices = FlutterBluePlus.connectedDevices;
    _scanResultSubscription = FlutterBluePlus.scanResults.listen((results) {
      Set<DeviceIdentifier> seen =
          _scanResults.map((e) => e.device.remoteId).toSet();
      for (ScanResult r in results) {
        if (seen.contains(r.device.remoteId) == false &&
            r.device.platformName.isNotEmpty) {
          _scanResults.add(r);
        }
      }
      setState(() {});
    });

    // FlutterBluePlus.li

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      setState(() {});
    });
  }

  Future onScanPressed() async {
    _scanResults = [];
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      _timer = Timer(const Duration(seconds: 5), () async {
        await FlutterBluePlus.stopScan();
        _timer.cancel();
      });
    } catch (e) {
      print(e);
    }
    setState(() {});
  }

  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _scanResultSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: _buildBackButton(context),
        title: _buildTitle(),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        _buildConnectedDevicesList(context),
        const Divider(),
        _buildAvailableDevicesList(context)
      ]),
      floatingActionButton: buildScanButton(context),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Linked Devices',
      style: TextStyle(fontSize: 24),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/images/mandel_angle_left.png',
        width: 25,
        height: 24,
      ),
      onPressed: () {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        } else {
          // SystemNavigator.pop();
          print("Cannot pop no one is there");
          // Navigator.of(context).pushNamed(CommonConstants);
        }
      },
    );
  }

  Widget _buildSectionTitle(title) {
    return Text(title,
        style: const TextStyle(
          color: CommonCustomColor.defaultTextColor,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ));
  }

  Widget _buildConnectedDevicesList(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Connected Devices'),
            Expanded(
                child: ListView(
              scrollDirection: Axis.vertical,
              children: _buildConnectedDevicesTiles(context),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableDevicesList(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Available Devices"),
            Expanded(
                child: ListView(
              scrollDirection: Axis.vertical,
              children: _buildScanResultTiles(context),
            ))
          ],
        ),
      ),
    );
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return FloatingActionButton.extended(
          onPressed: onStopPressed,
          backgroundColor: CommonCustomColor.warningColor,
          icon: const Icon(
            Icons.bluetooth_disabled_rounded,
            color: Colors.white,
          ),
          label: const Text(
            'Stop',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ));
    } else {
      return FloatingActionButton.extended(
          backgroundColor: CommonCustomColor.defaultTextColor,
          onPressed: onScanPressed,
          icon: const Icon(
            Icons.bluetooth_rounded,
            color: Colors.white,
          ),
          label: const Text(
            'Scan',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ));
    }
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map((e) => _buildAvailableDeviceTile(context, e))
        .toList();
  }

  List<Widget> _buildConnectedDevicesTiles(BuildContext context) {
    return _connectedDevices
        .map((e) => _buildConnectedDeviceTile(context, e))
        .toList();
  }

  Future<void> connectDevice(BluetoothDevice device) async {
    FlutterBluePlus.stopScan();
    await device.connect();

    await ConfigsRepository().storeConfigs(ConfigsEntity(
        id: CommonConstants.bluetoothScannerConfigid,
        key: CommonConstants.bluetoothScanerConfigKey,
        value: device.remoteId.str));
    await ConfigsRepository().storeConfigs(ConfigsEntity(
        id: CommonConstants.defaultBarcodeScannerConfigId,
        key: CommonConstants.defaultBarcodeScannerConfigKey,
        value: CommonConstants.bluetoothScanner));
    _connectedDevices = FlutterBluePlus.connectedDevices;
    setState(() {});
  }

  Future<void> disconnectDevice(BluetoothDevice device) async {
    await device.disconnect();
    await ConfigsRepository().removeConfig("BLUETOOTH_SCANNER");
    _connectedDevices = FlutterBluePlus.connectedDevices;
    setState(() {});
  }

  Widget _buildAvailableDeviceTile(BuildContext context, ScanResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
        title: Text(
          result.device.platformName,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: CommonCustomColor.menuItemColor),
        ),
        trailing: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
            ),
            icon: const Icon(Icons.link),
            label: const Text('Connect',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            onPressed: () {
              connectDevice(result.device);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedDeviceTile(
      BuildContext context, BluetoothDevice device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
        title: Text(
          device.platformName,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: CommonCustomColor.defaultTextColor),
        ),
        trailing: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: CommonCustomColor.defaultTextColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
            ),
            icon: const Icon(Icons.link_off),
            label: const Text("Forget",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            onPressed: () {
              disconnectDevice(device);
            },
          ),
        ),
      ),
    );
  }
}
