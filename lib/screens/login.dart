import 'package:flutter/material.dart';
import 'debug_page.dart';
import 'home_page.dart';

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
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
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
              ElevatedButton(onPressed: (){
                String username = userController.text;
                String password = passController.text;
                // print(username); Debug
                // print(password); // Debug
                if ((username == 'admin') && (password == 'admin123456')) { // Debug password
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(title: '',)));
                } else if (username == 'xx') {
                  // Manage real username and password through sharepreferences
                }
                // Clear password if it's wrong
                passController.clear();
              }, child: _selectedOption[0]?Text("Log in"):Text("Sign in")),

              ElevatedButton(onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DebugPage()));
              }, child: Text("Go to debug page")),
              
           ],
          ),
        ),
      );
  }
}