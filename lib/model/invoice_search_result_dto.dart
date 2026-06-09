import 'package:mandel_mobile_app/model/invoice_dto.dart';
import 'package:mandel_mobile_app/model/meta_dto.dart';

class InvoiceSearchResultDto {
  MetaDto? meta;
  List<InvoiceDto>? results;

  InvoiceSearchResultDto({this.meta, this.results}) {
    results = [];
  }

  InvoiceSearchResultDto.fromJson(Map<String, dynamic> json) {
    if (json['meta'] != null) {
      meta = MetaDto.fromJson(json['meta']);
    }

    if (json['results'] != null) {
      results = <InvoiceDto>[];

      json['results'].forEach((v) {
        results!.add(InvoiceDto.fromJson(v));
      });
    }
  }
}
