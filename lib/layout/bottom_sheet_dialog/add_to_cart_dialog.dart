import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/db/repository/order_repository.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/common_number_picker.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/utility/common_cart_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';

class AddToCartDialog extends CommonCartUtility {
  final Function onChange;
  final BuildContext context;
  final ProductDto productDto;
  final StreamController streamController = StreamController.broadcast();

  AddToCartDialog(
      {required this.context,
      required this.productDto,
      required this.onChange});

  double getProductUnitPrice() {
    return productDto.getNonFormatPrice();
  }

  void buildAddToCartBottomSheet() async {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return Wrap(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                      top: 10, bottom: 20, left: 20, right: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              productDto.productName ??
                                  CommonConstants.emptyRecodeIndicator,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: Image.asset(
                              'assets/images/mandel_close_icon.png',
                              width: 24,
                              height: 24,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.all(3),
                        child: Center(
                            child: Image.network(
                          (productDto.productImages?.isNotEmpty == true ? (productDto.productImages![0].url ?? '') : ''),
                          fit: BoxFit.cover,
                          height: 245,
                          width: 245,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/mandel_no_image.jpg',
                              fit: BoxFit.cover,
                              height: 245,
                              width: 245,
                            );
                          },
                        )),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20, top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('Category : ',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: CommonCustomColor
                                                .menuItemColor)),
                                    Text(
                                        null == productDto.category
                                            ? CommonConstants
                                                .emptyRecodeIndicator
                                            : productDto.category!.name ??
                                                CommonConstants
                                                    .emptyRecodeIndicator,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: CommonCustomColor
                                                .defaultTextColor))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text('Brand : ',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: CommonCustomColor
                                                .menuItemColor)),
                                    Text(
                                        null == productDto.brand
                                            ? CommonConstants
                                                .emptyRecodeIndicator
                                            : productDto.brand!.name ??
                                                CommonConstants
                                                    .emptyRecodeIndicator,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: CommonCustomColor
                                                .defaultTextColor))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text('Size : ',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: CommonCustomColor
                                                .menuItemColor)),
                                    Text(
                                        null == productDto.size
                                            ? CommonConstants
                                                .emptyRecodeIndicator
                                            : productDto.size!.name ??
                                                CommonConstants
                                                    .emptyRecodeIndicator,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: CommonCustomColor
                                                .defaultTextColor))
                                  ],
                                ),
                                const Row(
                                  children: [
                                    Text('SKU : ',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: CommonCustomColor
                                                .menuItemColor)),
                                    Text(CommonConstants.emptyRecodeIndicator,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: CommonCustomColor
                                                .defaultTextColor))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text('Unit Price : ',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: CommonCustomColor
                                                .menuItemColor)),
                                    Text('${getProductUnitPrice()}',
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: CommonCustomColor
                                                .defaultTextColor))
                                  ],
                                ),
                                _buildDealList(productDto)
                              ],
                            ),
                            StreamBuilder(
                              stream: streamController.stream,
                              initialData: getProductUnitPrice(),
                              builder: (context, snapshot) {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    return ScaleTransition(
                                        scale: animation, child: child);
                                  },
                                  child: Text('${snapshot.data}',
                                      style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w600)),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                              margin: const EdgeInsets.only(right: 20),
                              child: FutureBuilder(
                                future: OrderRepository()
                                    .getOrderItemQtyByProductId(productDto.id!),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    //////
                                    getTotalOrderItemPrice(
                                        productDto: productDto,
                                        qty: snapshot.data!.qty!);
                                    /////
                                    return CommonNumberPicker(
                                        defaultValue: snapshot.data!.qty!,
                                        isLimit: false,
                                        onChange: (value) {
                                          productDto.tempQty = value;
                                          double total = getTotalOrderItemPrice(
                                              productDto: productDto,
                                              qty: value);
                                          streamController.sink
                                              .add(total.toStringAsFixed(2));
                                        });
                                  }
                                  return const SizedBox();
                                },
                              )),
                          Flexible(
                            child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0)),
                                    ),
                                    minimumSize: const Size.fromHeight(45)),
                                onPressed: () async {
                                  await addToCart(
                                          productDto: productDto,
                                          qty: productDto.tempQty ?? 1)
                                      .then((value) {
                                    onChange();
                                    Navigator.pop(context);
                                  });
                                },
                                icon: const Icon(Icons.shopping_cart_rounded),
                                label: const Text(
                                  "Add to cart",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            );
          });
        });
  }

  Widget _buildDealList(ProductDto productDto) {
    List<Widget> deals = [];

    if (null != productDto.deal) {
      for (var element in productDto.deal!) {
        deals.add(DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(8),
          color: CommonCustomColor.pendingColor,
          strokeWidth: 1,
          child: Container(
            decoration: BoxDecoration(
                color: CommonCustomColor.dealColor,
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(
                        left: 15, right: 2.5, top: 10, bottom: 10),
                    child: const Icon(
                      Icons.local_offer_outlined,
                      color: CommonCustomColor.pendingColor,
                    )),
                Container(
                  margin: const EdgeInsets.all(12.5),
                  child: Text(
                    element.description!,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: CommonCustomColor.menuItemColor),
                  ),
                )
              ],
            ),
          ),
        ));
      }
    }

    return Visibility(
      visible: productDto.isDealExist(),
      child: Container(
        margin: const EdgeInsets.only(top: 15),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [...deals],
          ),
        ),
      ),
    );
  }
}
