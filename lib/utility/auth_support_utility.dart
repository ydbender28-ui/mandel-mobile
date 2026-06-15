import 'package:shared_preferences/shared_preferences.dart';

mixin AuthSupportUtility {
  static const String _tokenKey = 'mandel_portal_token';

  Future<void> signOutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<String> getTokenFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) ?? '';
  }

  Future<bool> checkSessionIsExist() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> saveLinkedStores(List<dynamic> stores) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = stores.map((s) => '${s['customerId']}|${s['name']}|${s['priceGroup'] ?? 0}').toList().join(';;');
    await prefs.setString('mandel_linked_stores', encoded);
  }

  Future<List<Map<String, dynamic>>> getLinkedStores() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('mandel_linked_stores') ?? '';
    if (raw.isEmpty) return [];
    return raw.split(';;').map((s) {
      final parts = s.split('|');
      if (parts.length < 2) return <String, dynamic>{};
      return <String, dynamic>{
        'customerId': int.tryParse(parts[0]) ?? 0,
        'name': parts[1],
        'priceGroup': int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0,
      };
    }).where((m) => m.isNotEmpty && m['customerId'] != 0).toList();
  }

  Future<void> clearLinkedStores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mandel_linked_stores');
  }

  Future<void> saveSalesmanName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mandel_salesman_name', name);
  }

  Future<String?> getSalesmanName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('mandel_salesman_name');
  }

  Future<void> clearSalesmanName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mandel_salesman_name');
  }
}
