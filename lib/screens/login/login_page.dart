import 'package:flutter/material.dart';
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
       backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .start,
          children: [
            SizedBox(height:50,),
            const Text("Please input login details"),
            SizedBox(height: 5,),
            ToggleButtons( 
              direction: Axis.horizontal,
               onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedOption.length; i++) {
                      _selectedOption[i] = i == index;
                    }
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.deepPurpleAccent[700],
                selectedColor: Colors.white,
                fillColor: const Color.fromARGB(255, 169, 100, 181),
                color: Colors.deepPurpleAccent[400],
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
                      border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),  
                ),
               ),
              ),
              SizedBox(height: 10,),
              ElevatedButton(onPressed: () async {
                String username = userController.text;
                String password = passController.text;
                // print(username); Debug
                // print(password); // Debug
                if (_selectedOption[0]) {
                  // Login
                  LoginResult loginResult = await verifyLoginData(username, password);

                  if (((username == 'admin') && (password == 'admin123'))) {
                    // Login with superuser
                    print('Login with superuser credentials!'); // Debug
                    // Maybe go to the debug page before
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(title: '',)));
                  } else if (loginResult.success) {
                    rememberData(rememberUserData);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(title: '',)));
                    print(loginResult.message); // Debug
                    getRememberData();
                  } else {
                    // Login failed case
                    print(loginResult.message); // Debug
                  }
                  _showAlertDialog(loginResult.message);
                  // Clear password if it's wrong
                  passController.clear();
                } else {
                  String email = emailController.text;
                  // Sign up
                  SignupResult signupResult = await enterSignupData(email, username, password);
                  print(signupResult.message); // Debug

                  if (signupResult.success) {
                    // Signup success
                    rememberData(rememberUserData);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(title: '',)));
                  }
                  // Signup failed
                  _showAlertDialog(signupResult.message);
                  // Clear password if it's duplicated
                  passController.clear();
                }
              
              }, child: _selectedOption[0]?Text("Log in"):Text("Sign in")),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => DebugPage()));
              }, child: Text("Go to debug page")),
           ],
          ),
        ),
      );
  }
}