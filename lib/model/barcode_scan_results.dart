import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/model/barcode_scan_status.dart';

class BarcodeScanResult {
  String code;
  BarcodeScanStatus status;
  List<ProductDto>? products;

  BarcodeScanResult({required this.code, required this.status, this.products});
}
