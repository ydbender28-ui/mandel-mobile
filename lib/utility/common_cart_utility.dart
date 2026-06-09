import 'package:mandel_mobile_app/db/entity/order_item_entity.dart';
import 'package:mandel_mobile_app/db/entity/order_master_entity.dart';
import 'package:mandel_mobile_app/db/repository/order_master_repository.dart';
import 'package:mandel_mobile_app/db/repository/order_repository.dart';
import 'package:mandel_mobile_app/model/price_dto.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';

class CommonCartUtility with CommonUtility {
  ///
  ///This method can be used for calculate item discounts and subtotal
  Future<void> addToCart(
      {required ProductDto productDto, required int qty}) async {
    OrderMasterEntity orderMaster = OrderMasterEntity(
        id: 1,
        createdDate: getCurrentTimeStampText(),
        updatedDate: getCurrentTimeStampText());

    bool exist = await OrderMasterRepository().isOrderExist();
    if (!exist) {
      await OrderMasterRepository().storeOrderMasterRecode(orderMaster);
    } else {
      await OrderMasterRepository().updateOrderMasterRecode(orderMaster);
    }

    double unitPrice = getUnitPrice(productDto: productDto);
    double subTotal = (unitPrice * qty);

    OrderItemEntity orderItem = OrderItemEntity(
        productId: productDto.id,
        productName: productDto.productName,
        qty: qty,
        unitPrice: unitPrice,
        subTotal: subTotal,
        discount: getDiscount(productDto: productDto),
        deal: productDto.price!.first.isDealExist()
            ? productDto.price!.first.deal?.id
            : null,
        priceGroup: productDto.price?.first.priceGroupId,
        orderMasterId: 1);

    if (null != productDto.size) {
      orderItem.size = productDto.size!.name;
    }

    if (null != productDto.category) {
      orderItem.categoryName = productDto.category!.name;
    }

    if (null != productDto.brand) {
      orderItem.brandName = productDto.brand!.name;
    }

    bool isExist = await OrderRepository().isItemExist(orderItem.productId!);
    if (!isExist) {
      await OrderRepository().storeOrderItemRecode(orderItem);
    } else {
      await OrderRepository()
          .updateOrderItemRecode(orderItem, orderItem.productId!);
    }
  }

  ///
  ///This method can be used for get unit price
  double getUnitPrice({required ProductDto productDto}) {
    double unitPrice = 0.0;

    if (null != productDto.price) {
      if (productDto.price!.isNotEmpty) {
        unitPrice = productDto.price![0].getPrice();
      }
    }
    return unitPrice;
  }

  double getDiscount({required ProductDto productDto}) {
    if (null != productDto.price) {
      if (productDto.price!.isNotEmpty) {
        return productDto.price![0].getDiscount();
      }
    }
    return 0.0;
  }

  PriceDto getPrice({required ProductDto productDto}) {
    return productDto.price![0];
  }

  ///
  ///This method will return order item sub total
  double getTotalOrderItemPrice(
      {required ProductDto productDto, required int qty}) {
    double unitPrice = 0.0;

    if (null != productDto.price) {
      if (productDto.price!.isNotEmpty) {
        unitPrice = productDto.price![0].getPrice();
      }
    }

    if (null != productDto.tempQty) {
      qty = productDto.tempQty!;
    }

    return unitPrice * qty;
  }
}
