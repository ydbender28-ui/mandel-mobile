const String tableConfigs = 'tbl_configs';

class ConfigsField {
  static const String id = 'id';
  static const String key = 'key';
  static const dynamic value = 'value';

  static final List<String> columns = [id, key, value];
}

class ConfigsEntity {
  int id;
  String key;
  dynamic value;

  ConfigsEntity({required this.id, required this.key, this.value});

  Map<String, dynamic> toMap() {
    return {'id': id, 'key': key, 'value': value};
  }
}
