import 'package:flutter/material.dart';
import 'package:habitscore/screens/habit_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import './db/db.dart';
import './screens/add_habit.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int score = 0;
  late Database db;

  Future getScore() async {
    List<Map> list = await (await getdb()).rawQuery('SELECT * FROM user');
    score = list[0]['score'];
    return score;
  }

  Future<List<Map<String, dynamic>>>? getHabits() async {
    return await (await getdb()).rawQuery('SELECT * FROM habits');
  }

  void setHabitScore(int habitId) async {
    await (await getdb()).rawInsert(
        "INSERT into habits_daily_score (date,habit_id) VALUES (?,?)",
        [DateTime.now().millisecondsSinceEpoch, habitId]);
  }

  @override
  void initState() {
    getdb().then(
      (database) {
        setState(() {
          db = database;
        });
      },
    );
    getScore();
    super.initState();
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
          actions: [
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddHabitScreen()))
                      .then((value) {
                    setState(() {});
                  });
                }),
          ],
          title: const Text("Habit Tracker")),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Your Score',
                        style: TextStyle(
                            fontSize: 23, fontWeight: FontWeight.w300)),
                    Text('$score',
                        style: const TextStyle(
                            fontSize: 43, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
            const Text("Your Habits",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w300)),
            const SizedBox(height: 20),
            FutureBuilder<List<Map<String, dynamic>>>(
                future: getHabits(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            leading: IconButton(
                                icon: const Icon(Icons.done,
                                    color: Color(0xff00ff00)),
                                onPressed: () {
                                  setHabitScore(snapshot.data![index]["id"]);
                                }),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HabitScreen(
                                          habitId: snapshot.data![index]
                                              ["id"]))).then((value) {
                                setState(() {});
                              });
                            },
                            title: Text(snapshot.data![index]["habit"]));
                      },
                    );
                  } else {
                    return const SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: Center(child: CircularProgressIndicator()));
                  }
                })
          ],
        ),
      ),
    );
  }
}
