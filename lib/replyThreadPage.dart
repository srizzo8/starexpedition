import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:starexpedition4/projects_firestore_database_information/projectsRepliesDatabaseFirestoreInfo.dart';
import 'package:starexpedition4/projects_firestore_database_information/projectsRepliesInformation.dart';
import 'package:starexpedition4/projects_firestore_database_information/projectsRepliesToRepliesInformation.dart';
import 'package:starexpedition4/questions_and_answers_firestore_database_information/questionsAndAnswersRepliesDatabaseFirestoreInfo.dart';
import 'package:starexpedition4/questions_and_answers_firestore_database_information/questionsAndAnswersRepliesInformation.dart';
import 'package:starexpedition4/questions_and_answers_firestore_database_information/questionsAndAnswersRepliesToRepliesInformation.dart';
import 'package:starexpedition4/technologies_firestore_database_information/technologiesRepliesDatabaseFirestoreInfo.dart';
import 'package:starexpedition4/technologies_firestore_database_information/technologiesRepliesInformation.dart';
import 'package:starexpedition4/technologies_firestore_database_information/technologiesRepliesToRepliesInformation.dart';

import 'createThread.dart';
import 'discussionBoardUpdatesPage.dart' as discussionBoardUpdatesPage;
//import 'discussionBoardUpdatesPage.dart';
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesRepliesDatabaseFirestoreInfo.dart';
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesRepliesInformation.dart';
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesRepliesToRepliesDatabaseFirestoreInfo.dart';
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesRepliesToRepliesInformation.dart';
import 'new_discoveries_firestore_database_information/newDiscoveriesRepliesDatabaseFirestoreInfo.dart';
import 'new_discoveries_firestore_database_information/newDiscoveriesRepliesInformation.dart';
import 'new_discoveries_firestore_database_information/newDiscoveriesRepliesToRepliesInformation.dart';
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
var myInfoForReplies;
var userDataForReplies;
var docNameForReplies;

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
        centerTitle: true,
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
              height: 5,
            ),
            Container(
              child: Text("Making a reply", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0), textAlign: TextAlign.center),
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
            InkWell(
              child: Ink(
                color: Colors.black,
                height: 30,
                width: 140,
                child: Container(
                  alignment: Alignment.center,
                  //margin: EdgeInsets.only(left: 200.0),
                  padding: EdgeInsets.all(5.0),
                  child: Text("Reply to Thread", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                ),
              ),
              onTap: () async{
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

                      if(theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theLoginPage.myUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultExistingUsername){
                          userDataForReplies = resultExistingUsername.data();
                          docNameForReplies = resultExistingUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the existing user!");
                        });
                      }
                      else if(theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theRegisterPage.myNewUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultNewUsername){
                          userDataForReplies = resultNewUsername.data();
                          docNameForReplies = resultNewUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the new user!");
                        });
                      }

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
                      if(theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theLoginPage.myUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultExistingUsername){
                          userDataForReplies = resultExistingUsername.data();
                          docNameForReplies = resultExistingUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the existing user!");
                        });
                      }
                      else if(theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theRegisterPage.myNewUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultNewUsername){
                          userDataForReplies = resultNewUsername.data();
                          docNameForReplies = resultNewUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the new user!");
                        });
                      }
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

                      if(theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theLoginPage.myUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultExistingUsername){
                          userDataForReplies = resultExistingUsername.data();
                          docNameForReplies = resultExistingUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the existing user!");
                        });
                      }
                      else if(theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theRegisterPage.myNewUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultNewUsername){
                          userDataForReplies = resultNewUsername.data();
                          docNameForReplies = resultNewUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the new user!");
                        });
                      }

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
                      if(theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theLoginPage.myUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultExistingUsername){
                          userDataForReplies = resultExistingUsername.data();
                          docNameForReplies = resultExistingUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the existing user!");
                        });
                      }
                      else if(theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theRegisterPage.myNewUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultNewUsername){
                          userDataForReplies = resultNewUsername.data();
                          docNameForReplies = resultNewUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the new user!");
                        });
                      }
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
                    final technologiesRepliesInfo = Get.put(technologiesRepliesInformation());

                    final technologiesRepliesToRepliesInfo = Get.put(technologiesRepliesToRepliesInformation());

                    Future<void> createTechnologiesReply(TechnologiesReplies tr, var docName) async{
                      await technologiesRepliesInfo.createMyTechnologiesReply(tr, docName);
                    }

                    Future<void> createTechnologiesReplyToReply(TechnologiesReplies tr, var secondDocName) async{
                      await technologiesRepliesToRepliesInfo.createMyTechnologiesReplyToReply(tr, secondDocName);
                    }
                    if(technologiesPage.technologiesReplyingToReplyBool == false){
                      threadNum = int.parse(technologiesPage.threadID);
                      assert(threadNum is int);
                      print(threadNum.runtimeType);
                      var myReplyTechnologies = TechnologiesReplies(
                          threadNumber: threadNum,
                          time: DateTime.now(),
                          replier: usernameReplyController.text,
                          replyContent: replyContentController.text,
                          theOriginalReplyInfo: {}
                      );
                      createTechnologiesReply(myReplyTechnologies, technologiesPage.myDocT);

                      if(theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theLoginPage.myUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultExistingUsername){
                          userDataForReplies = resultExistingUsername.data();
                          docNameForReplies = resultExistingUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the existing user!");
                        });
                      }
                      else if(theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theRegisterPage.myNewUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultNewUsername){
                          userDataForReplies = resultNewUsername.data();
                          docNameForReplies = resultNewUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the new user!");
                        });
                      }

                      pendingTechnologiesReply.add(DateTime.now().toString());
                      pendingTechnologiesReply.add(usernameReplyController.text);
                      pendingTechnologiesReply.add(replyContentController.text);
                    }
                    else if(technologiesPage.technologiesReplyingToReplyBool == true){
                      technologiesPage.technologiesReplyingToReplyBool = false;
                      threadNum = int.parse(technologiesPage.threadID);
                      assert(threadNum is int);
                      print(threadNum.runtimeType);
                      replyNum = technologiesPage.myIndex;
                      var myReplyTechnologies = TechnologiesReplies(
                          threadNumber: threadNum,
                          time: DateTime.now(),
                          replier: usernameReplyController.text,
                          replyContent: replyContentController.text,
                          theOriginalReplyInfo: technologiesPage.myReplyToReplyTMap
                      );
                      print("This is theOriginalReplyInfo: ${technologiesPage.myReplyToReplyTMap}");
                      createTechnologiesReplyToReply(myReplyTechnologies, technologiesPage.myDocT);

                      if(theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theLoginPage.myUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultExistingUsername){
                          userDataForReplies = resultExistingUsername.data();
                          docNameForReplies = resultExistingUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the existing user!");
                        });
                      }
                      else if(theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theRegisterPage.myNewUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultNewUsername){
                          userDataForReplies = resultNewUsername.data();
                          docNameForReplies = resultNewUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the new user!");
                        });
                      }
                    }
                    else{
                      pendingTechnologiesReply.add("");
                      pendingTechnologiesReply.add("");
                      print("I do not exist");
                    }
                    print(technologiesPage.reversedTechnologiesThreadsIterable);
                    print(technologiesPage.technologiesReplies);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const technologiesPage.technologiesPage()));
                    technologiesPage.technologiesReplyBool = false;
                  }
                  if(projectsPage.projectsReplyBool == true){
                    final projectsRepliesInfo = Get.put(projectsRepliesInformation());

                    final projectsRepliesToRepliesInfo = Get.put(projectsRepliesToRepliesInformation());

                    Future<void> createProjectsReply(ProjectsReplies pr, var docName) async{
                      await projectsRepliesInfo.createMyProjectsReply(pr, docName);
                    }

                    Future<void> createProjectsReplyToReply(ProjectsReplies pr, var secondDocName) async{
                      await projectsRepliesToRepliesInfo.createMyProjectsReplyToReply(pr, secondDocName);
                    }
                    if(projectsPage.projectsReplyingToReplyBool == false){
                      threadNum = int.parse(projectsPage.threadID);
                      assert(threadNum is int);
                      print(threadNum.runtimeType);
                      var myReplyProjects = ProjectsReplies(
                          threadNumber: threadNum,
                          time: DateTime.now(),
                          replier: usernameReplyController.text,
                          replyContent: replyContentController.text,
                          theOriginalReplyInfo: {}
                      );
                      createProjectsReply(myReplyProjects, projectsPage.myDocP);

                      if(theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theLoginPage.myUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultExistingUsername){
                          userDataForReplies = resultExistingUsername.data();
                          docNameForReplies = resultExistingUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the existing user!");
                        });
                      }
                      else if(theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theRegisterPage.myNewUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultNewUsername){
                          userDataForReplies = resultNewUsername.data();
                          docNameForReplies = resultNewUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the new user!");
                        });
                      }

                      pendingProjectsReply.add(DateTime.now().toString());
                      pendingProjectsReply.add(usernameReplyController.text);
                      pendingProjectsReply.add(replyContentController.text);
                    }
                    else if(projectsPage.projectsReplyingToReplyBool == true){
                      projectsPage.projectsReplyingToReplyBool = false;
                      threadNum = int.parse(projectsPage.threadID);
                      assert(threadNum is int);
                      print(threadNum.runtimeType);
                      replyNum = projectsPage.myIndex;
                      var myReplyProjects = ProjectsReplies(
                          threadNumber: threadNum,
                          time: DateTime.now(),
                          replier: usernameReplyController.text,
                          replyContent: replyContentController.text,
                          theOriginalReplyInfo: projectsPage.myReplyToReplyPMap
                      );
                      print("This is theOriginalReplyInfo: ${projectsPage.myReplyToReplyPMap}");
                      createProjectsReplyToReply(myReplyProjects, projectsPage.myDocP);

                      if(theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theLoginPage.myUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultExistingUsername){
                          userDataForReplies = resultExistingUsername.data();
                          docNameForReplies = resultExistingUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the existing user!");
                        });
                      }
                      else if(theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theRegisterPage.myNewUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultNewUsername){
                          userDataForReplies = resultNewUsername.data();
                          docNameForReplies = resultNewUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the new user!");
                        });
                      }
                    }
                    else{
                      pendingProjectsReply.add("");
                      pendingProjectsReply.add("");
                      print("I do not exist");
                    }
                    print(projectsPage.reversedProjectsThreadsIterable);
                    print(projectsPage.projectsReplies);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const projectsPage.projectsPage()));
                    projectsPage.projectsReplyBool = false;
                  }
                  if(newDiscoveriesPage.newDiscoveriesReplyBool == true){
                    final newDiscoveriesRepliesInfo = Get.put(newDiscoveriesRepliesInformation());

                    final newDiscoveriesRepliesToRepliesInfo = Get.put(newDiscoveriesRepliesToRepliesInformation());

                    Future<void> createNewDiscoveriesReply(NewDiscoveriesReplies ndr, var docName) async{
                      await newDiscoveriesRepliesInfo.createMyNewDiscoveriesReply(ndr, docName);
                    }

                    Future<void> createNewDiscoveriesReplyToReply(NewDiscoveriesReplies ndr, var secondDocName) async{
                      await newDiscoveriesRepliesToRepliesInfo.createMyNewDiscoveriesReplyToReply(ndr, secondDocName);
                    }
                    if(newDiscoveriesPage.newDiscoveriesReplyingToReplyBool == false){
                      threadNum = int.parse(newDiscoveriesPage.threadID);
                      assert(threadNum is int);
                      print(threadNum.runtimeType);
                      var myReplyNewDiscoveries = NewDiscoveriesReplies(
                          threadNumber: threadNum,
                          time: DateTime.now(),
                          replier: usernameReplyController.text,
                          replyContent: replyContentController.text,
                          theOriginalReplyInfo: {}
                      );
                      createNewDiscoveriesReply(myReplyNewDiscoveries, newDiscoveriesPage.myDocNd);

                      if(theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theLoginPage.myUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultExistingUsername){
                          userDataForReplies = resultExistingUsername.data();
                          docNameForReplies = resultExistingUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the existing user!");
                        });
                      }
                      else if(theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theRegisterPage.myNewUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultNewUsername){
                          userDataForReplies = resultNewUsername.data();
                          docNameForReplies = resultNewUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the new user!");
                        });
                      }

                      pendingNewDiscoveriesReply.add(DateTime.now().toString());
                      pendingNewDiscoveriesReply.add(usernameReplyController.text);
                      pendingNewDiscoveriesReply.add(replyContentController.text);
                    }
                    else if(newDiscoveriesPage.newDiscoveriesReplyingToReplyBool == true){
                      newDiscoveriesPage.newDiscoveriesReplyingToReplyBool = false;
                      threadNum = int.parse(newDiscoveriesPage.threadID);
                      assert(threadNum is int);
                      print(threadNum.runtimeType);
                      replyNum = newDiscoveriesPage.myIndex;
                      var myReplyNewDiscoveries = NewDiscoveriesReplies(
                          threadNumber: threadNum,
                          time: DateTime.now(),
                          replier: usernameReplyController.text,
                          replyContent: replyContentController.text,
                          theOriginalReplyInfo: newDiscoveriesPage.myReplyToReplyNdMap
                      );
                      print("This is theOriginalReplyInfo: ${newDiscoveriesPage.myReplyToReplyNdMap}");
                      createNewDiscoveriesReplyToReply(myReplyNewDiscoveries, newDiscoveriesPage.myDocNd);

                      if(theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theLoginPage.myUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultExistingUsername){
                          userDataForReplies = resultExistingUsername.data();
                          docNameForReplies = resultExistingUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the existing user!");
                        });
                      }
                      else if(theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != ""){
                        myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theRegisterPage.myNewUsername.toLowerCase()).get();
                        myInfoForReplies.docs.forEach((resultNewUsername){
                          userDataForReplies = resultNewUsername.data();
                          docNameForReplies = resultNewUsername.id;
                        });

                        print("userData: ${userDataForReplies}");
                        print("docName: ${docNameForReplies}");

                        FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                          "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                        }).then((a){
                          print("You have updated the post number for the new user!");
                        });
                      }
                    }
                    else{
                      pendingNewDiscoveriesReply.add("");
                      pendingNewDiscoveriesReply.add("");
                      print("I do not exist");
                    }
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