import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../db/db.dart';

class HabitScreen extends StatefulWidget {
  final int habitId;

  const HabitScreen({Key? key, required this.habitId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HabitScreenState createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  Future<List<Map<String, dynamic>>> getHabitDetails() async {
    return await (await getdb())
        .rawQuery('SELECT * FROM habits WHERE id=?', [widget.habitId]);
  }

  List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i < endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  Future<List<Map<String, dynamic>>> getHabitDates(
      int habitId, int isBad) async {
    List<Map<String, dynamic>> dates = await (await getdb()).rawQuery(
        'SELECT * FROM habits_daily_score WHERE habit_id=?', [habitId]);

    List<Map<String, dynamic>> datesWritable = [];
    for (var i = 0; i < dates.length; i++) {
      datesWritable.add(Map.from(dates[i]));
    }
    List<Map<String, dynamic>> datesCopy = [];
    int score = 1;
    for (var i = 0; i < datesWritable.length - 1; i++) {
      DateTime date =
          DateTime.fromMillisecondsSinceEpoch(datesWritable[i]['date']);
      DateTime date2 =
          DateTime.fromMillisecondsSinceEpoch(datesWritable[i + 1]['date']);

      datesWritable[i]['score'] = isBad == 1 ? --score : score;

      datesCopy.add(datesWritable[i]);

      List<DateTime> betweenDates = getDaysInBetween(date, date2);

      for (var j = 0; j < betweenDates.length; j++) {
        Map<String, dynamic> tempDateMap = {};
        tempDateMap['date'] = betweenDates[j];
        tempDateMap['score'] = isBad == 1 ? ++score : --score;
        datesCopy.add(tempDateMap);
      }

      datesWritable[i + 1]['score'] = isBad == 1 ? --score : ++score;
      datesCopy.add(datesWritable[i + 1]);
    }
    return datesCopy;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
        title: const Text("View Habit"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<Map<String, dynamic>>>(
            future: getHabitDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(snapshot.data![0]['habit'],
                        style: const TextStyle(
                            fontSize: 33, fontWeight: FontWeight.bold)),
                    Text(
                        snapshot.data![0]['is_bad'] == 1
                            ? 'Bad Habit'
                            : 'Good Habit',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w300)),
                    const SizedBox(height: 30),
                    const Text("Progress",
                        style: TextStyle(
                            fontSize: 23, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 30),
                    FutureBuilder<List<Map<String, dynamic>>>(
                        future: getHabitDates(snapshot.data![0]['id'],
                            snapshot.data![0]['is_bad']),
                        builder: (context, snapshot2) {
                          if (snapshot2.connectionState ==
                              ConnectionState.done) {
                            var habitDates = snapshot2.data!;
                            List<double> scores = [];
                            for (var habit in habitDates) {
                              scores.add(habit['score'].toDouble());
                            }

                            Map<DateTime, int> heatMapDataSet = {};

                            for (var habit in habitDates) {
                              var date = DateUtils.dateOnly(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      habit['date']));
                              heatMapDataSet[date] = 1;
                            }

                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Sparkline(
                                    data: scores,
                                    pointsMode: PointsMode.all,
                                    averageLine: true,
                                    averageLabel: true,
                                    kLine: const [
                                      'max',
                                      'min',
                                      'first',
                                      'last'
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  const Text("HeatMap",
                                      style: TextStyle(
                                          fontSize: 23,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 30),
                                  HeatMap(
                                  //datasets: {
                                  //DateTime(2022, 7, 17): 1,
                                  //},
                                  datasets: heatMapDataSet,
                                  colorMode: ColorMode.opacity,
                                  showColorTip: false,
                                  colorsets: const {
                                      1: Colors.blue,
                                  },
                                  scrollable: true,
                                  )
                                ]);
                          } else {
                            return const CircularProgressIndicator();
                          }
                        }),
                  ],
                );
              } else {
                return const CircularProgressIndicator();
              }
            }),
      ),
    );
  }
}
