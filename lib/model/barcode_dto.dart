class BarCodeDto {
  int? id;
  DateTime? createdDateTime;
  DateTime? lastChangedDateTime;
  String? value;

  BarCodeDto(
      {this.id, this.createdDateTime, this.lastChangedDateTime, this.value});

  BarCodeDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    value = json['value'];

    if (null != json['createdDateTime']) {
      createdDateTime = DateTime.parse(json['createdDateTime']);
    }

    if (null != json['lastChangedDateTime']) {
      lastChangedDateTime = DateTime.parse(json['lastChangedDateTime']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['value'] = value;

    // if (null != createdDateTime) {
    //   data['createdDateTime'] = DateFormat('M/d/y').format(createdDateTime!);
    // }

    // if (null != lastChangedDateTime) {
    //   data['lastChangedDateTime'] =
    //       DateFormat('M/d/y').format(lastChangedDateTime!);
    // }

    return data;
  }
}
