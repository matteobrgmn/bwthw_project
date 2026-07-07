import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/* Class with the login procedure result and message */
class LoginResult {
  final bool success;
  final String message;

  LoginResult(this.success, this.message);
}

/* Function to verify the login data according to the following criteria:
 *  - All the field must be completed.
 *  - User must be in the sharedpreferences
 *  - Password must corresponds with the password saved in the sharepreferences
 */
Future<LoginResult> verifyLoginData(
  String inUsername,
  String inPassword,
) async {
  // Verify empty field
  if (inUsername.isEmpty || inPassword.isEmpty) {
    return LoginResult(false, "Complete all the field please!");
  }

  final sp = await SharedPreferences.getInstance();
  final userList = sp.getStringList(inUsername);
  await sp.setString("username", inUsername);

  if (userList == null) {
    return LoginResult(false, "Username not found!");
  }

  if (userList[2] == inPassword) {
    return LoginResult(true, "Welcome back!");
  }

  return LoginResult(false, "Wrong password!");
}

/* Class with the signup procedure result and message */
class SignupResult {
  final bool success;
  final String message;

  SignupResult(this.success, this.message);
}

/* Function to verify the signup data according to the following criteria:
 *  - All the field must be completed.
 *  - Username must be not used.
 */
Future<SignupResult> enterSignupData(
  String inEmail,
  String inUsername,
  String inPassword,
) async {
  if (inEmail.isEmpty ||
      inUsername.isEmpty ||
      (inPassword.isEmpty ||
          inPassword.trim() ==
              "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")) {
    return SignupResult(false, "Complete all the field please!");
  }

  final sp = await SharedPreferences.getInstance();
  final verifyUserAlreadyExist = sp.getStringList(inUsername);

  if (verifyUserAlreadyExist == null) {
    // Create new user
    List<String> userList = [inEmail, inUsername, inPassword, "true"];

    await sp.setStringList(inUsername, userList); // Create new username
    await sp.setString("username", inUsername);
    return SignupResult(true, 'Registration completed. Welcome to NutriTrack!');
  }

  // Duplicated
  return SignupResult(false, 'Username already used!');
}

/* Function to remember login data */
void rememberData(bool remember, String username) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setBool('rememberLogin', remember);
  await sp.setString("username", username);
}

/* Function to get remember login data (for debug) 
void getRememberData () async {
  final sp = await SharedPreferences.getInstance();
  bool? rememberValue = sp.getBool('rememberLogin');
  //print('Remember value is $rememberValue'); // Debug
}*/

Future<bool> verifyUserBiometricsSaved(String inUser) async {
  final sp = await SharedPreferences.getInstance();
  final user = sp.getStringList(inUser);
  return (user![3] == "false");
}

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
