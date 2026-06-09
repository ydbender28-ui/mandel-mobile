class MetaDto {
  int? page;
  int? pageSize;
  int? totalCount;

  MetaDto({this.page, this.pageSize, this.totalCount});

  MetaDto.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    pageSize = json['pageSize'];
    totalCount = json['totalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['pageSize'] = pageSize;
    data['totalCount'] = totalCount;
    return data;
  }
}
