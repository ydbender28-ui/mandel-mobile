import 'package:mandel_mobile_app/model/media_dto.dart';
import 'package:mandel_mobile_app/model/user_dto.dart';

class InvoiceDto {
  int? arhId;
  int? id;
  int? number;
  String? type;
  double? amount;
  double? paid;
  double? due;
  String? invoiceDate;
  String? dueDate;
  String? status;
  bool? isOpen;
  UserDto? user;
  MediaDto? reference;

  InvoiceDto({
    this.arhId,
    this.id,
    this.number,
    this.type,
    this.amount,
    this.paid,
    this.due,
    this.invoiceDate,
    this.dueDate,
    this.status,
    this.isOpen,
    this.user,
    this.reference,
  });

  InvoiceDto.fromJson(Map<String, dynamic> json) {
    arhId = json['arhId'];
    id = json['id'];
    // Portal returns id = invoice number; fallback to legacy 'number' field
    number = json['id'] ?? json['number'];
    // Portal uses 'invoiceType'; legacy used 'type'
    type = json['invoiceType'] ?? json['type'];
    // Portal uses 'total'; legacy used 'amount'
    amount = (json['total'] ?? json['amount'] ?? 0).toDouble();
    paid = (json['paid'] ?? 0).toDouble();
    // Portal uses 'balance'; legacy used 'due'
    due = (json['balance'] ?? json['due'] ?? 0).toDouble();
    invoiceDate = json['invoiceDate'];
    dueDate = json['dueDate'];
    status = json['status'];
    isOpen = json['isOpen'];

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
    if (user != null) data['user'] = user!.toJson();
    if (reference != null) data['reference'] = reference!.toJson();
    return data;
  }
}
