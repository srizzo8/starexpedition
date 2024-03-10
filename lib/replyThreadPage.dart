import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'createThread.dart';
import 'discussionBoardUpdatesPage.dart' as discussionBoardUpdatesPage;
import 'questionsAndAnswersPage.dart' as questionsAndAnswersPage;
import 'technologiesPage.dart' as technologiesPage;
import 'projectsPage.dart' as projectsPage;
import 'newDiscoveriesPage.dart' as newDiscoveriesPage;
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
  List<String> pendingTechnologiesReply = [];
  List<String> pendingProjectsReply = [];
  List<String> pendingNewDiscoveriesReply = [];
  int threadNumber = 0;

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => showDialog(
            context: context,
            builder: (BuildContext myReplyContext){
              return AlertDialog(
                title: const Text("Are you sure?"),
                content: const Text("Your reply will not be saved."),
                actions: [
                  TextButton(
                    onPressed: () => {
                      Navigator.pop(context),
                      Navigator.pop(context),
                    },
                    child: const Text("Yes"),
                  ),
                  TextButton(
                    onPressed: () => {
                      Navigator.pop(context),
                    },
                    child: const Text("No"),
                  ),
                ],
              );
            }
          ),
        ),
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
                  else if(technologiesPage.technologiesReplyBool == true){
                    threadNumber = int.parse(technologiesPage.threadID);
                    assert(threadNumber is int);
                    print(threadNumber.runtimeType);
                    pendingTechnologiesReply.add(DateTime.now().toString());
                    pendingTechnologiesReply.add(usernameReplyController.text);
                    pendingTechnologiesReply.add(replyContentController.text);
                    if(technologiesPage.technologiesReplyingToReplyBool == true){
                      technologiesPage.technologiesReplyingToReplyBool = false;
                      pendingTechnologiesReply.add(technologiesPage.technologiesThreads[int.parse(technologiesPage.threadID)][4][technologiesPage.myIndex][1].toString());
                      pendingTechnologiesReply.add(technologiesPage.technologiesThreads[int.parse(technologiesPage.threadID)][4][technologiesPage.myIndex][2].toString());
                      print('Do we exist? ' + technologiesPage.technologiesThreads[int.parse(technologiesPage.threadID)][4][technologiesPage.myIndex][3].toString() + technologiesPage.technologiesThreads[int.parse(technologiesPage.threadID)][4][technologiesPage.myIndex][4].toString());
                    }
                    else{
                      pendingTechnologiesReply.add("");
                      pendingTechnologiesReply.add("");
                      print("I do not exist");
                    }
                    technologiesPage.technologiesThreads.toList()[threadNumber][4].add(pendingTechnologiesReply);
                    print(technologiesPage.reversedTechnologiesThreadsIterable);
                    print(technologiesPage.technologiesReplies);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const technologiesPage.technologiesPage()));
                    technologiesPage.technologiesReplyBool = false;
                  }
                  else if(projectsPage.projectsReplyBool == true){
                    threadNumber = int.parse(projectsPage.threadID);
                    assert(threadNumber is int);
                    print(threadNumber.runtimeType);
                    pendingProjectsReply.add(DateTime.now().toString());
                    pendingProjectsReply.add(usernameReplyController.text);
                    pendingProjectsReply.add(replyContentController.text);
                    if(projectsPage.projectsReplyingToReplyBool == true){
                      projectsPage.projectsReplyingToReplyBool = false;
                      pendingProjectsReply.add(projectsPage.projectsThreads[int.parse(projectsPage.threadID)][4][projectsPage.myIndex][1].toString());
                      pendingProjectsReply.add(projectsPage.projectsThreads[int.parse(projectsPage.threadID)][4][projectsPage.myIndex][2].toString());
                      print('Do we exist? ' + projectsPage.projectsThreads[int.parse(projectsPage.threadID)][4][projectsPage.myIndex][3].toString() + projectsPage.projectsThreads[int.parse(projectsPage.threadID)][4][projectsPage.myIndex][4].toString());
                    }
                    else{
                      pendingProjectsReply.add("");
                      pendingProjectsReply.add("");
                      print("I do not exist");
                    }
                    projectsPage.projectsThreads.toList()[threadNumber][4].add(pendingProjectsReply);
                    print(projectsPage.reversedProjectsThreadsIterable);
                    print(projectsPage.projectsReplies);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const projectsPage.projectsPage()));
                    projectsPage.projectsReplyBool = false;
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