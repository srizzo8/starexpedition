import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:starexpedition4/database_information/usersDatabaseInfo.dart';

class databaseService{
  static final databaseService dbs = databaseService.internal();
  factory databaseService() => dbs;
  databaseService.internal();
  static Database? db;

  Future<Database> get database async{
    if(db != null){
      return db!;
    }
    db = await initMyDatabase();
    return db!;
  }

  static const usersTable = """
  CREATE TABLE IF NOT EXISTS Users(
    id INT PRIMARY KEY,
    username TEXT,
    emailAddress TEXT,
    password TEXT
  );""";

  Future<Database> initMyDatabase() async{
    //final getMyDirectory = await getApplicationDocumentsDirectory();
    //String path = getMyDirectory.path + "/users.db";
    String path = join(await getDatabasesPath(), "users.db");
    log(path);
    //onCreate: onc,
    return await openDatabase(
        path,
        version: 1,
        onCreate: (Database myDb, int version) async{
          await myDb.execute(usersTable);
    });
  }

  /*void onc(Database myDatabase, int v) async{
    await myDatabase.execute(
      'CREATE TABLE Users(id INTEGER PRIMARY KEY, username TEXT, emailAddress TEXT, password TEXT)'
    );
    log("The table has been created.");
  }*/

  Future<List<User>> getUsers() async{
    final myDb = await dbs.database;
    var myData = await myDb.rawQuery(
        'SELECT * From User'
    );
    List<User> users = List.generate(myData.length, (index) => User.fromJson(myData[index]));
    print("The length of users: ${users.length}");
    return users;
  }

  Future<void> addUser(User user) async{
    final myDb = await dbs.database;
    var myData = await myDb.rawInsert(
      'INSERT INTO User(id, username, emailAddress, password) VALUES(?, ?, ?, ?)',
      [user.id, user.username, user.emailAddress, user.password]
    );
    log("This data has been inserted: $myData");
  }

  Future<void> updateUser(User user) async{
    final myDb = await dbs.database;
    var myData = await myDb.rawUpdate(
      'UPDATE User SET username = ?, emailAddress = ?, password = ? WHERE id = ?',
      [user.username, user.emailAddress, user.password, user.id]
    );
    log("This data has been updated: $myData");
  }

  Future<void> deleteUser(int id) async{
    final myDb = await dbs.database;
    var myData = await myDb.rawDelete(
      'DELETE from User WHERE id = ?', [id]
    );
    log("This data has been deleted: $myData");
  }
}

/*
class databaseService{
  Database? myDatabase;

  Future<void> create(Database db, int version) async =>
    await todoDb().createMyTable(db);

  Future<Database> initializeDb() async{
    final path = await fullPath;
    var myDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: create,
      singleInstance: true,
    );
    return myDatabase;
  }

  Future<Database> get database async{
    if(myDatabase != null){
      return myDatabase!;
    }
    myDatabase = await initializeDb();
    return myDatabase!;
  }

  Future<String> get fullPath async{
    final name = "users.db";
    final path = await getDatabasesPath();
    return join(path, name);
  }
*/