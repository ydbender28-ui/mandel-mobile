import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/common_number_picker.dart';
import 'package:mandel_mobile_app/model/order_dto.dart';
import 'package:mandel_mobile_app/model/order_item_dto.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/model/product_search_result_dto.dart';
import 'package:mandel_mobile_app/model/return_dto.dart';
import 'package:mandel_mobile_app/model/return_item_dto.dart';
import 'package:mandel_mobile_app/service/product_service.dart';
import 'package:mandel_mobile_app/service/return_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/message_utility.dart';

class AddToReturnDialog extends StatefulWidget {
  final OrderDto order;
  final int index;

  const AddToReturnDialog(
      {super.key, required this.order, required this.index});

  @override
  State<AddToReturnDialog> createState() => _AddToReturnDialogState();
}

class _AddToReturnDialogState extends State<AddToReturnDialog>
    with MessageUtility {
  ///
  final StreamController streamController = StreamController.broadcast();

  ///
  bool isProcess = false;

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //////
    OrderItem orderProduct = widget.order.orderItems![widget.index];
    ///////
    return Wrap(
      children: [
        Container(
          margin:
              const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      orderProduct.getProductName(),
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
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.all(3),
                child: Center(
                    child: FutureBuilder(
                  future: _getProductById(orderProduct.getProductId()),
                  builder: (context, snapshot) {
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Image.asset(
                        'assets/images/mandel_no_image.jpg',
                        fit: BoxFit.cover,
                        height: 245,
                        width: 245,
                      );
                    }

                    return Image.network(
                      (snapshot.data!.productImages?.isNotEmpty == true ? (snapshot.data!.productImages![0].url ?? '') : ''),
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
                    );
                  },
                )),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
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
                                    color: CommonCustomColor.menuItemColor)),
                            Text(orderProduct.getCategoryName(),
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: CommonCustomColor.defaultTextColor))
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Brand : ',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: CommonCustomColor.menuItemColor)),
                            Text(orderProduct.getBrandName(),
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: CommonCustomColor.defaultTextColor))
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Size : ',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: CommonCustomColor.menuItemColor)),
                            Text(orderProduct.getSize(),
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: CommonCustomColor.defaultTextColor))
                          ],
                        ),
                        const Row(
                          children: [
                            Text('SKU : ',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: CommonCustomColor.menuItemColor)),
                            Text(CommonConstants.emptyRecodeIndicator,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: CommonCustomColor.defaultTextColor))
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Unit Price : ',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: CommonCustomColor.menuItemColor)),
                            Text(orderProduct.getUnitPrice(),
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: CommonCustomColor.defaultTextColor))
                          ],
                        )
                      ],
                    ),
                    StreamBuilder(
                      initialData: orderProduct.price,
                      stream: streamController.stream,
                      builder: (context, snapshot) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: Text('${snapshot.data}',
                              key: ValueKey<String>('${snapshot.data}'),
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.w600)),
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
                      child: CommonNumberPicker(
                          defaultValue: orderProduct.quantity ?? 0,
                          isLimit: true,
                          onChange: (value) {
                            orderProduct.tempQty = value;
                            _getTotalReturnItemPrice(
                                orderProduct.unitPrice!, value);
                          })),
                  Flexible(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: CommonCustomColor
                                .pendingColor, // background (button) color
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                            ),
                            minimumSize: const Size.fromHeight(45)),
                        onPressed:
                            postReturnProduct(widget.order, widget.index),
                        child: _buildAddToReturnContent()),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAddToReturnContent() {
    if (isProcess) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
          color: Colors.black,
        ),
      );
    }

    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.assignment_return_outlined),
        SizedBox(
          width: 10,
        ),
        Text(
          "Add to Return",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        )
      ],
    );
  }

  Future<ProductDto> _getProductById(int productId) async {
    Map<String, dynamic> filters = <String, dynamic>{
      "page": 0,
      "pageSize": 1,
      "id": productId
    };

    Response response = await ProductService().getProductList(filters);
    final result = ProductSearchResultDto.fromJson(response.data);
    return result.results!.single;
  }

  ///
  ///This method will return order item sub total
  void _getTotalReturnItemPrice(double unitPrice, int qty) {
    double total = unitPrice * qty;
    streamController.sink.add(total.toStringAsFixed(2));
  }

  postReturnProduct(OrderDto orderDto, int index) {
    if (isProcess) {
      return null;
    }

    return () async {
      List<ReturnItemDto> returnItemList = [];

      setState(() {
        isProcess = !isProcess;
      });

      final returnDto = ReturnItemDto(
          order: OrderDto(id: orderDto.id),
          product: ProductDto(id: orderDto.orderItems![index].product!.id),
          quantity: orderDto.orderItems![index].quantity,
          unitPrice: orderDto.orderItems![index].unitPrice,
          returnStatus: 'PENDING',
          id: 0);

      returnItemList.add(returnDto);

      Response response = await ReturnService()
          .postReturn(ReturnDto(returnItems: returnItemList));
      if (!context.mounted) return;

      Navigator.pop(context);

      if (response.statusCode == 201) {
        showSuccessMessage(
            message: 'Your return has been successfully processed!',
            context: context);
      } else {
        showErrorMessage(
            message: 'Return placement failed. Please contact support!',
            context: context);
      }

      setState(() {
        isProcess = !isProcess;
      });
    };
  }
}
