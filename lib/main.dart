import 'package:flutter/material.dart';
import 'impact/impact.dart';

void main() {
  runApp(MainApp());
}
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  final impact = Impact();
  String serverStatus = 'offline';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center (
          child : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children : [
            // Button to verify the server status
            ElevatedButton(onPressed: () async {
              serverStatus = await impact.serverStatus();
              setState(() {
              });
            }, child: Text('Test ping')),
            Text('Server $serverStatus'),
            ElevatedButton(onPressed: () async {
              await impact.authentication();
            }, child: Text('Authentication')),
            ElevatedButton(onPressed: () async {
              impact.printer();
            }, child: Text('Printer')),
            ElevatedButton(onPressed: () async {
              await impact.getStepsSingleDay('2024-05-04');
            }, child: Text('Get steps')),
            ElevatedButton(onPressed: () async {
              await impact.refresh();
            }, child: Text('Refresh')),
          ]
        ),
        ),
      ),
      );
  }
}