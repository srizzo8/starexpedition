import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'createThread.dart';
import 'replyThreadPage.dart';
import 'main.dart' as myMain;

bool newDiscoveriesBool = false;
bool newDiscoveriesReplyBool = false;
bool newDiscoveriesReplyingToReplyBool = false;
var newDiscoveriesThreads = [];
var newDiscoveriesReplies = [];
int myIndex = -1;
var reversedNewDiscoveriesThreadsIterable = newDiscoveriesThreads.reversed;
var reversedNewDiscoveriesRepliesIterable = newDiscoveriesReplies.reversed;
String threadAuthorNd = "";
String threadTitleNd = "";
String threadContentNd = "";
String threadID = "";

class newDiscoveriesPage extends StatefulWidget{
  const newDiscoveriesPage ({Key? key}) : super(key: key);

  @override
  newDiscoveriesPageState createState() => newDiscoveriesPageState();
}

class MyNewDiscoveriesPage extends StatelessWidget{
  const MyNewDiscoveriesPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext bc){
    return MaterialApp(
      title: "New Discoveries Page",
      routes: {
        routeToCreateThreadNewDiscoveriesPage.createThreadPage: (context) => createThread(),
        routeToReplyToThreadNewDiscoveriesPage.replyThreadPage: (context) => replyThreadPage(),
      }
    );
  }
}

class routeToCreateThreadNewDiscoveriesPage{
  static String createThreadPage = createThreadState.threadCreator;
}

class routeToReplyToThreadNewDiscoveriesPage{
  static String replyThreadPage = replyThreadPageState.replyThread;
}

class newDiscoveriesPageState extends State<newDiscoveriesPage>{
  static String newDiscoveriesRoute = '/newDiscoveriesPage';

  Widget build(BuildContext buildContext){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Text("New Discoveries Subforum", style: TextStyle(fontWeight: FontWeight.bold)),
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
              print(newDiscoveriesBool);
              newDiscoveriesBool = true;
              print(newDiscoveriesBool);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
              print("I am going to write a new thread.");
            }
          ),
          Expanded(
            child: ListView.builder(
                itemCount: newDiscoveriesThreads.reversed.toList().length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      Container(
                        height: 10,
                      ),
                      GestureDetector(
                          child: Container(
                            child: Text(reversedNewDiscoveriesThreadsIterable.toList()[index][1] + "\n" + "By: " + reversedNewDiscoveriesThreadsIterable.toList()[index][0]),
                            height: 30,
                            width: 360,
                            color: Colors.tealAccent,
                          ),
                          onTap: (){
                            print("I clicked on a thread");
                            print('You clicked on: ' + reversedNewDiscoveriesThreadsIterable.toList()[index][1]);
                            threadAuthorNd = reversedNewDiscoveriesThreadsIterable.toList()[index][0];
                            threadTitleNd = reversedNewDiscoveriesThreadsIterable.toList()[index][1];
                            threadContentNd = reversedNewDiscoveriesThreadsIterable.toList()[index][2];
                            threadID = reversedNewDiscoveriesThreadsIterable.toList()[index][3];
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => newDiscoveriesThreadContent()));
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

class newDiscoveriesThreadContent extends StatelessWidget{
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
              child: Text("Thread title: " + threadTitleNd + "\n" + "Posted by: " + threadAuthorNd + "\n" + threadContentNd),
              color: Colors.tealAccent,
              alignment: Alignment.topLeft,
            ),
          ),
          GestureDetector(
            child: Container(
              child: Text("Reply to thread", style: TextStyle(fontWeight: FontWeight.bold)),
              color: Colors.deepPurpleAccent,
              height: 20,
            ),
            onTap: (){
              newDiscoveriesReplyingToReplyBool = false;
              newDiscoveriesReplyBool = true;
              print(reversedNewDiscoveriesThreadsIterable.toList());
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
                itemCount: newDiscoveriesThreads[int.parse(threadID)][4].length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      newDiscoveriesThreads[int.parse(threadID)][4][index][3] != "" && newDiscoveriesThreads[int.parse(threadID)][4][index][4] != ""?
                        Column(
                          children: <Widget>[
                            Container(
                              height: 5,
                            ),
                            Container(
                              child: Text("Reply to: \n" + "Posted by: " + newDiscoveriesThreads[int.parse(threadID)][4][index][3].toString() + "\n" + newDiscoveriesThreads[int.parse(threadID)][4][index][4].toString()),
                              color: Colors.teal,
                              width: 360,
                            ),
                            Container(
                              child: Text("Posted on: " + newDiscoveriesThreads[int.parse(threadID)][4][index][0].toString() + "\n" + "Posted by: " + newDiscoveriesThreads[int.parse(threadID)][4][index][1].toString() + "\n" + newDiscoveriesThreads[int.parse(threadID)][4][index][2].toString()),
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
                                newDiscoveriesReplyBool = true;
                                newDiscoveriesReplyingToReplyBool = true;
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                print('Reply no. ' + index.toString());
                                print('Replying to this reply: ' + newDiscoveriesThreads[int.parse(threadID)][4][myIndex][2].toString());
                              }
                            ),
                          ]
                        ): Column(
                            children: <Widget>[
                              Container(
                                height: 5,
                              ),
                              Container(
                                child: Text("Posted on: " + newDiscoveriesThreads[int.parse(threadID)][4][index][0].toString() + "\n" + "Posted by: " + newDiscoveriesThreads[int.parse(threadID)][4][index][1].toString() + "\n" + newDiscoveriesThreads[int.parse(threadID)][4][index][2].toString()),
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
                                  newDiscoveriesReplyBool = true;
                                  newDiscoveriesReplyingToReplyBool = true;
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                  print('Reply no. ' + index.toString());
                                  print('Replying to this reply: ' + newDiscoveriesThreads[int.parse(threadID)][4][myIndex][2].toString());
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