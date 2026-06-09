import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/round_number_picker.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/model/product_information_change.dart';
import 'package:mandel_mobile_app/utility/common_cart_utility.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/common_return_utility.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MultipleProductOptionWidget extends StatefulWidget {
  final ProductDto product;
  final bool showAddToCart;
  final bool showAddToReturn;

  const MultipleProductOptionWidget(
      {super.key,
      required this.product,
      this.showAddToCart = true,
      this.showAddToReturn = false});

  @override
  State<MultipleProductOptionWidget> createState() =>
      _MultipleProductOptionWidgetState();
}

class _MultipleProductOptionWidgetState
    extends State<MultipleProductOptionWidget> with CommonUtility {
  List<String> returnReasons = [
    'Unsaleable',
    'Damages',
    'OverStock',
    'Ordered Wrong',
    'Manufacturer Defect',
    'Other',
  ];

  List<String> returnTypes = ["BOX", "PIECE"];

  String returnTypeValue = "BOX";

  String returnReason = 'Unsaleable';

  final _otherReasonTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // final StreamController streamController = StreamController.broadcast();
  final StreamController<ProductInformationChange> _productInformationChange =
      StreamController.broadcast();

  @override
  Widget build(BuildContext context) {
    returnTypeValue = widget.product.isSingle! ? "PIECE" : "BOX";
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInformation(widget.product),
              const Spacer(flex: 1),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      RoundNumberPicker(
                          width: 240,
                          defaultValue: 1,
                          isLimit: false,
                          fromOrder: false,
                          onChange: (value) {
                            widget.product.tempQty = value;
                            double total = 0.0;
                            if (widget.showAddToReturn) {
                              bool piecePrice = returnTypeValue == "BOX";
                              total = getProductUnitPrice(piecePrice) * value;
                            } else {
                              total = getProductUnitPrice(false) * value;
                            }
                            _productInformationChange.sink.add(
                                ProductInformationChange(
                                    returnType: returnTypeValue,
                                    subTotal: total.toStringAsFixed(2)));
                            // streamController.sink.add(total.toStringAsFixed(2));
                          }),
                    ],
                  ),
                  Row(
                    children: [_buildPricing(widget.product)],
                  ),
                  if (widget.showAddToReturn)
                    Row(
                      children: [_buildReturnTypeSwitch()],
                    )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      if (widget.showAddToCart) _buildAddButton(widget.product),
                      if (widget.showAddToReturn)
                        _buildAddToReturnButton(widget.product)
                    ],
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInformation(ProductDto productDt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productDt.getProductName(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 8),
              child: Text(
                productDt.getCategoryName(),
                style: const TextStyle(fontSize: 12),
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 8),
              child: Text(productDt.getBrandName(),
                  style: const TextStyle(fontSize: 12),
                  softWrap: false,
                  overflow: TextOverflow.ellipsis),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 8),
              child: Text(productDt.getSize(),
                  style: const TextStyle(fontSize: 12),
                  softWrap: false,
                  overflow: TextOverflow.ellipsis),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 8),
              child: _buildUnitPrice(productDt),
            )
          ],
        )
      ],
    );
  }

  Widget _buildUnitPrice(ProductDto productDto) {
    return StreamBuilder(
        stream: _productInformationChange.stream,
        initialData: getInitialData(),
        builder: (context, snapshot) {
          ProductInformationChange change =
              snapshot.data as ProductInformationChange;
          bool picePrice = change.returnType == returnTypes[1];
          String unitPrice = getProductUnitPrice(picePrice).toStringAsFixed(2);
          return AnimatedSwitcher(
              duration: const Duration(microseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Row(
                children: [
                  Text(
                    "\$$unitPrice per ${picePrice ? 'Piece' : 'Box'}",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  // Text(
                  //   " per ${picePrice ? 'Piece' : 'Box'}",
                  //   style: const TextStyle(fontSize: 18),
                  // )
                ],
              ));
        });
  }

  Widget _buildPricing(ProductDto productDto) {
    return StreamBuilder(
        initialData: getInitialData(),
        stream: _productInformationChange.stream,
        builder: (context, snapshot) {
          ProductInformationChange change =
              snapshot.data as ProductInformationChange;
          bool picePrice = change.returnType == returnTypes[1];
          String subTotal = _getTotalReturnItemPrice(
              getProductUnitPrice(picePrice), productDto.tempQty ?? 1);
          return AnimatedSwitcher(
              duration: const Duration(microseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Row(
                children: [
                  Text(
                    "\$$subTotal",
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w600),
                  ),
                  // Text(
                  //   " per ${picePrice ? 'Piece' : 'Box'}",
                  //   style: const TextStyle(fontSize: 18),
                  // )
                ],
              ));
        });
  }

  Widget _buildAddButton(ProductDto productDto) {
    return Column(
      children: [
        Center(
            child: ElevatedButton(
                onPressed: () async {
                  await CommonCartUtility().addToCart(
                      productDto: productDto, qty: productDto.tempQty ?? 1);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
                child: const FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    "Add",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                )))
      ],
    );
  }

  Widget _buildAddToReturnButton(ProductDto productDto) {
    return Column(
      children: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              _handleAddToReturn(productDto);
            },
            child: const FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                "Return",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildViewButton(ProductDto productDto) {
    return Container(
      color: Colors.red,
      child: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: const FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              "View",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReturnTypeSwitch() {
    return ToggleSwitch(
      initialLabelIndex: 0,
      totalSwitches: 2,
      labels: const ['Box', 'Piece'],
      onToggle: (index) {
        returnTypeValue = returnTypes[index!];

        print('switched to index $index');
        print('returnTypeValue $returnTypeValue');
        bool piecePrice = returnTypeValue == returnTypes[1];

        String subTotal = _getTotalReturnItemPrice(
            getProductUnitPrice(piecePrice), widget.product.tempQty ?? 1);
        _productInformationChange.sink.add(ProductInformationChange(
            returnType: returnTypeValue, subTotal: subTotal));
      },
    );
  }

  String _getTotalReturnItemPrice(double unitPrice, int qty) {
    double total = unitPrice * qty;
    // streamController.sink.add(total.toStringAsFixed(2));
    return total.toStringAsFixed(2);
  }

  _handleAddToCart(ProductDto productDto) {}

  _handleAddToReturn(ProductDto productDto) {
    _showReturnReasonDialog(productDto);
  }

  ProductInformationChange getInitialData() {
    String price = "0.00";

    price = widget.product.getUnitPrice();

    return ProductInformationChange(
        returnType: returnTypeValue, subTotal: price);
  }

  double getProductUnitPrice(bool calculatePiecePrice) {
    double unitPrice = 0.00;

    unitPrice = widget.product.getNonFormatPrice();

    if (calculatePiecePrice) {
      unitPrice = unitPrice / widget.product.singleCount!;
    }
    return unitPrice;
  }

  _buildOtherReasonInput() {
    return Form(
      key: _formKey,
      child: Visibility(
          visible: 'Other' == returnReason,
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

  Widget _buildAddToReturnContent() {
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

  _buildReturnProductButton(StateSetter state, ProductDto productDto) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
      child: ElevatedButton(
        onPressed: () {
          //Change unit price and add
          bool piecePrice = returnTypeValue == returnTypes[1];
          double returnPrice = getProductUnitPrice(piecePrice);
          CommonReturnUtility().addToReturnList(
              productDto: productDto,
              returnReason: returnReason,
              returnType: returnTypeValue,
              qty: productDto.tempQty ?? 1,
              returnPrice: returnPrice);
          Navigator.of(context)
            ..pop()
            ..pop();
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: CommonCustomColor.defaultTextColor,
        ),
        child: _buildAddToReturnContent(),
      ),
    );
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
        groupValue: returnReason,
        onChanged: (value) {
          state(() {
            returnReason = value!;
          });
        },
      ));
    }
    return reasonWidgetList;
  }

  void _showReturnReasonDialog(ProductDto product) {
    showModalBottomSheet(
        isDismissible: true,
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
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
                            "Reason to return",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          )),
                          const SizedBox(
                            width: 10,
                          ),
                          IconButton(
                              onPressed: () {},
                              icon: Image.asset(
                                'assets/images/mandel_close_icon.png',
                                width: 24,
                                height: 24,
                              ))
                        ],
                      ),
                      ..._buildReasonList(setState),
                      _buildOtherReasonInput(),
                      _buildReturnProductButton(setState, product)
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }
}
