import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/bluetooth_devices_screen_widget.dart';
import 'package:mandel_mobile_app/layout/quick_order_screen.dart';
import 'package:mandel_mobile_app/layout/salesman_screen_widget.dart';
import 'package:mandel_mobile_app/layout/brand_screen_widget.dart';
import 'package:mandel_mobile_app/layout/camera_scanner_widget.dart';
import 'package:mandel_mobile_app/layout/category_screen_widget.dart';
import 'package:mandel_mobile_app/layout/deals_list_widget.dart';
import 'package:mandel_mobile_app/layout/initializing_screen_widget.dart';
import 'package:mandel_mobile_app/layout/ar_screen_widget.dart';
import 'package:mandel_mobile_app/layout/invoice_screen_widget.dart';
import 'package:mandel_mobile_app/layout/login_screen_widget.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/layout/news_screen_widget.dart';
import 'package:mandel_mobile_app/layout/offers_screen_widger.dart';
import 'package:mandel_mobile_app/layout/product_scan_widget.dart';
import 'package:mandel_mobile_app/layout/product_screen_widget.dart';
import 'package:mandel_mobile_app/layout/return_cart_widget.dart';
import 'package:mandel_mobile_app/layout/return_screen_widget.dart';
import 'package:mandel_mobile_app/layout/settings_screen_widget.dart';
import 'package:mandel_mobile_app/layout/splash_screen_widget.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings route) {
    switch (route.name) {
      case CommonConstants.baseUrl:
        return MaterialPageRoute(
            settings: route, builder: (_) => const SplashScreenWidget());
      case CommonConstants.offersScreenUrl:
        return MaterialPageRoute(
            settings: route, builder: (_) => const OffersScreenWidget());
      case CommonConstants.configurationScreenUrl:
        return MaterialPageRoute(
            settings: route,
            builder: (_) => const InitializingWaitScreenWidget());
      case CommonConstants.loginScreenUrl:
        return MaterialPageRoute(
            settings: route, builder: (_) => const LoginScreenWidget());
      case CommonConstants.mainScreenUrl:
        return MaterialPageRoute(
            settings: route,
            builder: (_) => const MainScreenWidget(
                  defaultIndex: 0,
                ));
      case CommonConstants.searchScreenUrl:
        return MaterialPageRoute(
            settings: route, builder: (_) => const ProductScreenWidget());
      case CommonConstants.brandScreenWidget:
        return MaterialPageRoute(
            settings: route, builder: (_) => const BrandScreenWidget());
      case CommonConstants.categoryScreenWidget:
        return MaterialPageRoute(
            settings: route, builder: (_) => const CategoryScreenWidget());
      case CommonConstants.productScannerScreenUrl:
        return MaterialPageRoute(
            settings: route, builder: (_) => const ProductScanWidget());
      case CommonConstants.bluetoothDeviceManagement:
        return MaterialPageRoute(
            settings: route,
            builder: (_) => const BluetoothDevicesScreenWidget());
      case CommonConstants.settingsScreenWidget:
        return MaterialPageRoute(
            settings: route, builder: (_) => const SettingsScreenWidget());
      case CommonConstants.cameraBrcodeScannerUrl:
        return MaterialPageRoute(
            settings: route, builder: (_) => const CameraScanner());
      case CommonConstants.returnCartScreenWidget:
        return MaterialPageRoute(
            settings: route, builder: (_) => const ReturnCartWidget());
      case CommonConstants.dealsListScreenWidget:
        return MaterialPageRoute(
            settings: route, builder: (_) => const DealsListWidget());
      case CommonConstants.returnListWidget:
        return MaterialPageRoute(
            builder: (_) => const ReturnScreenWidget(isFromHomePage: false),
            settings: route);
      case CommonConstants.newsScreenWidget:
        return MaterialPageRoute(
            builder: (_) => const NewsScreenWidget(), settings: route);
      case CommonConstants.invoiceScreenWidget:
        return MaterialPageRoute(
            builder: (_) => const InvoiceScreen(), settings: route);
      case CommonConstants.arScreenWidget:
        return MaterialPageRoute(
            builder: (_) => const ArScreenWidget(), settings: route);
      case CommonConstants.quickOrderScreen:
        return MaterialPageRoute(
            settings: route, builder: (_) => const QuickOrderScreen());
      case CommonConstants.salesmanScreenUrl:
        return MaterialPageRoute(
            settings: route, builder: (_) => const SalesmanScreenWidget());
      default:
        return MaterialPageRoute(
            settings: route, builder: (_) => const SplashScreenWidget());
    }
  }
}
