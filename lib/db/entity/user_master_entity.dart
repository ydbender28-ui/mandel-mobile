const String tableUserMaster = 'tbl_user_mst';

class UserMasterField {
  static const String id = 'id';
  static const String cognitoId = 'cognito_id';
  static const String userType = 'user_type';
  static const String title = 'title';
  static const String firstName = 'first_name';
  static const String middleName = 'middle_name';
  static const String lastName = 'last_name';
  static const String mediaUrl = 'media_url';
  static const String status = 'status';

  static final List<String> columns = [
    id,
    cognitoId,
    userType,
    title,
    firstName,
    middleName,
    lastName,
    mediaUrl,
    status
  ];
}

class UserMasterEntity {
  int? id;
  String? cognitoId;
  String? userType;
  String? title;
  String? firstName;
  String? middleName;
  String? lastName;
  String? mediaUrl;
  String? status;

  UserMasterEntity(
      {this.id,
      this.cognitoId,
      this.userType,
      this.title,
      this.firstName,
      this.middleName,
      this.lastName,
      this.mediaUrl,
      this.status});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['cognito_id'] = cognitoId;
    data['user_type'] = userType;
    data['title'] = title;
    data['first_name'] = firstName;
    data['middle_name'] = middleName;
    data['last_name'] = lastName;
    data['media_url'] = mediaUrl;
    data['status'] = status;
    return data;
  }
}
