import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'createThread.dart';
import 'replyThreadPage.dart';
import 'main.dart' as myMain;

bool projectsBool = false;
bool projectsReplyBool = false;
bool projectsReplyingToReplyBool = false;
var projectsThreads = [];
var projectsReplies = [];
int myIndex = -1;
var reversedProjectsThreadsIterable = projectsThreads.reversed;
var reversedProjectsRepliesIterable = projectsReplies.reversed;
String threadAuthorProjects = "";
String threadTitleProjects = "";
String threadContentProjects = "";
String threadID = "";

class projectsPage extends StatefulWidget{
  const projectsPage ({Key? key}) : super(key: key);

  @override
  projectsPageState createState() => projectsPageState();
}

class MyProjectsPage extends StatelessWidget{
  const MyProjectsPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext bc){
    return MaterialApp(
        title: "Projects Page",
        routes: {
          routeToCreateThreadProjectsPage.createThreadPage: (context) => createThread(),
          routeToReplyToThreadProjectsPage.replyThreadPage: (context) => replyThreadPage(),
        }
    );
  }
}

class routeToCreateThreadProjectsPage{
  static String createThreadPage = createThreadState.threadCreator;
}

class routeToReplyToThreadProjectsPage{
  static String replyThreadPage = replyThreadPageState.replyThread;
}

class projectsPageState extends State<projectsPage>{
  static String projectsRoute = '/projectsPage';

  Widget build(BuildContext buildContext){
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
                print(projectsBool);
                projectsBool = true;
                print(projectsBool);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                print("I am going to write a new thread.");
              }
          ),
          Expanded(
            child: ListView.builder(
                itemCount: projectsThreads.reversed.toList().length,
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
                            print("I clicked on a thread");
                            print('You clicked on: ' + reversedProjectsThreadsIterable.toList()[index][1]);
                            threadAuthorProjects = reversedProjectsThreadsIterable.toList()[index][0];
                            threadTitleProjects = reversedProjectsThreadsIterable.toList()[index][1];
                            threadContentProjects = reversedProjectsThreadsIterable.toList()[index][2];
                            threadID = reversedProjectsThreadsIterable.toList()[index][3];
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => projectsThreadContent()));
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
          GestureDetector(
              child: Container(
                alignment: Alignment.topCenter,
                child: Text("Reply to thread", style: TextStyle(fontWeight: FontWeight.bold)),
                color: Colors.deepPurpleAccent,
                height: 20,
              ),
              onTap: (){
                projectsReplyingToReplyBool = false;
                projectsReplyBool = true;
                print(reversedProjectsThreadsIterable.toList());
                print(threadID);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                print('Replying to the thread');
              }
          ),
          Column(
            children: <Widget>[
              ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: projectsThreads[int.parse(threadID)][4].length,
                  itemBuilder: (context, index){
                    return Column(
                      children: <Widget>[
                        projectsThreads[int.parse(threadID)][4][index][3] != "" && projectsThreads[int.parse(threadID)][4][index][4] != ""?
                        Column(
                            children: <Widget>[
                              Container(
                                height: 5,
                              ),
                              Container(
                                child: Text("Reply to: \n" + "Posted by: " + projectsThreads[int.parse(threadID)][4][index][3].toString() + "\n" + projectsThreads[int.parse(threadID)][4][index][4].toString()),
                                color: Colors.teal,
                                width: 360,
                              ),
                              Container(
                                child: Text("Posted on: " + projectsThreads[int.parse(threadID)][4][index][0].toString() + "\n" + "Posted by: " + projectsThreads[int.parse(threadID)][4][index][1].toString() + "\n" + projectsThreads[int.parse(threadID)][4][index][2].toString()),
                                color: Colors.tealAccent,
                                width: 360,
                              ),
                              GestureDetector(
                                  child: Container(
                                    child: Text("Reply"),
                                    color: Colors.purple.shade200,
                                    width: 360,
                                  ),
                                  onTap: (){
                                    myIndex = index;
                                    projectsReplyBool = true;
                                    projectsReplyingToReplyBool = true;
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                    print('Reply no. ' + index.toString());
                                    print('Replying to this reply: ' + projectsThreads[int.parse(threadID)][4][myIndex][2].toString());
                                  }
                              ),
                            ]
                        ): Column(
                            children: <Widget>[
                              Container(
                                height: 5,
                              ),
                              Container(
                                child: Text("Posted on: " + projectsThreads[int.parse(threadID)][4][index][0].toString() + "\n" + "Posted by: " + projectsThreads[int.parse(threadID)][4][index][1].toString() + "\n" + projectsThreads[int.parse(threadID)][4][index][2].toString()),
                                color: Colors.tealAccent,
                                width: 360,
                              ),
                              GestureDetector(
                                  child: Container(
                                    child: Text("Reply"),
                                    color: Colors.purple.shade200,
                                    width: 360,
                                  ),
                                  onTap: (){
                                    myIndex = index;
                                    projectsReplyBool = true;
                                    projectsReplyingToReplyBool = true;
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                    print('Reply no. ' + index.toString());
                                    print('Replying to this reply: ' + projectsThreads[int.parse(threadID)][4][myIndex][2].toString());
                                  }
                              ),
                            ]
                        ),
                      ],
                    );
                  }
              ),
            ],
          ),
        ],
      ),
    );
  }
}