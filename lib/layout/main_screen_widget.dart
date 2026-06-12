import 'dart:ui';
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

  static const _primary   = Color(0xFF818CF8);   // lighter indigo for dark bg
  static const _unsel     = Color(0xFF4B5589);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: DefaultTabController(
        length: 6,
        initialIndex: widget.defaultIndex,
        child: Scaffold(
          backgroundColor: const Color(0xFF07091A),
          extendBody: true,
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
          bottomNavigationBar: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF07091A).withOpacity(0.82),
                  border: Border(top: BorderSide(
                    color: Colors.white.withOpacity(0.10), width: 0.5)),
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
                      _NavTab(icon: Icons.home_rounded,         outlineIcon: Icons.home_outlined,           label: 'Home'),
                      _NavTab(icon: Icons.storefront_rounded,   outlineIcon: Icons.storefront_outlined,     label: 'Products'),
                      _NavTab(icon: Icons.receipt_rounded,      outlineIcon: Icons.receipt_outlined,        label: 'Orders'),
                      _NavTab(icon: Icons.shopping_bag_rounded, outlineIcon: Icons.shopping_bag_outlined,   label: 'Cart'),
                      _NavTab(icon: Icons.undo_rounded,         outlineIcon: Icons.undo_outlined,           label: 'Returns'),
                      _NavTab(icon: Icons.person_rounded,       outlineIcon: Icons.person_outline_rounded,  label: 'Profile'),
                    ],
                  ),
                ),
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
          Icon(icon, size: 22),
          const SizedBox(height: 2),
          Text(label,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9)),
        ],
      ),
    );
  }
}
