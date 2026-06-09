class SizeDto {
  int? id;
  DateTime? createdDateTime;
  DateTime? lastChangedDateTime;
  String? name;
  String? description;
  String? extra;

  SizeDto(
      {this.id,
      this.createdDateTime,
      this.lastChangedDateTime,
      this.name,
      this.description,
      this.extra});

  SizeDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    extra = json['extra'];

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

    data['name'] = name;
    data['description'] = description;
    data['extra'] = extra;

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
