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
          GestureDetector(
            child: Container(
              child: Text("Post to Subforum", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              color: Colors.black,
              margin: EdgeInsets.only(left: 200.0),
              height: 30,
              width: 140,
              alignment: Alignment.center,
            ),
            onTap: (){
              print('Posting the thread');
            }
          ),
        ],
      ),
    );
  }
}