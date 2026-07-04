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
import '../theme.dart';

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
  late DataProvider _dataProvider;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataProvider = context.read<DataProvider>();
  }

  @override
  void dispose() {
    _dataProvider.stop();
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
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WELCOME BACK',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  widget.username,
                  style: displayNumber(size: 44),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          //yesterday's steps and burned calories side by side
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.directions_walk,
                  label: 'STEPS',
                  value: '${provider.stepsDay}',
                  color: AppColors.accent,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department,
                  label: 'KCAL BURNED',
                  value: '${provider.caloriesDay}',
                  color: AppColors.fat,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          StepsBarChart(data: provider.stepsBtwTwoDates),
          SizedBox(height: 12),
          // Step perc from last week
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: provider.increaseStepPerc > 0
                        ? AppColors.accent.withValues(alpha: 0.12)
                        : AppColors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        provider.increaseStepPerc > 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: provider.increaseStepPerc > 0
                            ? AppColors.accent
                            : AppColors.danger,
                        size: 22,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "${provider.increaseStepPerc > 0 ? '+' : ''}${provider.increaseStepPerc}%",
                        style: displayNumber(
                          size: 24,
                          color: provider.increaseStepPerc > 0
                              ? AppColors.accent
                              : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "from last week",
                  style: TextStyle(fontSize: 15, color: AppColors.muted),
                ),
              ],
            ),
          ),
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
              color: AppColors.accent, //active tab
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

//compact stat card with icon, big numeral and label
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: displayNumber(size: 34)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.titleSmall),
        ],
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