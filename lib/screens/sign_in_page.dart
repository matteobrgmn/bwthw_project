import 'dart:math' as math;
import 'package:bwthw_project/screens/home_page.dart';
import 'package:bwthw_project/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const SignInPage(title: 'Start your journey', username: ""),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.title, required this.username});
  final String title;
  final String username;
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Map<String, TextEditingController> _textFields = {};
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _textFields["H"] = TextEditingController();
    _textFields["W"] = TextEditingController();
    _textFields["BD"] = TextEditingController();
    _textFields["G"] = TextEditingController();
  }

  //method to check wether or not all textfields have been filled
  bool emptyKeys(Map<String, TextEditingController> checkMap) {
    bool flag = false;
    for (var i in checkMap.keys) {
      flag = (checkMap[i] == null || checkMap[i]!.text == "");
      if (flag) {
        break;
      }
    }
    return flag;
  }

  //method to handle the selection of dates to then fix the value of the related textfield
  Future<void> _selectDate() async {
    //generates a popup datepicker object, ranging from 1900 to today (adjusted)
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
    );

    //changes the date in the related textField
    setState(() {
      selectedDate = pickedDate;
      //print(selectedDate.toString().substring(0,10));
      _textFields["BD"]!.text = (selectedDate.toString()).substring(0, 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: .start,
            children: [
              SizedBox(height: 30),
              Text('ABOUT YOU', style: Theme.of(context).textTheme.titleSmall),
              Text('Profiling data', style: displayNumber(size: 40)),
              SizedBox(height: 16),

              //height
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: TextField(
                  controller: _textFields["H"],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Height',
                    hintText: 'Enter your height (cm)',
                    prefixIcon: Icon(Icons.height),
                  ),
                ),
              ),

              //weight
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: TextField(
                  controller: _textFields["W"],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Weight',
                    hintText: 'Enter your weight (Kg)',
                    prefixIcon: Icon(Icons.monitor_weight),
                  ),
                ),
              ),

              //birth date
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: TextField(
                  controller: _textFields["BD"],
                  decoration: InputDecoration(
                    labelText: 'Date of birth',
                    hintText: 'date of birth',
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  onTap: _selectDate,
                ),
              ),

              //gender
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  children: [
                    Text("Insert gender:"),
                    DropdownMenu<String>(
                      controller: _textFields["G"],
                      hintText: "Enter your gender",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: 'M', label: 'M'),
                        DropdownMenuEntry(value: 'F', label: 'F'),
                        DropdownMenuEntry(value: 'O', label: 'Other'),
                      ],
                    ),
                  ],
                ),
              ),

              //submit button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: ElevatedButton(
                  onPressed: () async {
                    //checks for all fields to be filled
                    if (emptyKeys(_textFields)) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Missing input'),
                            content: const Text(
                              'Fill out all values before submitting the form',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      final sp = await SharedPreferences.getInstance();
                      List<String>? userInfo = sp.getStringList(
                        widget.username,
                      );
                      for (var i in _textFields.keys) {
                        userInfo!.add(_textFields[i]!.text);
                      }
                      double bmi =
                          double.parse(_textFields["W"]!.text) /
                          (math.pow(
                            double.parse(_textFields["H"]!.text) / 100,
                            2,
                          ));
                      userInfo!.add(bmi.toString());
                      userInfo[3] = "false";
                      sp.setStringList(widget.username, userInfo);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(
                            title: "Title",
                            username: widget.username,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text("Save data"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
