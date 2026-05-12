import 'package:flutter/material.dart';

//void main() {
//  runApp(const MyApp()); SEGMENTO UTILE PER TESTARE LA PAGINA DA SOLA
//}

List<bool> _selectedOption = [true, false];

const List<Widget> options = <Widget>[Text("New Meal"),Text("Meal List")];
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MealPage(title: 'Meal register'),
    );
  }
}

class MealPage extends StatefulWidget {
  const MealPage({super.key, required this.title});
  final String title;
  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
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
            SizedBox(height:50,),
              ElevatedButton(onPressed: () async{
                // TODO: implementare menu modulare di aggiunta pasti
                // TO assess: LLM-powered??
              }, child: Icon(Icons.add)),
              ElevatedButton(onPressed: () async {
                Navigator.pop(context);
              }, child: Text("Homepage")),             
           ],
          ),
        ),
      );
  }
}
