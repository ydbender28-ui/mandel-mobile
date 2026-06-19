import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandel_mobile_app/db/entity/return_item_entity.dart';
import 'package:mandel_mobile_app/layout/bottom_sheet_dialog/clear_cart_confirmation_dialog.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/common_cart_number_picker.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/multi_action_confirmation_widget.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/model/product_details_options.dart';
import 'package:mandel_mobile_app/model/product_search_arguments.dart';
import 'package:mandel_mobile_app/model/scanner_arguments.dart';
import 'package:mandel_mobile_app/utility/barcode_scanner_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';
import 'package:mandel_mobile_app/utility/message_utility.dart';
import 'package:mandel_mobile_app/utility/return_state.dart';

class ReturnCartWidget extends StatefulWidget {
  const ReturnCartWidget({super.key});

  @override
  State<ReturnCartWidget> createState() => _ReturnCartWidgetState();
}

class _ReturnCartWidgetState extends State<ReturnCartWidget>
    with CommonUtility, MessageUtility, BarcodeScannerUtility {
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

  static const _h1     = Color(0xFF0C0F1E);
  static const _h2     = Color(0xFF1B2860);
  static const _indigo = Color(0xFF4F46E5);
  static const _bg     = Color(0xFFEEF0FA);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddItemButton(),
                _buildReturnDetailTitle(),
                _buildOrderList(context),
                _buildSummary(),
                _buildPlaceOrderButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() {
    final count = ReturnState.itemCount;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_h1, _h2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        Positioned(right: -30, top: -30,
          child: Container(width: 130, height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _indigo.withOpacity(0.1)))),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Return Cart',
                    style: TextStyle(color: Colors.white, fontSize: 22,
                        fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  Text(
                    count > 0
                        ? '$count item${count == 1 ? '' : 's'} to return'
                        : 'No items in cart',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 11)),
                ]),
              ),
              GestureDetector(
                onTap: () => Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(
                      builder: (_) => const MainScreenWidget(defaultIndex: 0)),
                  (r) => false),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: Colors.white),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  void _showAddItemSheet() {
    final List<ConfirmationAction> actions = [
      ConfirmationAction(
        text: 'Search Products',
        onSelect: () {
          Navigator.pop(context);
          Navigator.of(context).pushNamed(
            CommonConstants.searchScreenUrl,
            arguments: ProductSearchArguments(
              filters: {},
              startingIndex: 0,
              productDetailsOptions: ProductDetailsOptions(
                  showAddToCart: false, showReturn: true),
            ),
          ).then((_) {
            if (mounted) setState(() {});
          });
        },
      ),
      ConfirmationAction(
        text: 'Scan Barcode',
        onSelect: () {
          Navigator.pop(context);
          navigateToDefaultScanner(
            context,
            ScannerArguments(
              enableRapidMode: false,
              productDetailsOptions: ProductDetailsOptions(
                  showAddToCart: false, showReturn: true),
            ),
          );
        },
      ),
    ];
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, _) => MultiActionConfirmationWidget(
          title: 'Add Item to Return',
          description:
              'Search for a product by name or scan its barcode to add it to your return.',
          actions: actions,
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

  Widget _buildAddItemButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _showAddItemSheet,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Scan or Search Item to Return',
              style: TextStyle(fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            foregroundColor: _indigo,
            side: const BorderSide(color: _indigo),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  _buildOrderList(BuildContext context) {
    final items = ReturnState.items;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.assignment_return_outlined,
                  size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('No items in return cart',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text('Tap the button above to add items',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade400)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final bool piecePrice = item.returnType == 'PIECE';
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
                      '${item.productName}',
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
                              width: 120,
                              child: Text(
                                item.categoryName ??
                                    CommonConstants.emptyRecodeIndicator,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color:
                                        CommonCustomColor.defaultTextColor),
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
                              item.brandName ??
                                  CommonConstants.emptyRecodeIndicator,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: CommonCustomColor.defaultTextColor),
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
                              item.size ??
                                  CommonConstants.emptyRecodeIndicator,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color:
                                      CommonCustomColor.defaultTextColor),
                            )
                          ],
                        ),
                      ),
                      Text(
                        piecePrice ? 'Per Piece' : 'Per Box',
                        style: const TextStyle(
                            fontSize: 12,
                            color: CommonCustomColor.menuItemColor),
                      ),
                    ],
                  )
                ],
              ),
              const Spacer(),
              _buildItemQtyPicker(items.toList(), index, () {
                setState(() {});
              })
            ],
          ),
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(indent: 10, endIndent: 10);
      },
    );
  }

  _buildItemQtyPicker(
      List<ReturnItemEntity> orderEntities, int index, Function update) {
    return SizedBox(
      child: StatefulBuilder(
        builder: (context, setState) {
          return CommonCartNumberPicker(
              onChange: (value) {
                final orderItemEntity = orderEntities[index];

                if (value < 1) {
                  ClearCartConfirmationDialog(
                    context: context,
                    clearOrder: orderEntities.length == 1,
                    masterClearTitle: 'Clear Returns ?',
                    masterClearDetail:
                        'You can save the return and place the return later ?',
                    itemClearTitle: 'Remove Item',
                    itemCleatDetail: 'Do you want to remove this item ?',
                    onSelect: (confirmation) {
                      if (confirmation) {
                        ReturnState.removeItem(orderItemEntity.productId!);
                      } else {
                        orderEntities[index].qty = 1;
                      }
                      setState(() {});
                      update();
                    },
                  ).showClearCartConfirmation();
                } else {
                  ReturnState.updateQty(
                      orderItemEntity.productId!,
                      orderItemEntity.returnType ?? 'FULL_PACK',
                      value);
                  update();
                }
              },
              defaultValue: orderEntities[index].qty ?? 0);
        },
      ),
    );
  }

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

  _buildSummaryTitle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: const Text(
        'Summary',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }

  _buildCategorySummary() {
    final items = ReturnState.items;
    final Map<String, int> catQtys = {};
    for (final item in items) {
      final cat = item.categoryName ?? 'Unknown';
      catQtys[cat] = (catQtys[cat] ?? 0) + (item.qty ?? 0);
    }
    if (catQtys.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Column(
        children: catQtys.entries.map((e) => Row(
          children: [
            Text(e.key,
                style: const TextStyle(
                    fontSize: 14,
                    color: CommonCustomColor.defaultTextColor)),
            const Spacer(),
            Text('${e.value}',
                style: const TextStyle(
                    fontSize: 14,
                    color: CommonCustomColor.defaultTextColor)),
          ],
        )).toList(),
      ),
    );
  }

  _buildGrandTotal() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 15, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Credit amount will be determined by our team upon review.',
              style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
            ),
          ),
        ],
      ),
    );
  }

  _buildPlaceOrderButton() {
    if (ReturnState.itemCount == 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              minimumSize: const Size.fromHeight(50)),
          onPressed: isProcess ? null : _placeReturn,
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
                  'Place the Return',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                )),
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
                            const SizedBox(width: 10),
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
        onPressed: () {},
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
        SizedBox(width: 20),
        Text(
          'Add to Return',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        )
      ],
    );
  }

  Future<void> _placeReturn() async {
    setState(() { isProcess = true; });
    try {
      final response = await DioClient().dio.post(
        buildUrl('/product-returns'),
        data: {
          'items': ReturnState.items.map((e) => {
            'productId': e.productId,
            'productName': e.productName ?? '',
            'qty': e.qty ?? 1,
            'unitPrice': e.returnPrice ?? e.unitPrice ?? 0,
            'returnType': e.returnType ?? 'FULL_PACK',
            'returnReason': e.returnReason ?? '',
          }).toList(),
          'notes': _otherReasonTextController.text,
        },
      );
      if (!mounted) return;

      if (response.statusCode == 201) {
        ReturnState.clear();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (_) => const MainScreenWidget(defaultIndex: 0),
        ), (route) => false);
        showSuccessMessage(
            message: 'Your return has been successfully processed!',
            context: context);
      } else {
        showErrorMessage(
            message: 'Return placement failed. Please contact support!',
            context: context);
      }
    } catch (_) {
      if (!mounted) return;
      showErrorMessage(
          message: 'Return placement failed. Please contact support!',
          context: context);
    } finally {
      if (mounted) setState(() { isProcess = false; });
    }
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
