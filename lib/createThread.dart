import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'discussionBoardUpdatesPage.dart' as discussionBoardUpdatesPage;
import 'questionsAndAnswersPage.dart' as questionsAndAnswersPage;

import 'main.dart' as myMain;

class createThread extends StatefulWidget{
  const createThread ({Key? key}) : super(key: key);

  @override
  createThreadState createState() => createThreadState();
}

class createThreadState extends State<createThread>{
  static String threadCreator = '/createThread';
  final usernameController = TextEditingController();
  final threadNameController = TextEditingController();
  final threadContentController = TextEditingController();
  List<String> discussionBoardUpdatesPendingThreads = [];
  List<String> questionsAndAnswersPendingThreads = [];

  Widget build(BuildContext createThreadBuildContext){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: Text("Making a thread", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0), textAlign: TextAlign.center),
              width: 480,
              alignment: Alignment.center,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Username",
                ),
                maxLines: 1,
                maxLength: 30,
                controller: usernameController,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Thread Name",
                ),
                maxLines: 2,
                maxLength: 250,
                controller: threadNameController,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Thread Content",
                  contentPadding: EdgeInsets.symmetric(vertical: 80),
                ),
                controller: threadContentController,
              ),
            ),
            GestureDetector(
              child: Container(
                child: Text("Post to Subforum", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                color: Colors.black,
                margin: EdgeInsets.only(left: 200.0),
                height: 30,
                width: 140,
                alignment: Alignment.center,
              ),
              onTap: (){
                //print('Posting the thread');
                print(discussionBoardUpdatesPage.discussionBoardUpdatesBool);
                if(usernameController.text != "" && threadNameController.text != "" && threadContentController.text != "" && discussionBoardUpdatesPage.discussionBoardUpdatesBool == true && questionsAndAnswersPage.questionsAndAnswersBool == false){
                  //print(usernameController.text);
                  if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == true && questionsAndAnswersPage.questionsAndAnswersBool == false) {
                    print('You are ready to post this thread');
                    discussionBoardUpdatesPendingThreads.add(usernameController.text);
                    discussionBoardUpdatesPendingThreads.add(threadNameController.text);
                    discussionBoardUpdatesPendingThreads.add(threadContentController.text);
                    print(discussionBoardUpdatesPendingThreads);
                    discussionBoardUpdatesPage.discussionBoardUpdatesThreads.add(discussionBoardUpdatesPendingThreads);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardUpdatesPage.discussionBoardUpdatesPage()));
                    discussionBoardUpdatesPage.discussionBoardUpdatesBool = false;
                    //print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesThreadsList);
                    print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesThreadsIterable.toList());
                  }
                  else{
                    if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == true){
                      questionsAndAnswersPendingThreads.add(usernameController.text);
                      questionsAndAnswersPendingThreads.add(threadNameController.text);
                      questionsAndAnswersPendingThreads.add(threadContentController.text);
                      questionsAndAnswersPage.questionsAndAnswersThreads.add(questionsAndAnswersPendingThreads);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const questionsAndAnswersPage.questionsAndAnswersPage()));
                      questionsAndAnswersPage.questionsAndAnswersBool = false;
                    }
                  }
                }
              }
            ),
          ],
        ),
      ),
    );
  }
}