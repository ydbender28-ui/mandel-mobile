import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mandel_mobile_app/db/entity/order_item_entity.dart';
import 'package:mandel_mobile_app/db/entity/order_master_entity.dart';
import 'package:mandel_mobile_app/db/repository/order_master_repository.dart';
import 'package:mandel_mobile_app/db/repository/order_repository.dart';
import 'package:mandel_mobile_app/db/repository/user_master_repository.dart';
import 'package:mandel_mobile_app/layout/bottom_sheet_dialog/clear_cart_confirmation_dialog.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/common_cart_number_picker.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/model/order_dto.dart';
import 'package:mandel_mobile_app/model/user_dto.dart';
import 'package:mandel_mobile_app/service/order_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/message_utility.dart';

class CartWidget extends StatefulWidget {
  final bool isFromHomePage;

  const CartWidget({required this.isFromHomePage, super.key});

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget>
    with CommonUtility, MessageUtility {
  final _deliveryNoteTextController = TextEditingController();
  final _deliveryDateTextController = TextEditingController();
  final _deliveryInfoFormKey = GlobalKey<FormState>();

  ///
  bool isProcess = false;

  @override
  void dispose() {
    _deliveryDateTextController.dispose();
    _deliveryNoteTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Cart',
              style: TextStyle(fontSize: 24),
            ),
            FutureBuilder(
              future: OrderMasterRepository().getLastUpdatedTimeStamp(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Last Updated: ${snapshot.data}',
                      style: const TextStyle(fontSize: 12));
                }

                if (!snapshot.hasData) {
                  return const Text('Empty cart',
                      style: TextStyle(fontSize: 12));
                }

                if (snapshot.hasError) {
                  return const Text('Some thing went wrong',
                      style: TextStyle(fontSize: 12));
                }

                return const SizedBox();
              },
            )
          ],
        ),
        automaticallyImplyLeading: !widget.isFromHomePage,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderDetailTitle(),
            _buildOrderList(context),
            _buildSummary(),
            _buildForm(),
            _buildPlaceOrderButton()
          ],
        ),
      ),
    );
  }

  _buildOrderDetailTitle() {
    return Container(
      margin: const EdgeInsets.only(left: 15, top: 15, bottom: 10),
      child: const Text('Order Details',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: CommonCustomColor.defaultTextColor)),
    );
  }

  ///
  ///This method will build order list
  _buildOrderList(BuildContext context) {
    return FutureBuilder(
      future: OrderRepository().getOrderList(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('error');
        }

        if (!snapshot.hasData) {
          return Text('empty');
        }

        return SizedBox(
          height: 360,
          child: ListView.separated(
              itemBuilder: (context, index) {
                // bool isPiece = snapshot.data![index]
                return Container(
                  margin: const EdgeInsets.only(
                      left: 15, right: 15, top: 10, bottom: 10),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 193,
                            child: Text(
                              '${snapshot.data![index].productName}',
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
                                          color:
                                              CommonCustomColor.menuItemColor),
                                    ),
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        snapshot.data![index].categoryName ??
                                            CommonConstants
                                                .emptyRecodeIndicator,
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
                                      snapshot.data![index].brandName ??
                                          CommonConstants.emptyRecodeIndicator,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: CommonCustomColor
                                              .defaultTextColor),
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
                                          color:
                                              CommonCustomColor.menuItemColor),
                                    ),
                                    Text(
                                      snapshot.data![index].size ??
                                          CommonConstants.emptyRecodeIndicator,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: CommonCustomColor
                                              .defaultTextColor),
                                    )
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  const Text('Unit Price : \$',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              CommonCustomColor.menuItemColor)),
                                  Text(
                                    snapshot.data![index].getUnitPrice(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color:
                                            CommonCustomColor.defaultTextColor),
                                  )
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Row(
                                children: [
                                  const Text('Sub Total : \$',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              CommonCustomColor.menuItemColor)),
                                  Text(
                                      snapshot.data![index].subTotal!
                                          .toStringAsFixed(2),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: CommonCustomColor
                                              .defaultTextColor))
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      const Spacer(),
                      _buildItemQtyPicker(snapshot.data!, index, () {
                        setState(() {});
                      })
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  indent: 10,
                  endIndent: 10,
                );
              },
              itemCount: snapshot.data!.length),
        );
      },
    );
  }

  ///
  ///This method will return number picker
  _buildItemQtyPicker(
      List<OrderItemEntity> orderEntities, int index, Function update) {
    return SizedBox(
      child: StatefulBuilder(
        builder: (context, setState) {
          return CommonCartNumberPicker(
              onChange: (value) {
                double unitPrice = orderEntities[index].unitPrice ?? 0.0;
                double subTotal = (unitPrice * value);

                OrderItemEntity orderItemEntity = orderEntities[index];
                orderItemEntity.qty = value;
                orderItemEntity.subTotal = subTotal;

                if (value < 1) {
                  ClearCartConfirmationDialog(
                    context: context,
                    clearOrder: orderEntities.length == 1,
                    masterClearTitle: "Clear cart ?",
                    masterClearDetail:
                        "You can save the cart and place the order later ?",
                    itemClearTitle: "Remove Item",
                    itemCleatDetail: "Do you want to remove this item ?",
                    onSelect: (confirmation) {
                      setState(() {
                        ///Remove order if order item length = 1
                        ///Item remove if order item length > 1
                        if (confirmation) {
                          if (orderEntities.length == 1) {
                            OrderMasterRepository().deleteOrder(1);
                          }
                          OrderRepository()
                              .deleteItem(orderItemEntity.productId!);
                        } else {
                          orderEntities[index].qty = 1;
                        }
                        update();
                      });
                    },
                  ).showClearCartConfirmation();
                } else {
                  OrderRepository().updateOrderItemQtyRecode(
                      orderItemEntity, orderItemEntity.productId!);
                  update();
                }

                OrderMasterRepository().updateOrderMasterRecode(
                    OrderMasterEntity(updatedDate: getCurrentTimeStampText()));
              },
              defaultValue: orderEntities[index].qty ?? 0);
        },
      ),
    );
  }

  ///
  ///This method will return all summary information contents
  _buildSummary() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Wrap(
        children: [
          _buildSummaryTitle(),
          _buildCategorySummary(),
          _buildSubTotal(),
          _buildDiscount(),
          _buildGrandTotal(),
        ],
      ),
    );
  }

  ///
  ///This method will return summary title
  _buildSummaryTitle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: const Text(
        'Summary',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }

  ///
  ///This method will return category wise summary
  _buildCategorySummary() {
    return FutureBuilder(
      future: OrderRepository().getCategoryWiseSummary(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Widget> items = [];

          for (var element in snapshot.data!) {
            items.add(Row(
              children: [
                Text(
                  '${element.category}',
                  style: const TextStyle(
                      fontSize: 14, color: CommonCustomColor.defaultTextColor),
                ),
                const Spacer(),
                Text(
                  '${element.qty}',
                  style: const TextStyle(
                      fontSize: 14, color: CommonCustomColor.defaultTextColor),
                )
              ],
            ));
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: Column(
              children: [...items],
            ),
          );
        }
        return Container();
      },
    );
  }

  ///
  ///This method will return sub total of oder items
  _buildSubTotal() {
    return Row(
      children: [
        const Text(
          'Sub Total',
          style: TextStyle(
              fontSize: 14, color: CommonCustomColor.defaultTextColor),
        ),
        const Spacer(),
        FutureBuilder(
          future: OrderRepository().getSubTotal(),
          builder: (context, snapshot) {
            return Text(snapshot.hasData ? "\$${snapshot.data!}" : '\$0.0',
                style: const TextStyle(
                  fontSize: 14,
                  color: CommonCustomColor.defaultTextColor,
                  decoration: TextDecoration.lineThrough,
                ));
          },
        )
      ],
    );
  }

  ///
  ///This method will return total of discounted items
  _buildDiscount() {
    return Row(
      children: [
        const Text(
          'Discount',
          style: TextStyle(fontSize: 14, color: CommonCustomColor.pendingColor),
        ),
        const Spacer(),
        FutureBuilder(
          future: OrderRepository().getDiscount(),
          builder: (context, snapshot) {
            return Text(
              snapshot.hasData ? "\$${snapshot.data!}" : '\$0.0',
              style: const TextStyle(
                  fontSize: 14, color: CommonCustomColor.pendingColor),
            );
          },
        )
      ],
    );
  }

  ///
  ///This method will return grand total of order
  _buildGrandTotal() {
    return Row(
      children: [
        const Text(
          'Grand Total',
          style: TextStyle(
              fontSize: 18, color: CommonCustomColor.defaultTextColor),
        ),
        const Spacer(),
        FutureBuilder(
          future: OrderRepository().getFormattedGrandTotal(),
          builder: (context, snapshot) {
            return Text(
              snapshot.hasData ? "\$${snapshot.data!}" : '\$0.0',
              style: const TextStyle(
                  fontSize: 18, color: CommonCustomColor.defaultTextColor),
            );
          },
        )
      ],
    );
  }

  Widget _buildDeliveryNoteField() {
    return Container(
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Note',
              style: TextStyle(fontSize: 13),
            ),
            TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
              controller: _deliveryNoteTextController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 13),
              maxLines: 5,
              validator: (value) {
                if (value!.isEmpty) {
                  //return CommonMessage.usernameCanNotEmpty;
                }
                return null;
              },
              onSaved: (value) {
                //_username = value!;
              },
            ),
          ],
        ));
  }

  Widget _buildDeliveryDateField() {
    return Container(
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Date',
              style: TextStyle(fontSize: 13),
            ),
            TextFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    contentPadding: EdgeInsets.all(10),
                    suffixIcon: Icon(Icons.calendar_month)),
                readOnly: true,
                controller: _deliveryDateTextController,
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.done,
                style: const TextStyle(fontSize: 13),
                maxLines: 1,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)));

                  if (null != pickedDate) {
                    String formattedDate =
                        DateFormat(CommonConstants.usDateFormat)
                            .format(pickedDate);
                    _deliveryDateTextController.text = formattedDate;
                  } else {
                    _deliveryDateTextController.clear();
                  }
                }),
          ],
        ));
  }

  _buildForm() {
    return Form(
      key: _deliveryInfoFormKey,
      child: Column(
        children: [_buildDeliveryNoteField(), _buildDeliveryDateField()],
      ),
    );
  }

  _buildPlaceOrderButton() {
    return FutureBuilder(
      future: OrderMasterRepository().isOrderExist(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            margin:
                const EdgeInsets.only(top: 10, bottom: 20, left: 15, right: 15),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    minimumSize: const Size.fromHeight(50)),
                onPressed: handelOnPressPurchaseOrder(context, snapshot),
                child: isProcess
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        "Place the Order",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )),
          );
        }

        return Container();
      },
    );
  }

  handelOnPressPurchaseOrder(
      BuildContext context, AsyncSnapshot<bool> snapshot) {
    if (isProcess) {
      return null;
    }

    if (snapshot.hasError) {
      return null;
    }

    if (!snapshot.data!) {
      return null;
    }

    return () async {
      if (_deliveryInfoFormKey.currentState!.validate()) {
        setState(() {
          isProcess = true;
        });

        final userId = await UserMasterRepository().getUserId();
        final total = await OrderRepository().getPeoGrandTotal();
        final orderItemList = await OrderRepository().getOrderItemList();
        final deliveryNote = _deliveryNoteTextController.text;
        final deliveryDate = _deliveryDateTextController.text != ''
            ? DateFormat(CommonConstants.usDateFormat)
                .parse(_deliveryDateTextController.text)
            : DateTime.now();
        ////
        OrderDto orderDto = OrderDto(
            user: UserDto(id: userId),
            orderItems: orderItemList,
            orderState: 'PENDING',
            orderSource: 'WEB',
            deliveryDate: deliveryDate,
            notes: deliveryNote,
            total: total);

        Response response = await OrderService().postOrder(orderDto);
        if (!context.mounted) return;
        if (response.statusCode == 201) {
          ////
          showSuccessMessage(
              message: 'Your order successfully processed!', context: context);
          ////
          OrderRepository().clearOrderItems();
          OrderMasterRepository().clearOrderMaster();
          ////
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (context) {
              return const MainScreenWidget(
                defaultIndex: 0,
              );
            },
          ), (route) => false);
        } else {
          showErrorMessage(
              message: 'Order placement failed. Please contact support!',
              context: context);
        }

        ///
        setState(() {
          isProcess = false;
        });
      }
    };
  }
}
