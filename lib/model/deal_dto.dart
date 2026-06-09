import 'package:intl/intl.dart';
import 'package:mandel_mobile_app/model/media_dto.dart';

class DealDto {
  int? id;
  DateTime? createdDateTime;
  DateTime? lastChangedDateTime;
  String? status;
  String? title;
  String? description;
  DateTime? startDate;
  DateTime? endDate;
  double? amount;
  double? price;
  List<MediaDto>? media;

  DealDto(
      {this.id,
      this.createdDateTime,
      this.lastChangedDateTime,
      this.status,
      this.title,
      this.description,
      this.startDate,
      this.endDate,
      this.amount,
      this.price,
      this.media});

  DealDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    if (null != json['createdDateTime']) {
      createdDateTime = DateTime.parse(json['createdDateTime']);
    }

    if (null != json['lastChangedDateTime']) {
      lastChangedDateTime = DateTime.parse(json['lastChangedDateTime']);
    }

    status = json['status'];
    title = json['title'];
    description = json['description'];

    // if (null != json['startDate']) {
    //   startDate = DateTime.parse(json['startDate']);
    // }

    // if (null != json['endDate']) {
    //   endDate = DateTime.parse(json['endDate']);
    // }

    amount = json['amount'].toDouble();

    if (null != json['price']) {
      price = json['price'].toDouble();
    }

    if (json['media'] != null) {
      media = <MediaDto>[];
      json['media'].forEach((v) {
        media!.add(MediaDto.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['title'] = title;
    data['description'] = description;

    if (null != startDate) {
      data['startDate'] = DateFormat('M/d/y').format(startDate!);
    }

    if (null != endDate) {
      data['endDate'] = DateFormat('M/d/y').format(endDate!);
    }

    data['amount'] = amount;

    if (null != price) {
      data['price'] = price;
    }

    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}
