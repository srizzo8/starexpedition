import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'discussionBoardUpdatesPage.dart';
import 'questionsAndAnswersPage.dart';
import 'technologiesPage.dart';
import 'projectsPage.dart';
import 'newDiscoveriesPage.dart';
import 'main.dart' as myMain;

var discussionBoardUpdatesThreadCount;
var discussionBoardUpdatesThreads;
var questionsAndAnswersThreadCount;
var questionsAndAnswersThreads;
var technologiesThreadCount;
var technologiesThreads;
var projectsThreadCount;
var projectsThreads;
var newDiscoveriesThreadCount;
var newDiscoveriesThreads;

class discussionBoardPage extends StatefulWidget{
  const discussionBoardPage ({Key? key}) : super(key: key);

  @override
  discussionBoardPageState createState() => discussionBoardPageState();
}

class MyDiscussionBoard extends StatelessWidget{
  const MyDiscussionBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext bc) {
    return MaterialApp(
        title: 'Discussion Board Main Page',
        routes: {
          discussionBoardRoutes.updatesSubforum: (context) => discussionBoardUpdatesPage(),
          discussionBoardRoutes.questionsAndAnswersSubforum: (context) => questionsAndAnswersPage(),
          discussionBoardRoutes.technologiesSubforum: (context) => technologiesPage(),
          discussionBoardRoutes.projectsSubforum: (context) => projectsPage(),
          discussionBoardRoutes.newDiscoveriesSubforum: (context) => newDiscoveriesPage(),
        }
    );
  }
}

class discussionBoardRoutes{
  static String updatesSubforum = discussionBoardUpdatesPageState.dBoardRoute;
  static String questionsAndAnswersSubforum = questionsAndAnswersPageState.questionsAndAnswersRoute;
  static String technologiesSubforum = technologiesPageState.technologiesRoute;
  static String projectsSubforum = projectsPageState.projectsRoute;
  static String newDiscoveriesSubforum = newDiscoveriesPageState.newDiscoveriesRoute;
}

class discussionBoardPageState extends State<discussionBoardPage>{
  static String nameOfRoute = '/discussionBoardPage';
  List<String> subforumList = ["Discussion Board Updates", "Questions and Answers", "Technologies", "Projects", "New Discoveries"];

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Text("Star Expedition Discussion Board",textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: subforumList.length,
              itemBuilder: (context, index){
              return Column(
                children: <Widget>[
                  Container(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () async{
                      //Getting the amount of threads that are in a subforum
                      discussionBoardUpdatesThreadCount = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").count().get();
                      QuerySnapshot dbuQuerySnapshot = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").get();
                      discussionBoardUpdatesThreads = dbuQuerySnapshot.docs.map((myDoc) => myDoc.data()).toList();
                      //print(discussionBoardUpdatesThreads.toString());
                      //Going to a certain subforum
                      print("Testing subforum button");
                      switch(subforumList[index]){
                        case "Discussion Board Updates":
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardUpdatesPage()));
                          break;
                        case "Questions and Answers":
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const questionsAndAnswersPage()));
                          print("Questions and Answers");
                          break;
                        case "Technologies":
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const technologiesPage()));
                          print("Technologies");
                          break;
                        case "Projects":
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const projectsPage()));
                          print("Projects");
                          break;
                        case "New Discoveries":
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const newDiscoveriesPage()));
                          print("New Discoveries");
                          break;
                      }
                    },
                    child: Container(
                      height: 80,
                      width: 240,
                      alignment: Alignment.center,
                      color: Colors.red,
                      child: Text(subforumList[index], textAlign: TextAlign.center),
                    ),
                  ),
                ],
              );
            },
          ),
          ),
        ],
      ),
      drawer: myMain.starExpeditionNavigationDrawer(),
    );
  }
}