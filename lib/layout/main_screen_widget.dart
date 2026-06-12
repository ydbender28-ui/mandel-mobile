import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/cart_widget.dart';
import 'package:mandel_mobile_app/layout/home_screen_widget.dart';
import 'package:mandel_mobile_app/layout/order_screen_widget.dart';
import 'package:mandel_mobile_app/layout/product_screen_widget.dart';
import 'package:mandel_mobile_app/layout/profile_screen_widget.dart';
import 'package:mandel_mobile_app/layout/return_cart_widget.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';

class MainScreenWidget extends StatefulWidget {
  final int defaultIndex;
  const MainScreenWidget({super.key, required this.defaultIndex});

  @override
  State<MainScreenWidget> createState() => _MainScreenWidgetState();
}

class _MainScreenWidgetState extends State<MainScreenWidget>
    with WidgetsBindingObserver, CommonUtility {

  static const _primary   = Color(0xFF4F46E5);
  static const _navBg     = Colors.white;
  static const _unsel     = Color(0xFF9AA3C2);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: DefaultTabController(
        length: 6,
        initialIndex: widget.defaultIndex,
        child: Scaffold(
          body: const TabBarView(
            physics: NeverScrollableScrollPhysics(),
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
            decoration: BoxDecoration(
              color: _navBg,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D1135).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4)),
              ],
            ),
            child: SafeArea(
              top: false,
              child: TabBar(
                indicatorColor: Colors.transparent,
                dividerColor: Colors.transparent,
                labelColor: _primary,
                unselectedLabelColor: _unsel,
                labelStyle: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    fontFamily: 'Nunito'),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w500,
                    fontFamily: 'Nunito'),
                tabs: const [
                  _NavTab(icon: Icons.home_rounded,       outlineIcon: Icons.home_outlined,              label: 'Home'),
                  _NavTab(icon: Icons.storefront_rounded, outlineIcon: Icons.storefront_outlined,        label: 'Products'),
                  _NavTab(icon: Icons.receipt_rounded,    outlineIcon: Icons.receipt_outlined,           label: 'Orders'),
                  _NavTab(icon: Icons.shopping_bag_rounded, outlineIcon: Icons.shopping_bag_outlined,    label: 'Cart'),
                  _NavTab(icon: Icons.undo_rounded,       outlineIcon: Icons.undo_outlined,              label: 'Returns'),
                  _NavTab(icon: Icons.person_rounded,     outlineIcon: Icons.person_outline_rounded,     label: 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final IconData outlineIcon;
  final String label;
  const _NavTab({required this.icon, required this.outlineIcon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          Icon(icon, size: 24),
          const SizedBox(height: 3),
          Text(label),
        ],
      ),
    );
  }
}
