import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'main.dart' as myMain;

class discussionBoardUpdatesPage extends StatefulWidget{
  const discussionBoardUpdatesPage ({Key? key}) : super(key: key);

  @override
  discussionBoardUpdatesPageState createState() => discussionBoardUpdatesPageState();
}

class discussionBoardUpdatesPageState extends State<discussionBoardUpdatesPage>{
  static String dBoardRoute = '/discussionBoardUpdatesPage';

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Text("Discussion Board Updates Subforum", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            child: Text("Post new thread", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
            color: Colors.black,
            height: 20,
            width: 120,
            margin: EdgeInsets.only(left: 250.0),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index){
              return Column(
                children: <Widget>[
                  Container(
                    height: 10,
                  ),
                  Container(
                    child: Text("Updates subforum post"),
                    height: 30,
                    width: 360,
                    color: Colors.tealAccent,
                  ),
                ],
              );
            }
          ),
          ),
        ],
      ),
    );
  }
}

