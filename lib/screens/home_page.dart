import 'package:bwthw_project/screens/login/login_page.dart';
import 'package:bwthw_project/screens/meal_page.dart';
import 'package:bwthw_project/screens/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*void main() {
  // DEBUGGING SEGMENT
  runApp(MyApp());
}*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Page',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const HomePage(title: 'Home Page', username: ""),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title, required this.username});
  final String title;
  final String username;
  @override
  State<HomePage> createState() => _HomePageState();

  void needSignUp(BuildContext context) async {
    final sp = await SharedPreferences.getInstance();
    final user = sp.getStringList(username);
    if (username.isEmpty || user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(title: "")),
      );
    } else if (user[3] == "true") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInPage(title: "", username: username),
        ),
      );
    }
  }
}

class _HomePageState extends State<HomePage> {


  @override
  void initState() {
    widget.needSignUp(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


  final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
  );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title : Text('Home'),
        actions: <Widget>[
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Are you sure you want to log out of you account?'),
 //                       content: const Text('Fill out all values before submitting the form'),
                        actions: [
                          ElevatedButton(onPressed: (){
                            Navigator.pop(context);
                            // Logout 
                            logout(context);
                          }, child: Text('Yes')),
                          ElevatedButton(onPressed: (){
                            // Close dialog
                            Navigator.pop(context);
                          }, child: Text('No'))
                        ],
                      );
                    },
                  );
            },
          ),
        ],

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .start,
          children: [
            SizedBox(height: 50),
            Spacer(),
          ],
        ),
      ),

      //navigation bar used in each of the pages. each page will return to the homepage in order
      //to maintain a tidy navigation stack
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      alignment: Alignment.center,
                      title: const Text(
                        "Refresh page",
                        style: TextStyle(fontSize: 26),
                      ),
                      content: const Text("Do you wish to refresh the page?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("No"),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              //SETUP PAGE REFRESH IF NEEDED
                            });
                          },
                          child: const Text("Yes"),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.home_filled),
            ),

            //transfer context to data page
            IconButton(
              onPressed: () {
                // INSERIRE IL DATO PER IDENTIFICARE LA PAGINA DEI DATI UNA VOLTA CHE SARÀ CREATA

                //Navigator.push(context, MaterialPageRoute(builder: (context) => const DataPage()));
              },
              icon: Icon(Icons.bar_chart),
            ),

            //transfer context to meal page
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealPage(username: widget.username),
                  ),
                );
              },
              icon: const Icon(Icons.menu_book),
            ),
          ],
        ),
      ),
    );
  }
}

/* Function for logout */
Future<void> logout(BuildContext context) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setBool('rememberLogin', false);
  
 if (!context.mounted) return;

  Navigator.pushReplacement(
    context, 
    MaterialPageRoute(builder: (context) => LoginPage(title: '')),
  );
}

