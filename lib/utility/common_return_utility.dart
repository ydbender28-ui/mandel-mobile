import 'package:mandel_mobile_app/db/entity/return_item_entity.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/return_state.dart';

class CommonReturnUtility with CommonUtility {
  Future<void> addToReturnList(
      {required productDto,
      required String returnType,
      required String returnReason,
      required int qty,
      required double returnPrice}) async {
    double unitPrice = getUnitPrice(productDto: productDto);
    double subTotal = returnPrice * qty;

    final item = ReturnItemEntity(
      productId: productDto.id,
      productName: productDto.productName,
      qty: qty,
      unitPrice: unitPrice,
      subTotal: subTotal,
      returnReason: returnReason,
      returnType: returnType,
      returnMasterId: 1,
      returnPrice: returnPrice,
      categoryName: productDto.category?.name,
      brandName: productDto.brand?.name,
      size: productDto.size?.name,
    );

    ReturnState.addOrUpdate(item);
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
