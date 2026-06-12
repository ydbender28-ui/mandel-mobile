import 'package:mandel_mobile_app/model/barcode_dto.dart';
import 'package:mandel_mobile_app/model/brand_dto.dart';
import 'package:mandel_mobile_app/model/category_dto.dart';
import 'package:mandel_mobile_app/model/deal_dto.dart';
import 'package:mandel_mobile_app/model/price_dto.dart';
import 'package:mandel_mobile_app/model/media_dto.dart';
import 'package:mandel_mobile_app/model/size_dto.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

class ProductDto {
  int? id;
  DateTime? createdDateTime;
  DateTime? lastChangedDateTime;
  String? productName;
  String? description;
  double? defaultSellingPrice;
  int? quantity;
  int? buyingPrice;
  String? productCode;
  String? manufacturerCode;
  List<MediaDto>? productImages;
  BrandDto? brand;
  CategoryDto? category;
  List<BarCodeDto>? barcodes;
  List<PriceDto>? price;
  List<DealDto>? deal;
  SizeDto? size;
  int? tempQty;
  bool? isSingle;
  bool? isNew;
  int? singleCount;
  String? expiryDate;

  ProductDto(
      {this.id,
      this.createdDateTime,
      this.lastChangedDateTime,
      this.productName,
      this.description,
      this.defaultSellingPrice,
      this.quantity,
      this.buyingPrice,
      this.productCode,
      this.manufacturerCode,
      this.productImages,
      this.brand,
      this.category,
      this.barcodes,
      this.price,
      this.size,
      this.isSingle,
      this.isNew,
      this.singleCount});

  ProductDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productName = json['productName'];
    description = json['description'];
    defaultSellingPrice = json['defaultSellingPrice'];
    quantity = json['quantity'];
    buyingPrice = json['buyingPrice'];
    productCode = json['productCode'];
    manufacturerCode = json['manufacturerCode'];
    isSingle = json['isSingle'];
    singleCount = json['singleCount'];
    isNew = json['isNew'];
    expiryDate = json['expiryDate'] as String?;

    if (json['brand'] != null) {
      brand = BrandDto.fromJson(json['brand']);
    }

    if (json['category'] != null) {
      category = CategoryDto.fromJson(json['category']);
    }

    if (json['size'] != null) {
      size = SizeDto.fromJson(json['size']);
    }

    if (null != json['createdDateTime']) {
      createdDateTime = DateTime.parse(json['createdDateTime']);
    }

    // if (null != json['lastChangedDateTime']) {
    //   lastChangedDateTime = DateTime.parse(json['lastChangedDateTime']);
    // }

    if (json['productImages'] != null) {
      productImages = <MediaDto>[];
      json['productImages'].forEach((v) {
        productImages!.add(MediaDto.fromJson(v));
      });
    }

    if (json['barcodes'] != null) {
      barcodes = <BarCodeDto>[];
      json['barcodes'].forEach((v) {
        barcodes!.add(BarCodeDto.fromJson(v));
      });
    }

    if (json['price'] != null) {
      price = <PriceDto>[];
      json['price'].forEach((v) {
        price!.add(PriceDto.fromJson(v));
      });
    }

    if (json['deal'] != null) {
      deal = <DealDto>[];
      json['deal'].forEach((v) {
        deal!.add(DealDto.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['productName'] = productName;
    data['description'] = description;
    data['defaultSellingPrice'] = defaultSellingPrice;
    data['quantity'] = quantity;
    data['buyingPrice'] = buyingPrice;
    data['productCode'] = productCode;
    data['manufacturerCode'] = manufacturerCode;
    data['isSingle'] = isSingle;
    data['singleCount'] = singleCount;
    data['isNew'] = isNew;
    // if (null != createdDateTime) {
    //   data['createdDateTime'] = DateFormat('M/d/y').format(createdDateTime!);
    // }

    // if (null != lastChangedDateTime) {
    //   data['lastChangedDateTime'] =
    //       DateFormat('M/d/y').format(lastChangedDateTime!);
    // }

    if (productImages != null) {
      data['productImages'] = productImages!.map((v) => v.toJson()).toList();
    }

    if (brand != null) {
      data['brand'] = brand!.toJson();
    }

    if (category != null) {
      data['category'] = category!.toJson();
    }

    if (size != null) {
      data['size'] = size!.toJson();
    }

    if (barcodes != null) {
      data['barcodes'] = barcodes!.map((v) => v.toJson()).toList();
    }

    if (price != null) {
      data['price'] = price!.map((v) => v).toList();
    }

    if (price != null) {
      data['deal'] = deal!.map((v) => v).toList();
    }

    data.removeWhere((key, value) => value == null);

    return data;
  }

  String getProductName() {
    if (null != productName) {
      return productName!;
    }
    return CommonConstants.emptyRecodeIndicator;
  }

  String getProductCode() {
    if (null != productCode) {
      return productCode!;
    }
    return CommonConstants.emptyRecodeIndicator;
  }

  String getCategoryName() {
    if (null != category && null != category!.name) {
      return category!.name!;
    }
    return CommonConstants.emptyRecodeIndicator;
  }

  String getBrandName() {
    if (null != brand && null != brand!.name) {
      return brand!.name!;
    }
    return CommonConstants.emptyRecodeIndicator;
  }

  String getSize() {
    if (null != size && null != size!.name) {
      return size!.name!;
    }
    return CommonConstants.emptyRecodeIndicator;
  }

  String getUnitPrice() {
    double unitPrice = 0.0;

    if (null == price) {
      return unitPrice.toStringAsFixed(2);
    }

    if (price!.isEmpty) {
      return unitPrice.toStringAsFixed(2);
    }

    unitPrice += price![0].getPrice();
    return unitPrice.toStringAsFixed(2);
  }

  PriceDto getPrice() {
    final dummyPrice = PriceDto(price: 0.0);
    if (null == price) {
      return dummyPrice;
    }
    if (price!.isEmpty) {
      return dummyPrice;
    }
    return price![0];
  }

  double getNonFormatPrice() {
    double unitPrice = 0.0;

    if (null == price) {
      return unitPrice;
    }

    if (price!.isEmpty) {
      return unitPrice;
    }

    unitPrice += price![0].getPrice();
    return unitPrice;
  }

  String getNonDiscountedUnitPrice() {
    double unitPrice = 0.0;

    if (null == price) {
      return unitPrice.toStringAsFixed(2);
    }

    if (price!.isEmpty) {
      return unitPrice.toStringAsFixed(2);
    }

    unitPrice += price![0].getNonDiscountedPrice();
    return unitPrice.toStringAsFixed(2);
  }

  double getNonDiscounterFormatPrice() {
    double unitPrice = 0.0;

    if (null == price) {
      return unitPrice;
    }

    if (price!.isEmpty) {
      return unitPrice;
    }

    unitPrice += price![0].getNonDiscountedPrice();
    return unitPrice;
  }

  String getProductImageUrl() {
    return productImages!.isNotEmpty && productImages![0].url != null ? productImages![0].url! : '';
  }

  bool isDealExist() {
    if (null == deal) {
      return false;
    }

    if (deal!.isEmpty) {
      return false;
    }

    return true;
  }
}
