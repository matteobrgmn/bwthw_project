import 'package:bwthw_project/screens/home_page.dart';
import 'package:bwthw_project/screens/login/login_utils.dart';
import 'package:flutter/material.dart';
import 'screens/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/sign_in_page.dart';
import 'package:provider/provider.dart';
import 'providers/data_provider.dart';
import 'theme.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => DataProvider(),
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Widget? startPage;

  @override
  void initState() {
    super.initState();
    loadStartPage();
  }

  /* Function executed in the first application start to verify if: 
   *    - the user selected rememberLogin
   *    - the correct user data
   *  and select the correct page
   */
  void loadStartPage() async {
    final sp = await SharedPreferences.getInstance();

    bool remember = false;
    bool? storedValue = sp.getBool('rememberLogin');
    
    if (storedValue != null) {
      remember = storedValue;
    } else {
      remember = false;
    }

    if (remember == true) {
      String username = sp.getString("username")!;
      bool userBiom = await verifyUserBiometricsSaved(username);
      if(userBiom)
      {
        // Verification ok, go to the home page
        startPage = HomePage(title: 'Title', username: username);
      }
      else{
        // Go to the signin page to fill the data
        startPage = SignInPage(title: 'Title', username: username);
      }
    } else {
      // Remember me false go to the login page
      startPage = LoginPage(title: 'Title');
    }
    // Rebuild widget
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Loading fail
    if (startPage == null) {
      return MaterialApp(
        theme: buildAppTheme(),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    // Loading success go to the page
    return MaterialApp(
      theme: buildAppTheme(),
      home: startPage!,
    );
  }
}