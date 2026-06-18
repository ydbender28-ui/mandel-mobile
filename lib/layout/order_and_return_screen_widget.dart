import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/mandel_network_image.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/round_number_picker.dart';
import 'package:mandel_mobile_app/model/order_dto.dart';
import 'package:mandel_mobile_app/model/order_item_dto.dart';
import 'package:mandel_mobile_app/model/price_dto.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/model/product_information_change.dart';
import 'package:mandel_mobile_app/model/return_dto.dart';
import 'package:mandel_mobile_app/model/return_item_dto.dart';
import 'package:mandel_mobile_app/model/user_dto.dart';
import 'package:mandel_mobile_app/service/product_service.dart';
import 'package:mandel_mobile_app/service/return_service.dart';
import 'package:mandel_mobile_app/utility/common_cart_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/common_return_utility.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/label_print.dart';
import 'package:mandel_mobile_app/utility/message_utility.dart';
import 'package:toggle_switch/toggle_switch.dart';

class OrderAndReturnScreenWidget extends StatefulWidget {
  final OrderDto? order;
  final ProductDto? productDto;
  final int index;
  final bool fromOrder;
  final Function onClose;
  final bool showReturn;
  final bool showAddToCart;
  final double? discountedPrice;

  const OrderAndReturnScreenWidget(
      {super.key,
      this.order,
      this.productDto,
      this.showAddToCart = true,
      this.showReturn = true,
      required this.index,
      required this.fromOrder,
      required this.onClose,
      this.discountedPrice});

  @override
  State<OrderAndReturnScreenWidget> createState() =>
      _OrderAndReturnScreenWidgetState();
}

class _OrderAndReturnScreenWidgetState extends State<OrderAndReturnScreenWidget>
    with MessageUtility, CommonUtility {
  final _otherReasonTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final StreamController<ProductInformationChange> _productInformationChange =
      StreamController.broadcast();

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

  String groupValue = 'Unsaleable';

  String _packCondition = 'FULL_PACK';

  int _damagedReturnPct = 50;

  bool isProcess = false;
  bool _reasonSelected = false;

  @override
  void initState() {
    super.initState();
    ReturnService().getReturnSettings().then((resp) {
      if (resp.statusCode == 200 && resp.data != null && mounted) {
        setState(() {
          _damagedReturnPct = (resp.data['damagedReturnPct'] as num?)?.toInt() ?? 50;
        });
      }
    }).catchError((_) {});
  }

  ///
  ///This method will return order item sub total
  String _getTotalReturnItemPrice(double unitPrice, int qty) {
    double total = unitPrice * qty;
    // streamController.sink.add(total.toStringAsFixed(2));
    return total.toStringAsFixed(2);
  }

  ProductDto getProductInfo() {
    if (widget.fromOrder) {
      ProductDto productDto = widget.order!.orderItems![widget.index].product!;
      productDto.price = [];
      productDto.price!.add(
          PriceDto(price: widget.order!.orderItems![widget.index].unitPrice));

      return productDto;
    }

    return widget.productDto!;
  }

  OrderItem getOrderItemInfo() {
    return widget.order!.orderItems![widget.index];
  }

  ProductInformationChange getInitialData() {
    String price = "0.00";
    if (widget.fromOrder) {
      price = widget.order!.orderItems![widget.index].getSubTotal();
    }
    price = getProductInfo().getUnitPrice();

    return ProductInformationChange(
        returnType: returnTypeValue, subTotal: price);
  }

  double getProductUnitPrice(bool calculatePiecePrice) {
    double unitPrice = 0.00;
    if (widget.fromOrder) {
      unitPrice =
          widget.order!.orderItems![widget.index].getNonFormattedUnitPrice();
    }
    unitPrice = getProductInfo().getNonFormatPrice();

    if (calculatePiecePrice && (getProductInfo().singleCount ?? 0) > 0) {
      unitPrice = unitPrice / getProductInfo().singleCount!;
    }
    return unitPrice;
  }

  double getProductNonDiscountedUnitPrice() {
    if (widget.fromOrder) {
      return widget.order!.orderItems![widget.index].getNonFormattedUnitPrice();
    }
    return getProductInfo().getNonDiscounterFormatPrice();
  }

  @override
  Widget build(BuildContext context) {
    returnTypeValue = (widget.productDto?.isSingle == true) ? "PIECE" : "BOX";
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: _buildBackButton(context),
        title: _buildTitle(getProductInfo().getProductName()),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          ProductDto productDto = getProductInfo();
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    _buildProductImage(productDto),
                    _buildNumberPicker(productDto, widget.fromOrder),
                    if (widget.showReturn) _buildBoxSingleSwitch(productDto),
                    _buildInformation(productDto),
                    const Expanded(child: SizedBox()),
                    if ((productDto.quantity ?? 1) <= 0) _buildOutOfStock(productDto),
                    const Expanded(child: SizedBox()),
                    _buildButtonList(getProductInfo())
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle(String product) {
    return Row(
      children: [
        Flexible(
            child: Text(
          product,
          maxLines: 5,
          style: const TextStyle(fontSize: 22),
        ))
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
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

  _buildBoxSingleSwitch(ProductDto productDto) {
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
            getProductUnitPrice(piecePrice), productDto.tempQty ?? 1);
        _productInformationChange.sink.add(ProductInformationChange(
            returnType: returnTypeValue, subTotal: subTotal));
      },
    );
  }

  _buildProductImage(ProductDto productDto) {
    final url = (productDto.productImages?.isNotEmpty == true && productDto.productImages![0].url != null)
        ? productDto.productImages![0].url!
        : '';
    final onDiscount = widget.discountedPrice != null;
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 20, bottom: 10),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            url.startsWith('http')
              ? MandelNetworkImage(url: url, width: 245, height: 245)
              : Image.asset('assets/images/mandel_no_image.jpg', fit: BoxFit.cover, height: 245, width: 245),
            if (onDiscount)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFdc2626),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('SALE',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _buildNumberPicker(ProductDto productDto, bool fromOrder) {
    ////
    int defaultValue = fromOrder ? getOrderItemInfo().quantity ?? 0 : 1;
    ////
    return RoundNumberPicker(
      defaultValue: defaultValue,
      fromOrder: fromOrder,
      isLimit: fromOrder,
      onChange: (value) {
        productDto.tempQty = value;
        bool piecePrice = returnTypeValue == returnTypes[1];
        String price =
            _getTotalReturnItemPrice(getProductUnitPrice(piecePrice), value);

        _productInformationChange.sink.add(ProductInformationChange(
            returnType: returnTypeValue, subTotal: price));
      },
    );
  }

  _buildInformation(ProductDto product) {
    bool piecePrice = returnTypeValue == returnTypes[1];
    return Container(
      margin: const EdgeInsets.only(left: 21, right: 21, top: 50, bottom: 30),
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
                  Text(product.getCategoryName(),
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
                  Text(product.getBrandName(),
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
                  Text(product.getSize(),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: CommonCustomColor.defaultTextColor))
                ],
              ),
              Row(
                children: [
                  const Text('Product Code : ',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: CommonCustomColor.menuItemColor)),
                  Text(product.getProductCode(),
                      style: const TextStyle(
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
                  Visibility(
                    visible: widget.discountedPrice != null || getProductInfo().isDealExist(),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Text(
                          getProductInfo().getUnitPrice(),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: CommonCustomColor.pendingColor,
                              decoration: TextDecoration.lineThrough)),
                    ),
                  ),
                  StreamBuilder(
                      initialData: getInitialData(),
                      stream: _productInformationChange.stream,
                      builder: (context, snapshot) {
                        ProductInformationChange change =
                            snapshot.data as ProductInformationChange;
                        bool picePrice = change.returnType == returnTypes[1];
                        final String unitPrice;
                        if (widget.discountedPrice != null && !picePrice) {
                          unitPrice = widget.discountedPrice!.toStringAsFixed(2);
                        } else {
                          unitPrice = getProductUnitPrice(picePrice).toStringAsFixed(2);
                        }
                        final bool isSalePrice = widget.discountedPrice != null && !picePrice;
                        return AnimatedSwitcher(
                          duration: const Duration(microseconds: 200),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: Text(
                            "\$$unitPrice per ${picePrice ? 'Piece' : 'Box'}",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSalePrice
                                    ? const Color(0xFFdc2626)
                                    : CommonCustomColor.defaultTextColor),
                          ),
                        );
                      })
                  // Text(getProductUnitPrice(piecePrice).toStringAsFixed(2),
                  //     style: const TextStyle(
                  //         fontSize: 15,
                  //         fontWeight: FontWeight.w600,
                  //         color: CommonCustomColor.defaultTextColor))
                ],
              ),
              if (product.expiryDate != null && product.expiryDate!.isNotEmpty)
                _buildExpiryRow(product.expiryDate!),
              _buildDealList(product)
            ],
          ),
          StreamBuilder(
            initialData: getInitialData(),
            stream: _productInformationChange.stream,
            builder: (context, snapshot) {
              print(snapshot);
              ProductInformationChange change =
                  snapshot.data as ProductInformationChange;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text("\$${change.subTotal}",
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w600)),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildOutOfStock(ProductDto productDto) {
    return Container(
      margin: const EdgeInsets.only(top: 0, left: 21, right: 21),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(8),
                  color: CommonCustomColor.warningColor,
                  strokeWidth: 1,
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                        color: CommonCustomColor.warningColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                              margin: const EdgeInsets.all(15),
                              child: const Center(
                                child: Text(
                                  "Out of stock",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                              )),
                        )
                      ],
                    ),
                  )))
        ],
      ),
    );
  }

  String _getBarcodeValue(ProductDto product) {
    if (product.barcodes != null && product.barcodes!.isNotEmpty) {
      final mpr = product.barcodes!.firstWhere(
        (b) => b.value != null && b.value!.startsWith('MPR:'),
        orElse: () => product.barcodes!.first,
      );
      if (mpr.value != null && mpr.value!.isNotEmpty) return mpr.value!;
    }
    if (product.id != null) {
      return 'MPR:${product.id.toString().padLeft(6, '0')}';
    }
    return product.productCode ?? '';
  }

  void _showPrintLabelDialog(ProductDto productDto) {
    final priceController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Print Shelf Label',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(productDto.getProductName(),
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Price (optional)',
                prefixText: '\$ ',
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                final price = priceController.text.trim();
                printLabel(
                  productName: productDto.getProductName(),
                  barcodeValue: _getBarcodeValue(productDto),
                  price: price.isEmpty ? null : price,
                );
              },
              icon: const Icon(Icons.print_outlined),
              label: const Text('Print', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonList(ProductDto productDto) {
    return Container(
      margin: const EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: () => _showPrintLabelDialog(productDto),
            icon: const Icon(Icons.print_outlined),
            label: const Text('Print Label',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              side: const BorderSide(color: Color(0xFFc9a84c)),
              foregroundColor: const Color(0xFFc9a84c),
            ),
          ),
          const SizedBox(height: 10),
          Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.showReturn)
            Expanded(
              child: productDto.isReturnable == false
                  ? ElevatedButton.icon(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9E9E9E),
                          minimumSize: const Size.fromHeight(50)),
                      icon: const Icon(Icons.block_outlined),
                      label: const Text(
                        'Not Returnable',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ))
                  : ElevatedButton.icon(
                      onPressed: () {
                        _showReturnReasonDialog(productDto);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CommonCustomColor.defaultTextColor,
                          minimumSize: const Size.fromHeight(50)),
                      icon: const Icon(Icons.assignment_return_outlined),
                      label: const Text(
                        'Add to Return',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      )),
            ),
          Visibility(
            visible: !widget.fromOrder,
            child: const SizedBox(
              width: 20,
            ),
          ),
          if (widget.showAddToCart)
            Visibility(
              visible: !widget.fromOrder,
              child: Expanded(
                child: ElevatedButton.icon(
                  onPressed: productDto.quantity! <= 0
                      ? null
                      : () async {
                          try {
                            await CommonCartUtility().addToCart(
                                productDto: productDto,
                                qty: productDto.tempQty ?? 1);
                            if (!mounted) return;
                            widget.onClose();
                            Navigator.of(context).pop();
                          } catch (e) {
                            showErrorMessage(
                                message:
                                    "Could not add product to the cart try again later ${e.toString()}",
                                context: context);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text(
                    'Add to cart',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
            )
        ],
      ),
        ],
      ),
    );
  }

  // void _buildReturnTypeBottomSheet(ProductDto productDto) {
  //   final List<ConfirmationAction> actions = [
  //     ConfirmationAction(
  //         text: 'Return Selected Item',
  //         onSelect: () {
  //           Navigator.pop(context);
  //           _showReturnReasonDialog(productDto);
  //         }),
  //     ConfirmationAction(
  //         text: 'Add To Return List',
  //         onSelect: () {
  //           CommonReturnUtility().addToReturnList(
  //               productDto: productDto, qty: productDto.tempQty ?? 1);
  //           Navigator.of(context)
  //             ..pop()
  //             ..pop();
  //         }),
  //   ];

  //   showModalBottomSheet(
  //       context: context,
  //       isDismissible: true,
  //       isScrollControlled: true,
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
  //       builder: (context) {
  //         return StatefulBuilder(builder: (BuildContext context, setState) {
  //           return MultiActionConfirmationWidget(
  //               title: 'Store or process ?', actions: actions);
  //         });
  //       });
  // }

  void _showReturnReasonDialog(ProductDto product) {
    _packCondition = 'FULL_PACK';
    _reasonSelected = false;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              final bool isPiece = _packCondition == 'PIECE';
              final bool isPartial = _packCondition == 'PARTIAL';
              final double basePrice = getProductUnitPrice(isPiece);
              final double creditPrice = isPartial ? basePrice * _damagedReturnPct / 100 : basePrice;
              final double totalCredit = creditPrice * (product.tempQty ?? 1);
              final bool hasPieceOption = (getProductInfo().singleCount ?? 0) > 0;

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
                            const SizedBox(width: 10),
                            IconButton(
                              icon: Image.asset(
                                'assets/images/mandel_close_icon.png',
                                width: 24,
                                height: 24,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            )
                          ],
                        ),
                        ..._buildReasonList(setState),
                        _buildOtherReasonInput(),
                        // Pack condition section
                        const SizedBox(height: 16),
                        const Text('Pack Condition',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _packOptionCard(setState, 'FULL_PACK', Icons.inventory_2_outlined, 'Full\nPack'),
                            const SizedBox(width: 8),
                            if (hasPieceOption) ...[
                              _packOptionCard(setState, 'PIECE', Icons.filter_1_outlined, 'By\nPiece'),
                              const SizedBox(width: 8),
                            ],
                            _packOptionCard(setState, 'PARTIAL', Icons.broken_image_outlined, 'Partial /\nDamaged'),
                          ],
                        ),
                        // Credit preview — only shown after reason is selected
                        if (_reasonSelected)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isPartial ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Return Credit',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '\$${totalCredit.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800,
                                    color: isPartial ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        _buildReturnProductButton(setState, product)
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
            _reasonSelected = true;
          });
        },
      ));
    }
    return reasonWidgetList;
  }

  _buildReturnTypeList(StateSetter setState) {
    List<Widget> selectionList = [];

    for (var element in returnTypes) {
      selectionList.add(RadioListTile<String>(
        contentPadding: EdgeInsets.zero,
        title: Text(element),
        value: element,
        groupValue: returnTypeValue,
        onChanged: (value) {
          setState(() {
            returnTypeValue = value!;
          });
        },
      ));
    }
    return selectionList;
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

  Widget _packOptionCard(StateSetter setState, String value, IconData icon, String label) {
    final bool selected = _packCondition == value;
    const accent = Color(0xFF4F46E5);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _packCondition = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? accent.withOpacity(0.10) : Colors.grey.shade50,
            border: Border.all(
              color: selected ? accent : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: selected ? accent : Colors.grey.shade500),
              const SizedBox(height: 6),
              Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? accent : Colors.grey.shade700,
                  height: 1.3,
                )),
            ],
          ),
        ),
      ),
    );
  }

  _buildReturnProductButton(StateSetter state, ProductDto productDto) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
      child: ElevatedButton(
        onPressed: () async {
          final bool piecePrice = _packCondition == 'PIECE';
          final double basePrice = getProductUnitPrice(piecePrice);
          final double returnPrice = _packCondition == 'PARTIAL'
              ? basePrice * _damagedReturnPct / 100
              : basePrice;
          await CommonReturnUtility().addToReturnList(
              productDto: productDto,
              returnReason: groupValue,
              returnType: _packCondition,
              qty: productDto.tempQty ?? 1,
              returnPrice: returnPrice);
          if (!mounted) return;
          // Return-only flow: pop dialog + detail screen + search screen → back to return cart
          if (!widget.showAddToCart && widget.showReturn) {
            Navigator.of(context)..pop()..pop()..pop();
          } else {
            Navigator.of(context)..pop()..pop();
          }
        },
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

  Widget _buildExpiryRow(String expiryDate) {
    // Try to parse the expiry date to calculate days remaining
    int? daysLeft;
    try {
      final parts = expiryDate.split(' ');
      if (parts.length == 3) {
        // Format: "Jun 1, 2025" → DateTime
        final months = {'Jan':1,'Feb':2,'Mar':3,'Apr':4,'May':5,'Jun':6,
                        'Jul':7,'Aug':8,'Sep':9,'Oct':10,'Nov':11,'Dec':12};
        final month = months[parts[0]];
        final day = int.tryParse(parts[1].replaceAll(',', ''));
        final year = int.tryParse(parts[2]);
        if (month != null && day != null && year != null) {
          final expiry = DateTime(year, month, day);
          daysLeft = expiry.difference(DateTime.now()).inDays;
        }
      }
    } catch (_) {}

    Color labelColor;
    if (daysLeft != null && daysLeft <= 30) {
      labelColor = const Color(0xFFdc2626);
    } else if (daysLeft != null && daysLeft <= 90) {
      labelColor = const Color(0xFFd97706);
    } else {
      labelColor = const Color(0xFF16a34a);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Text('Expires : ',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: CommonCustomColor.menuItemColor)),
          Text(
            daysLeft != null ? '$expiryDate  (${daysLeft}d left)' : expiryDate,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: labelColor),
          ),
        ],
      ),
    );
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
        margin: const EdgeInsets.only(top: 25),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [...deals],
          ),
        ),
      ),
    );
  }

  postReturnProduct(StateSetter state, ProductDto productDto) {
    if (isProcess) {
      return null;
    }

    return () async {
      List<ReturnItemDto> returnItemList = [];

      if (_formKey.currentState!.validate()) {
        state(() {
          isProcess = !isProcess;
        });

        ReturnItemDto returnDto = ReturnItemDto(
            product: ProductDto(id: productDto.id),
            quantity: productDto.tempQty ?? 1,
            unitPrice: productDto.getNonFormatPrice(),
            returnReason: groupValue,
            note: _otherReasonTextController.text,
            returnType: returnTypeValue,
            returnStatus: 'PENDING');

        if (widget.fromOrder) {
          returnDto.order = OrderDto(id: widget.order!.id);
        }

        returnItemList.add(returnDto);

        Response response = await ReturnService().postReturn(ReturnDto(
            returnItems: returnItemList,
            user: UserDto(id: widget.order!.user!.id)));

        if (!context.mounted) return;

        Navigator.of(context)
          ..pop()
          ..pop();

        if (response.statusCode == 201) {
          showSuccessMessage(
              message: 'Your return has been successfully processed!',
              context: context);
        } else {
          showErrorMessage(
              message: 'Return placement failed. Please contact support!',
              context: context);
        }

        state(() {
          isProcess = !isProcess;
        });
      }
    };
  }
}
