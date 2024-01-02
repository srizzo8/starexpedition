import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'createThread.dart';
import 'discussionBoardUpdatesPage.dart' as discussionBoardUpdatesPage;
import 'newDiscoveriesPage.dart' as newDiscoveriesPage;
import 'questionsAndAnswersPage.dart' as questionsAndAnswersPage;
import 'main.dart' as myMain;
import 'package:starexpedition4/loginPage.dart' as theLoginPage;
import 'package:starexpedition4/registerPage.dart' as theRegisterPage;

class replyThreadPage extends StatefulWidget{
  const replyThreadPage ({Key? key}) : super(key: key);

  @override
  replyThreadPageState createState() => replyThreadPageState();
}

class replyThreadPageState extends State<replyThreadPage>{
  static String replyThread = '/replyThreadPage';
  final usernameReplyController = TextEditingController();
  final replyContentController = TextEditingController();
  List<String> pendingDiscussionBoardUpdatesReply = [];
  List<String> pendingQuestionsAndAnswersReply = [];
  List<String> pendingNewDiscoveriesReply = [];
  int threadNumber = 0;

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: Text("Replying to a thread", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0), textAlign: TextAlign.center),
              width: 480,
              alignment: Alignment.center,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: (theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == "")?
                TextField(
                  decoration: InputDecoration(
                    labelText: "Username",
                  ),
                  maxLines: 1,
                  maxLength: 30,
                  enabled: false,
                  controller: TextEditingController()..text = theLoginPage.myUsername,
                ): (theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != "")?
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Username",
                    ),
                    maxLines: 1,
                    maxLength: 30,
                    enabled: false,
                    controller: TextEditingController()..text = theRegisterPage.myNewUsername,
                  ): TextField(),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Reply content",
                  contentPadding: EdgeInsets.symmetric(vertical: 80),
                ),
                controller: replyContentController,
              ),
            ),
            GestureDetector(
              child: Container(
                child: Text("Reply to thread", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                color: Colors.black,
                margin: EdgeInsets.only(left: 200.0),
                height: 30,
                width: 140,
                alignment: Alignment.center,
              ),
              onTap: (){
                if(theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""){
                  usernameReplyController.text = theLoginPage.myUsername;
                }
                else if(theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != ""){
                  usernameReplyController.text = theRegisterPage.myNewUsername;
                }
                if(usernameReplyController.text != "" && replyContentController.text != ""){
                  if(discussionBoardUpdatesPage.discussionBoardUpdatesReplyBool == true){
                    threadNumber = int.parse(discussionBoardUpdatesPage.threadID);
                    assert(threadNumber is int);
                    print(threadNumber.runtimeType);
                    pendingDiscussionBoardUpdatesReply.add(DateTime.now().toString());
                    pendingDiscussionBoardUpdatesReply.add(usernameReplyController.text);
                    pendingDiscussionBoardUpdatesReply.add(replyContentController.text);
                    if(discussionBoardUpdatesPage.discussionBoardUpdatesReplyingToReplyBool == true){
                      discussionBoardUpdatesPage.discussionBoardUpdatesReplyingToReplyBool = false;
                      pendingDiscussionBoardUpdatesReply.add(discussionBoardUpdatesPage.discussionBoardUpdatesThreads[int.parse(discussionBoardUpdatesPage.threadID)][4][discussionBoardUpdatesPage.myIndex][1].toString());
                      pendingDiscussionBoardUpdatesReply.add(discussionBoardUpdatesPage.discussionBoardUpdatesThreads[int.parse(discussionBoardUpdatesPage.threadID)][4][discussionBoardUpdatesPage.myIndex][2].toString());
                      print('Do we exist? ' + discussionBoardUpdatesPage.discussionBoardUpdatesThreads[int.parse(discussionBoardUpdatesPage.threadID)][4][discussionBoardUpdatesPage.myIndex][3].toString() + discussionBoardUpdatesPage.discussionBoardUpdatesThreads[int.parse(discussionBoardUpdatesPage.threadID)][4][discussionBoardUpdatesPage.myIndex][4].toString());
                    }
                    else{
                      pendingDiscussionBoardUpdatesReply.add("");
                      pendingDiscussionBoardUpdatesReply.add("");
                      print("I do not exist");
                    }
                    discussionBoardUpdatesPage.discussionBoardUpdatesThreads.toList()[threadNumber][4].add(pendingDiscussionBoardUpdatesReply);
                    //= discussionBoardUpdatesPage.discussionBoardUpdatesReplies.toString();
                    //print(pendingDiscussionBoardUpdatesReply);
                    //discussionBoardUpdatesPage.discussionBoardUpdatesReplies.add(pendingDiscussionBoardUpdatesReply);
                    print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesThreadsIterable);
                    print(discussionBoardUpdatesPage.discussionBoardUpdatesReplies);
                    //print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesRepliesIterable.toList()[0][0]);
                    //print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesRepliesIterable.toList()[0][1]);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardUpdatesPage.discussionBoardUpdatesPage()));
                    discussionBoardUpdatesPage.discussionBoardUpdatesReplyBool = false;
                  }
                  else if(questionsAndAnswersPage.questionsAndAnswersReplyBool == true){
                    threadNumber = int.parse(questionsAndAnswersPage.threadID);
                    assert(threadNumber is int);
                    print(threadNumber.runtimeType);
                    pendingQuestionsAndAnswersReply.add(DateTime.now().toString());
                    pendingQuestionsAndAnswersReply.add(usernameReplyController.text);
                    pendingQuestionsAndAnswersReply.add(replyContentController.text);
                    if(questionsAndAnswersPage.questionsAndAnswersReplyingToReplyBool == true){
                      questionsAndAnswersPage.questionsAndAnswersReplyingToReplyBool = false;
                      pendingQuestionsAndAnswersReply.add(questionsAndAnswersPage.questionsAndAnswersThreads[int.parse(questionsAndAnswersPage.threadID)][4][questionsAndAnswersPage.myIndex][1].toString());
                      pendingQuestionsAndAnswersReply.add(questionsAndAnswersPage.questionsAndAnswersThreads[int.parse(questionsAndAnswersPage.threadID)][4][questionsAndAnswersPage.myIndex][2].toString());
                      print('Do we exist? ' + questionsAndAnswersPage.questionsAndAnswersThreads[int.parse(questionsAndAnswersPage.threadID)][4][questionsAndAnswersPage.myIndex][3].toString() + questionsAndAnswersPage.questionsAndAnswersThreads[int.parse(questionsAndAnswersPage.threadID)][4][questionsAndAnswersPage.myIndex][4].toString());
                    }
                    else{
                      pendingQuestionsAndAnswersReply.add("");
                      pendingQuestionsAndAnswersReply.add("");
                      print("I do not exist");
                    }
                    questionsAndAnswersPage.questionsAndAnswersThreads.toList()[threadNumber][4].add(pendingQuestionsAndAnswersReply);
                    print(questionsAndAnswersPage.reversedQuestionsAndAnswersThreadsIterable);
                    print(questionsAndAnswersPage.questionsAndAnswersReplies);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const questionsAndAnswersPage.questionsAndAnswersPage()));
                    questionsAndAnswersPage.questionsAndAnswersReplyBool = false;
                  }
                  else if(newDiscoveriesPage.newDiscoveriesReplyBool == true){
                    threadNumber = int.parse(newDiscoveriesPage.threadID);
                    assert(threadNumber is int);
                    print(threadNumber.runtimeType);
                    pendingNewDiscoveriesReply.add(DateTime.now().toString());
                    pendingNewDiscoveriesReply.add(usernameReplyController.text);
                    pendingNewDiscoveriesReply.add(replyContentController.text);
                    if(newDiscoveriesPage.newDiscoveriesReplyingToReplyBool == true){
                      newDiscoveriesPage.newDiscoveriesReplyingToReplyBool = false;
                      pendingNewDiscoveriesReply.add(newDiscoveriesPage.newDiscoveriesThreads[int.parse(newDiscoveriesPage.threadID)][4][newDiscoveriesPage.myIndex][1].toString());
                      pendingNewDiscoveriesReply.add(newDiscoveriesPage.newDiscoveriesThreads[int.parse(newDiscoveriesPage.threadID)][4][newDiscoveriesPage.myIndex][2].toString());
                      print('Do we exist? ' + newDiscoveriesPage.newDiscoveriesThreads[int.parse(newDiscoveriesPage.threadID)][4][newDiscoveriesPage.myIndex][3].toString() + newDiscoveriesPage.newDiscoveriesThreads[int.parse(newDiscoveriesPage.threadID)][4][newDiscoveriesPage.myIndex][4].toString());
                    }
                    else{
                      pendingNewDiscoveriesReply.add("");
                      pendingNewDiscoveriesReply.add("");
                      print("I do not exist");
                    }
                    newDiscoveriesPage.newDiscoveriesThreads.toList()[threadNumber][4].add(pendingNewDiscoveriesReply);
                    print(newDiscoveriesPage.reversedNewDiscoveriesThreadsIterable);
                    print(newDiscoveriesPage.newDiscoveriesReplies);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const newDiscoveriesPage.newDiscoveriesPage()));
                    newDiscoveriesPage.newDiscoveriesReplyBool = false;
                  }
                }
              }
            ),
          ],
        ),
      )
    );
  }
}