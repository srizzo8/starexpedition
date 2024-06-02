import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class User{
  int id;
  String? username;
  String? emailAddress;
  String? password;

  User({
    required this.id,
    required this.username,
    required this.emailAddress,
    required this.password,
  });

  factory User.fromSqfliteDatabase(Map<String, dynamic> map) => User(
    id: map['id']?.toInt() ?? 0,
    username: map['username'] ?? "",
    emailAddress: map['emailAddress'] ?? "",
    password: map['password'] ?? ""
  );

  /*Map<String, Object?> toMap(){
    return{
      'username': username,
      'emailAddress': emailAddress,
      'password': password,
    };
  }
  @override
  String toString(){
    return "User{user: $username, emailAddress: $emailAddress, password: $password}";
  }*/
}

/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = openDatabase(
    join(await getDatabasesPath(), 'users_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE users(username TEXT PRIMARY KEY, email_address TEXT, password TEXT)',
      );
    },
    version: 1,
  );
}

  var john = User(
      username: "John",
      emailAddress: "john@starexpeditiontest.com",
      password: "testing123"
  );

class User{
  String? username = "";
  String? emailAddress = "";
  String? password = "";

  User({
    required this.username,
    required this.emailAddress,
    required this.password,
  });

  Map<String, Object?> toMap(){
    return{
      'username': username,
      'emailAddress': emailAddress,
      'password': password,
    };
  }
  @override
  String toString(){
    return "User{user: $username, emailAddress: $emailAddress, password: $password}";
  }
}

Future<void> addNewUser(User user) async{
  var myDatabase;

  await myDatabase.insert(
    'users',
    user.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<User>> retrieveUsers() async{
  var myDatabase;

  final List<Map<String, Object?>> userMaps = await myDatabase.query('users');

  return [
    for(final{
      'username': username as String,
      'emailAddress': emailAddress as String,
      'password': password as String,
      } in userMaps)
      User(username: username, emailAddress: emailAddress, password: password),
  ];
}

Future<void> updateUser(User user) async{
  var myDatabase;

  await myDatabase.update(
    'users',
    user.toMap(),
    where: 'username = ?',
    whereArgs: [user.username],
  );
}

Future<void> deleteUser(User user) async{
  var myDatabase;

  await myDatabase.delete(
    'users',
    where: 'username = ?',
    whereArgs: [user.username],
  );
}
*/