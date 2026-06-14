import 'package:mandel_mobile_app/db/entity/order_item_entity.dart';
import 'package:mandel_mobile_app/model/price_dto.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/utility/cart_state.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';

class CommonCartUtility with CommonUtility {
  Future<void> addToCart({required ProductDto productDto, required int qty, double? unitPrice}) async {
    unitPrice ??= getUnitPrice(productDto: productDto);
    double subTotal = unitPrice * qty;

    OrderItemEntity orderItem = OrderItemEntity(
        productId: productDto.id,
        productName: productDto.productName,
        qty: qty,
        unitPrice: unitPrice,
        subTotal: subTotal,
        discount: getDiscount(productDto: productDto),
        deal: productDto.price?.first.isDealExist() == true
            ? productDto.price!.first.deal?.id
            : null,
        priceGroup: productDto.price?.first.priceGroupId,
        orderMasterId: 1);

    if (productDto.size != null) orderItem.size = productDto.size!.name;
    if (productDto.category != null) orderItem.categoryName = productDto.category!.name;
    if (productDto.brand != null) orderItem.brandName = productDto.brand!.name;

    CartState.addItem(orderItem);
  }

  double getUnitPrice({required ProductDto productDto}) {
    if (productDto.price != null && productDto.price!.isNotEmpty) {
      return productDto.price![0].getPrice();
    }
    return 0.0;
  }

  double getDiscount({required ProductDto productDto}) {
    if (productDto.price != null && productDto.price!.isNotEmpty) {
      return productDto.price![0].getDiscount();
    }
    return 0.0;
  }

  PriceDto getPrice({required ProductDto productDto}) {
    return productDto.price![0];
  }

  double getTotalOrderItemPrice({required ProductDto productDto, required int qty}) {
    double unitPrice = 0.0;
    if (productDto.price != null && productDto.price!.isNotEmpty) {
      unitPrice = productDto.price![0].getPrice();
    }
    if (productDto.tempQty != null) qty = productDto.tempQty!;
    return unitPrice * qty;
  }
}
