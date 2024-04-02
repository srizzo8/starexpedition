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
bool discussionBoardUpdatesReplyBool = false;
bool discussionBoardUpdatesReplyingToReplyBool = false;
var discussionBoardUpdatesThreads = [];
var discussionBoardUpdatesReplies = [];
int myIndex = -1;
//List<List> reversedDiscussionBoardUpdatesThreadsList = discussionBoardUpdatesThreads.reversed.toList();
var reversedDiscussionBoardUpdatesThreadsIterable = discussionBoardUpdatesThreads.reversed;
var reversedDiscussionBoardUpdatesRepliesIterable = discussionBoardUpdatesReplies.reversed;
String threadAuthorDbu = "";
String threadTitleDbu = "";
String threadContentDbu = "";
//int threadsIndex = reversedDiscussionBoardUpdatesThreadsIterable.
String threadID = "";

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            if(beingOnCreateThread == true){
              print(ModalRoute.of(context)!.settings.name!),
              print("You are on create thread."),
            }
            else{
              Navigator.pop(context),
              print(ModalRoute.of(context)!.settings.name!),
              print("You are not on create thread"),
            }
          }
        ),
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
              itemCount: discussionBoardUpdatesThreads.reversed.toList().length,
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
                      threadAuthorDbu = reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][0];
                      threadTitleDbu = reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][1];
                      threadContentDbu = reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][2];
                      threadID = reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][3];
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => discussionBoardUpdatesThreadContent()));
                      //myIndexPlace = index;
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => {
            //if previous page was createThread or replyThread:
            if(beingOnCreateThread == true){
              print("You are on create thread."),
            }
            else{
              Navigator.pop(context),
              print("You are not on create thread."),
            }
            //Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardUpdatesPage()))
          }
        ),
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
                alignment: Alignment.topCenter,
                child: Text("Reply to thread", style: TextStyle(fontWeight: FontWeight.bold)),
                color: Colors.deepPurpleAccent,
                height: 20,
              ),
              onTap: (){
                discussionBoardUpdatesReplyingToReplyBool = false;
                discussionBoardUpdatesReplyBool = true;
                print(reversedDiscussionBoardUpdatesThreadsIterable.toList());
                //myIndexPlace = discussionBoardUpdatesPageState.index;
                //myIndexPlace = reversedDiscussionBoardUpdatesThreadsIterable.toList().indexWhere((reversedDiscussionBoardUpdatesThreadsIterable) => reversedDiscussionBoardUpdatesThreadsIterable.contains("[" + threadAuthorDbu + ", " + threadTitleDbu + ", " + threadContentDbu + "]"));
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
                    itemCount: discussionBoardUpdatesThreads[int.parse(threadID)][4].length,
                    itemBuilder: (context, index){
                      return Column(
                        children: <Widget>[
                          discussionBoardUpdatesThreads[int.parse(threadID)][4][index][3] != "" && discussionBoardUpdatesThreads[int.parse(threadID)][4][index][4] != ""?
                          Column(
                          children: <Widget>[
                            Container(
                              height: 5,
                            ),
                            Container(
                              child: Text("Reply to: \n" + "Posted by: " + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][3].toString() + "\n" + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][4].toString()),
                              color: Colors.teal,
                              width: 360,
                            ),
                            //if(discussionBoardUpdatesThreads[int.parse(threadID)][4] != null)
                            Container(
                              //child: Text("Posted on: " + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][2] + "\n" + "Posted by: " + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][0] + "\n" + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][1]),
                              child: Text("Posted on: " + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][0].toString() + "\n" + "Posted by: " + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][1].toString() + "\n" + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][2].toString()),
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
                                discussionBoardUpdatesReplyBool = true;
                                discussionBoardUpdatesReplyingToReplyBool = true;
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                print('Reply no. ' + index.toString());
                                print('Replying to this reply: ' + discussionBoardUpdatesThreads[int.parse(threadID)][4][myIndex][2].toString());
                              }
                            ),
                          ]
                          ): Column(
                              children: <Widget>[
                                Container(
                                  height: 5,
                                ),
                                //if(discussionBoardUpdatesThreads[int.parse(threadID)][4] != null)
                                Container(
                                  //child: Text("Posted on: " + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][2] + "\n" + "Posted by: " + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][0] + "\n" + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][1]),
                                  child: Text("Posted on: " + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][0].toString() + "\n" + "Posted by: " + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][1].toString() + "\n" + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][2].toString()),
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
                                      discussionBoardUpdatesReplyBool = true;
                                      discussionBoardUpdatesReplyingToReplyBool = true;
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                      print('Reply no. ' + index.toString());
                                      print('Replying to this reply: ' + discussionBoardUpdatesThreads[int.parse(threadID)][4][myIndex][2].toString());
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
      ),
    );
  }
}