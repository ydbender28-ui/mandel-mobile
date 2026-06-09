import 'package:mandel_mobile_app/model/media_dto.dart';
import 'package:mandel_mobile_app/model/user_dto.dart';

class InvoiceDto {
  int? id;
  int? number;
  String? type;
  double? amount;
  double? paid;
  double? due;
  UserDto? user;
  MediaDto? reference;

  InvoiceDto(
      {this.id,
      this.number,
      this.type,
      this.amount,
      this.paid,
      this.due,
      this.user,
      this.reference});

  InvoiceDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    type = json['type'];
    amount = json['amount'] == null ? 0.0 : json['amount'].toDouble();
    paid = json['paid'] == null ? 0.0 : json['paid'].toDouble();
    due = json['due'] == null ? 0.0 : json['due'].toDouble();

    if (json['reference'] != null) {
      reference = MediaDto.fromJson(json['reference']);
    }

    if (json['user'] != null) {
      user = UserDto.fromJson(json['user']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['number'] = number;
    data['type'] = type;
    data['amount'] = amount;
    data['paid'] = paid;
    data['due'] = due;

    if (user != null) {
      data['user'] = user!.toJson();
    }

    if (reference != null) {
      data['reference'] = reference!.toJson();
    }

    return data;
  }
}
