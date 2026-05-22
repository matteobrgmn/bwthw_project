import 'package:bwthw_project/screens/login/login_page.dart';
import 'package:bwthw_project/screens/meal_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login/login_utils.dart';

void main() {
  // DEBUGGING SEGMENT
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Page',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const HomePage(title: 'Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

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
            SizedBox(height: 50),
            ElevatedButton(onPressed: () {
              getRememberData(); // Debug
              print('Logout'); // Debug
              logout();
              getRememberData(); // Debug
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(title: ''),
                ),
              );
            }, child: Text('Logout')),
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
                      title: const Text("Refresh page", style: TextStyle(fontSize: 26)),
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
              icon: const Icon(Icons.home_filled)),

            //transfer context to data page
            IconButton(onPressed: () {


              // INSERIRE IL DATO PER IDENTIFICARE LA PAGINA DEI DATI UNA VOLTA CHE SARÀ CREATA
            

              //Navigator.push(context, MaterialPageRoute(builder: (context) => const DataPage()));
            }, icon: Icon(Icons.bar_chart)),

           //transfer context to meal page
           IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MealPage(title: "Meal Page")));
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
void logout() async {
  final sp = await SharedPreferences.getInstance();
  await sp.setBool('rememberLogin', false);
}