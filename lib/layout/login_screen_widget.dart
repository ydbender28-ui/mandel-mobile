import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/utility/auth_support_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});

  @override
  State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget>
    with AuthSupportUtility {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false;
  String _errorMessage = '';

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final dio = Dio();
      final response = await dio.post(
        '${CommonConstants.mandelBaseUrl}/login',
        data: {
          'email': _userNameController.text.trim().toLowerCase(),
          'password': _passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        await saveToken(response.data['token']);
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(CommonConstants.mainScreenUrl);
        }
      } else {
        setState(() { _errorMessage = response.data['error'] ?? 'Login failed'; });
      }
    } catch (e) {
      setState(() { _errorMessage = 'Invalid email or password'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Logo
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 7.0),
                  child: Image.asset(
                    'assets/images/mandel_login.png',
                    width: 200,
                    height: 200,
                  ),
                ),
                const Text(
                  'Mandel Wholesale',
                  style: TextStyle(
                    color: Color(0xFF26464a),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to your account',
                  style: TextStyle(color: Color(0xFF26464a), fontSize: 14),
                ),
                const SizedBox(height: 30),

                // Email field
                Container(
                  margin: const EdgeInsets.only(left: 40, right: 40, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email *', style: TextStyle(fontSize: 13)),
                      TextFormField(
                        controller: _userNameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                          contentPadding: EdgeInsets.only(left: 10),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 13),
                        validator: (value) {
                          if (value!.trim().isEmpty) return 'Email is required';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                // Password field
                Container(
                  margin: const EdgeInsets.only(left: 40, right: 40, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Password *', style: TextStyle(fontSize: 13)),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                          contentPadding: const EdgeInsets.only(left: 10),
                          suffixIcon: IconButton(
                            icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() { _passwordVisible = !_passwordVisible; }),
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                        validator: (value) {
                          if (value!.trim().isEmpty) return 'Password is required';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                // Error message
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                    child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),

                const SizedBox(height: 16),

                // Login button
                Container(
                  margin: const EdgeInsets.only(left: 40, right: 40),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
