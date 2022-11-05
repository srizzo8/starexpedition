import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'main.dart' as myMain;

class createThread extends StatefulWidget{
  const createThread ({Key? key}) : super(key: key);

  @override
  createThreadState createState() => createThreadState();
}

class createThreadState extends State<createThread>{
  static String threadCreator = '/createThread';

  Widget build(BuildContext createThreadBuildContext){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Text("Making a thread", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0), textAlign: TextAlign.center),
            width: 480,
            alignment: Alignment.center,
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Thread Name",
              ),
              maxLines: 2,
              maxLength: 250,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Thread Content",
                contentPadding: EdgeInsets.symmetric(vertical: 80),
              ),
            )
          ),
        ],
      ),
    );
  }
}