import 'package:mandel_mobile_app/db/entity/return_item_entity.dart';
import 'package:mandel_mobile_app/db/entity/return_master_entity.dart';
import 'package:mandel_mobile_app/db/repository/return_item_repository.dart';
import 'package:mandel_mobile_app/db/repository/return_master_repository.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';

class CommonReturnUtility with CommonUtility {
  Future<void> addToReturnList(
      {required productDto,
      required String returnType,
      required String returnReason,
      required int qty,
      required double returnPrice}) async {
    ReturnMasterEntity returnMasterEntity = ReturnMasterEntity(
        id: 1,
        createdDate: getCurrentTimeStampText(),
        updatedDate: getCurrentTimeStampText());

    bool exist = await ReturnMasterRepository().isReturnExist();
    if (!exist) {
      await ReturnMasterRepository()
          .storeReturnMasterRecode(returnMasterEntity);
    } else {
      await ReturnMasterRepository()
          .updateReturnMasterRecode(returnMasterEntity);
    }

    double unitPrice = getUnitPrice(productDto: productDto);
    double subTotal = (returnPrice * qty);

    ReturnItemEntity orderItem = ReturnItemEntity(
        productId: productDto.id,
        productName: productDto.productName,
        qty: qty,
        unitPrice: unitPrice,
        subTotal: subTotal,
        returnReason: returnReason,
        returnType: returnType,
        returnMasterId: 1,
        returnPrice: returnPrice);

    if (null != productDto.size) {
      orderItem.size = productDto.size!.name;
    }

    if (null != productDto.category) {
      orderItem.categoryName = productDto.category!.name;
    }

    if (null != productDto.brand) {
      orderItem.brandName = productDto.brand!.name;
    }

    bool isExist = await ReturnItemRepository()
        .isItemExist(orderItem.productId!, orderItem.returnType!);
    if (!isExist) {
      await ReturnItemRepository().storeReturnItemRecode(orderItem);
    } else {
      await ReturnItemRepository()
          .updateReturnItemRecode(orderItem, orderItem.productId!);
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
