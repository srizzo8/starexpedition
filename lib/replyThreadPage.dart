import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:starexpedition4/questions_and_answers_firestore_database_information/questionsAndAnswersRepliesDatabaseFirestoreInfo.dart';
import 'package:starexpedition4/questions_and_answers_firestore_database_information/questionsAndAnswersRepliesInformation.dart';
import 'package:starexpedition4/questions_and_answers_firestore_database_information/questionsAndAnswersRepliesToRepliesInformation.dart';

import 'createThread.dart';
import 'discussionBoardUpdatesPage.dart' as discussionBoardUpdatesPage;
//import 'discussionBoardUpdatesPage.dart';
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesRepliesDatabaseFirestoreInfo.dart';
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesRepliesInformation.dart';
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesRepliesToRepliesDatabaseFirestoreInfo.dart';
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesRepliesToRepliesInformation.dart';
import 'questionsAndAnswersPage.dart' as questionsAndAnswersPage;
import 'technologiesPage.dart' as technologiesPage;
import 'projectsPage.dart' as projectsPage;
import 'newDiscoveriesPage.dart' as newDiscoveriesPage;
import 'main.dart' as myMain;
import 'package:starexpedition4/loginPage.dart' as theLoginPage;
import 'package:starexpedition4/registerPage.dart' as theRegisterPage;

import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesDatabaseFirestoreInfo.dart';
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesInformation.dart';

int replyNum = 0;
List<dynamic> info = [];

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
  int threadNum = 0;

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
                    //For the Discussion Board Updates subforum:
                    final discussionBoardUpdatesRepliesInfo = Get.put(discussionBoardUpdatesRepliesInformation());

                    final discussionBoardUpdatesRepliesToRepliesInfo = Get.put(discussionBoardUpdatesRepliesToRepliesInformation());

                    Future<void> createDiscussionBoardUpdatesReply(DiscussionBoardUpdatesReplies dbur, var docName) async{
                      await discussionBoardUpdatesRepliesInfo.createMyDiscussionBoardUpdatesReply(dbur, docName);
                    }

                    Future<void> createDiscussionBoardUpdatesReplyToReply(DiscussionBoardUpdatesReplies dbur, var secondDocName) async{
                      await discussionBoardUpdatesRepliesToRepliesInfo.createMyDiscussionBoardUpdatesReplyToReply(dbur, secondDocName);
                    }
                    if(discussionBoardUpdatesPage.discussionBoardUpdatesReplyingToReplyBool == false){
                      threadNum = int.parse(discussionBoardUpdatesPage.threadID);
                      //threadNumber = int.parse(discussionBoardUpdatesPage.threadID);
                      assert(threadNum is int);
                      print(threadNum.runtimeType);
                      var myReply = DiscussionBoardUpdatesReplies(
                        threadNumber: threadNum,
                        time: DateTime.now(),
                        replier: usernameReplyController.text,
                        replyContent: replyContentController.text,
                        theOriginalReplyInfo: {}
                      );
                      createDiscussionBoardUpdatesReply(myReply, discussionBoardUpdatesPage.myDocDbu);
                      pendingDiscussionBoardUpdatesReply.add(DateTime.now().toString());
                      pendingDiscussionBoardUpdatesReply.add(usernameReplyController.text);
                      pendingDiscussionBoardUpdatesReply.add(replyContentController.text);
                    }
                    else if(discussionBoardUpdatesPage.discussionBoardUpdatesReplyingToReplyBool == true){
                      discussionBoardUpdatesPage.discussionBoardUpdatesReplyingToReplyBool = false;
                      threadNum = int.parse(discussionBoardUpdatesPage.threadID);
                      assert(threadNum is int);
                      print(threadNum.runtimeType);
                      replyNum = discussionBoardUpdatesPage.myIndex;
                      var myReply = DiscussionBoardUpdatesReplies(
                          threadNumber: threadNum,
                          time: DateTime.now(),
                          replier: usernameReplyController.text,
                          replyContent: replyContentController.text,
                          theOriginalReplyInfo: discussionBoardUpdatesPage.myReplyToReplyDbuMap
                      );
                      print("This is theOriginalReplyInfo: ${discussionBoardUpdatesPage.myReplyToReplyDbuMap}");
                      createDiscussionBoardUpdatesReplyToReply(myReply, discussionBoardUpdatesPage.myDocDbu); //replyToReplyDocDbu//discussionBoardUpdatesPage.replyToReplyDocDbu
                      //info = discussionBoardUpdatesPage.myReplyToReplyDbuMap as List;
                      //pendingDiscussionBoardUpdatesReply.add(discussionBoardUpdatesPage.discussionBoardUpdatesThreads[int.parse(discussionBoardUpdatesPage.threadID)][4][discussionBoardUpdatesPage.myIndex][1].toString());
                      //pendingDiscussionBoardUpdatesReply.add(discussionBoardUpdatesPage.discussionBoardUpdatesThreads[int.parse(discussionBoardUpdatesPage.threadID)][4][discussionBoardUpdatesPage.myIndex][2].toString());
                      //print('Do we exist? ' + discussionBoardUpdatesPage.discussionBoardUpdatesThreads[int.parse(discussionBoardUpdatesPage.threadID)][4][discussionBoardUpdatesPage.myIndex][3].toString() + discussionBoardUpdatesPage.discussionBoardUpdatesThreads[int.parse(discussionBoardUpdatesPage.threadID)][4][discussionBoardUpdatesPage.myIndex][4].toString());
                    }
                  }
                    else{
                      pendingDiscussionBoardUpdatesReply.add("");
                      pendingDiscussionBoardUpdatesReply.add("");
                      print("I do not exist");
                    }
                    //discussionBoardUpdatesPage.discussionBoardUpdatesThreads.toList()[threadNum][4].add(pendingDiscussionBoardUpdatesReply);
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
                  if(questionsAndAnswersPage.questionsAndAnswersReplyBool == true){
                  //For the Questions and Answers subforum:
                  final questionsAndAnswersRepliesInfo = Get.put(questionsAndAnswersRepliesInformation());

                  final questionsAndAnswersRepliesToRepliesInfo = Get.put(questionsAndAnswersRepliesToRepliesInformation());

                  Future<void> createQuestionsAndAnswersReply(QuestionsAndAnswersReplies qaar, var docName) async{
                    await questionsAndAnswersRepliesInfo.createMyQuestionsAndAnswersReply(qaar, docName);
                  }

                  Future<void> createQuestionsAndAnswersReplyToReply(QuestionsAndAnswersReplies qaar, var secondDocName) async{
                    await questionsAndAnswersRepliesToRepliesInfo.createMyQuestionsAndAnswersReplyToReply(qaar, secondDocName);
                  }
                    if(questionsAndAnswersPage.questionsAndAnswersReplyingToReplyBool == false){
                      threadNum = int.parse(questionsAndAnswersPage.threadID);
                      assert(threadNum is int);
                      print(threadNum.runtimeType);
                      var myReplyQuestionsAndAnswers = QuestionsAndAnswersReplies(
                          threadNumber: threadNum,
                          time: DateTime.now(),
                          replier: usernameReplyController.text,
                          replyContent: replyContentController.text,
                          theOriginalReplyInfo: {}
                      );
                      createQuestionsAndAnswersReply(myReplyQuestionsAndAnswers, questionsAndAnswersPage.myDocQaa);
                      pendingQuestionsAndAnswersReply.add(DateTime.now().toString());
                      pendingQuestionsAndAnswersReply.add(usernameReplyController.text);
                      pendingQuestionsAndAnswersReply.add(replyContentController.text);
                    }
                    else if(questionsAndAnswersPage.questionsAndAnswersReplyingToReplyBool == true){
                      questionsAndAnswersPage.questionsAndAnswersReplyingToReplyBool = false;
                      threadNum = int.parse(questionsAndAnswersPage.threadID);
                      assert(threadNum is int);
                      print(threadNum.runtimeType);
                      replyNum = questionsAndAnswersPage.myIndex;
                      var myReplyQuestionsAndAnswers = QuestionsAndAnswersReplies(
                          threadNumber: threadNum,
                          time: DateTime.now(),
                          replier: usernameReplyController.text,
                          replyContent: replyContentController.text,
                          theOriginalReplyInfo: questionsAndAnswersPage.myReplyToReplyQaaMap
                      );
                      print("This is theOriginalReplyInfo: ${questionsAndAnswersPage.myReplyToReplyQaaMap}");
                      createQuestionsAndAnswersReplyToReply(myReplyQuestionsAndAnswers, questionsAndAnswersPage.myDocQaa);
                      //pendingQuestionsAndAnswersReply.add(questionsAndAnswersPage.questionsAndAnswersThreads[int.parse(questionsAndAnswersPage.threadID)][4][questionsAndAnswersPage.myIndex][1].toString());
                      //pendingQuestionsAndAnswersReply.add(questionsAndAnswersPage.questionsAndAnswersThreads[int.parse(questionsAndAnswersPage.threadID)][4][questionsAndAnswersPage.myIndex][2].toString());
                      //print('Do we exist? ' + questionsAndAnswersPage.questionsAndAnswersThreads[int.parse(questionsAndAnswersPage.threadID)][4][questionsAndAnswersPage.myIndex][3].toString() + questionsAndAnswersPage.questionsAndAnswersThreads[int.parse(questionsAndAnswersPage.threadID)][4][questionsAndAnswersPage.myIndex][4].toString());
                    }
                    else{
                      pendingQuestionsAndAnswersReply.add("");
                      pendingQuestionsAndAnswersReply.add("");
                      print("I do not exist");
                    }
                    //questionsAndAnswersPage.questionsAndAnswersThreads.toList()[threadNum][4].add(pendingQuestionsAndAnswersReply);
                    print(questionsAndAnswersPage.reversedQuestionsAndAnswersThreadsIterable);
                    print(questionsAndAnswersPage.questionsAndAnswersReplies);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const questionsAndAnswersPage.questionsAndAnswersPage()));
                    questionsAndAnswersPage.questionsAndAnswersReplyBool = false;
                  }
                  if(technologiesPage.technologiesReplyBool == true){
                    if(technologiesPage.technologiesReplyingToReplyBool == false){
                      threadNum = int.parse(technologiesPage.threadID);
                      assert(threadNum is int);
                      print(threadNum.runtimeType);
                      pendingTechnologiesReply.add(DateTime.now().toString());
                      pendingTechnologiesReply.add(usernameReplyController.text);
                      pendingTechnologiesReply.add(replyContentController.text);
                    }
                    else if(technologiesPage.technologiesReplyingToReplyBool == true){
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
                    technologiesPage.technologiesThreads.toList()[threadNum][4].add(pendingTechnologiesReply);
                    print(technologiesPage.reversedTechnologiesThreadsIterable);
                    print(technologiesPage.technologiesReplies);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const technologiesPage.technologiesPage()));
                    technologiesPage.technologiesReplyBool = false;
                  }
                  if(projectsPage.projectsReplyBool == true){
                    if(projectsPage.projectsReplyingToReplyBool == false){
                      threadNum = int.parse(projectsPage.threadID);
                      assert(threadNum is int);
                      print(threadNum.runtimeType);
                      pendingProjectsReply.add(DateTime.now().toString());
                      pendingProjectsReply.add(usernameReplyController.text);
                      pendingProjectsReply.add(replyContentController.text);
                    }
                    else if(projectsPage.projectsReplyingToReplyBool == true){
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
                    projectsPage.projectsThreads.toList()[threadNum][4].add(pendingProjectsReply);
                    print(projectsPage.reversedProjectsThreadsIterable);
                    print(projectsPage.projectsReplies);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const projectsPage.projectsPage()));
                    projectsPage.projectsReplyBool = false;
                  }
                  if(newDiscoveriesPage.newDiscoveriesReplyBool == true){
                    if(newDiscoveriesPage.newDiscoveriesReplyingToReplyBool == false){
                      threadNum = int.parse(newDiscoveriesPage.threadID);
                      assert(threadNum is int);
                      print(threadNum.runtimeType);
                      pendingNewDiscoveriesReply.add(DateTime.now().toString());
                      pendingNewDiscoveriesReply.add(usernameReplyController.text);
                      pendingNewDiscoveriesReply.add(replyContentController.text);
                    }
                    else if(newDiscoveriesPage.newDiscoveriesReplyingToReplyBool == true){
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
                    newDiscoveriesPage.newDiscoveriesThreads.toList()[threadNum][4].add(pendingNewDiscoveriesReply);
                    print(newDiscoveriesPage.reversedNewDiscoveriesThreadsIterable);
                    print(newDiscoveriesPage.newDiscoveriesReplies);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const newDiscoveriesPage.newDiscoveriesPage()));
                    newDiscoveriesPage.newDiscoveriesReplyBool = false;
                  }
                }
            ),
          ],
        ),
      )
    );
  }
}