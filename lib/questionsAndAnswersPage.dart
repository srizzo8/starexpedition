import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'createThread.dart';
import 'main.dart' as myMain;

bool questionsAndAnswersBool = false;
List<List> questionsAndAnswersThreads = [];
Iterable<List> reversedQuestionsAndAnswersThreadsIterable = questionsAndAnswersThreads.reversed;
String threadAuthorQaa = "";
String threadTitleQaa = "";
String threadContentQaa = "";

class questionsAndAnswersPage extends StatefulWidget{
  const questionsAndAnswersPage ({Key? key}) : super(key: key);

  @override
  questionsAndAnswersPageState createState()=> questionsAndAnswersPageState();
}

class MyQuestionsAndAnswersPage extends StatelessWidget{
  const MyQuestionsAndAnswersPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext bc){
    return MaterialApp(
      title: "Questions and Answers Page",
      routes:{
        routeToCreateThreadQuestionsAndAnswersPage.createThreadPage: (context) => createThread(),
      }
    );
  }
}

class routeToCreateThreadQuestionsAndAnswersPage{
  static String createThreadPage = createThreadState.threadCreator;
}

class questionsAndAnswersPageState extends State<questionsAndAnswersPage>{
  static String nameOfRoute = '/questionsAndAnswersPage';

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Text("Questions and Answers Subforum", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          GestureDetector(
            child: Container(
              child: Text("Post new thread", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              color: Colors.black,
              height: 20,
              width: 120,
              margin: EdgeInsets.only(left: 250.0),
              alignment: Alignment.center,
            ),
            onTap: (){
              questionsAndAnswersBool = true;
              Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
            }
          ),
          Expanded(
            child: ListView.builder(
              itemCount: reversedQuestionsAndAnswersThreadsIterable.toList().length,
              itemBuilder: (content, index){
                return Column(
                  children: <Widget>[
                    Container(
                      height: 10,
                    ),
                    GestureDetector(
                      child: Container(
                        height: 30,
                        width: 360,
                        color: Colors.tealAccent,
                      ),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => questionsAndAnswersThreadContent()));
                        threadAuthorQaa = reversedQuestionsAndAnswersThreadsIterable.toList()[index][0];
                        threadTitleQaa = reversedQuestionsAndAnswersThreadsIterable.toList()[index][1];
                        threadContentQaa = reversedQuestionsAndAnswersThreadsIterable.toList()[index][2];
                      }
                    ),
                  ]
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
class questionsAndAnswersThreadContent extends StatelessWidget{
  @override
  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Wrap(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Container(
              child: Text("Thread title: " + threadTitleQaa + "\n" + "Posted by: " + threadAuthorQaa + "\n" + threadContentQaa),
              color: Colors.tealAccent,
              alignment: Alignment.topLeft,
            ),
          ),
        ],
      ),
    );
  }
}