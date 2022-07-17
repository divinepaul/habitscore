import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../db/db.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  late Database db;

  final _formKey = GlobalKey<FormState>();
  bool is_bad = false;

  final nameController = TextEditingController();
  late String name;

  @override
  void initState() {
    getdb().then(
      (database) {
        db = database;
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    close(db);
    super.dispose();
  }

  Future addHabit(String habit, bool isBad) async {
    await db.rawInsert('INSERT INTO habits(habit, is_bad) VALUES(?,?)',
        [habit, isBad ? 1 : 0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.0,
        toolbarTextStyle: const TextStyle(color: Colors.black),
        title: const Text("Add Habit to track"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    const Text("Add a Habit",
                        style: TextStyle(
                            fontSize: 33, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  label: Text("Name"),
                  hintText: "eg: Drink Water",
                  border: OutlineInputBorder(),
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter a Habit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                  "Check the below checkbox if the habit you're adding is a bad habit that you want to avoid."),
              CheckboxListTile(
                  contentPadding: const EdgeInsets.all(0),
                  onChanged: (value) {
                    setState(() {
                      is_bad = !is_bad;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  value: is_bad,
                  title: const Text("Bad Habit")),
              ElevatedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    addHabit(nameController.text, is_bad).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Habit Added Succesfully")));

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddHabitScreen()));
                      Navigator.pop(context);
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Something went wrong"),
                      ));
                    });
                  }
                },
                child: const Text('Add Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
