import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score int NOT NULL DEFAULT 0 
    )
    ''');

  await db.execute('''
        INSERT INTO user ( id,score ) VALUES (1,0)
    ''');

  await db.execute('''
        CREATE TABLE habits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            habit varchar(200) NOT NULL DEFAULT 0,
            is_bad boolean NOT NULL DEFAULT 1
        )
    ''');

  await db.execute('''
        CREATE TABLE habits_daily_score (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date int NOT NULL DEFAULT (strftime('%s', 'now')),  
            habit_id int NOT NULL,
            FOREIGN KEY (habit_id) REFERENCES habits(id)
        )
    ''');
}

Future onOpen(Database db) async {}

Future<Database> getdb() async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'notes.db');
  return await openDatabase(path,
      version: 1, onCreate: createDB, onOpen: onOpen);
}



Future close(Database db) async {
    await db.close();
}
