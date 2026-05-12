import 'package:flutter/material.dart';
import '../impact/impact.dart';
import 'package:fl_chart/fl_chart.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  
  final impact = Impact();
  List<FlSpot> spots = [];
  String serverStatus = 'offline';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              if (mapOfDates == null){
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('The date range is not valid!')),
                );
              }
              else{
                var i = 0;
                spots = [];
                mapOfDates.forEach((key, value) {
                spots.add(
                    FlSpot(i.toDouble(), value.toDouble()),
                  );
                  i += 1;
                  setState(() {
                    
                });
              });
              }
              // print(spots); // Debug
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
          ),
          ElevatedButton(onPressed: () async {
              Navigator.pop(context);
            }, child: Text('Back to login page')),
        ]
        ),
      ),
    );
  }
}