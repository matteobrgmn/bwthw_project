import 'package:bwthw_project/screens/sign_in_page.dart';
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../debug_page.dart';
import '../home_page.dart';
import 'login_utils.dart';


//void main() {
//  runApp(const MyApp()); SEGMENTO UTILE PER TESTARE LA PAGINA DA SOLA
//}

List<bool> _selectedOption = [true, false];

const List<Widget> options = <Widget>[Text("Login"),Text("Sign up")];
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(title: 'Start your journey'),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool rememberUserData = false;
  bool acceptTermsAndConditions = false;
  bool signUp = false;

  void _showAlertDialog(String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: .start,
          children: [
            SizedBox(height: 30),
            Text('WELCOME', style: Theme.of(context).textTheme.titleSmall),
            Text('Start your journey', style: displayNumber(size: 40)),
            SizedBox(height: 24),
            ToggleButtons(
              direction: Axis.horizontal,
               onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedOption.length; i++) {
                      _selectedOption[i] = i == index;
                    }
                  });
                  signUp = _selectedOption[1];
                },
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderColor: AppColors.outline,
                selectedBorderColor: AppColors.accent,
                selectedColor: AppColors.onAccent,
                fillColor: AppColors.accent,
                color: AppColors.muted,
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 80.0,
                ),
                isSelected: _selectedOption,
                children: options,
              ),
              SizedBox(height: 10,),
              if (_selectedOption[1]) ... [
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.fromLTRB(20,0,20,0),
                child: TextField(
                  controller : userController,
                  decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  prefixIcon: Icon(Icons.person),
                ),
               ),
              ),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.fromLTRB(20,0,20,0),
                child: TextField(
                  obscureText: true,
                  controller : passController,
                  decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.key),
                ),
               ),
              ),
              SizedBox(height: 10,),

              if (_selectedOption[1]) ...[
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: InkWell(
                    onTap: () {
                        _showAlertDialog("This application is intended for demonstration purposes only. Data stored on the device are not encrypted and should not be considered secure. Do not use real or sensitive personal information.");
                    },
                    child: const Text(
                      "Accept terms and conditions",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  value: acceptTermsAndConditions,
                  onChanged: (value) {
                    setState(() {
                      acceptTermsAndConditions = value ?? false;
                    });
                  },
                ),
              ],

              CheckboxListTile(
                title: const Text("Remember me"),
                value: rememberUserData,
                onChanged: (value) {
                  setState(() {
                    rememberUserData = value ?? false;
                  });
                },
              ),
              
              ElevatedButton(onPressed: () async {
                String username = userController.text;
                String password = hashPassword(passController.text);
                // print(username); Debug
                // print(password); // Debug
                if (_selectedOption[0]) {
                  // Login
                  
                  LoginResult loginResult = await verifyLoginData(username, password);

                  if (((username == 'admin') && (password == hashPassword('admin123')))) {
                    // Login with superuser
                    //print('Login with superuser credentials!'); // Debug
                    // Maybe go to the debug page before
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(title: '',username: username ,)));
                  } else if (loginResult.success) {
                    rememberData(rememberUserData, username);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(title: '', username: username,)));
                    //print(loginResult.message); // Debug
                    //getRememberData();
                  } 
                  //else {
                    // Login failed case
                    // print(loginResult.message); // Debug
                  //}
                  _showAlertDialog(loginResult.message);
                  // Clear password if it's wrong
                  passController.clear();
                } else {
                  String email = emailController.text;
                  // Signup failed
                  if (!acceptTermsAndConditions) {
                    _showAlertDialog('Please read and accept our terms and conditions.');
                  }
                  else {
                    // Sign up
                    SignupResult signupResult = await enterSignupData(email, username, password);
                    
                    if (signupResult.success) {
                      // Signup success
                      rememberData(rememberUserData, username);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage(title: '', username: username,)));
                    } else {
                      _showAlertDialog(signupResult.message);
                    }
                  }
                  // Clear password if it's duplicated
                  passController.clear();
                }

              }, child: _selectedOption[0]?Text("Log in"):Text("Sign in")),    
              
              TextButton(onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DebugPage()));
              }, child: Text("Go to debug page")),
           ],
          ),
         ),
        ),
      );
  }
}