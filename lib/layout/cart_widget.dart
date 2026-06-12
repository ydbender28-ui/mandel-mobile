import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final _noteCtrl     = TextEditingController();
  final _dateCtrl     = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool  _isProcessing = false;

  static const _h1     = Color(0xFF0C0F1E);
  static const _h2     = Color(0xFF1B2860);
  static const _indigo = Color(0xFF4F46E5);
  static const _bg     = Color(0xFFEEF0FA);
  static const _card   = Colors.white;
  static const _textHi = Color(0xFF0D1135);
  static const _textLo = Color(0xFF9AA3C2);
  static const _divClr = Color(0xFFF0F1F8);

  @override
  void dispose() {
    _dateCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        _header(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Items'),
                  _buildOrderList(),
                  _sectionLabel('Summary'),
                  _buildSummaryCard(),
                  _sectionLabel('Delivery Info'),
                  _buildDeliveryCard(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        _buildStickyPlaceOrder(),
      ]),
    );
  }

  // ── header ──────────────────────────────────────────────────────────────

  Widget _header() {
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
              if (!widget.isFromHomePage)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: Colors.white),
                  ),
                ),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Order Cart',
                    style: TextStyle(color: Colors.white, fontSize: 22,
                        fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  FutureBuilder<String?>(
                    future: OrderMasterRepository().getLastUpdatedTimeStamp(),
                    builder: (_, snap) => Text(
                      snap.data != null ? 'Updated ${snap.data}' : 'Empty cart',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 11)),
                  ),
                ]),
              ),
              if (widget.isFromHomePage)
                GestureDetector(
                  onTap: () => Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const MainScreenWidget(defaultIndex: 0)),
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

  // ── section label ────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
    child: Text(text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
          color: _textLo, letterSpacing: 1.0)),
  );

  // ── order list ───────────────────────────────────────────────────────────

  Widget _buildOrderList() {
    return FutureBuilder<List<OrderItemEntity>>(
      future: OrderRepository().getOrderList(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _divClr)),
            child: Column(children: [
              Icon(Icons.shopping_bag_outlined, size: 48,
                  color: _textLo.withOpacity(0.5)),
              const SizedBox(height: 12),
              const Text('Your cart is empty',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                    color: _textLo)),
            ]),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
              color: const Color(0xFF0D1135).withOpacity(0.04),
              blurRadius: 12, offset: const Offset(0, 3))],
          ),
          child: Column(
            children: List.generate(snap.data!.length, (i) {
              final isLast = i == snap.data!.length - 1;
              return _cartItem(snap.data!, i, isLast);
            }),
          ),
        );
      },
    );
  }

  Widget _cartItem(List<OrderItemEntity> items, int index, bool isLast) {
    final item = items[index];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: _divClr, width: 1))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _indigo.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.inventory_2_outlined, size: 20, color: _indigo),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.productName ?? '—',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: _textHi),
              overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${item.categoryName ?? ''}  •  \$${item.getUnitPrice()} each',
              style: const TextStyle(fontSize: 11, color: _textLo)),
            const SizedBox(height: 4),
            Text('\$${item.subTotal?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: _indigo)),
          ]),
        ),
        const SizedBox(width: 8),
        StatefulBuilder(builder: (ctx, localSet) {
          return CommonCartNumberPicker(
            defaultValue: item.qty ?? 0,
            onChange: (val) {
              final unitPrice = item.unitPrice ?? 0.0;
              item.qty = val;
              item.subTotal = unitPrice * val;

              if (val < 1) {
                ClearCartConfirmationDialog(
                  context: context,
                  clearOrder: items.length == 1,
                  masterClearTitle: 'Clear cart?',
                  masterClearDetail: 'Save the cart and place the order later?',
                  itemClearTitle: 'Remove Item',
                  itemCleatDetail: 'Do you want to remove this item?',
                  onSelect: (confirmed) {
                    if (confirmed) {
                      if (items.length == 1) OrderMasterRepository().deleteOrder(1);
                      OrderRepository().deleteItem(item.productId!);
                    } else {
                      item.qty = 1;
                    }
                    setState(() {});
                  },
                ).showClearCartConfirmation();
              } else {
                OrderRepository().updateOrderItemQtyRecode(
                    item.productId!, item.qty ?? 1);
                setState(() {});
              }
              OrderMasterRepository().updateOrderMasterRecode(
                  OrderMasterEntity(updatedDate: getCurrentTimeStampText()));
            },
          );
        }),
      ]),
    );
  }

  // ── summary card ─────────────────────────────────────────────────────────

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: const Color(0xFF0D1135).withOpacity(0.04),
          blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        FutureBuilder(
          future: OrderRepository().getCategoryWiseSummary(),
          builder: (_, snap) {
            if (!snap.hasData) return const SizedBox();
            return Column(children: snap.data!.map((e) =>
              _summaryRow('${e.category}', '${e.qty} units',
                color: _textLo, bold: false)).toList());
          },
        ),
        _divLine(),
        FutureBuilder(
          future: OrderRepository().getSubTotal(),
          builder: (_, snap) => _summaryRow(
            'Subtotal', '\$${snap.data ?? '0.00'}', lineThrough: true),
        ),
        const SizedBox(height: 4),
        FutureBuilder(
          future: OrderRepository().getDiscount(),
          builder: (_, snap) => _summaryRow(
            'Discount', '-\$${snap.data ?? '0.00'}',
            color: const Color(0xFF10B981)),
        ),
        _divLine(),
        FutureBuilder(
          future: OrderRepository().getFormattedGrandTotal(),
          builder: (_, snap) => _summaryRow(
            'Grand Total', '\$${snap.data ?? '0.00'}',
            large: true, color: _indigo),
        ),
      ]),
    );
  }

  Widget _summaryRow(String label, String value, {
    Color color = _textHi, bool bold = true, bool large = false,
    bool lineThrough = false,
  }) {
    final style = TextStyle(
      fontSize: large ? 16 : 13,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: color,
      decoration: lineThrough ? TextDecoration.lineThrough : null);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Text(label, style: style), const Spacer(), Text(value, style: style),
      ]),
    );
  }

  Widget _divLine() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Divider(color: _divClr, thickness: 1, height: 1));

  // ── delivery card ─────────────────────────────────────────────────────────

  Widget _buildDeliveryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: const Color(0xFF0D1135).withOpacity(0.04),
          blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('Delivery Date'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _dateCtrl,
          readOnly: true,
          style: const TextStyle(fontSize: 13, color: _textHi),
          decoration: InputDecoration(
            hintText: 'Select a date',
            prefixIcon: const Icon(Icons.calendar_today_outlined,
                size: 16, color: _textLo),
            suffixIcon: _dateCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16, color: _textLo),
                    onPressed: () => setState(() => _dateCtrl.clear()))
                : null),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)));
            if (picked != null) {
              setState(() => _dateCtrl.text =
                  DateFormat(CommonConstants.usDateFormat).format(picked));
            }
          },
        ),
        const SizedBox(height: 16),
        _fieldLabel('Delivery Note'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _noteCtrl,
          maxLines: 3,
          style: const TextStyle(fontSize: 13, color: _textHi),
          decoration: const InputDecoration(
            hintText: 'Special instructions, gate code, etc.',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.notes_rounded, size: 16, color: _textLo))),
        ),
      ]),
    );
  }

  Widget _fieldLabel(String t) => Text(t,
    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
        color: Color(0xFF4A5272), letterSpacing: 0.3));

  // ── sticky place order ────────────────────────────────────────────────────

  Widget _buildStickyPlaceOrder() {
    return FutureBuilder<bool>(
      future: OrderMasterRepository().isOrderExist(),
      builder: (context, snap) {
        final hasOrder = snap.data == true;
        return Container(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(
              color: const Color(0xFF0D1135).withOpacity(0.08),
              blurRadius: 20, offset: const Offset(0, -4))],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: hasOrder && !_isProcessing ? _placeOrder : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _indigo,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD1D5E8),
                disabledForegroundColor: Colors.white54,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: hasOrder ? 2 : 0,
                shadowColor: _indigo.withOpacity(0.35),
              ),
              icon: _isProcessing
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Icon(
                      hasOrder
                          ? Icons.check_circle_outline_rounded
                          : Icons.shopping_cart_outlined,
                      size: 20),
              label: Text(
                _isProcessing
                    ? 'Placing Order…'
                    : hasOrder
                        ? 'Place Order'
                        : 'Add items to place an order',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        );
      },
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);
    try {
      final userId = await UserMasterRepository().getUserId();
      final total  = await OrderRepository().getPeoGrandTotal();
      final items  = await OrderRepository().getOrderItemList();
      final date   = _dateCtrl.text.isNotEmpty
          ? DateFormat(CommonConstants.usDateFormat).parse(_dateCtrl.text)
          : DateTime.now();

      final dto = OrderDto(
        user: UserDto(id: userId),
        orderItems: items,
        orderState: 'PENDING',
        orderSource: 'WEB',
        deliveryDate: date,
        notes: _noteCtrl.text,
        total: total,
      );

      final Response resp = await OrderService().postOrder(dto);
      if (!mounted) return;

      if (resp.statusCode == 201) {
        showSuccessMessage(
            message: 'Order placed successfully!', context: context);
        await OrderRepository().clearOrderItems();
        await OrderMasterRepository().clearOrderMaster();
        Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const MainScreenWidget(defaultIndex: 0)),
          (r) => false);
      } else {
        showErrorMessage(
            message: 'Order failed. Please contact support.', context: context);
      }
    } catch (_) {
      if (mounted) {
        showErrorMessage(message: 'Something went wrong.', context: context);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
