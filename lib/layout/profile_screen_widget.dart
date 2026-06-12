import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandel_mobile_app/db/repository/order_master_repository.dart';
import 'package:mandel_mobile_app/db/repository/order_repository.dart';
import 'package:mandel_mobile_app/db/repository/return_item_repository.dart';
import 'package:mandel_mobile_app/db/repository/return_master_repository.dart';
import 'package:mandel_mobile_app/db/repository/user_master_repository.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/utility/auth_support_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreenWidget extends StatefulWidget {
  final bool isFromHomePage;
  const ProfileScreenWidget({required this.isFromHomePage, super.key});
  @override
  State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget>
    with AuthSupportUtility {

  static const _h1     = Color(0xFF0C0F1E);
  static const _h2     = Color(0xFF1B2860);
  static const _indigo = Color(0xFF4F46E5);
  static const _bg     = Color(0xFFEEF0FA);
  static const _textHi = Color(0xFF0D1135);
  static const _textLo = Color(0xFF9AA3C2);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 24),
            _menuSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_h1, _h2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        Positioned(right: -40, top: -40,
          child: Container(width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _indigo.withOpacity(0.1)))),
        Positioned(left: -20, bottom: 10,
          child: Container(width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0EA5E9).withOpacity(0.07)))),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Row(
              children: [
                // initials circle
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [_indigo, const Color(0xFF818CF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.25), width: 2),
                  ),
                  child: FutureBuilder<String>(
                    future: UserMasterRepository().getUserName(),
                    builder: (ctx, snap) {
                      final name = snap.data ?? '';
                      final initials = name.trim().isEmpty
                          ? '?'
                          : name.trim().split(' ')
                              .take(2)
                              .map((p) => p[0].toUpperCase())
                              .join('');
                      return Center(
                        child: Text(initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // name + label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Account',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      FutureBuilder<String>(
                        future: UserMasterRepository().getUserName(),
                        builder: (ctx, snap) => Text(
                          snap.data ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _menuSection() {
    final items = [
      _MenuItem(index: 0, icon: Icons.receipt_long_rounded,     label: 'My Orders',  color: _indigo),
      _MenuItem(index: 1, icon: Icons.shopping_bag_rounded,      label: 'My Cart',    color: const Color(0xFF0EA5E9)),
      _MenuItem(index: 3, icon: Icons.description_outlined,      label: 'Invoices',   color: const Color(0xFF10B981)),
      _MenuItem(index: 5, icon: Icons.account_balance_rounded,   label: 'Account (AR)', color: const Color(0xFFF59E0B)),
      _MenuItem(index: 2, icon: Icons.help_outline_rounded,      label: 'Get Help',   color: const Color(0xFF8B5CF6)),
      _MenuItem(index: 4, icon: Icons.logout_rounded,            label: 'Logout',     color: const Color(0xFFEF4444), isDestructive: true),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1135).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return _menuRow(item, isLast);
        }),
      ),
    );
  }

  Widget _menuRow(_MenuItem item, bool isLast) {
    return InkWell(
      onTap: () => _manageItemSelection(item.index),
      borderRadius: BorderRadius.vertical(
        top: item.index == 0 ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        height: 60,
        decoration: isLast
            ? null
            : const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF0F1F8), width: 1))),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, size: 18, color: item.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(item.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: item.isDestructive
                    ? const Color(0xFFEF4444)
                    : _textHi)),
          ),
          Icon(Icons.chevron_right_rounded,
            size: 20,
            color: item.isDestructive ? const Color(0xFFEF4444) : _textLo),
        ]),
      ),
    );
  }

  Future<void> _manageItemSelection(int key) async {
    if (key == 0) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (_) => const MainScreenWidget(defaultIndex: 2),
      ), (route) => false);
    }
    if (key == 1) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (_) => const MainScreenWidget(defaultIndex: 3),
      ), (route) => false);
    }
    if (key == 2) {
      final Uri url = Uri.parse(CommonConstants.helpUrl);
      await launchUrl(url);
    }
    if (key == 3) {
      Navigator.pushNamed(context, CommonConstants.invoiceScreenWidget);
    }
    if (key == 5) {
      Navigator.pushNamed(context, CommonConstants.arScreenWidget);
    }
    if (key == 4) {
      signOutUser();
      UserMasterRepository().clearUserMaster();
      OrderRepository().clearOrderItems();
      OrderMasterRepository().clearOrderMaster();
      ReturnItemRepository().clearReturnItems();
      ReturnMasterRepository().clearReturnMaster();
      Navigator.pushNamedAndRemoveUntil(
          context, CommonConstants.loginScreenUrl, (route) => false);
    }
  }
}

class _MenuItem {
  final int index;
  final IconData icon;
  final String label;
  final Color color;
  final bool isDestructive;
  const _MenuItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.color,
    this.isDestructive = false,
  });
}
