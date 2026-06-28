import 'package:bwthw_project/screens/home_page.dart';
import 'package:bwthw_project/screens/login/login_utils.dart';
import 'package:flutter/material.dart';
import 'screens/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/sign_in_page.dart';
import 'package:provider/provider.dart';
import 'providers/data_provider.dart';


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
        startPage = HomePage(title: 'Title', username: username);
      }
      else{
        startPage = SignInPage(title: 'Title', username: username);
      }
    } else {
      startPage = LoginPage(title: 'Title');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (startPage == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return MaterialApp(
      home: startPage!,
    );
  }
}