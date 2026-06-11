import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/cart_widget.dart';
import 'package:mandel_mobile_app/layout/home_screen_widget.dart';
import 'package:mandel_mobile_app/layout/order_screen_widget.dart';
import 'package:mandel_mobile_app/layout/product_screen_widget.dart';
import 'package:mandel_mobile_app/layout/profile_screen_widget.dart';
import 'package:mandel_mobile_app/layout/return_cart_widget.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/top_indicator.dart';

class MainScreenWidget extends StatefulWidget {
  final int defaultIndex;
  const MainScreenWidget({super.key, required this.defaultIndex});

  @override
  State<MainScreenWidget> createState() => _MainScreenWidgetState();
}

class _MainScreenWidgetState extends State<MainScreenWidget>
    with WidgetsBindingObserver, CommonUtility {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // Future<void> _loadUrl() async {
  //   final Uri url = Uri.parse('https://flutter.dev');
  //   if (!await launchUrl(url)) {
  //     throw Exception('Could not launch $url');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: DefaultTabController(
        length: 6,
        initialIndex: widget.defaultIndex,
        child: Scaffold(
          body: const TabBarView(
            children: [
              HomeScreenWidget(),
              ProductScreenWidget(),
              OrderScreenWidget(isFromHomePage: true),
              CartWidget(isFromHomePage: true),
              ReturnCartWidget(),
              ProfileScreenWidget(isFromHomePage: true),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: Color(0xFFD2D2D2), width: 0.5))),
            child: TabBar(
              indicator: TopIndicator(),
              labelStyle:
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.w200),
              indicatorPadding: EdgeInsets.zero,
              tabs: const [
                Tab(
                    icon: Icon(Icons.home_outlined, size: 25),
                    text: 'Home'),
                Tab(
                    icon: Icon(Icons.storefront_outlined, size: 25),
                    text: 'Products'),
                Tab(
                    icon: Icon(Icons.list_outlined, size: 25),
                    text: 'Orders'),
                Tab(
                    icon: Icon(Icons.shopping_cart_outlined, size: 25),
                    text: 'Cart'),
                Tab(
                    icon: Icon(Icons.assignment_return_outlined, size: 25),
                    text: 'Returns'),
                Tab(
                    icon: Icon(Icons.account_circle_outlined, size: 25),
                    text: 'Profile')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
