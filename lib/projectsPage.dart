import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'createThread.dart';
import 'main.dart' as myMain;

bool projectsBool = false;
List<List> projectsThreads = [];
Iterable<List> reversedProjectsThreadsIterable = projectsThreads.reversed;
String threadAuthorProjects = "";
String threadTitleProjects = "";
String threadContentProjects = "";

class projectsPage extends StatefulWidget{
  const projectsPage ({Key? key}) : super(key: key);

  @override
  projectsPageState createState() => projectsPageState();
}

class MyProjectsPage extends StatelessWidget{
  const MyProjectsPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext buildContext){
    return MaterialApp(
      title: 'Projects Page',
      routes:{
        routesToCreateThreadProjectsPage.createThreadPage: (context) => createThread(),
      }
    );
  }
}

class routesToCreateThreadProjectsPage{
  static String createThreadPage = createThreadState.threadCreator;
}

class projectsPageState extends State<projectsPage>{
  static String projectsSubforumRoute = '/projectsPage';

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Text("Projects Subforum", style: TextStyle(fontWeight: FontWeight.bold)),
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
              projectsBool = true;
              Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
            }
          ),
          Expanded(
            child: ListView.builder(
              itemCount: reversedProjectsThreadsIterable.toList().length,
              itemBuilder: (context, index){
                return Column(
                  children: <Widget>[
                    Container(
                      height: 10,
                    ),
                    GestureDetector(
                      child: Container(
                        child: Text(reversedProjectsThreadsIterable.toList()[index][1] + "\n" + "By: " + reversedProjectsThreadsIterable.toList()[index][0]),
                        height: 30,
                        width: 360,
                        color: Colors.tealAccent,
                      ),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => projectsThreadContent()));
                        threadAuthorProjects = reversedProjectsThreadsIterable.toList()[index][0];
                        threadTitleProjects = reversedProjectsThreadsIterable.toList()[index][1];
                        threadContentProjects = reversedProjectsThreadsIterable.toList()[index][2];
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

class projectsThreadContent extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Wrap(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              child: Text("Thread title: " + threadTitleProjects + "\n" + "Posted by: " + threadAuthorProjects + "\n" + threadContentProjects),
              color: Colors.tealAccent,
              alignment: Alignment.topLeft,
            ),
          ),
        ],
      ),
    );
  }
}