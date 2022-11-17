import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'createThread.dart';
import 'replyThreadPage.dart';
import 'main.dart' as myMain;

bool discussionBoardUpdatesBool = false;
List<List> discussionBoardUpdatesThreads = [];
List<List> discussionBoardUpdatesReplies = [];
//List<List> reversedDiscussionBoardUpdatesThreadsList = discussionBoardUpdatesThreads.reversed.toList();
Iterable<List> reversedDiscussionBoardUpdatesThreadsIterable = discussionBoardUpdatesThreads.reversed;
Iterable<List> reversedDiscussionBoardUpdatesRepliesIterable = discussionBoardUpdatesReplies.reversed;
String threadAuthorDbu = "";
String threadTitleDbu = "";
String threadContentDbu = "";

class discussionBoardUpdatesPage extends StatefulWidget{
  const discussionBoardUpdatesPage ({Key? key}) : super(key: key);

  @override
  discussionBoardUpdatesPageState createState() => discussionBoardUpdatesPageState();
}

class MyDiscussionBoardUpdatesPage extends StatelessWidget{
  const MyDiscussionBoardUpdatesPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext updatesSubforumBuildContext){
    return MaterialApp(
      title: 'Discussion Board Updates Page',
      routes: {
        routeToCreateThread.createThreadPage: (context) => createThread(),
        routeToReplyToThreadDiscussionBoardUpdates.replyThreadPage: (context) => replyThreadPage(),
      }
    );
  }
}

class routeToCreateThread{
  static String createThreadPage = createThreadState.threadCreator;
}

class routeToReplyToThreadDiscussionBoardUpdates{
  static String replyThreadPage = replyThreadPageState.replyThread;
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
              print(discussionBoardUpdatesBool);
              discussionBoardUpdatesBool = true;
              print(discussionBoardUpdatesBool);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
              print("I am going to write a new thread.");
            }
          ),
          Expanded(
            child: ListView.builder(
              itemCount: reversedDiscussionBoardUpdatesThreadsIterable.toList().length,
              itemBuilder: (context, index){
              return Column(
                children: <Widget>[
                  Container(
                    height: 10,
                  ),
                  GestureDetector(
                    child: Container(
                      child: Text(reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][1] + "\n" + "By: " + reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][0]),
                      height: 30,
                      width: 360,
                      color: Colors.tealAccent,
                    ),
                    onTap: (){
                      print("I clicked on a thread");
                      print('You clicked on: ' + reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][1]);
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => discussionBoardUpdatesThreadContent()));
                      threadAuthorDbu = reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][0];
                      threadTitleDbu = reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][1];
                      threadContentDbu = reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][2];
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

class discussionBoardUpdatesThreadContent extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                child: Text("Thread title: " + threadTitleDbu + "\n" + "Posted by: " + threadAuthorDbu + "\n" + threadContentDbu),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                print('Replying to thread');
              }
            ),
            Expanded(
              child: ListView.builder(
                itemCount: reversedDiscussionBoardUpdatesRepliesIterable.toList().length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      Container(
                        height: 5,
                      ),
                      Container(
                        child: Text("Reply " + (index + 1).toString() + "\n" + "Posted by: " + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][0] + "\n" + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][1]),
                        color: Colors.tealAccent,
                        height: 30,
                        width: 360,
                      ),
                    ],
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}