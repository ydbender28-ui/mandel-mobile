import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mandel_mobile_app/db/entity/order_item_entity.dart';
import 'package:mandel_mobile_app/db/entity/order_master_entity.dart';
import 'package:mandel_mobile_app/db/repository/order_master_repository.dart';
import 'package:mandel_mobile_app/db/repository/order_repository.dart';
import 'package:mandel_mobile_app/db/repository/user_master_repository.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/multi_action_confirmation_widget.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/layout/order_and_return_screen_widget.dart';
import 'package:mandel_mobile_app/model/order_dto.dart';
import 'package:mandel_mobile_app/model/user_dto.dart';
import 'package:mandel_mobile_app/service/order_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/message_utility.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailWidget extends StatefulWidget {
  final OrderDto orderDto;

  const OrderDetailWidget({super.key, required this.orderDto});

  @override
  State<OrderDetailWidget> createState() => _OrderDetailWidgetState();
}

class _OrderDetailWidgetState extends State<OrderDetailWidget>
    with CommonUtility, MessageUtility {
  final OrderMasterRepository orderMasterRepo = OrderMasterRepository();
  final UserMasterRepository userRepo = UserMasterRepository();
  final OrderRepository orderRepo = OrderRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          child: IconButton(
            icon: Image.asset(
              'assets/images/mandel_angle_left.png',
              width: 25,
              height: 24,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#${widget.orderDto.id}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderDetailTitle(widget.orderDto),
          _buildOrderList(context, widget.orderDto),
          _buildInformationBox(context, widget.orderDto),
          _buildButtonList(context, widget.orderDto)
          //_buildSummary()
        ],
      ),
    );
  }

  MaterialColor buildItemColor(String status) {
    if (CommonConstants.statusComplete == status) {
      return CommonCustomColor.mSuccessColor;
    }
    if (CommonConstants.statusPending == status) {
      return CommonCustomColor.mPendingColor;
    }
    return CommonCustomColor.mDraftColor;
  }

  Widget _buildOrderDetailTitle(OrderDto orderDto) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Order',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: CommonCustomColor.defaultTextColor)),
              Text(getFormattedTimeStamp(widget.orderDto.createdDateTime),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CommonCustomColor.menuItemColor))
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                  margin: const EdgeInsets.only(right: 5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: buildItemColor(widget.orderDto.orderState!),
                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                  )),
              Text(
                '${orderDto.orderState}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: buildItemColor(orderDto.orderState!)),
              )
            ],
          )
        ],
      ),
    );
  }

  _buildOrderList(BuildContext context, OrderDto orderDto) {
    return Expanded(
      child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Slidable(
              startActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  Visibility(
                    visible:
                        orderDto.orderState == CommonConstants.statusComplete,
                    child: SlidableAction(
                      flex: 1,
                      onPressed: (context) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    OrderAndReturnScreenWidget(
                                      order: orderDto,
                                      index: index,
                                      fromOrder: true,
                                      onClose: () {},
                                    )));
                      },
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      icon: Icons.assignment_return_sharp,
                      label: 'Return',
                    ),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.only(
                    left: 15, right: 15, top: 10, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 230,
                          child: Text(
                            orderDto.orderItems![index].getProductName(),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: Row(
                                children: [
                                  const Text(
                                    'Category : ',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: CommonCustomColor.menuItemColor),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      orderDto.orderItems![index]
                                          .getCategoryName(),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: CommonCustomColor
                                              .defaultTextColor),
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Brand : ',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: CommonCustomColor.menuItemColor),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    orderDto.orderItems![index].getBrandName(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color:
                                            CommonCustomColor.defaultTextColor),
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: Row(
                                children: [
                                  const Text(
                                    'Size : ',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: CommonCustomColor.menuItemColor),
                                  ),
                                  Text(
                                    orderDto.orderItems![index].getSize(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color:
                                            CommonCustomColor.defaultTextColor),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Text('Price : ',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            CommonCustomColor.menuItemColor)),
                                Text(
                                  '${orderDto.orderItems![index].unitPrice} x ${orderDto.orderItems![index].quantity}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color:
                                          CommonCustomColor.defaultTextColor),
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(orderDto.orderItems![index].getSubTotal(),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: CommonCustomColor.defaultTextColor))
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const Divider(
              indent: 10,
              endIndent: 10,
            );
          },
          itemCount: orderDto.orderItems!.length),
    );
  }

  _buildInformationBox(BuildContext context, OrderDto orderDto) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
      height: 90,
      decoration: BoxDecoration(
          color: CommonCustomColor.menuItemColor,
          borderRadius: BorderRadius.circular(10)),
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                const Text(
                  'Grand Total',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                const Spacer(),
                Text(
                  orderDto.getTotal(),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButtonList(BuildContext context, OrderDto orderDto) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton(
                onPressed: () async {
                  if (orderDto.invoice != null) {
                    try {
                      final Uri _url =
                          Uri.parse(orderDto.invoice!.reference!.url!);
                      await launchUrl(_url);
                    } catch (error) {
                      debugPrint(error.toString());
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: CommonCustomColor.fieldColor,
                    minimumSize: const Size.fromHeight(50)
                    // Background color
                    ),
                child: const Text(
                  'View Receipt',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CommonCustomColor.menuItemColor),
                )),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _addToCart(orderDto);
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
              child: _buildReOrderContent(orderDto.orderState!),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReOrderContent(String orderStatus) {
    if (orderStatus == 'DRAFT') {
      return const Text(
        "Move to cart",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      );
    }

    return const Text(
      "Re-order",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  void _addToCart(OrderDto orderDto) async {
    bool isOrderExist = await orderMasterRepo.isOrderExist();
    if (isOrderExist) {
      _buildConfirmNewOrderBottomSheet(orderDto);
    } else {
      await _moveToCartOrder(orderDto);
    }
  }

  void _buildConfirmNewOrderBottomSheet(OrderDto orderDto) {
    final List<ConfirmationAction> actions = [
      ConfirmationAction(
          text: 'Continue With Existing Order',
          onSelect: () {
            Navigator.pop(context);
          }),
      ConfirmationAction(
          text: 'Create New Order',
          onSelect: () async {
            await _saveCartAsDraftOrder();
            await _moveToCartOrder(orderDto);
          })
    ];
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return MultiActionConfirmationWidget(
                title: 'Save existing order?', actions: actions);
          });
        });
  }

  Future _saveCartAsDraftOrder() async {
    showInProgressMessage(
        message: "Saving your current order. Hold tight", context: context);
    final userId = await userRepo.getUserId();
    final total = await orderRepo.getPeoGrandTotal();
    final orderItems = await orderRepo.getOrderItemList();

    OrderDto orderDto = OrderDto(
        user: UserDto(id: userId),
        orderState: 'DRAFT',
        orderSource: 'MOBILE',
        deliveryDate: DateTime.now(),
        total: total,
        orderItems: orderItems);
    Response response = await OrderService().postOrder(orderDto);
    if (!context.mounted) return;
    if (response.statusCode == 201) {
      showSuccessMessage(
          message: "Your order saved in drafts", context: context);
      orderRepo.clearOrderItems();
      orderMasterRepo.clearOrderMaster();
    } else {
      showErrorMessage(message: "Could not saved", context: context);
    }
  }

  Future _moveToCartOrder(OrderDto orderDto) async {
    if (null == orderDto.orderItems) {
      return;
    }

    if (orderDto.orderItems!.isEmpty) {
      return;
    }

    try {
      OrderMasterEntity orderMaster = OrderMasterEntity(
          id: 1,
          createdDate: getCurrentTimeStampText(),
          updatedDate: getCurrentTimeStampText());

      await OrderMasterRepository().storeOrderMasterRecode(orderMaster);

      for (var item in orderDto.orderItems!) {
        OrderItemEntity orderItem = OrderItemEntity(
            productId: item.product!.id,
            productName: item.product!.productName,
            qty: item.quantity,
            unitPrice: item.unitPrice,
            subTotal: item.getNonFormattedSubTotal(),
            orderMasterId: 1);

        await OrderRepository().storeOrderItemRecode(orderItem);
      }

      if (orderDto.orderState == "DRAFT") {
        await OrderService().deleteOrder(orderDto.id!);
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) {
          return const MainScreenWidget(
            defaultIndex: 2,
          );
        },
      ), (route) => false);
    } catch (e) {
      showErrorMessage(message: "Could move to cart", context: context);
    }
  }
}
