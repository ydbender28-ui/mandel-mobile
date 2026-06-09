import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/db/entity/user_master_entity.dart';
import 'package:mandel_mobile_app/db/repository/user_master_repository.dart';
import 'package:mandel_mobile_app/model/user_search_result_dto.dart';
import 'package:mandel_mobile_app/service/user_service.dart';
import 'package:mandel_mobile_app/utility/auth_support_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_message.dart';
import 'package:mandel_mobile_app/utility/message_utility.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});

  @override
  State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget>
    with AuthSupportUtility, MessageUtility {
  final _userService = UserService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _confirmCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late String _username;
  late String _password;
  late String _confirmedPassword;
  late String _confirmCode;

  bool _isLording = false;
  bool _passwordVisible = false;
  bool _isInvalidCredentials = false;

  AuthSignInStep? _cognitoSigninStep;

  String? _loginAction;

  String _message = CommonConstants.symbolEmptyString;

  String _version = "";
  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
    });
  }

  Future<void> _signInUser(String username, String password) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      setState(() {
        _cognitoSigninStep = result.nextStep.signInStep;
        _loginAction = result.nextStep.signInStep.toString();
      });
      await _handleSignInResult(result);
    } on AuthException catch (e) {
      safePrint('Error signing in: ${e.message}');
      if (!mounted) return;
      showErrorMessage(message: e.message, context: context);
    }

    setState(() {
      _isLording = false;
    });
  }

  Future<void> _initiateForgetPasswrod() async {
    if (_formKey.currentState!.validate() && !_isLording) {
      setState(() {
        _isInvalidCredentials = false;
        _isLording = true;
      });

      _formKey.currentState!.save();

      if (await checkSessionIsExist()) {
        await signOutUser();
      }

      try {
        final results = await Amplify.Auth.resetPassword(username: _username);
        print(results);
        setState(() {
          //  _cognitoSigninStep = results.nextStep.updateStep;
          _loginAction = results.nextStep.updateStep.name.toString();
          _isLording = false;
        });
        if (!mounted) return;
        showSuccessMessage(
            message: "Password reset confirmation code sent to your email",
            context: context);
      } on AuthException catch (e) {
        safePrint(e);
        if (!mounted) return;
        showErrorMessage(message: e.message, context: context);
        setState(() {
          _isLording = false;
        });
      }
    }
  }

  Future<void> _confirmPasswordReset() async {
    if (_formKey.currentState!.validate() && !_isLording) {
      setState(() {
        _isInvalidCredentials = false;
        _isLording = true;
      });

      _formKey.currentState!.save();

      if (await checkSessionIsExist()) {
        await signOutUser();
      }

      try {
        final results = await Amplify.Auth.confirmResetPassword(
            username: _username,
            newPassword: _password,
            confirmationCode: _confirmCode);
        safePrint(results);
        setState(() {
          _isLording = false;
          _loginAction = results.nextStep.updateStep.name.toString();
        });
      } on AuthException catch (e) {
        safePrint(e);
        if (!mounted) return;
        showErrorMessage(message: e.message, context: context);
        setState(() {
          _isLording = false;
        });
      }
    }
  }

  Future<void> _handleSignInResult(SignInResult result) async {
    switch (result.nextStep.signInStep) {
      case AuthSignInStep.confirmSignInWithSmsMfaCode:
        final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
        _handleCodeDelivery(codeDeliveryDetails);
        break;
      case AuthSignInStep.confirmSignInWithNewPassword:
        setState(() {
          _password = "";
          _confirmedPassword = "";
        });
        _passwordController.clear();
        _confirmPasswordController.clear();
        break;
      case AuthSignInStep.confirmSignInWithCustomChallenge:
        final parameters = result.nextStep.additionalInfo;
        final prompt = parameters['prompt']!;
        safePrint(prompt);
        break;
      case AuthSignInStep.resetPassword:
        safePrint('Reset Password Request');
        // final resetResult = await Amplify.Auth.resetPassword(
        //   username: username,
        // );
        // await _handleResetPasswordResult(resetResult);
        break;
      case AuthSignInStep.confirmSignUp:
        safePrint('Resend the sign up code to the registered device.');
        // // Resend the sign up code to the registered device.
        // final resendResult = await Amplify.Auth.resendSignUpCode(
        //   username: username,
        // );
        // _handleCodeDelivery(resendResult.codeDeliveryDetails);
        break;
      case AuthSignInStep.done:
        safePrint('Sign in is complete');
        showSuccessMessage(
            message: 'Sign in is complete',
            context: context,
            duration: const Duration(seconds: 1));
        _storeAuthUser();
        break;
      default:
        safePrint('other');
        break;
    }
  }

  void _handleCodeDelivery(AuthCodeDeliveryDetails codeDeliveryDetails) {
    safePrint(
      'A confirmation code has been sent to ${codeDeliveryDetails.destination}. '
      'Please check your ${codeDeliveryDetails.deliveryMedium.name} for the code.',
    );
  }

  void _storeAuthUser() async {
    try {
      AuthUser authUser = await getCurrentUser();
      Response response = await _userService.getUser(authUser.userId);
      if (response.statusCode == 200) {
        UserSearchResultDto user = UserSearchResultDto.fromJson(response.data);
        await UserMasterRepository().storeOrderMasterRecode(UserMasterEntity(
          id: user.results![0].id,
          cognitoId: user.results![0].cognitoId,
          userType: user.results![0].userType,
          title: user.results![0].title,
          firstName: user.results![0].firstName,
          mediaUrl: user.results![0].middleName,
          lastName: user.results![0].lastName,
          status: user.results![0].status!,
        ));
        if (!mounted) return;
        Navigator.pushNamed(context, CommonConstants.mainScreenUrl);
      }
    } catch (e) {
      safePrint('Error get Current User: $e');
      if (!mounted) return;
      showErrorMessage(message: 'Error get Current User', context: context);
    }
  }

  Future<void> _performSignIn() async {
    if (_formKey.currentState!.validate() && !_isLording) {
      setState(() {
        _isInvalidCredentials = false;
        _isLording = true;
      });

      _formKey.currentState!.save();

      if (await checkSessionIsExist()) {
        await signOutUser();
      }

      _signInUser(_username, _password);
    }
  }

  Future<void> _performPasswordConfirm() async {
    if (_formKey.currentState!.validate() && !_isLording) {
      setState(() {
        _isLording = true;
      });

      _formKey.currentState!.save();

      try {
        final results = await Amplify.Auth.confirmSignIn(
            confirmationValue: _confirmedPassword);

        setState(() {
          _cognitoSigninStep = results.nextStep.signInStep;
          _loginAction = results.nextStep.signInStep.toString();
        });

        await _handleSignInResult(results);
      } on AuthException catch (e) {
        safePrint('Sign in error ${e.message}');
        if (!mounted) return;
        showErrorMessage(message: e.message, context: context);
      }
      // try {
      //   final result = await Amplify.Auth.signIn(
      //     username: username,
      //     password: password,
      //   );
      //   setState(() {
      //     _cognitoSigninStep = result.nextStep.signInStep;
      //   });
      //   await _handleSignInResult(result);
      // } on AuthException catch (e) {
      //   safePrint('Error signing in: ${e.message}');
      // }

      // setState(() {
      //   _isLording = false;
      // });
    }
  }

  List<Widget> _getSignFormWidgets() {
    return [
      _buildTitle('Hello'),
      _buildHeaderDescription('Sign in to your account...'),
      _buildBackgroundImage(),
      _buildEmailField(),
      _buildPasswordField("Password", _passwordController, (String? value) {
        _password = value!;
      }),
      _buildInformationBox(),
      _buildForgotPasswordCard(),
      _buildSignInButton("LOGIN", _performSignIn),
      _buildApplicationVersion(),
    ];
  }

  List<Widget> _getNewPasswordFormWidgets() {
    return [
      _buildTitle('Enter New Password'),
      _buildHeaderDescription('Confirm your new password'),
      _buildBackgroundImage(),
      _buildPasswordField("Password", _passwordController, (String? value) {
        _password = value!;
      }),
      _buildPasswordField("Confirm Password", _confirmPasswordController,
          (String? value) {
        _confirmedPassword = value!;
      }),
      _buildInformationBox(),
      _buildSignInButton('CONTINUE', _performPasswordConfirm),
      _buildApplicationVersion()
    ];
  }

  List<Widget> _initiateResetPasswordWigets() {
    return [
      _buildTitle("Reset Password"),
      _buildHeaderDescription(
          "Enter your email address to receive the verification code"),
      _buildBackgroundImage(),
      _buildEmailField(),
      _buildBackToLoginCard(),
      _buildSignInButton("SUBMIT", _initiateForgetPasswrod),
      _buildApplicationVersion()
    ];
  }

  List<Widget> _confirmResetPasswordWithCodeWigets() {
    return [
      _buildTitle("Enter New Password"),
      _buildHeaderDescription(
          "Submit your password reset code sent to your email"),
      _buildBackgroundImage(),
      _buildPasswordField("Password", _passwordController, (String? value) {
        _password = value!;
      }),
      _buildPasswordField("Confirm Password", _confirmPasswordController,
          (String? value) {
        _confirmedPassword = value!;
      }),
      _buildPasswordResetCodeField(),
      _buildBackToLoginCard(),
      _buildSignInButton("SUBMIT", _confirmPasswordReset),
      _buildApplicationVersion()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (AuthSignInStep.confirmSignInWithNewPassword.toString() ==
                      _loginAction)
                    ..._getNewPasswordFormWidgets()
                  else if ("InitiatePasswordReset" == _loginAction)
                    ..._initiateResetPasswordWigets()
                  else if ("confirmResetPasswordWithCode" == _loginAction)
                    ..._confirmResetPasswordWithCodeWigets()
                  else
                    ..._getSignFormWidgets()
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF26464a),
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderDescription(String text) {
    return Container(
      margin: const EdgeInsets.only(
        top: 1.0,
        bottom: 20.0,
      ),
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF26464a),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 7.0),
      child: Image.asset(
        'assets/images/mandel_login.png',
        width: 200,
        height: 200,
        opacity: const AlwaysStoppedAnimation(1),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
        margin: const EdgeInsets.only(left: 40, right: 40, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User ID or Email *',
              style: TextStyle(fontSize: 13),
            ),
            TextFormField(
              controller: _userNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                contentPadding: EdgeInsets.only(left: 10),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 13),
              validator: (value) {
                if (value!.trim().isEmpty) {
                  return CommonMessage.usernameCanNotEmpty;
                }
                return null;
              },
              onSaved: (value) {
                _username = value!.trim();
              },
            ),
          ],
        ));
  }

  Widget _buildPasswordResetCodeField() {
    return Container(
        margin: const EdgeInsets.only(left: 40, right: 40, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Code*',
              style: TextStyle(fontSize: 13),
            ),
            TextFormField(
              controller: _confirmCodeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                contentPadding: EdgeInsets.only(left: 10),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 13),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Code cannot be empty";
                }
                return null;
              },
              onSaved: (value) {
                _confirmCode = value!;
              },
            ),
          ],
        ));
  }

  Widget _buildPasswordField(String fieldName, TextEditingController controller,
      void Function(String?) onSaved) {
    return Container(
      margin: const EdgeInsets.only(left: 40, right: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$fieldName *',
            style: const TextStyle(fontSize: 13),
          ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              contentPadding: const EdgeInsets.only(left: 10),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
                icon: Icon(
                    _passwordVisible ? Icons.visibility_off : Icons.visibility),
              ),
            ),
            keyboardType: TextInputType.visiblePassword,
            obscureText: !_passwordVisible,
            textInputAction: TextInputAction.done,
            style: const TextStyle(fontSize: 15),
            validator: (value) {
              if (value!.isEmpty) {
                return CommonMessage.passwordCanNotEmpty;
              }
              return null;
            },
            onSaved: onSaved,
          )
        ],
      ),
    );
  }

  Widget _buildInformationBox() {
    return Visibility(
      visible: _isInvalidCredentials,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(
              maxWidth: 330.0,
            ),
            decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            margin: const EdgeInsets.only(top: 10.0),
            padding: const EdgeInsets.all(5),
            child: Text(
              _message,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordCard() {
    return Container(
      padding: const EdgeInsets.only(
        right: 50.0,
      ),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {
                  setState(() {
                    _loginAction = "InitiatePasswordReset";
                  });
                },
                child: const Text(" Forgot your password ?",
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    )))
          ]),
    );
  }

  Widget _buildBackToLoginCard() {
    return Container(
      padding: const EdgeInsets.only(
        right: 50.0,
      ),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {
                  setState(() {
                    _loginAction = "";
                  });
                },
                child: const Text("Try loging in?",
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    )))
          ]),
    );
  }

  Widget _buildApplicationVersion() {
    return Container(
        margin: const EdgeInsets.only(top: 30),
        child: Text(
          _version,
          style: const TextStyle(fontSize: 12, color: Colors.black38),
        ));
  }

  Widget _buildSignInButton(String buttonText, void Function() onPressed) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 114, right: 114),
      alignment: Alignment.center,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            minimumSize: const Size.fromHeight(45)),
        onPressed: onPressed,
        child: _isLording
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Text(
                buttonText,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
      ),
    );
  }
}
