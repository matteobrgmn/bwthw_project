import 'package:bwthw_project/screens/data_page.dart';
import 'package:bwthw_project/screens/login/login_page.dart';
import 'package:bwthw_project/screens/meal_page.dart';
import 'package:bwthw_project/screens/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/impact/impact.dart';
import '../widgets/steps_bar_chart.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../providers/data_provider.dart';

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
  final impact = Impact();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.needSignUp(context);
    });
    Future.microtask(() {
      context.read<DataProvider>().start();
    });
  }

  @override
  void dispose() {
    context.read<DataProvider>().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Home'),
        actions: <Widget>[
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'Are you sure you want to log out of your account?',
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Logout
                          logout(context);
                        },
                        child: Text('Yes'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Close dialog
                          Navigator.pop(context);
                        },
                        child: Text('No'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
              "Hello ${widget.username}!",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.directions_walk),
              SizedBox(width: 10),
              Text(
                "Daily steps: ${provider.stepsDay}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.local_dining),
              SizedBox(width: 10),
              Text(
                "Daily calories: ${provider.caloriesDay}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          StepsBarChart(data: provider.stepsBtwTwoDates),
          SizedBox(height: 20),
          Row( children : [
            SizedBox(width: 20),
            if (provider.increaseStepPerc > 0)
              const Icon(
                Icons.local_fire_department,
                color: Colors.red,
                size: 30,
              )
            else
              const Icon(
              Icons.sentiment_very_dissatisfied,
              color: Colors.blue,
              size: 30,
            ),
            SizedBox(width: 5),
            Text(
              "${provider.increaseStepPerc > 0 ? '+' : ''}${provider.increaseStepPerc}%",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(width: 10),
            Text(
                "from last week!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
            ),          ]
        ),// Step perc from last week
        ],
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

            IconButton(
              onPressed: () async {
                String? nav = "data";
                do {
                  if (nav == "data") {
                    nav = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DataPage(username: widget.username),
                      ),
                    );
                  } else if (nav == "meal") {
                    nav = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MealPage(username: widget.username),
                      ),
                    );
                  }
                } while (nav != null && nav != "home");
              },
              icon: const Icon(Icons.bar_chart),
            ),

            //transfer context to meal page
            IconButton(
              onPressed: () async {
                String? nav = "meal";
                do {
                  if (nav == "meal") {
                    nav = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MealPage(username: widget.username),
                      ),
                    );
                  } else if (nav == "data") {
                    nav = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DataPage(username: widget.username),
                      ),
                    );
                  }
                } while (nav != null && nav != "home");
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