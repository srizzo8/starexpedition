import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'discussionBoardUpdatesPage.dart' as discussionBoardUpdatesPage;

import 'main.dart' as myMain;

class createThread extends StatefulWidget{
  const createThread ({Key? key}) : super(key: key);

  @override
  createThreadState createState() => createThreadState();
}

class createThreadState extends State<createThread>{
  static String threadCreator = '/createThread';
  final usernameController = TextEditingController();
  final threadNameController = TextEditingController();
  final threadContentController = TextEditingController();

  Widget build(BuildContext createThreadBuildContext){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                  labelText: "Username",
                ),
                maxLines: 1,
                maxLength: 30,
                controller: usernameController,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Thread Name",
                ),
                maxLines: 2,
                maxLength: 250,
                controller: threadNameController,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Thread Content",
                  contentPadding: EdgeInsets.symmetric(vertical: 80),
                ),
                controller: threadContentController,
              ),
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
                //print('Posting the thread');
                print(discussionBoardUpdatesPage.discussionBoardUpdatesBool);
                if(usernameController.text != "" && threadNameController.text != "" && threadContentController.text != "" && discussionBoardUpdatesPage.discussionBoardUpdatesBool == true){
                  //print(usernameController.text);
                  print('You are ready to post this thread');
                  discussionBoardUpdatesPage.discussionBoardUpdatesBool = false;
                }
              }
            ),
          ],
        ),
      ),
    );
  }
}