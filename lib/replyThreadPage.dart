import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
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
import 'feedback_and_suggestions_firestore_database_information/feedbackAndSuggestionsRepliesDatabaseFirestoreInfo.dart';
import 'feedback_and_suggestions_firestore_database_information/feedbackAndSuggestionsRepliesInformation.dart';
import 'feedback_and_suggestions_firestore_database_information/feedbackAndSuggestionsRepliesToRepliesInformation.dart';
import 'questionsAndAnswersPage.dart' as questionsAndAnswersPage;
import 'technologiesPage.dart' as technologiesPage;
import 'projectsPage.dart' as projectsPage;
import 'newDiscoveriesPage.dart' as newDiscoveriesPage;
import 'feedbackAndSuggestionsPage.dart' as feedbackAndSuggestionsPage;
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

var dbuDoc;
var qaaDoc;
var technologiesDoc;
var projectsDoc;
var ndDoc;
var fasDoc;

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
  List<String> pendingFeedbackAndSuggestionsReply = [];
  int threadNum = 0;

  List<String> replyInfo = [];
  List<Text> messageReplyThread = [];

  List<Text> createReplyDialogMessage(List<String> info){
    List<Text> messageForUserReplyToThread = [];
    if(usernameReplyController.text == ""){
      messageForUserReplyToThread.add(Text("Username is empty"));
    }
    if(replyContentController.text == ""){
      messageForUserReplyToThread.add(Text("Reply content is empty"));
    }

    return messageForUserReplyToThread;
  }

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
                keyboardType: TextInputType.multiline,
                maxLines: null,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
                    else{
                      pendingDiscussionBoardUpdatesReply.add("");
                      pendingDiscussionBoardUpdatesReply.add("");
                      print("I do not exist");
                    }

                    print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesThreadsIterable);
                    print(discussionBoardUpdatesPage.discussionBoardUpdatesReplies);
                    //print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesRepliesIterable.toList()[0][0]);
                    //print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesRepliesIterable.toList()[0][1]);

                    //Getting the information of the thread one replied to
                    print("page number: ${discussionBoardUpdatesPage.myLocation}, index place: ${discussionBoardUpdatesPage.myIndexPlaceDbu}");
                    var mySublistsForDbu = discussionBoardUpdatesPage.mySublistsDbuInformation;
                    var dbuReplies = discussionBoardUpdatesPage.theDbuThreadReplies;
                    //print("mySublistsForDbu: ${mySublistsForDbu}");
                    discussionBoardUpdatesPage.threadAuthorDbu = mySublistsForDbu[discussionBoardUpdatesPage.myLocation][discussionBoardUpdatesPage.myIndexPlaceDbu]["poster"].toString();
                    discussionBoardUpdatesPage.threadTitleDbu = mySublistsForDbu[discussionBoardUpdatesPage.myLocation][discussionBoardUpdatesPage.myIndexPlaceDbu]["threadTitle"].toString();
                    discussionBoardUpdatesPage.threadContentDbu = mySublistsForDbu[discussionBoardUpdatesPage.myLocation][discussionBoardUpdatesPage.myIndexPlaceDbu]["threadContent"].toString();
                    discussionBoardUpdatesPage.threadID = mySublistsForDbu[discussionBoardUpdatesPage.myLocation][discussionBoardUpdatesPage.myIndexPlaceDbu]["threadId"].toString();

                    print("${discussionBoardUpdatesPage.threadAuthorDbu} + ${discussionBoardUpdatesPage.threadTitleDbu} + ${discussionBoardUpdatesPage.threadContentDbu} + ${discussionBoardUpdatesPage.threadID}");

                    //Getting documents
                    await FirebaseFirestore.instance.collection("Discussion_Board_Updates").where("threadId", isEqualTo: int.parse(discussionBoardUpdatesPage.threadID)).get().then((d) {
                      dbuDoc = d.docs.first.id;
                      print(dbuDoc);
                    });

                    //Getting the replies of the thread one made a reply to
                    await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(dbuDoc).collection("Replies");//.add(oneReply);

                    QuerySnapshot dbuRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(dbuDoc).collection("Replies").get();//.do//.docs.map((myDoc) => myDoc.data()).toList();;
                    print("dbuReplies: ${dbuReplies.length}");
                    dbuReplies = dbuRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                    print("dbuReplies: ${dbuReplies.length}");
                    (dbuReplies as List<dynamic>).sort((b, a) => (a["time"].toDate()).compareTo(b["time"].toDate()));

                    discussionBoardUpdatesPage.theDbuThreadReplies = dbuReplies;

                    //Navigator.pop(context);
                    Navigator.push(bc, MaterialPageRoute(builder: (context) => discussionBoardUpdatesPage.discussionBoardUpdatesThreadsPage()));

                    //Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardUpdatesPage.discussionBoardUpdatesPage()));
                    discussionBoardUpdatesPage.discussionBoardUpdatesReplyBool = false;
                  }
                    /*else{
                      pendingDiscussionBoardUpdatesReply.add("");
                      pendingDiscussionBoardUpdatesReply.add("");
                      print("I do not exist");
                    }*/
                    //discussionBoardUpdatesPage.discussionBoardUpdatesThreads.toList()[threadNum][4].add(pendingDiscussionBoardUpdatesReply);
                    //= discussionBoardUpdatesPage.discussionBoardUpdatesReplies.toString();
                    //print(pendingDiscussionBoardUpdatesReply);
                    //discussionBoardUpdatesPage.discussionBoardUpdatesReplies.add(pendingDiscussionBoardUpdatesReply);
                    /*print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesThreadsIterable);
                    print(discussionBoardUpdatesPage.discussionBoardUpdatesReplies);
                    //print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesRepliesIterable.toList()[0][0]);
                    //print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesRepliesIterable.toList()[0][1]);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardUpdatesPage.discussionBoardUpdatesPage()));
                    discussionBoardUpdatesPage.discussionBoardUpdatesReplyBool = false;*/
                  //}
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

                    //Getting thread information
                    print("page number: ${questionsAndAnswersPage.myLocation}, index place: ${questionsAndAnswersPage.myIndexPlaceQaa}");
                    var mySublistsForQaa = questionsAndAnswersPage.mySublistsQaaInformation;
                    var qaaReplies = questionsAndAnswersPage.theQaaThreadReplies;
                    questionsAndAnswersPage.threadAuthorQaa = mySublistsForQaa[questionsAndAnswersPage.myLocation][questionsAndAnswersPage.myIndexPlaceQaa]["poster"].toString();
                    questionsAndAnswersPage.threadTitleQaa = mySublistsForQaa[questionsAndAnswersPage.myLocation][questionsAndAnswersPage.myIndexPlaceQaa]["threadTitle"].toString();
                    questionsAndAnswersPage.threadContentQaa = mySublistsForQaa[questionsAndAnswersPage.myLocation][questionsAndAnswersPage.myIndexPlaceQaa]["threadContent"].toString();
                    questionsAndAnswersPage.threadID = mySublistsForQaa[questionsAndAnswersPage.myLocation][questionsAndAnswersPage.myIndexPlaceQaa]["threadId"].toString();

                    print("${questionsAndAnswersPage.threadAuthorQaa} + ${questionsAndAnswersPage.threadTitleQaa} + ${questionsAndAnswersPage.threadContentQaa} + ${questionsAndAnswersPage.threadID}");

                    //Getting documents
                    await FirebaseFirestore.instance.collection("Questions_And_Answers").where("threadId", isEqualTo: int.parse(questionsAndAnswersPage.threadID)).get().then((d) {
                      qaaDoc = d.docs.first.id;
                      print(qaaDoc);
                    });

                    //Getting the replies of the thread one made a reply to
                    await FirebaseFirestore.instance.collection("Questions_And_Answers").doc(qaaDoc).collection("Replies");//.add(oneReply);

                    QuerySnapshot qaaRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Questions_And_Answers").doc(qaaDoc).collection("Replies").get();
                    print("qaaReplies: ${qaaReplies.length}");
                    qaaReplies = qaaRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                    print("qaaReplies: ${qaaReplies.length}");
                    (qaaReplies as List<dynamic>).sort((b, a) => (a["time"].toDate()).compareTo(b["time"].toDate()));

                    questionsAndAnswersPage.theQaaThreadReplies = qaaReplies;

                    Navigator.push(context, MaterialPageRoute(builder: (context) => const questionsAndAnswersPage.questionsAndAnswersThreadsPage()));
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

                    //Getting thread information
                    print("page number: ${technologiesPage.myLocation}, index place: ${technologiesPage.myIndexPlaceTechnologies}");
                    var mySublistsForTechnologies = technologiesPage.mySublistsTechnologiesInformation;
                    var technologiesReplies = technologiesPage.theTThreadReplies;
                    technologiesPage.threadAuthorT = mySublistsForTechnologies[technologiesPage.myLocation][technologiesPage.myIndexPlaceTechnologies]["poster"].toString();
                    technologiesPage.threadTitleT = mySublistsForTechnologies[technologiesPage.myLocation][technologiesPage.myIndexPlaceTechnologies]["threadTitle"].toString();
                    technologiesPage.threadContentT = mySublistsForTechnologies[technologiesPage.myLocation][technologiesPage.myIndexPlaceTechnologies]["threadContent"].toString();
                    technologiesPage.threadID = mySublistsForTechnologies[technologiesPage.myLocation][technologiesPage.myIndexPlaceTechnologies]["threadId"].toString();

                    print("${technologiesPage.threadAuthorT} + ${technologiesPage.threadTitleT} + ${technologiesPage.threadContentT} + ${technologiesPage.threadID}");

                    //Getting documents
                    await FirebaseFirestore.instance.collection("Technologies").where("threadId", isEqualTo: int.parse(technologiesPage.threadID)).get().then((d) {
                      technologiesDoc = d.docs.first.id;
                      print(technologiesDoc);
                    });

                    //Getting the replies of the thread one made a reply to
                    await FirebaseFirestore.instance.collection("Technologies").doc(technologiesDoc).collection("Replies");

                    QuerySnapshot technologiesRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Technologies").doc(technologiesDoc).collection("Replies").get();
                    print("technologiesReplies: ${technologiesReplies.length}");
                    technologiesReplies = technologiesRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                    print("technologiesReplies: ${technologiesReplies.length}");
                    (technologiesReplies as List<dynamic>).sort((b, a) => (a["time"].toDate()).compareTo(b["time"].toDate()));

                    technologiesPage.theTThreadReplies = technologiesReplies;

                    Navigator.push(context, MaterialPageRoute(builder: (context) => const technologiesPage.technologiesThreadsPage()));

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

                    //Getting thread information
                    print("page number: ${projectsPage.myLocation}, index place: ${projectsPage.myIndexPlaceProjects}");
                    var mySublistsForProjects = projectsPage.mySublistsProjectsInformation;
                    var projectsReplies = projectsPage.thePThreadReplies;
                    projectsPage.threadAuthorP = mySublistsForProjects[projectsPage.myLocation][projectsPage.myIndexPlaceProjects]["poster"].toString();
                    projectsPage.threadTitleP = mySublistsForProjects[projectsPage.myLocation][projectsPage.myIndexPlaceProjects]["threadTitle"].toString();
                    projectsPage.threadContentP = mySublistsForProjects[projectsPage.myLocation][projectsPage.myIndexPlaceProjects]["threadContent"].toString();
                    projectsPage.threadID = mySublistsForProjects[projectsPage.myLocation][projectsPage.myIndexPlaceProjects]["threadId"].toString();

                    print("${projectsPage.threadAuthorP} + ${projectsPage.threadTitleP} + ${projectsPage.threadContentP} + ${projectsPage.threadID}");

                    //Getting documents
                    await FirebaseFirestore.instance.collection("Projects").where("threadId", isEqualTo: int.parse(projectsPage.threadID)).get().then((d) {
                      projectsDoc = d.docs.first.id;
                      print(projectsDoc);
                    });

                    //Getting the replies of the thread one made a reply to
                    await FirebaseFirestore.instance.collection("Projects").doc(projectsDoc).collection("Replies");

                    QuerySnapshot projectsRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Projects").doc(projectsDoc).collection("Replies").get();
                    print("projectsReplies: ${projectsReplies.length}");
                    projectsReplies = projectsRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                    print("projectsReplies: ${projectsReplies.length}");
                    (projectsReplies as List<dynamic>).sort((b, a) => (a["time"].toDate()).compareTo(b["time"].toDate()));

                    projectsPage.thePThreadReplies = projectsReplies;

                    Navigator.push(context, MaterialPageRoute(builder: (context) => const projectsPage.projectsThreadsPage()));

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

                    //Getting thread information
                    print("page number: ${newDiscoveriesPage.myLocation}, index place: ${newDiscoveriesPage.myIndexPlaceNewDiscoveries}");
                    var mySublistsForNewDiscoveries = newDiscoveriesPage.mySublistsNewDiscoveriesInformation;
                    var newDiscoveriesReplies = newDiscoveriesPage.theNdThreadReplies;
                    newDiscoveriesPage.threadAuthorNd = mySublistsForNewDiscoveries[newDiscoveriesPage.myLocation][newDiscoveriesPage.myIndexPlaceNewDiscoveries]["poster"].toString();
                    newDiscoveriesPage.threadTitleNd = mySublistsForNewDiscoveries[newDiscoveriesPage.myLocation][newDiscoveriesPage.myIndexPlaceNewDiscoveries]["threadTitle"].toString();
                    newDiscoveriesPage.threadContentNd = mySublistsForNewDiscoveries[newDiscoveriesPage.myLocation][newDiscoveriesPage.myIndexPlaceNewDiscoveries]["threadContent"].toString();
                    newDiscoveriesPage.threadID = mySublistsForNewDiscoveries[newDiscoveriesPage.myLocation][newDiscoveriesPage.myIndexPlaceNewDiscoveries]["threadId"].toString();

                    print("${newDiscoveriesPage.threadAuthorNd} + ${newDiscoveriesPage.threadTitleNd} + ${newDiscoveriesPage.threadContentNd} + ${newDiscoveriesPage.threadID}");

                    //Getting documents
                    await FirebaseFirestore.instance.collection("New_Discoveries").where("threadId", isEqualTo: int.parse(newDiscoveriesPage.threadID)).get().then((d) {
                      ndDoc = d.docs.first.id;
                      print(ndDoc);
                    });

                    //Getting the replies of the thread one made a reply to
                    await FirebaseFirestore.instance.collection("New_Discoveries").doc(ndDoc).collection("Replies");

                    QuerySnapshot newDiscoveriesRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("New_Discoveries").doc(ndDoc).collection("Replies").get();
                    print("newDiscoveriesReplies: ${newDiscoveriesReplies.length}");
                    newDiscoveriesReplies = newDiscoveriesRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                    print("newDiscoveriesReplies: ${newDiscoveriesReplies.length}");
                    (newDiscoveriesReplies as List<dynamic>).sort((b, a) => (a["time"].toDate()).compareTo(b["time"].toDate()));

                    newDiscoveriesPage.theNdThreadReplies = newDiscoveriesReplies;

                    Navigator.push(context, MaterialPageRoute(builder: (context) => const newDiscoveriesPage.newDiscoveriesThreadsPage()));

                    newDiscoveriesPage.newDiscoveriesReplyBool = false;
                  }
                  if(feedbackAndSuggestionsPage.fasReplyBool == true){
                    final feedbackAndSuggestionsRepliesInfo = Get.put(feedbackAndSuggestionsRepliesInformation());

                    final feedbackAndSuggestionsRepliesToRepliesInfo = Get.put(feedbackAndSuggestionsRepliesToRepliesInformation());

                    Future<void> createFeedbackAndSuggestionsReply(FeedbackAndSuggestionsReplies fasr, var docName) async{
                      await feedbackAndSuggestionsRepliesInfo.createMyFeedbackAndSuggestionsReply(fasr, docName);
                    }

                    Future<void> createFeedbackAndSuggestionsReplyToReply(FeedbackAndSuggestionsReplies fasr, var secondDocName) async{
                      await feedbackAndSuggestionsRepliesToRepliesInfo.createMyFeedbackAndSuggestionsReplyToReply(fasr, secondDocName);
                    }
                    if(feedbackAndSuggestionsPage.fasReplyingToReplyBool == false){
                      threadNum = int.parse(feedbackAndSuggestionsPage.threadID);
                      assert(threadNum is int);
                      print(threadNum.runtimeType);
                      var myReplyFeedbackAndSuggestions = FeedbackAndSuggestionsReplies(
                          threadNumber: threadNum,
                          time: DateTime.now(),
                          replier: usernameReplyController.text,
                          replyContent: replyContentController.text,
                          theOriginalReplyInfo: {}
                      );
                      createFeedbackAndSuggestionsReply(myReplyFeedbackAndSuggestions, feedbackAndSuggestionsPage.myDocFas);

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

                      pendingFeedbackAndSuggestionsReply.add(DateTime.now().toString());
                      pendingFeedbackAndSuggestionsReply.add(usernameReplyController.text);
                      pendingFeedbackAndSuggestionsReply.add(replyContentController.text);
                    }
                    else if(feedbackAndSuggestionsPage.fasReplyingToReplyBool == true){
                      feedbackAndSuggestionsPage.fasReplyingToReplyBool = false;
                      threadNum = int.parse(feedbackAndSuggestionsPage.threadID);
                      assert(threadNum is int);
                      print(threadNum.runtimeType);
                      replyNum = feedbackAndSuggestionsPage.myIndex;
                      var myReplyFeedbackAndSuggestions = FeedbackAndSuggestionsReplies(
                          threadNumber: threadNum,
                          time: DateTime.now(),
                          replier: usernameReplyController.text,
                          replyContent: replyContentController.text,
                          theOriginalReplyInfo: feedbackAndSuggestionsPage.myReplyToReplyFasMap
                      );
                      print("This is theOriginalReplyInfo: ${feedbackAndSuggestionsPage.myReplyToReplyFasMap}");
                      createFeedbackAndSuggestionsReplyToReply(myReplyFeedbackAndSuggestions, feedbackAndSuggestionsPage.myDocFas);

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
                      pendingFeedbackAndSuggestionsReply.add("");
                      pendingFeedbackAndSuggestionsReply.add("");
                      print("I do not exist");
                    }
                    print(feedbackAndSuggestionsPage.reversedFasThreadsIterable);
                    print(feedbackAndSuggestionsPage.fasReplies);

                    //Getting thread information
                    print("page number: ${feedbackAndSuggestionsPage.myLocation}, index place: ${feedbackAndSuggestionsPage.myIndexPlaceFas}");
                    var mySublistsForFeedbackAndSuggestions = feedbackAndSuggestionsPage.mySublistsFasInformation;
                    var feedbackAndSuggestionsReplies = feedbackAndSuggestionsPage.theFasThreadReplies;
                    feedbackAndSuggestionsPage.threadAuthorFas = mySublistsForFeedbackAndSuggestions[feedbackAndSuggestionsPage.myLocation][feedbackAndSuggestionsPage.myIndexPlaceFas]["poster"].toString();
                    feedbackAndSuggestionsPage.threadTitleFas = mySublistsForFeedbackAndSuggestions[feedbackAndSuggestionsPage.myLocation][feedbackAndSuggestionsPage.myIndexPlaceFas]["threadTitle"].toString();
                    feedbackAndSuggestionsPage.threadContentFas = mySublistsForFeedbackAndSuggestions[feedbackAndSuggestionsPage.myLocation][feedbackAndSuggestionsPage.myIndexPlaceFas]["threadContent"].toString();
                    feedbackAndSuggestionsPage.threadID = mySublistsForFeedbackAndSuggestions[feedbackAndSuggestionsPage.myLocation][feedbackAndSuggestionsPage.myIndexPlaceFas]["threadId"].toString();

                    print("${feedbackAndSuggestionsPage.threadAuthorFas} + ${feedbackAndSuggestionsPage.threadTitleFas} + ${feedbackAndSuggestionsPage.threadContentFas} + ${feedbackAndSuggestionsPage.threadID}");

                    //Getting documents
                    await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").where("threadId", isEqualTo: int.parse(feedbackAndSuggestionsPage.threadID)).get().then((d) {
                      fasDoc = d.docs.first.id;
                      print(fasDoc);
                    });

                    //Getting the replies of the thread one made a reply to
                    await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").doc(fasDoc).collection("Replies");

                    QuerySnapshot feedbackAndSuggestionsRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").doc(fasDoc).collection("Replies").get();
                    print("feedbackAndSuggestionsReplies: ${feedbackAndSuggestionsReplies.length}");
                    feedbackAndSuggestionsReplies = feedbackAndSuggestionsRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                    print("feedbackAndSuggestionsReplies: ${feedbackAndSuggestionsReplies.length}");
                    (feedbackAndSuggestionsReplies as List<dynamic>).sort((b, a) => (a["time"].toDate()).compareTo(b["time"].toDate()));

                    feedbackAndSuggestionsPage.theFasThreadReplies = feedbackAndSuggestionsReplies;

                    Navigator.push(context, MaterialPageRoute(builder: (context) => const feedbackAndSuggestionsPage.feedbackAndSuggestionsThreadsPage()));

                    feedbackAndSuggestionsPage.fasReplyBool = false;
                  }
                }
                else{
                  replyInfo.add(usernameReplyController.text);
                  replyInfo.add(replyContentController.text);

                  messageReplyThread = createReplyDialogMessage(replyInfo);

                  showDialog(
                      context: context,
                      builder: (BuildContext myContext){
                        return AlertDialog(
                          title: const Text("Unable to post thread"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(messageReplyThread.length, (i){
                              return messageReplyThread[i];
                            }),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => {
                                Navigator.pop(context),
                              },
                              child: const Text("Ok"),
                            ),
                          ],
                        );
                      }
                  );
                }
              }
            ),
          ],
        ),
      )
    );
  }
}