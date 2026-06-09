import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/model/product_details_options.dart';
import 'package:mandel_mobile_app/model/product_search_arguments.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

class CommonNavOption {
  List<Widget> optionList = [];

  ///This method will return all navigation option list
  List<Widget> getNavOption(
      {required Function(String option) onSelect,
      required BuildContext context}) {
    List<Widget> optionList = [];

    optionList.add(Column(
      children: [
        Container(
          width: 82.0,
          height: 70.0,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: const BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/images/mandel_new_order.png',
              width: 40,
              height: 49,
            ),
            onPressed: () {
              onSelect(CommonConstants.productScannerScreenUrl);
            },
          ),
        ),
        const Text('New Order',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C6C6C)))
      ],
    ));

    optionList.add(Column(
      children: [
        Container(
          width: 82.0,
          height: 70.0,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: const BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/images/mandel_my_order.png',
              width: 61,
              height: 59,
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) {
                  return const MainScreenWidget(
                    defaultIndex: 2,
                  );
                },
              ), (route) => false);
            },
          ),
        ),
        const Text('My Orders',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C6C6C)))
      ],
    ));

    optionList.add(Column(
      children: [
        Container(
          width: 82.0,
          height: 70.0,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: const BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/images/mandel_brand.png',
              width: 45,
              height: 45,
            ),
            onPressed: () {
              onSelect(CommonConstants.brandScreenWidget);
            },
          ),
        ),
        const Text('Brands',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C6C6C)))
      ],
    ));

    optionList.add(Column(
      children: [
        Container(
          width: 82.0,
          height: 70.0,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: const BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/images/mandel_category.png',
              width: 38,
              height: 38,
            ),
            onPressed: () {
              onSelect(CommonConstants.categoryScreenWidget);
            },
          ),
        ),
        const Text('Categories',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C6C6C)))
      ],
    ));

    optionList.add(Column(
      children: [
        Container(
          width: 82.0,
          height: 70.0,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: const BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/images/mandel_return.png',
              width: 38,
              height: 38,
            ),
            onPressed: () {
              onSelect(CommonConstants.returnListWidget);
            },
          ),
        ),
        const Text('My Returns',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C6C6C)))
      ],
    ));

    optionList.add(Column(
      children: [
        Container(
          width: 82.0,
          height: 70.0,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: const BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/images/mandel_notification.png',
              width: 38,
              height: 38,
            ),
            onPressed: () {
              onSelect(CommonConstants.newsScreenWidget);
            },
          ),
        ),
        const Text('News',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C6C6C)))
      ],
    ));

    optionList.add(Column(
      children: [
        Container(
          width: 82.0,
          height: 70.0,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: const BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/images/mandel_notification.png',
              width: 38,
              height: 38,
            ),
            onPressed: () {
              onSelect(CommonConstants.invoiceScreenWidget);
            },
          ),
        ),
        const Text('Invoices',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C6C6C)))
      ],
    ));

    optionList.add(Column(
      children: [
        Container(
          width: 82.0,
          height: 70.0,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: const BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/images/mandel_settings.png',
              width: 38,
              height: 38,
            ),
            onPressed: () {
              onSelect(CommonConstants.settingsScreenWidget);
            },
          ),
        ),
        const Text('Settings',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C6C6C)))
      ],
    ));

    optionList.add(Column(
      children: [
        Container(
          width: 82.0,
          height: 70.0,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: const BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/images/mandel_deals.png',
              width: 38,
              height: 38,
            ),
            onPressed: () {
              Navigator.popAndPushNamed(
                  context, CommonConstants.searchScreenUrl,
                  arguments: ProductSearchArguments(
                      filters: {'isOnDeal': true},
                      startingIndex: 1,
                      productDetailsOptions: ProductDetailsOptions(
                          showAddToCart: true, showReturn: false)));
            },
          ),
        ),
        const Text('Deals',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C6C6C)))
      ],
    ));

    optionList.add(Column(
      children: [
        Container(
          width: 82.0,
          height: 70.0,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: const BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/images/mandel_new_items.png',
              width: 38,
              height: 38,
            ),
            onPressed: () {
              Navigator.popAndPushNamed(
                  context, CommonConstants.searchScreenUrl,
                  arguments: ProductSearchArguments(
                      filters: {'isNewItem': true},
                      startingIndex: 2,
                      productDetailsOptions: ProductDetailsOptions(
                          showAddToCart: true, showReturn: false)));
            },
          ),
        ),
        const Text('New Items',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C6C6C)))
      ],
    ));

    return optionList;
  }

  ///This method will return see all nav widget
  Widget getSeeAllNavOption(
      {required Function() onSelect, required BuildContext context}) {
    return Column(
      children: [
        Container(
          width: 82.0,
          height: 70.0,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: const BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/images/mandel_more.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              onSelect();
            },
          ),
        ),
        const Text('See All',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C6C6C)))
      ],
    );
  }
}
