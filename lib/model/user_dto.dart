class UserDto {
  int? id;
  DateTime? createdDateTime;
  DateTime? lastChangedDateTime;
  String? status;
  String? cognitoId;
  String? userType;
  String? title;
  String? firstName;
  String? middleName;
  String? lastName;
  String? customerReferenceId;
  List<String>? contacts;
  List<double>? priceGroup;

  UserDto(
      {this.id,
      this.createdDateTime,
      this.lastChangedDateTime,
      this.status,
      this.cognitoId,
      this.userType,
      this.title,
      this.firstName,
      this.middleName,
      this.lastName,
      this.customerReferenceId,
      this.contacts,
      this.priceGroup});

  UserDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    cognitoId = json['cognitoId'];
    userType = json['userType'];
    title = json['title'];
    firstName = json['firstName'];
    middleName = json['middleName'];
    lastName = json['lastName'];
    customerReferenceId = json['customerReferenceId'];

    if (null != json['createdDateTime']) {
      createdDateTime = DateTime.parse(json['createdDateTime']);
    }

    if (null != json['lastChangedDateTime']) {
      lastChangedDateTime = DateTime.parse(json['lastChangedDateTime']);
    }

    if (json['contacts'] != null) {
      contacts = <String>[];
      json['contacts'].forEach((v) {
        //contacts!.add(v);
      });
    }

    if (json['priceGroup'] != null) {
      priceGroup = <double>[];
      // json['priceGroup'].forEach((v) {
      //   priceGroup!.add(v);
      // });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['cognitoId'] = cognitoId;
    data['userType'] = userType;
    data['title'] = title;
    data['firstName'] = firstName;
    data['middleName'] = middleName;
    data['lastName'] = lastName;
    data['customerReferenceId'] = customerReferenceId;

    // if (null != createdDateTime) {
    //   data['createdDateTime'] = DateFormat('M/d/y').format(createdDateTime!);
    // }

    // if (null != lastChangedDateTime) {
    //   data['lastChangedDateTime'] =
    //       DateFormat('M/d/y').format(lastChangedDateTime!);
    // }

    if (contacts != null) {
      data['contacts'] = contacts!.map((v) => v).toList();
    }

    if (priceGroup != null) {
      data['priceGroup'] = priceGroup!.map((v) => v).toList();
    }

    return data;
  }
}
