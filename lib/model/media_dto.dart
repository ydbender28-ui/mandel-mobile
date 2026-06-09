class MediaDto {
  int? id;
  DateTime? createdDateTime;
  DateTime? lastChangedDateTime;
  String? url;
  String? description;
  String? type;

  MediaDto(
      {this.id,
      this.createdDateTime,
      this.lastChangedDateTime,
      this.url,
      this.description,
      this.type});

  MediaDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    description = json['description'];
    type = json['type'];

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
    data['url'] = url;
    data['description'] = description;
    data['type'] = type;

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
