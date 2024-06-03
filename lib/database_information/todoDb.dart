import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:starexpedition4/database_information/usersDatabaseInfo.dart';
import 'databaseService.dart';
/*
class todoDb{
  final tableName = "users";

  Future<void> createMyTable(Database db) async{
    await db.execute("""CREATE TABLE IF NOT EXISTS $tableName (
      "id"  INTEGER NOT NULL,
      "username"  STRING NOT NULL,
      "emailAddress"  STRING NOT NULL,
      "password"  STRING NOT NULL,
      PRIMARY KEY("id") 
    );""");
  }

  Future<int> create({required String username}) async{
    final myDb = await databaseService().database;
    return await myDb.rawInsert(
      '''INSERT INTO $tableName (username) VALUES (?)''',
      [username],
    );
  }

  Future<List<User>> fetchAll() async{
    final myDb = await databaseService().database;
    final users = await myDb.rawQuery(
      '''SELECT * from $tableName ORDER BY COALESCE(id, username, emailAddress, password)'''
    );
    return users.map((user) => User.fromSqfliteDatabase(user)).toList();
  }

  Future<User> fetchById(int id) async{
    final myDb = await databaseService().database;
    final user = await myDb.rawQuery('''SELECT * from $tableName WHERE id = ?''' [id]);
    return User.fromSqfliteDatabase(user.first);
  }

  Future<int> update({required int id, String? username}) async{
    final myDb = await databaseService().database;
    return await myDb.update(
      tableName,
      {
        if(username != null) 'username': username,
      },
      where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async{
    final myDb = await databaseService().database;
    await myDb.rawDelete('''DELETE FROM $tableName WHERE id = ?'''[id]);
  }
*/