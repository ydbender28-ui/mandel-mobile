import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/order_line_item_widger.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';

class OrderScreenWidget extends StatefulWidget {
  final bool isFromHomePage;

  const OrderScreenWidget({required this.isFromHomePage, super.key});

  @override
  State<OrderScreenWidget> createState() => _OrderScreenWidgetState();
}

class _OrderScreenWidgetState extends State<OrderScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          body: const TabBarView(children: [
            OrderLineItemWidget(status: 'ALL'),
            OrderLineItemWidget(status: 'PENDING'),
            OrderLineItemWidget(status: 'COMPLETE'),
            OrderLineItemWidget(status: 'DRAFT'),
          ]),
          appBar: AppBar(
            title: const Text('My Orders'),
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
                  Tab(text: 'Completed'),
                  Tab(text: 'Draft'),
                ]),
          ),
        ));
  }
}
