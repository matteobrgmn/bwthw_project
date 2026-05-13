import 'package:flutter/material.dart';

void main() {
  // DEBUGGING SEGMENT
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Page',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
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
  final List<TextEditingController> _controllers = [];
  int numMeal = 1;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

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
            SizedBox(height: 50),
            // TODO: implementare menu modulare di aggiunta pasti
            // TO assess: LLM-powered??
            Title(color: Colors.black, child: Text("Meal update")),

            //makes a list of all the entries of the menu
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: _controllers.asMap().entries.map((e) {
                  return Row(
                    key: ValueKey(e.key),
                    mainAxisAlignment: .center,
                    children: [
                      Text("Menu entry #${e.key + 1}"),
                      Expanded(
                        child: TextField(
                          controller: e.value,
                          decoration: InputDecoration(
                            hintText: 'Enter the ingredient',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _controllers.add(TextEditingController());
                  numMeal++;
                });
              },

              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor: const Color.fromARGB(255, 171, 97, 184),
              ),
              child: Icon(
                Icons.add,
                color: Colors.deepPurpleAccent[400],
                size: 30,
              ),
            ),

            //generazione condizionata di un elevatedButton che rimuove gli elementi dei pasti se esiste almeno un alimento nel menu
            numMeal > 1
                ? ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _controllers.last.dispose();
                        _controllers.removeLast();
                        numMeal--;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: const Color.fromARGB(255, 169, 100, 181),
                    ),
                    child: Icon(
                      Icons.remove_circle,
                      color: Colors.deepPurpleAccent[400],
                      size: 30,
                    ),
                  )
                : SizedBox(height: 0),
            /* ElevatedButton(onPressed: () async {
                Navigator.pop(context);
              }, child: Text("Homepage")),     */
          ],
        ),
      ),
    );
  }
}
