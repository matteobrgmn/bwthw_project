import 'package:flutter/material.dart';
import 'impact/impact.dart';
import 'package:fl_chart/fl_chart.dart';

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
  List<FlSpot> spots = [];

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
            ElevatedButton(onPressed: () async {
              final mapOfDates = await impact.getStepsBtwTwoDates('2024-05-04', '2024-05-11');
              // print(mapOfDates); // Debug
              var i = 0;
              spots = [];
              mapOfDates.forEach((key, value) {
                spots.add(
                    FlSpot(i.toDouble(), value.toDouble()),
                  );
                  i += 1;
              });
              // print(spots); // Debug
              setState(() {
                
              });
            }, child: Text('Get steps between two dates')), 

            // Small chart to represent steps data
            SizedBox(
            height: 300,
            width : 300,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 7,
                minY: 0,
                maxY: 40000,
                gridData: FlGridData(show:false),
                // To remove description from right and the top
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots : spots,
                    isCurved: false,
                    barWidth: 2,
                  )
                ]
              )
            )
          )
        ]
        ),
        ),
      ),
      );
  }
}