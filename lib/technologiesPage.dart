import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'createThread.dart';
import 'main.dart' as myMain;

bool technologiesBool = false;
List<List> technologiesThreads = [];
Iterable<List> reversedTechnologiesThreadsIterable = technologiesThreads.reversed;
String threadAuthorTechnologies = "";
String threadTitleTechnologies = "";
String threadContentTechnologies = "";

class technologiesPage extends StatefulWidget{
  const technologiesPage ({Key? key}) : super(key: key);

  @override
  technologiesPageState createState() => technologiesPageState();
}

class MyTechnologiesPage extends StatelessWidget{
  const MyTechnologiesPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext buildContext){
    return MaterialApp(
      title: "Technologies Page",
      routes: {
        routeToCreateThreadTechnologiesPage.createThreadPage: (context) => createThread(),
      }
    );
  }
}

class routeToCreateThreadTechnologiesPage{
  static String createThreadPage = createThreadState.threadCreator;
}

class technologiesPageState extends State<technologiesPage>{
  static String technologiesRoute = '/technologiesPage';
  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Text("Technologies Subforum", style: TextStyle(fontWeight: FontWeight.bold)),
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
              technologiesBool = true;
              Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
            }
          ),
          Expanded(
            child: ListView.builder(
              itemCount: reversedTechnologiesThreadsIterable.toList().length,
              itemBuilder: (content, index){
                return Column(
                  children: <Widget>[
                    Container(
                      height: 10,
                    ),
                    GestureDetector(
                      child: Container(
                        child: Text(reversedTechnologiesThreadsIterable.toList()[index][1] + "\n" + "By: " + reversedTechnologiesThreadsIterable.toList()[index][0]),
                        height: 30,
                        width: 360,
                        color: Colors.tealAccent,
                      ),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => technologiesThreadContent()));
                        threadAuthorTechnologies = reversedTechnologiesThreadsIterable.toList()[index][0];
                        threadTitleTechnologies = reversedTechnologiesThreadsIterable.toList()[index][1];
                        threadContentTechnologies = reversedTechnologiesThreadsIterable.toList()[index][2];
                      }
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

class technologiesThreadContent extends StatelessWidget{
  @override
  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Wrap(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              child: Text("Thread title: " + threadTitleTechnologies + "\n" + "Posted by: " + threadAuthorTechnologies + "\n" + threadContentTechnologies),
              color: Colors.tealAccent,
              alignment: Alignment.topLeft,
            ),
          )
        ],
      ),
    );
  }

}