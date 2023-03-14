import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'discussionBoardUpdatesPage.dart' as discussionBoardUpdatesPage;
import 'questionsAndAnswersPage.dart' as questionsAndAnswersPage;
import 'technologiesPage.dart' as technologiesPage;
import 'projectsPage.dart' as projectsPage;
import 'newDiscoveriesPage.dart' as newDiscoveriesPage;

import 'main.dart' as myMain;

class registerPage extends StatefulWidget{
  const registerPage ({Key? key}) : super(key: key);

  @override
  registerPageState createState() => registerPageState();
}

class MyRegisterPage extends StatelessWidget{
  const MyRegisterPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext buildC){
    return MaterialApp(
      title: "Registration Page",
    );
  }
}

class registerPageRoutes{
  static String homePage = myMain.theStarExpeditionState.nameOfRoute;
}

class registerPageState extends State<registerPage>{
  static String nameOfRoute = '/registerPage';
  TextEditingController theUsername = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Widget build(BuildContext buildContext){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Wrap(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Text("Username", style: TextStyle(fontSize: 14.0)),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(0.0),
              alignment: Alignment.centerLeft,
              child: Text("Username", style: TextStyle(fontSize: 14.0)),
              height: 20,
              width: 380,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: theUsername,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(0.0),
              alignment: Alignment.centerLeft,
              child: Text("E-mail address", style: TextStyle(fontSize: 14.0)),
              height: 20,
              width: 380,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: email,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(0.0),
              alignment: Alignment.centerLeft,
              child: Text("Password", style: TextStyle(fontSize: 14.0)),
              height: 20,
              width: 380,
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            child: TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ]
      ),
    );
  }
}