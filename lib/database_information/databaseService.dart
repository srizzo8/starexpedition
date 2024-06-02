import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:starexpedition4/database_information/todoDb.dart';

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
}