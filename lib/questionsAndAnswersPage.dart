import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'createThread.dart';
import 'replyThreadPage.dart';
import 'main.dart' as myMain;

bool questionsAndAnswersBool = false;
bool questionsAndAnswersReplyBool = false;
bool questionsAndAnswersReplyingToReplyBool = false;
var questionsAndAnswersThreads = [];
var questionsAndAnswersReplies = [];
int myIndex = -1;
var reversedQuestionsAndAnswersThreadsIterable = questionsAndAnswersThreads.reversed;
var reversedQuestionsAndAnswersRepliesIterable = questionsAndAnswersReplies.reversed;
String threadAuthorQaa = "";
String threadTitleQaa = "";
String threadContentQaa = "";
String threadID = "";

class questionsAndAnswersPage extends StatefulWidget{
  const questionsAndAnswersPage ({Key? key}) : super(key: key);

  @override
  questionsAndAnswersPageState createState() => questionsAndAnswersPageState();
}

class MyQuestionsAndAnswersPage extends StatelessWidget{
  const MyQuestionsAndAnswersPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext bc){
    return MaterialApp(
        title: "Questions and Answers Page",
        routes: {
          routeToCreateThreadQuestionsAndAnswersPage.createThreadPage: (context) => createThread(),
          routeToReplyToThreadQuestionsAndAnswersPage.replyThreadPage: (context) => replyThreadPage(),
        }
    );
  }
}

class routeToCreateThreadQuestionsAndAnswersPage{
  static String createThreadPage = createThreadState.threadCreator;
}

class routeToReplyToThreadQuestionsAndAnswersPage{
  static String replyThreadPage = replyThreadPageState.replyThread;
}

class questionsAndAnswersPageState extends State<questionsAndAnswersPage>{
  static String questionsAndAnswersRoute = '/questionsAndAnswersPage';

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
                print(questionsAndAnswersBool);
                questionsAndAnswersBool = true;
                print(questionsAndAnswersBool);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                print("I am going to write a new thread.");
              }
          ),
          Expanded(
            child: ListView.builder(
                itemCount: questionsAndAnswersThreads.reversed.toList().length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      Container(
                        height: 10,
                      ),
                      GestureDetector(
                          child: Container(
                            child: Text(reversedQuestionsAndAnswersThreadsIterable.toList()[index][1] + "\n" + "By: " + reversedQuestionsAndAnswersThreadsIterable.toList()[index][0]),
                            height: 30,
                            width: 360,
                            color: Colors.tealAccent,
                          ),
                          onTap: (){
                            print("I clicked on a thread");
                            print('You clicked on: ' + reversedQuestionsAndAnswersThreadsIterable.toList()[index][1]);
                            threadAuthorQaa = reversedQuestionsAndAnswersThreadsIterable.toList()[index][0];
                            threadTitleQaa = reversedQuestionsAndAnswersThreadsIterable.toList()[index][1];
                            threadContentQaa = reversedQuestionsAndAnswersThreadsIterable.toList()[index][2];
                            threadID = reversedQuestionsAndAnswersThreadsIterable.toList()[index][3];
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => questionsAndAnswersThreadContent()));
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

class questionsAndAnswersThreadContent extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            Navigator.pop(context),
          }
        ),
      ),
      body: Wrap(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              child: Text("Thread title: " + threadTitleQaa + "\n" + "Posted by: " + threadAuthorQaa + "\n" + threadContentQaa),
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
                questionsAndAnswersReplyingToReplyBool = false;
                questionsAndAnswersReplyBool = true;
                print(reversedQuestionsAndAnswersThreadsIterable.toList());
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
                  itemCount: questionsAndAnswersThreads[int.parse(threadID)][4].length,
                  itemBuilder: (context, index){
                    return Column(
                      children: <Widget>[
                        questionsAndAnswersThreads[int.parse(threadID)][4][index][3] != "" && questionsAndAnswersThreads[int.parse(threadID)][4][index][4] != ""?
                        Column(
                            children: <Widget>[
                              Container(
                                height: 5,
                              ),
                              Container(
                                child: Text("Reply to: \n" + "Posted by: " + questionsAndAnswersThreads[int.parse(threadID)][4][index][3].toString() + "\n" + questionsAndAnswersThreads[int.parse(threadID)][4][index][4].toString()),
                                color: Colors.teal,
                                width: 360,
                              ),
                              Container(
                                child: Text("Posted on: " + questionsAndAnswersThreads[int.parse(threadID)][4][index][0].toString() + "\n" + "Posted by: " + questionsAndAnswersThreads[int.parse(threadID)][4][index][1].toString() + "\n" + questionsAndAnswersThreads[int.parse(threadID)][4][index][2].toString()),
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
                                    questionsAndAnswersReplyBool = true;
                                    questionsAndAnswersReplyingToReplyBool = true;
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                    print('Reply no. ' + index.toString());
                                    print('Replying to this reply: ' + questionsAndAnswersThreads[int.parse(threadID)][4][myIndex][2].toString());
                                  }
                              ),
                            ]
                        ): Column(
                            children: <Widget>[
                              Container(
                                height: 5,
                              ),
                              Container(
                                child: Text("Posted on: " + questionsAndAnswersThreads[int.parse(threadID)][4][index][0].toString() + "\n" + "Posted by: " + questionsAndAnswersThreads[int.parse(threadID)][4][index][1].toString() + "\n" + questionsAndAnswersThreads[int.parse(threadID)][4][index][2].toString()),
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
                                    questionsAndAnswersReplyBool = true;
                                    questionsAndAnswersReplyingToReplyBool = true;
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                    print('Reply no. ' + index.toString());
                                    print('Replying to this reply: ' + questionsAndAnswersThreads[int.parse(threadID)][4][myIndex][2].toString());
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