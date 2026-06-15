import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandel_mobile_app/utility/auth_support_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});
  @override
  State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget>
    with AuthSupportUtility {
  final _formKey            = GlobalKey<FormState>();
  final _emailCtrl          = TextEditingController();
  final _passCtrl           = TextEditingController();
  bool _loading             = false;
  bool _passVisible         = false;
  String _error             = '';

  static const _h1    = Color(0xFF0C0F1E);
  static const _h2    = Color(0xFF1B2860);
  static const _indigo = Color(0xFF4F46E5);
  static const _bg    = Color(0xFFEEF0FA);

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await Dio().post(
        '${CommonConstants.mandelBaseUrl}/login',
        data: {
          'email':    _emailCtrl.text.trim().toLowerCase(),
          'password': _passCtrl.text.trim(),
        },
      );
      if (res.statusCode == 200 && res.data['token'] != null) {
        await saveToken(res.data['token']);
        final role = res.data['role'] ?? 'customer';
        if (role == 'salesman') {
          final salesmanName = res.data['salesmanName'] ?? '';
          await saveSalesmanName(salesmanName);
          if (mounted) Navigator.of(context).pushReplacementNamed(CommonConstants.salesmanScreenUrl);
        } else {
          final linkedStores = res.data['linkedStores'];
          if (linkedStores is List && linkedStores.isNotEmpty) {
            await saveLinkedStores(linkedStores);
          } else {
            await clearLinkedStores();
          }
          if (mounted) Navigator.of(context).pushReplacementNamed(CommonConstants.mainScreenUrl);
        }
      } else {
        setState(() { _error = res.data['error'] ?? 'Login failed'; });
      }
    } catch (_) {
      setState(() { _error = 'Invalid email or password'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        // dark header background
        Container(
          height: MediaQuery.of(context).size.height * 0.42,
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
            Positioned(left: -20, bottom: 20,
              child: Container(width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0EA5E9).withOpacity(0.08)))),
          ]),
        ),

        // scrollable content
        SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(children: [
                const SizedBox(height: 36),

                // logo
                Center(
                  child: Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2), width: 1)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      child: Image.asset(
                        'assets/images/mandel_login.png',
                        fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Mandel Wholesale',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3)),
                const SizedBox(height: 4),
                Text('Sign in to your account',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 13)),

                const SizedBox(height: 36),

                // card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D1135).withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // email
                      _label('Email'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0D1135)),
                        decoration: const InputDecoration(
                          hintText: 'you@company.com',
                          prefixIcon: Icon(Icons.mail_outline_rounded,
                              size: 18, color: Color(0xFF9AA3C2)),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        ),
                        validator: (v) =>
                            (v?.trim().isEmpty ?? true) ? 'Email is required' : null,
                      ),
                      const SizedBox(height: 18),

                      // password
                      _label('Password'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: !_passVisible,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0D1135)),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              size: 18, color: Color(0xFF9AA3C2)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18, color: const Color(0xFF9AA3C2)),
                            onPressed: () =>
                                setState(() => _passVisible = !_passVisible),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                        ),
                        validator: (v) =>
                            (v?.trim().isEmpty ?? true) ? 'Password is required' : null,
                      ),

                      // error
                      if (_error.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFEC4899).withOpacity(0.3))),
                          child: Row(children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 15, color: Color(0xFFEC4899)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error,
                                style: const TextStyle(
                                    color: Color(0xFFBE185D), fontSize: 12))),
                          ]),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Sign In',
                                  style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _label(String text) => Text(text,
    style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4A5272),
        letterSpacing: 0.3));
}
