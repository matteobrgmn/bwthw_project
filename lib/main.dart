import 'package:flutter/material.dart';
import 'screens/debugPage.dart';
void main() {
  runApp(MainApp());
}
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  String serverStatus = 'offline';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home : DebugPage(),
    );
  }
}