import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

mixin AuthSupportUtility {
  Future<void> signOutUser() async {
    final result = await Amplify.Auth.signOut();
    if (result is CognitoCompleteSignOut) {
      safePrint('Sign out completed successfully');
    } else if (result is CognitoFailedSignOut) {
      safePrint('Error signing user out: ${result.exception.message}');
    }
  }

  Future<String> getTokenFromSession() async {
    final result = await Amplify.Auth.fetchAuthSession();
    final cognitoAuthSession = result as CognitoAuthSession;
    return cognitoAuthSession.userPoolTokensResult.value.accessToken.raw;
  }

  Future<bool> checkSessionIsExist() async {
    final result = await Amplify.Auth.fetchAuthSession();
    return result.isSignedIn;
  }

  Future<AuthUser> getCurrentUser() async {
    return await Amplify.Auth.getCurrentUser();
  }
}
