import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'createThread.dart';
import 'replyThreadPage.dart';
import 'main.dart' as myMain;

bool technologiesBool = false;
bool technologiesReplyBool = false;
bool technologiesReplyingToReplyBool = false;
var technologiesThreads = [];
var technologiesReplies = [];
int myIndex = -1;
var reversedTechnologiesThreadsIterable = technologiesThreads.reversed;
var reversedTechnologiesRepliesIterable = technologiesReplies.reversed;
String threadAuthorTechnologies = "";
String threadTitleTechnologies = "";
String threadContentTechnologies = "";
String threadID = "";

class technologiesPage extends StatefulWidget{
  const technologiesPage ({Key? key}) : super(key: key);

  @override
  technologiesPageState createState() => technologiesPageState();
}

class MyTechnologiesPage extends StatelessWidget{
  const MyTechnologiesPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext bc){
    return MaterialApp(
        title: "Technologies Page",
        routes: {
          routeToCreateThreadTechnologiesPage.createThreadPage: (context) => createThread(),
          routeToReplyToThreadTechnologiesPage.replyThreadPage: (context) => replyThreadPage(),
        }
    );
  }
}

class routeToCreateThreadTechnologiesPage{
  static String createThreadPage = createThreadState.threadCreator;
}

class routeToReplyToThreadTechnologiesPage{
  static String replyThreadPage = replyThreadPageState.replyThread;
}

class technologiesPageState extends State<technologiesPage>{
  static String technologiesRoute = '/technologiesPage';

  Widget build(BuildContext buildContext){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            Navigator.pushNamed(context, '/discussionBoardPage'),
          }
        ),
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
                print(technologiesBool);
                technologiesBool = true;
                print(technologiesBool);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                print("I am going to write a new thread.");
              }
          ),
          Expanded(
            child: ListView.builder(
                itemCount: technologiesThreads.reversed.toList().length,
                itemBuilder: (context, index){
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
                            print("I clicked on a thread");
                            print('You clicked on: ' + reversedTechnologiesThreadsIterable.toList()[index][1]);
                            threadAuthorTechnologies = reversedTechnologiesThreadsIterable.toList()[index][0];
                            threadTitleTechnologies = reversedTechnologiesThreadsIterable.toList()[index][1];
                            threadContentTechnologies = reversedTechnologiesThreadsIterable.toList()[index][2];
                            threadID = reversedTechnologiesThreadsIterable.toList()[index][3];
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => technologiesThreadContent()));
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
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            Navigator.pushNamed(context, '/discussionBoardPage'),
          }
        ),
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
          ),
          GestureDetector(
              child: Container(
                alignment: Alignment.topCenter,
                child: Text("Reply to thread", style: TextStyle(fontWeight: FontWeight.bold)),
                color: Colors.deepPurpleAccent,
                height: 20,
              ),
              onTap: (){
                technologiesReplyingToReplyBool = false;
                technologiesReplyBool = true;
                print(reversedTechnologiesThreadsIterable.toList());
                print(threadID);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                //Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                print('Replying to the thread');
              }
          ),
          Column(
            children: <Widget>[
              ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: technologiesThreads[int.parse(threadID)][4].length,
                  itemBuilder: (context, index){
                    return Column(
                      children: <Widget>[
                        technologiesThreads[int.parse(threadID)][4][index][3] != "" && technologiesThreads[int.parse(threadID)][4][index][4] != ""?
                        Column(
                            children: <Widget>[
                              Container(
                                height: 5,
                              ),
                              Container(
                                child: Text("Reply to: \n" + "Posted by: " + technologiesThreads[int.parse(threadID)][4][index][3].toString() + "\n" + technologiesThreads[int.parse(threadID)][4][index][4].toString()),
                                color: Colors.teal,
                                width: 360,
                              ),
                              Container(
                                child: Text("Posted on: " + technologiesThreads[int.parse(threadID)][4][index][0].toString() + "\n" + "Posted by: " + technologiesThreads[int.parse(threadID)][4][index][1].toString() + "\n" + technologiesThreads[int.parse(threadID)][4][index][2].toString()),
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
                                    technologiesReplyBool = true;
                                    technologiesReplyingToReplyBool = true;
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                    print('Reply no. ' + index.toString());
                                    print('Replying to this reply: ' + technologiesThreads[int.parse(threadID)][4][myIndex][2].toString());
                                  }
                              ),
                            ]
                        ): Column(
                            children: <Widget>[
                              Container(
                                height: 5,
                              ),
                              Container(
                                child: Text("Posted on: " + technologiesThreads[int.parse(threadID)][4][index][0].toString() + "\n" + "Posted by: " + technologiesThreads[int.parse(threadID)][4][index][1].toString() + "\n" + technologiesThreads[int.parse(threadID)][4][index][2].toString()),
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
                                    technologiesReplyBool = true;
                                    technologiesReplyingToReplyBool = true;
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                    print('Reply no. ' + index.toString());
                                    print('Replying to this reply: ' + technologiesThreads[int.parse(threadID)][4][myIndex][2].toString());
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