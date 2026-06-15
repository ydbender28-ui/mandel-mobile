import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/utility/auth_support_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

class SalesmanScreenWidget extends StatefulWidget {
  const SalesmanScreenWidget({super.key});
  @override
  State<SalesmanScreenWidget> createState() => _SalesmanScreenWidgetState();
}

class _SalesmanScreenWidgetState extends State<SalesmanScreenWidget>
    with AuthSupportUtility {
  final _searchCtrl = TextEditingController();
  List<dynamic> _customers = [];
  bool _loading = true;
  String _error = '';
  String _salesmanName = '';

  static const _navy   = Color(0xFF07101E);
  static const _orange = Color(0xFFF0560F);
  static const _bg     = Color(0xFFEEF0FA);
  static const _dark   = Color(0xFF0D1135);
  static const _light  = Color(0xFF8A9BB5);
  static const _border = Color(0xFFDDE4EF);

  @override
  void initState() {
    super.initState();
    _load();
    getSalesmanName().then((n) { if (mounted) setState(() => _salesmanName = n ?? ''); });
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _load(q: _searchCtrl.text.trim()));
  }

  Timer? _debounce;

  Future<void> _load({String q = ''}) async {
    setState(() { _loading = true; _error = ''; });
    try {
      final token = await getTokenFromSession();
      final res = await Dio().get(
        '${CommonConstants.mandelBaseUrl}/salesman/customers',
        queryParameters: {'q': q},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (mounted) setState(() { _customers = res.data['customers'] ?? []; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Could not load customers'; _loading = false; });
    }
  }

  Future<void> _selectCustomer(dynamic c) async {
    setState(() => _loading = true);
    try {
      final token = await getTokenFromSession();
      final res = await Dio().post(
        '${CommonConstants.mandelBaseUrl}/salesman/act-as',
        data: {'customerId': c['id']},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      await saveToken(res.data['token']);
      await clearLinkedStores();
      if (mounted) Navigator.of(context).pushReplacementNamed(CommonConstants.mainScreenUrl);
    } catch (_) {
      if (mounted) setState(() { _error = 'Could not select customer'; _loading = false; });
    }
  }

  Future<void> _signOut() async {
    await signOutUser();
    await clearLinkedStores();
    await clearSalesmanName();
    if (mounted) Navigator.of(context).pushReplacementNamed(CommonConstants.loginScreenUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _navy,
        automaticallyImplyLeading: false,
        title: Row(children: [
          const Text('Mandel Wholesale', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          if (_salesmanName.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('🧑‍💼 $_salesmanName', style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ],
        ]),
        actions: [
          TextButton(
            onPressed: _signOut,
            child: const Text('Sign Out', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Choose a Customer', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _dark)),
              const SizedBox(height: 4),
              const Text('Select the store you want to place an order for', style: TextStyle(fontSize: 13, color: _light)),
              const SizedBox(height: 16),
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search by store name or ID…',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: _light),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
                  filled: true, fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                ),
              ),
            ]),
          ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(_error, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ),
          Expanded(
            child: _loading && _customers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _customers.isEmpty
                    ? const Center(child: Text('No customers found', style: TextStyle(color: _light)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        itemCount: _customers.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: _border),
                        itemBuilder: (ctx, i) {
                          final c = _customers[i];
                          final initial = (c['name'] as String? ?? '?')[0].toUpperCase();
                          final parts = [c['address'], c['city'], c['state']].where((v) => v != null && (v as String).isNotEmpty).join(', ');
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            leading: CircleAvatar(
                              radius: 21,
                              backgroundColor: const Color(0xFFEEF0FA),
                              child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _dark)),
                            ),
                            title: Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _dark)),
                            subtitle: Text('$parts · #${c['id']}', style: const TextStyle(fontSize: 12, color: _light)),
                            trailing: const Icon(Icons.chevron_right_rounded, color: _light),
                            onTap: () => _selectCustomer(c),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
