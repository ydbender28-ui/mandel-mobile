import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/db/entity/return_item_entity.dart';
import 'package:mandel_mobile_app/db/entity/return_master_entity.dart';
import 'package:mandel_mobile_app/db/repository/return_item_repository.dart';
import 'package:mandel_mobile_app/db/repository/return_master_repository.dart';
import 'package:mandel_mobile_app/db/repository/user_master_repository.dart';
import 'package:mandel_mobile_app/layout/bottom_sheet_dialog/clear_cart_confirmation_dialog.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/common_cart_number_picker.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/model/return_dto.dart';
import 'package:mandel_mobile_app/model/return_item_dto.dart';
import 'package:mandel_mobile_app/model/user_dto.dart';
import 'package:mandel_mobile_app/service/return_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/message_utility.dart';

class ReturnCartWidget extends StatefulWidget {
  const ReturnCartWidget({super.key});

  @override
  State<ReturnCartWidget> createState() => _ReturnCartWidgetState();
}

class _ReturnCartWidgetState extends State<ReturnCartWidget>
    with CommonUtility, MessageUtility {
  final _otherReasonTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<String> returnReasons = [
    'Unsaleable',
    'Damages',
    'OverStock',
    'Ordered Wrong',
    'Manufacturer Defect',
    'Other'
  ];

  String groupValue = 'Unsaleable';

  bool isProcess = false;

  @override
  void dispose() {
    _otherReasonTextController.dispose();
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
              'Return Cart',
              style: TextStyle(fontSize: 24),
            ),
            FutureBuilder(
              future: ReturnMasterRepository().getLastUpdatedTimeStamp(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Last Updated: ${snapshot.data}',
                      style: const TextStyle(fontSize: 12));
                }

                if (!snapshot.hasData) {
                  return const Text('Empty returns',
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
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReturnDetailTitle(),
            _buildOrderList(context),
            _buildSummary(),
            _buildPlaceOrderButton()
          ],
        ),
      ),
    );
  }

  _buildReturnDetailTitle() {
    return Container(
      margin: const EdgeInsets.only(left: 15, top: 15, bottom: 10),
      child: const Text('Return Details',
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
      future: ReturnItemRepository().getReturnList(),
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
                bool piecePrice = snapshot.data![index].returnType == "PIECE";
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
                                    snapshot.data![index].returnPrice!
                                        .toStringAsFixed(2),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color:
                                            CommonCustomColor.defaultTextColor),
                                  ),
                                  Text(
                                    " per ${piecePrice ? 'Piece' : 'Box'}",
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
      List<ReturnItemEntity> orderEntities, int index, Function update) {
    return SizedBox(
      child: StatefulBuilder(
        builder: (context, setState) {
          return CommonCartNumberPicker(
              onChange: (value) {
                double unitPrice = orderEntities[index].unitPrice ?? 0.0;
                double discount = orderEntities[index].discount ?? 0.0;
                double subTotal = (unitPrice * value) - discount;

                ReturnItemEntity orderItemEntity = orderEntities[index];
                orderItemEntity.qty = value;
                orderItemEntity.subTotal = subTotal;

                if (value < 1) {
                  ClearCartConfirmationDialog(
                    context: context,
                    clearOrder: orderEntities.length == 1,
                    masterClearTitle: "Clear Returns ?",
                    masterClearDetail:
                        "You can save the return and place the return later ?",
                    itemClearTitle: "Remove Item",
                    itemCleatDetail: "Do you want to remove this item ?",
                    onSelect: (confirmation) {
                      setState(() {
                        ///Remove order if order item length = 1
                        ///Item remove if order item length > 1
                        if (confirmation) {
                          if (orderEntities.length == 1) {
                            ReturnMasterRepository().deleteReturn(1);
                          }
                          ReturnItemRepository()
                              .deleteItem(orderItemEntity.productId!);
                        } else {
                          orderEntities[index].qty = 1;
                        }
                        update();
                      });
                    },
                  ).showClearCartConfirmation();
                } else {
                  ReturnItemRepository().updateReturnItemQtyRecode(
                      orderItemEntity, orderItemEntity.productId!);
                  update();
                }

                ReturnMasterRepository().updateReturnMasterRecode(
                    ReturnMasterEntity(updatedDate: getCurrentTimeStampText()));
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
      future: ReturnItemRepository().getCategoryWiseSummary(),
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
          future: ReturnItemRepository().getSubTotal(),
          builder: (context, snapshot) {
            return Text(snapshot.hasData ? snapshot.data! : '0.0',
                style: const TextStyle(
                    fontSize: 14, color: CommonCustomColor.defaultTextColor));
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
          future: ReturnItemRepository().getDiscount(),
          builder: (context, snapshot) {
            return Text(
              snapshot.hasData ? snapshot.data! : '0.0',
              style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  fontSize: 14,
                  color: CommonCustomColor.pendingColor),
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
          future: ReturnItemRepository().getFormattedGrandTotal(),
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

  _buildPlaceOrderButton() {
    return FutureBuilder(
      future: ReturnMasterRepository().isReturnExist(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            margin:
                const EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    minimumSize: const Size.fromHeight(50)),
                onPressed: postReturnProduct(snapshot),
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
                        "Place the Return",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )),
          );
        }

        return Container();
      },
    );
  }

  void _showReturnReasonDialog() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    margin: const EdgeInsets.only(
                        top: 10, bottom: 20, left: 20, right: 20),
                    child: Wrap(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text(
                                'Reason to return',
                                style: TextStyle(
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
                        ..._buildReasonList(setState),
                        _buildOtherReasonInput(),
                        _buildReturnProductButton(setState)
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  _buildReasonList(StateSetter state) {
    List<Widget> reasonWidgetList = [];

    for (var element in returnReasons) {
      reasonWidgetList.add(RadioListTile<String>(
        contentPadding: EdgeInsets.zero,
        visualDensity: const VisualDensity(
            horizontal: VisualDensity.minimumDensity,
            vertical: VisualDensity.minimumDensity),
        title: Text(element),
        value: element,
        groupValue: groupValue,
        onChanged: (value) {
          state(() {
            groupValue = value!;
          });
        },
      ));
    }
    return reasonWidgetList;
  }

  _buildOtherReasonInput() {
    return Form(
      key: _formKey,
      child: Visibility(
          visible: 'Other' == groupValue,
          child: Container(
              margin: const EdgeInsets.only(
                  left: 15, right: 15, bottom: 10, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Other reason',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  TextFormField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      contentPadding: EdgeInsets.all(10),
                    ),
                    controller: _otherReasonTextController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 3,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Other reason can not empty.';
                      }
                      return null;
                    },
                  ),
                ],
              ))),
    );
  }

  _buildReturnProductButton(StateSetter state) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
      child: ElevatedButton(
        onPressed: () {}, //postReturnProduct(state),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: CommonCustomColor.defaultTextColor,
        ),
        child: _buildAddToReturnContent(),
      ),
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
          width: 20,
        ),
        Text(
          "Add to Return",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        )
      ],
    );
  }

  postReturnProduct(AsyncSnapshot<bool> snapshot) {
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
      List<ReturnItemDto> returnItemList = [];

      // if (_formKey.currentState!.validate()) {
      // state(() {
      //   isProcess = !isProcess;
      // });

      setState(() {
        isProcess = !isProcess;
      });
      final userId = await UserMasterRepository().getUserId();
      List<ReturnItemEntity> returnItemEntityList =
          await ReturnItemRepository().getReturnList();

      for (var element in returnItemEntityList) {
        returnItemList.add(ReturnItemDto(
            product: ProductDto(id: element.productId),
            quantity: element.qty,
            unitPrice: element.unitPrice,
            returnReason: element.returnReason,
            note: _otherReasonTextController.text,
            returnType: element.returnType,
            returnStatus: 'PENDING',
            returnPrice: element.returnPrice));
      }

      Response response = await ReturnService().postReturn(
          ReturnDto(returnItems: returnItemList, user: UserDto(id: userId)));
      if (!context.mounted) return;

      if (response.statusCode == 201) {
        ReturnItemRepository().clearReturnItems();
        ReturnMasterRepository().clearReturnMaster();

        ///
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) {
            return const MainScreenWidget(
              defaultIndex: 0,
            );
          },
        ), (route) => false);

        ///
        showSuccessMessage(
            message: 'Your return has been successfully processed!',
            context: context);
      } else {
        Navigator.of(context).pop();
        showErrorMessage(
            message: 'Return placement failed. Please contact support!',
            context: context);
      }

      // state(() {
      //   isProcess = !isProcess;
      // });
      setState(() {
        isProcess = !isProcess;
      });
      // }
    };
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Image.asset(
        'assets/images/mandel_angle_left.png',
        width: 25,
        height: 24,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
