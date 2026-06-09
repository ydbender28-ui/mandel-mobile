const String tableOrderMaster = 'tbl_order_mst';

class OrderMasterField {
  static const String id = 'id';
  static const String createdDate = 'created_date';
  static const String updatedDate = 'updated_date';

  static final List<String> columns = [
    id,
    createdDate,
    updatedDate,
  ];
}

class OrderMasterEntity {
  int? id = 1;
  String? createdDate;
  String? updatedDate;

  OrderMasterEntity({this.id, this.createdDate, this.updatedDate}) {
    id = 1;
  }

  OrderMasterEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdDate = json['created_date'];
    updatedDate = json['updated_date'];
  }

  Map<String, dynamic> insertDataToJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['created_date'] = createdDate;
    data['updated_date'] = updatedDate;
    return data;
  }

  Map<String, dynamic> updateDataToJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['updated_date'] = updatedDate;
    return data;
  }
}
