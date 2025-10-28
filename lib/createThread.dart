import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
//import 'package:feedback_sentry/feedback_sentry.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
//import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:starexpedition4/projects_firestore_database_information/projectsDatabaseFirestoreInfo.dart';
import 'package:starexpedition4/projects_firestore_database_information/projectsInformation.dart';
import 'package:starexpedition4/questions_and_answers_firestore_database_information/questionsAndAnswersDatabaseFirestoreInfo.dart';
import 'package:starexpedition4/questions_and_answers_firestore_database_information/questionsAndAnswersInformation.dart';
import 'package:starexpedition4/technologies_firestore_database_information/technologiesDatabaseFirestoreInfo.dart';
import 'package:starexpedition4/technologies_firestore_database_information/technologiesInformation.dart';
import 'discussionBoardPage.dart';
import 'discussionBoardUpdatesPage.dart' as discussionBoardUpdatesPage;
import 'new_discoveries_firestore_database_information/newDiscoveriesDatabaseFirestoreInfo.dart';
import 'new_discoveries_firestore_database_information/newDiscoveriesInformation.dart';
import 'questionsAndAnswersPage.dart' as questionsAndAnswersPage;
import 'technologiesPage.dart' as technologiesPage;
import 'projectsPage.dart' as projectsPage;
import 'newDiscoveriesPage.dart' as newDiscoveriesPage;
import 'package:starexpedition4/loginPage.dart' as theLoginPage;
import 'replyThreadPage.dart';
import 'main.dart' as myMain;
import 'package:starexpedition4/registerPage.dart' as theRegisterPage;
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesDatabaseFirestoreInfo.dart';
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesInformation.dart';
import 'feedback_and_suggestions_firestore_database_information/feedbackAndSuggestionsDatabaseFirestoreInfo.dart';
import 'feedback_and_suggestions_firestore_database_information/feedbackAndSuggestionsInformation.dart';
import 'feedbackAndSuggestionsPage.dart' as feedbackAndSuggestionsPage;
import 'package:starexpedition4/loginPage.dart';
import 'package:starexpedition4/registerPage.dart';
import 'package:starexpedition4/firebaseDesktopHelper.dart';
//import 'package:sentry/sentry.dart';
//import 'package:feedback/feedback.dart';

var myInfo;
var userData;
var docName;

//SentryOptions so = "" as SentryOptions;

class createThread extends StatefulWidget{
  const createThread ({Key? key}) : super(key: key);

  @override
  createThreadState createState() => createThreadState();
}

/*void main() async{

  /*await SentryFlutter.init(
        (options) {
      options.dsn = dotenv.env["OPTIONS_DSN"];

      options.tracesSampleRate = 1.0;

      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(const MyApp()),
  );*/
}*/

class createThreadState extends State<createThread>{
  static String threadCreator = '/createThread';
  final usernameController = TextEditingController();
  final threadNameController = TextEditingController();
  final threadContentController = TextEditingController();
  int discussionBoardUpdatesThreadId = 0;
  int questionsAndAnswersThreadId = 0;
  int technologiesThreadId = 0;
  int projectsThreadId = 0;
  int newDiscoveriesThreadId = 0;
  int feedbackAndSuggestionsThreadId = 0;
  var discussionBoardUpdatesPendingThreads = [];
  var questionsAndAnswersPendingThreads = [];
  var technologiesPendingThreads = [];
  var projectsPendingThreads = [];
  var newDiscoveriesPendingThreads = [];
  var feedbackAndSuggestionsPendingThreads = [];

  List<String> threadInfo = [];
  List<Text> messageCreateThread = [];

  List<Text> createThreadDialogMessage(List<String> info){
    List<Text> messageForUserCreateThread = [];
    if(usernameController.text == ""){
      messageForUserCreateThread.add(Text("Username is empty"));
    }
    if(threadNameController.text == ""){
      messageForUserCreateThread.add(Text("Thread name is empty"));
    }
    if(threadContentController.text == ""){
      messageForUserCreateThread.add(Text("Thread content is empty"));
    }

    return messageForUserCreateThread;
  }

  Widget build(BuildContext createThreadBuildContext){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => showDialog(
            context: context,
            builder: (BuildContext myContext) {
              return AlertDialog(
                title: const Text("Are you sure?"),
                content: const Text("Your thread will not be saved."),
                actions: [
                  TextButton(
                    onPressed: () => {
                      if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == true && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == false && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == false && feedbackAndSuggestionsPage.fasBool == false){
                        discussionBoardUpdatesPage.discussionBoardUpdatesBool = false,
                      }
                      else if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == true && technologiesPage.technologiesBool == false && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == false && feedbackAndSuggestionsPage.fasBool == false){
                        questionsAndAnswersPage.questionsAndAnswersBool = false,
                      }
                      else if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == true && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == false && feedbackAndSuggestionsPage.fasBool == false){
                        technologiesPage.technologiesBool = false,
                      }
                      else if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == false && projectsPage.projectsBool == true && newDiscoveriesPage.newDiscoveriesBool == false && feedbackAndSuggestionsPage.fasBool == false){
                        projectsPage.projectsBool = false,
                      }
                      else if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == false && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == true && feedbackAndSuggestionsPage.fasBool == false){
                        newDiscoveriesPage.newDiscoveriesBool = false,
                      }
                      else if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == false && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == false && feedbackAndSuggestionsPage.fasBool == true){
                        feedbackAndSuggestionsPage.fasBool = false,
                      },
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
              //print("Are you sure?")
            },
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
              child: Text("Making a thread", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0), textAlign: TextAlign.center),
              width: 480,
              alignment: Alignment.center,
            ),
            Padding(
                padding: EdgeInsets.all(20.0),
                child: theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""?
                SizedBox(
                  width: 320,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Username",
                    ),
                    maxLines: 1,
                    maxLength: null,
                    enabled: false,
                    controller: TextEditingController()..text = theLoginPage.myUsername,
                  ),
                ): (theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != "")?
                SizedBox(
                  width: 320,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Username",
                    ),
                    maxLines: 1,
                    maxLength: null,
                    enabled: false,
                    controller: TextEditingController()..text = theRegisterPage.myNewUsername,
                  ),
                ): SizedBox(
                    width: 320,
                    child: TextField(),
                ),
              ),
            /*Container(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
              ),
            child: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Thread Name",
                    ),
                    maxLines: 1,
                    maxLength: 250,
                    controller: threadNameController,
                  ),
                ),
              ),
            ),
            ),
            ),*/
            /*Padding(
              padding: EdgeInsets.all(20.0),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  decoration: InputDecoration(
                    labelText: "Thread Content",
                    contentPadding: EdgeInsets.symmetric(vertical: 80),
                  ),
                  controller: threadContentController,
                ),
            ),*/
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.only(left: 10.0, top: 20.0, right: 10.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 320,
                          ),
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              reverse: true,
                              child: SizedBox(
                                child: TextField(
                                  minLines: 1,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Thread Name",
                                  ),
                                  maxLength: 250,
                                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                  controller: threadNameController,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    )
                  ),
                ],
              ),
            ),
            IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.only(left: 10.0, top: 20.0, right: 10.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 320,
                            ),
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                reverse: true,
                                child: SizedBox(
                                  child: TextField(
                                    minLines: 5,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Thread Content",
                                    ),
                                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                    controller: threadContentController,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]
              ),
            ),
            Container(
              height: 5,
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                ),
                child: InkWell(
                  child: Ink(
                    color: Colors.black,
                    height: 30,
                    width: 140,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(5.0),
                      child: Text("Post to Subforum", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal), textAlign: TextAlign.center),
                    ),
                  ),
                ),
                onPressed: () async{
                  //print('Posting the thread');
                  print(discussionBoardUpdatesPage.discussionBoardUpdatesBool);
                  print(technologiesPage.technologiesBool);
                  if(theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""){
                    usernameController.text = theLoginPage.myUsername;
                  }
                  else if(theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != ""){
                    usernameController.text = theRegisterPage.myNewUsername;
                  }
                  if(usernameController.text != "" && threadNameController.text != "" && threadContentController.text != ""){
                    //print(usernameController.text);
                    if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == true && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == false && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == false && feedbackAndSuggestionsPage.fasBool == false) {
                      final discussionBoardUpdatesThreadsInfo = Get.put(discussionBoardUpdatesInformation());

                      Future<void> createDiscussionBoardUpdatesThread(DiscussionBoardUpdatesThreads dbut) async{
                        await discussionBoardUpdatesThreadsInfo.createMyDiscussionBoardUpdatesThread(dbut);
                      }

                      //discussionBoardUpdatesThreadId++;
                      if(discussionBoardUpdatesThreads.length > 0){
                        if(firebaseDesktopHelper.onDesktop){
                          var threadIdResult = await firebaseDesktopHelper.getFirestoreCollection("Discussion_Board_Updates");
                          var threadIdFound = threadIdResult.firstWhere((myThread) => myThread["threadId"] == (threadIdResult.length - 1), orElse: () => {} as Map<String, dynamic>);
                          discussionBoardUpdatesThreadId = threadIdFound["threadId"] + 1;
                        }
                        else{
                          await FirebaseFirestore.instance.collection("Discussion_Board_Updates").orderBy("threadId", descending: true).limit(1).get().then((myId){
                            discussionBoardUpdatesThreadId = myId.docs.first.data()["threadId"] + 1;
                          });
                        }
                      }
                      //Map<String, List<String>> dbuReplies = new Map<String, List<String>>();

                      var theNewDiscussionBoardUpdatesThread = DiscussionBoardUpdatesThreads(
                        threadId: discussionBoardUpdatesThreadId,
                        poster: usernameController.text,
                        threadTitle: threadNameController.text,
                        threadContent: threadContentController.text,
                      );

                      createDiscussionBoardUpdatesThread(theNewDiscussionBoardUpdatesThread);

                      if(myUsername != "" && myNewUsername == ""){
                        if(firebaseDesktopHelper.onDesktop){
                          List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                          var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                          if(theCorrectUser.isNotEmpty){
                            userData = theCorrectUser;
                            docName = theCorrectUser["docId"] ?? "N/A";

                            print("userData: ${userData}");
                            print("docName for your username: ${docName}");

                            //Updating the document:
                            try{
                              //Getting the current information about a user:
                              Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                              print("theCorrectUser: ${theCorrectUser}");
                              print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                              print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                              print("Full user info: ${currentInfoOfUser}");
                              print("Full user keys: ${currentInfoOfUser.keys}");

                              //Incrementing the number of posts a user has:
                              int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                              currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                              //Updating the information about a user:
                              await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                "usernameProfileInformation": currentInfoOfUser,
                              });

                              print("You have updated the number of posts for the user!");

                              //Determining if the full document still has all of the fields
                              List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                              var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                              print("The full document after the update: $theVerifiedUser");
                            }
                            catch (error){
                              print("Error updating information of user: ${error}");
                              print("Stack trace: ${StackTrace.current}");
                            }
                          }
                          else{
                            print("User not found");
                          }
                        }
                        else{
                          myInfo = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                          myInfo.docs.forEach((resultExistingUsername){
                            userData = resultExistingUsername.data();
                            docName = resultExistingUsername.id;
                          });

                          print("userData: ${userData}");
                          print("docName: ${docName}");

                          FirebaseFirestore.instance.collection("User").doc(docName).update({
                            "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                          }).then((a){
                            print("You have updated the post number for the existing user!");
                          });
                        }
                      }
                      else if(myUsername == "" && myNewUsername != ""){
                        if(firebaseDesktopHelper.onDesktop){
                          List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                          var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                          if(theCorrectUser.isNotEmpty){
                            userData = theCorrectUser;
                            docName = theCorrectUser["docId"] ?? "N/A";

                            print("userData: ${userData}");
                            print("docName for your username: ${docName}");

                            //Updating the document:
                            try{
                              //Getting the current information about a user:
                              Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                              print("theCorrectUser: ${theCorrectUser}");
                              print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                              print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                              print("Full user info: ${currentInfoOfUser}");
                              print("Full user keys: ${currentInfoOfUser.keys}");

                              //Incrementing the number of posts a user has:
                              int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                              currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                              //Updating the information about a user:
                              await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                "usernameProfileInformation": currentInfoOfUser,
                              });

                              print("You have updated the number of posts for the user!");

                              //Determining if the full document still has all of the fields
                              List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                              var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                              print("The full document after the update: $theVerifiedUser");
                            }
                            catch (error){
                              print("Error updating information of user: ${error}");
                              print("Stack trace: ${StackTrace.current}");
                            }
                          }
                          else{
                            print("User not found");
                          }
                        }
                        else{
                          myInfo = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                          myInfo.docs.forEach((resultNewUsername){
                            userData = resultNewUsername.data();
                            docName = resultNewUsername.id;
                          });

                          print("userData: ${userData}");
                          print("docName: ${docName}");

                          FirebaseFirestore.instance.collection("User").doc(docName).update({
                            "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                          }).then((a){
                            print("You have updated the post number for the new user!");
                          });
                        }
                      }

                      print('You are ready to post this thread');
                      discussionBoardUpdatesPendingThreads.add(usernameController.text);
                      discussionBoardUpdatesPendingThreads.add(threadNameController.text);
                      discussionBoardUpdatesPendingThreads.add(threadContentController.text);
                      discussionBoardUpdatesPendingThreads.add((discussionBoardUpdatesPage.discussionBoardUpdatesThreads.length).toString());
                      discussionBoardUpdatesPendingThreads.add(List.empty(growable: true));
                      print(discussionBoardUpdatesPendingThreads);
                      discussionBoardUpdatesPage.discussionBoardUpdatesThreads.add(discussionBoardUpdatesPendingThreads);

                      //Making sure the new thread gets added to the Discussion Board Updates subforum
                      if(firebaseDesktopHelper.onDesktop){
                        discussionBoardUpdatesThreads = await firebaseDesktopHelper.getFirestoreCollection("Discussion_Board_Updates");
                        discussionBoardUpdatesThreadCount = discussionBoardUpdatesThreads.length;
                        (discussionBoardUpdatesThreads as List<dynamic>).sort((b, a) => (a["threadId"]).compareTo(b["threadId"]));
                      }
                      else{
                        discussionBoardUpdatesThreadCount = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").count().get();
                        QuerySnapshot dbuQuerySnapshot = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").get();
                        discussionBoardUpdatesThreads = dbuQuerySnapshot.docs.map((myDoc) => myDoc.data()).toList();
                        (discussionBoardUpdatesThreads as List<dynamic>).sort((b, a) => (a["threadId"]).compareTo(b["threadId"]));
                      }

                      //Going to the Discussion Board Updates subforum
                      print("Threads in discussion board updates subforum: " + discussionBoardUpdatesPage.discussionBoardUpdatesThreads.toString());
                      print("Length: ${discussionBoardUpdatesThreads.length}");
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardUpdatesPage.discussionBoardUpdatesPage())); //originally going to discussionBoardUpdatesPage
                      discussionBoardUpdatesPage.discussionBoardUpdatesBool = false;
                      //print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesThreadsList);
                      print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesThreadsIterable.toList());
                    }
                    else{
                      if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == true && technologiesPage.technologiesBool == false && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == false && feedbackAndSuggestionsPage.fasBool == false){
                        final questionsAndAnswersThreadsInfo = Get.put(questionsAndAnswersInformation());

                        Future<void> createQuestionsAndAnswersThread(QuestionsAndAnswersThreads qaat) async{
                          await questionsAndAnswersThreadsInfo.createMyQuestionsAndAnswersThread(qaat);
                        }

                        if(questionsAndAnswersThreads.length > 0){
                          if(firebaseDesktopHelper.onDesktop){
                            var threadIdResult = await firebaseDesktopHelper.getFirestoreCollection("Questions_And_Answers");
                            var threadIdFound = threadIdResult.firstWhere((myThread) => myThread["threadId"] == (threadIdResult.length - 1), orElse: () => {} as Map<String, dynamic>);
                            questionsAndAnswersThreadId = threadIdFound["threadId"] + 1;
                          }
                          else{
                            await FirebaseFirestore.instance.collection("Questions_And_Answers").orderBy("threadId", descending: true).limit(1).get().then((myId){
                              questionsAndAnswersThreadId = myId.docs.first.data()["threadId"] + 1;
                            });
                          }
                        }

                        var theNewQuestionsAndAnswersThread = QuestionsAndAnswersThreads(
                          threadId: questionsAndAnswersThreadId,
                          poster: usernameController.text,
                          threadTitle: threadNameController.text,
                          threadContent: threadContentController.text,
                        );

                        createQuestionsAndAnswersThread(theNewQuestionsAndAnswersThread);

                        if(myUsername != "" && myNewUsername == ""){
                          if(firebaseDesktopHelper.onDesktop){
                            List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                            var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                            if(theCorrectUser.isNotEmpty){
                              userData = theCorrectUser;
                              docName = theCorrectUser["docId"] ?? "N/A";

                              print("userData: ${userData}");
                              print("docName for your username: ${docName}");

                              //Updating the document:
                              try{
                                //Getting the current information about a user:
                                Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                print("theCorrectUser: ${theCorrectUser}");
                                print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                print("Full user info: ${currentInfoOfUser}");
                                print("Full user keys: ${currentInfoOfUser.keys}");

                                //Incrementing the number of posts a user has:
                                int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                //Updating the information about a user:
                                await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                  "usernameProfileInformation": currentInfoOfUser,
                                });

                                print("You have updated the number of posts for the user!");

                                //Determining if the full document still has all of the fields
                                List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                print("The full document after the update: $theVerifiedUser");
                              }
                              catch (error){
                                print("Error updating information of user: ${error}");
                                print("Stack trace: ${StackTrace.current}");
                              }
                            }
                            else{
                              print("User not found");
                            }
                          }
                          else{
                            myInfo = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                            myInfo.docs.forEach((resultExistingUsername){
                              userData = resultExistingUsername.data();
                              docName = resultExistingUsername.id;
                            });

                            print("userData: ${userData}");
                            print("docName: ${docName}");

                            FirebaseFirestore.instance.collection("User").doc(docName).update({
                              "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                            }).then((a){
                              print("You have updated the post number for the existing user!");
                            });
                          }
                        }
                        else if(myUsername == "" && myNewUsername != ""){
                          if(firebaseDesktopHelper.onDesktop){
                            List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                            var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                            if(theCorrectUser.isNotEmpty){
                              userData = theCorrectUser;
                              docName = theCorrectUser["docId"] ?? "N/A";

                              print("userData: ${userData}");
                              print("docName for your username: ${docName}");

                              //Updating the document:
                              try{
                                //Getting the current information about a user:
                                Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                print("theCorrectUser: ${theCorrectUser}");
                                print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                print("Full user info: ${currentInfoOfUser}");
                                print("Full user keys: ${currentInfoOfUser.keys}");

                                //Incrementing the number of posts a user has:
                                int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                //Updating the information about a user:
                                await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                  "usernameProfileInformation": currentInfoOfUser,
                                });

                                print("You have updated the number of posts for the user!");

                                //Determining if the full document still has all of the fields
                                List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                print("The full document after the update: $theVerifiedUser");
                              }
                              catch (error){
                                print("Error updating information of user: ${error}");
                                print("Stack trace: ${StackTrace.current}");
                              }
                            }
                            else{
                              print("User not found");
                            }
                          }
                          else{
                            myInfo = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                            myInfo.docs.forEach((resultNewUsername){
                              userData = resultNewUsername.data();
                              docName = resultNewUsername.id;
                            });

                            print("userData: ${userData}");
                            print("docName: ${docName}");

                            FirebaseFirestore.instance.collection("User").doc(docName).update({
                              "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                            }).then((a){
                              print("You have updated the post number for the new user!");
                            });
                          }
                        }

                        questionsAndAnswersPendingThreads.add(usernameController.text);
                        questionsAndAnswersPendingThreads.add(threadNameController.text);
                        questionsAndAnswersPendingThreads.add(threadContentController.text);
                        questionsAndAnswersPendingThreads.add(questionsAndAnswersPage.questionsAndAnswersThreads.length.toString());
                        questionsAndAnswersPendingThreads.add(List.empty(growable: true));
                        print(questionsAndAnswersPendingThreads);
                        questionsAndAnswersPage.questionsAndAnswersThreads.add(questionsAndAnswersPendingThreads);

                        if(firebaseDesktopHelper.onDesktop){
                          questionsAndAnswersThreads = await firebaseDesktopHelper.getFirestoreCollection("Questions_And_Answers");
                          questionsAndAnswersThreadCount = questionsAndAnswersThreads.length;
                          (questionsAndAnswersThreads as List<dynamic>).sort((b, a) => (a["threadId"]).compareTo(b["threadId"]));
                        }
                        else{
                          questionsAndAnswersThreadCount = await FirebaseFirestore.instance.collection("Questions_And_Answers").count().get();
                          QuerySnapshot qaaQuerySnapshot = await FirebaseFirestore.instance.collection("Questions_And_Answers").get();
                          questionsAndAnswersThreads = qaaQuerySnapshot.docs.map((myDoc) => myDoc.data()).toList();
                          (questionsAndAnswersThreads as List<dynamic>).sort((b, a) => (a["threadId"]).compareTo(b["threadId"]));
                        }

                        print("Threads in questions and answers subforum: " + questionsAndAnswersPage.questionsAndAnswersThreads.toString());
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const questionsAndAnswersPage.questionsAndAnswersPage()));
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => const questionsAndAnswersPage.questionsAndAnswersPage()));
                        questionsAndAnswersPage.questionsAndAnswersBool = false;
                        print(questionsAndAnswersPage.reversedQuestionsAndAnswersThreadsIterable.toList());
                      }
                      else{
                        if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == true && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == false && feedbackAndSuggestionsPage.fasBool == false){
                          final technologiesThreadsInfo = Get.put(technologiesInformation());

                          Future<void> createTechnologiesThread(TechnologiesThreads tt) async{
                            await technologiesThreadsInfo.createMyTechnologiesThread(tt);
                          }

                          if(technologiesThreads.length > 0){
                            if(firebaseDesktopHelper.onDesktop){
                              var threadIdResult = await firebaseDesktopHelper.getFirestoreCollection("Technologies");
                              var threadIdFound = threadIdResult.firstWhere((myThread) => myThread["threadId"] == (threadIdResult.length - 1), orElse: () => {} as Map<String, dynamic>);
                              technologiesThreadId = threadIdFound["threadId"] + 1;
                            }
                            else{
                              await FirebaseFirestore.instance.collection("Technologies").orderBy("threadId", descending: true).limit(1).get().then((myId){
                                technologiesThreadId = myId.docs.first.data()["threadId"] + 1;
                              });
                            }
                          }

                          var theNewTechnologiesThread = TechnologiesThreads(
                            threadId: technologiesThreadId,
                            poster: usernameController.text,
                            threadTitle: threadNameController.text,
                            threadContent: threadContentController.text,
                          );

                          createTechnologiesThread(theNewTechnologiesThread);

                          if(myUsername != "" && myNewUsername == ""){
                            if(firebaseDesktopHelper.onDesktop){
                              List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                              var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                              if(theCorrectUser.isNotEmpty){
                                userData = theCorrectUser;
                                docName = theCorrectUser["docId"] ?? "N/A";

                                print("userData: ${userData}");
                                print("docName for your username: ${docName}");

                                //Updating the document:
                                try{
                                  //Getting the current information about a user:
                                  Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                  print("theCorrectUser: ${theCorrectUser}");
                                  print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                  print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                  print("Full user info: ${currentInfoOfUser}");
                                  print("Full user keys: ${currentInfoOfUser.keys}");

                                  //Incrementing the number of posts a user has:
                                  int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                  currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                  //Updating the information about a user:
                                  await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                    "usernameProfileInformation": currentInfoOfUser,
                                  });

                                  print("You have updated the number of posts for the user!");

                                  //Determining if the full document still has all of the fields
                                  List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                  var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                  print("The full document after the update: $theVerifiedUser");
                                }
                                catch (error){
                                  print("Error updating information of user: ${error}");
                                  print("Stack trace: ${StackTrace.current}");
                                }
                              }
                              else{
                                print("User not found");
                              }
                            }
                            else{
                              myInfo = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                              myInfo.docs.forEach((resultExistingUsername){
                                userData = resultExistingUsername.data();
                                docName = resultExistingUsername.id;
                              });

                              print("userData: ${userData}");
                              print("docName: ${docName}");

                              FirebaseFirestore.instance.collection("User").doc(docName).update({
                                "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                              }).then((a){
                                print("You have updated the post number for the existing user!");
                              });
                            }
                          }
                          else if(myUsername == "" && myNewUsername != ""){
                            if(firebaseDesktopHelper.onDesktop){
                              List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                              var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                              if(theCorrectUser.isNotEmpty){
                                userData = theCorrectUser;
                                docName = theCorrectUser["docId"] ?? "N/A";

                                print("userData: ${userData}");
                                print("docName for your username: ${docName}");

                                //Updating the document:
                                try{
                                  //Getting the current information about a user:
                                  Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                  print("theCorrectUser: ${theCorrectUser}");
                                  print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                  print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                  print("Full user info: ${currentInfoOfUser}");
                                  print("Full user keys: ${currentInfoOfUser.keys}");

                                  //Incrementing the number of posts a user has:
                                  int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                  currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                  //Updating the information about a user:
                                  await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                    "usernameProfileInformation": currentInfoOfUser,
                                  });

                                  print("You have updated the number of posts for the user!");

                                  //Determining if the full document still has all of the fields
                                  List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                  var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                  print("The full document after the update: $theVerifiedUser");
                                }
                                catch (error){
                                  print("Error updating information of user: ${error}");
                                  print("Stack trace: ${StackTrace.current}");
                                }
                              }
                              else{
                                print("User not found");
                              }
                            }
                            else{
                              myInfo = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                              myInfo.docs.forEach((resultNewUsername){
                                userData = resultNewUsername.data();
                                docName = resultNewUsername.id;
                              });

                              print("userData: ${userData}");
                              print("docName: ${docName}");

                              FirebaseFirestore.instance.collection("User").doc(docName).update({
                                "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                              }).then((a){
                                print("You have updated the post number for the new user!");
                              });
                            }
                          }

                          technologiesPendingThreads.add(usernameController.text);
                          technologiesPendingThreads.add(threadNameController.text);
                          technologiesPendingThreads.add(threadContentController.text);
                          technologiesPendingThreads.add(technologiesPage.technologiesThreads.length.toString());
                          technologiesPendingThreads.add(List.empty(growable: true));
                          print(technologiesPendingThreads);
                          technologiesPage.technologiesThreads.add(technologiesPendingThreads);

                          if(firebaseDesktopHelper.onDesktop){
                            technologiesThreads = await firebaseDesktopHelper.getFirestoreCollection("Technologies");
                            technologiesThreadCount = technologiesThreads.length;
                            (technologiesThreads as List<dynamic>).sort((b, a) => (a["threadId"]).compareTo(b["threadId"]));
                          }
                          else{
                            technologiesThreadCount = await FirebaseFirestore.instance.collection("Technologies").count().get();
                            QuerySnapshot tQuerySnapshot = await FirebaseFirestore.instance.collection("Technologies").get();
                            technologiesThreads = tQuerySnapshot.docs.map((myDoc) => myDoc.data()).toList();
                            (technologiesThreads as List<dynamic>).sort((b, a) => (a["threadId"]).compareTo(b["threadId"]));
                          }

                          print("Threads in technologies subforum: " + technologiesPage.technologiesThreads.toString());
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const technologiesPage.technologiesPage()));
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => const technologiesPage.technologiesPage()));
                          technologiesPage.technologiesBool = false;
                          print(technologiesPage.reversedTechnologiesThreadsIterable.toList());
                        }
                        else{
                          if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == false && projectsPage.projectsBool == true && newDiscoveriesPage.newDiscoveriesBool == false && feedbackAndSuggestionsPage.fasBool == false){
                            final projectsThreadsInfo = Get.put(projectsInformation());

                            Future<void> createProjectsThread(ProjectsThreads pt) async{
                              await projectsThreadsInfo.createMyProjectsThread(pt);
                            }

                            if(projectsThreads.length > 0){
                              if(firebaseDesktopHelper.onDesktop){
                                var threadIdResult = await firebaseDesktopHelper.getFirestoreCollection("Projects");
                                var threadIdFound = threadIdResult.firstWhere((myThread) => myThread["threadId"] == (threadIdResult.length - 1), orElse: () => {} as Map<String, dynamic>);
                                projectsThreadId = threadIdFound["threadId"] + 1;
                              }
                              else{
                                await FirebaseFirestore.instance.collection("Projects").orderBy("threadId", descending: true).limit(1).get().then((myId){
                                  projectsThreadId = myId.docs.first.data()["threadId"] + 1;
                                });
                              }
                            }

                            var theNewProjectsThread = ProjectsThreads(
                              threadId: projectsThreadId,
                              poster: usernameController.text,
                              threadTitle: threadNameController.text,
                              threadContent: threadContentController.text,
                            );

                            createProjectsThread(theNewProjectsThread);

                            if(myUsername != "" && myNewUsername == ""){
                              if(firebaseDesktopHelper.onDesktop){
                                List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                if(theCorrectUser.isNotEmpty){
                                  userData = theCorrectUser;
                                  docName = theCorrectUser["docId"] ?? "N/A";

                                  print("userData: ${userData}");
                                  print("docName for your username: ${docName}");

                                  //Updating the document:
                                  try{
                                    //Getting the current information about a user:
                                    Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                    print("theCorrectUser: ${theCorrectUser}");
                                    print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                    print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                    print("Full user info: ${currentInfoOfUser}");
                                    print("Full user keys: ${currentInfoOfUser.keys}");

                                    //Incrementing the number of posts a user has:
                                    int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                    currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                    //Updating the information about a user:
                                    await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                      "usernameProfileInformation": currentInfoOfUser,
                                    });

                                    print("You have updated the number of posts for the user!");

                                    //Determining if the full document still has all of the fields
                                    List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                    var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                    print("The full document after the update: $theVerifiedUser");
                                  }
                                  catch (error){
                                    print("Error updating information of user: ${error}");
                                    print("Stack trace: ${StackTrace.current}");
                                  }
                                }
                                else{
                                  print("User not found");
                                }
                              }
                              else{
                                myInfo = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                myInfo.docs.forEach((resultExistingUsername){
                                  userData = resultExistingUsername.data();
                                  docName = resultExistingUsername.id;
                                });

                                print("userData: ${userData}");
                                print("docName: ${docName}");

                                FirebaseFirestore.instance.collection("User").doc(docName).update({
                                  "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                }).then((a){
                                  print("You have updated the post number for the existing user!");
                                });
                              }
                            }
                            else if(myUsername == "" && myNewUsername != ""){
                              if(firebaseDesktopHelper.onDesktop){
                                List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                if(theCorrectUser.isNotEmpty){
                                  userData = theCorrectUser;
                                  docName = theCorrectUser["docId"] ?? "N/A";

                                  print("userData: ${userData}");
                                  print("docName for your username: ${docName}");

                                  //Updating the document:
                                  try{
                                    //Getting the current information about a user:
                                    Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                    print("theCorrectUser: ${theCorrectUser}");
                                    print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                    print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                    print("Full user info: ${currentInfoOfUser}");
                                    print("Full user keys: ${currentInfoOfUser.keys}");

                                    //Incrementing the number of posts a user has:
                                    int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                    currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                    //Updating the information about a user:
                                    await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                      "usernameProfileInformation": currentInfoOfUser,
                                    });

                                    print("You have updated the number of posts for the user!");

                                    //Determining if the full document still has all of the fields
                                    List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                    var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                    print("The full document after the update: $theVerifiedUser");
                                  }
                                  catch (error){
                                    print("Error updating information of user: ${error}");
                                    print("Stack trace: ${StackTrace.current}");
                                  }
                                }
                                else{
                                  print("User not found");
                                }
                              }
                              else{
                                myInfo = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                myInfo.docs.forEach((resultNewUsername){
                                  userData = resultNewUsername.data();
                                  docName = resultNewUsername.id;
                                });

                                print("userData: ${userData}");
                                print("docName: ${docName}");

                                FirebaseFirestore.instance.collection("User").doc(docName).update({
                                  "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                }).then((a){
                                  print("You have updated the post number for the new user!");
                                });
                              }
                            }

                            projectsPendingThreads.add(usernameController.text);
                            projectsPendingThreads.add(threadNameController.text);
                            projectsPendingThreads.add(threadContentController.text);
                            projectsPendingThreads.add(projectsPage.projectsThreads.length.toString());
                            projectsPendingThreads.add(List.empty(growable: true));
                            print(projectsPendingThreads);
                            projectsPage.projectsThreads.add(projectsPendingThreads);

                            if(firebaseDesktopHelper.onDesktop){
                              projectsThreads = await firebaseDesktopHelper.getFirestoreCollection("Projects");
                              projectsThreadCount = discussionBoardUpdatesThreads.length;
                              (projectsThreads as List<dynamic>).sort((b, a) => (a["threadId"]).compareTo(b["threadId"]));
                            }
                            else{
                              projectsThreadCount = await FirebaseFirestore.instance.collection("Projects").count().get();
                              QuerySnapshot pQuerySnapshot = await FirebaseFirestore.instance.collection("Projects").get();
                              projectsThreads = pQuerySnapshot.docs.map((myDoc) => myDoc.data()).toList();
                              (projectsThreads as List<dynamic>).sort((b, a) => (a["threadId"]).compareTo(b["threadId"]));
                            }

                            print("Threads in projects subforum: " + projectsPage.projectsThreads.toString());
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const projectsPage.projectsPage()));
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => const projectsPage.projectsPage()));
                            projectsPage.projectsBool = false;
                            print(projectsPage.reversedProjectsThreadsIterable.toList());
                          }
                          else{
                            if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == false && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == true && feedbackAndSuggestionsPage.fasBool == false){
                              final newDiscoveriesThreadsInfo = Get.put(newDiscoveriesInformation());

                              Future<void> createNewDiscoveriesThread(NewDiscoveriesThreads ndt) async{
                                await newDiscoveriesThreadsInfo.createMyNewDiscoveriesThread(ndt);
                              }

                              if(newDiscoveriesThreads.length > 0){
                                if(firebaseDesktopHelper.onDesktop){
                                  var threadIdResult = await firebaseDesktopHelper.getFirestoreCollection("New_Discoveries");
                                  var threadIdFound = threadIdResult.firstWhere((myThread) => myThread["threadId"] == (threadIdResult.length - 1), orElse: () => {} as Map<String, dynamic>);
                                  newDiscoveriesThreadId = threadIdFound["threadId"] + 1;
                                }
                                else{
                                  await FirebaseFirestore.instance.collection("New_Discoveries").orderBy("threadId", descending: true).limit(1).get().then((myId){
                                    newDiscoveriesThreadId = myId.docs.first.data()["threadId"] + 1;
                                  });
                                }
                              }

                              var theNewNewDiscoveriesThread = NewDiscoveriesThreads(
                                threadId: newDiscoveriesThreadId,
                                poster: usernameController.text,
                                threadTitle: threadNameController.text,
                                threadContent: threadContentController.text,
                              );

                              createNewDiscoveriesThread(theNewNewDiscoveriesThread);

                              if(myUsername != "" && myNewUsername == ""){
                                if(firebaseDesktopHelper.onDesktop){
                                  List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                  var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                  if(theCorrectUser.isNotEmpty){
                                    userData = theCorrectUser;
                                    docName = theCorrectUser["docId"] ?? "N/A";

                                    print("userData: ${userData}");
                                    print("docName for your username: ${docName}");

                                    //Updating the document:
                                    try{
                                      //Getting the current information about a user:
                                      Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                      print("theCorrectUser: ${theCorrectUser}");
                                      print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                      print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                      print("Full user info: ${currentInfoOfUser}");
                                      print("Full user keys: ${currentInfoOfUser.keys}");

                                      //Incrementing the number of posts a user has:
                                      int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                      currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                      //Updating the information about a user:
                                      await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                        "usernameProfileInformation": currentInfoOfUser,
                                      });

                                      print("You have updated the number of posts for the user!");

                                      //Determining if the full document still has all of the fields
                                      List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                      var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                      print("The full document after the update: $theVerifiedUser");
                                    }
                                    catch (error){
                                      print("Error updating information of user: ${error}");
                                      print("Stack trace: ${StackTrace.current}");
                                    }
                                  }
                                  else{
                                    print("User not found");
                                  }
                                }
                                else{
                                  myInfo = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                  myInfo.docs.forEach((resultExistingUsername){
                                    userData = resultExistingUsername.data();
                                    docName = resultExistingUsername.id;
                                  });

                                  print("userData: ${userData}");
                                  print("docName: ${docName}");

                                  FirebaseFirestore.instance.collection("User").doc(docName).update({
                                    "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                  }).then((a){
                                    print("You have updated the post number for the existing user!");
                                  });
                                }
                              }
                              else if(myUsername == "" && myNewUsername != ""){
                                if(firebaseDesktopHelper.onDesktop){
                                  List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                  var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                  if(theCorrectUser.isNotEmpty){
                                    userData = theCorrectUser;
                                    docName = theCorrectUser["docId"] ?? "N/A";

                                    print("userData: ${userData}");
                                    print("docName for your username: ${docName}");

                                    //Updating the document:
                                    try{
                                      //Getting the current information about a user:
                                      Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                      print("theCorrectUser: ${theCorrectUser}");
                                      print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                      print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                      print("Full user info: ${currentInfoOfUser}");
                                      print("Full user keys: ${currentInfoOfUser.keys}");

                                      //Incrementing the number of posts a user has:
                                      int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                      currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                      //Updating the information about a user:
                                      await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                        "usernameProfileInformation": currentInfoOfUser,
                                      });

                                      print("You have updated the number of posts for the user!");

                                      //Determining if the full document still has all of the fields
                                      List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                      var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                      print("The full document after the update: $theVerifiedUser");
                                    }
                                    catch (error){
                                      print("Error updating information of user: ${error}");
                                      print("Stack trace: ${StackTrace.current}");
                                    }
                                  }
                                  else{
                                    print("User not found");
                                  }
                                }
                                else{
                                  myInfo = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                  myInfo.docs.forEach((resultNewUsername){
                                    userData = resultNewUsername.data();
                                    docName = resultNewUsername.id;
                                  });

                                  print("userData: ${userData}");
                                  print("docName: ${docName}");

                                  FirebaseFirestore.instance.collection("User").doc(docName).update({
                                    "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                  }).then((a){
                                    print("You have updated the post number for the new user!");
                                  });
                                }
                              }

                              newDiscoveriesPendingThreads.add(usernameController.text);
                              newDiscoveriesPendingThreads.add(threadNameController.text);
                              newDiscoveriesPendingThreads.add(threadContentController.text);
                              newDiscoveriesPendingThreads.add(newDiscoveriesPage.newDiscoveriesThreads.length.toString());
                              newDiscoveriesPendingThreads.add(List.empty(growable: true));
                              print(newDiscoveriesPendingThreads);
                              newDiscoveriesPage.newDiscoveriesThreads.add(newDiscoveriesPendingThreads);

                              //Making sure new thread gets added to the New Discoveries subforum
                              if(firebaseDesktopHelper.onDesktop){
                                newDiscoveriesThreads = await firebaseDesktopHelper.getFirestoreCollection("New_Discoveries");
                                newDiscoveriesThreadCount = newDiscoveriesThreads.length;
                                (newDiscoveriesThreads as List<dynamic>).sort((b, a) => (a["threadId"]).compareTo(b["threadId"]));
                              }
                              else{
                                newDiscoveriesThreadCount = await FirebaseFirestore.instance.collection("New_Discoveries").count().get();
                                QuerySnapshot ndQuerySnapshot = await FirebaseFirestore.instance.collection("New_Discoveries").get();
                                newDiscoveriesThreads = ndQuerySnapshot.docs.map((myDoc) => myDoc.data()).toList();
                                (newDiscoveriesThreads as List<dynamic>).sort((b, a) => (a["threadId"]).compareTo(b["threadId"]));
                              }

                              print("Threads in new discoveries subforum: " + newDiscoveriesPage.newDiscoveriesThreads.toString());
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const newDiscoveriesPage.newDiscoveriesPage()));
                              //Navigator.push(context, MaterialPageRoute(builder: (context) => const newDiscoveriesPage.newDiscoveriesPage()));
                              newDiscoveriesPage.newDiscoveriesBool = false;
                              print(newDiscoveriesPage.reversedNewDiscoveriesThreadsIterable.toList());
                            }
                            else{
                              if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == false && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == false && feedbackAndSuggestionsPage.fasBool == true){
                                final feedbackAndSuggestionsThreadsInfo = Get.put(feedbackAndSuggestionsInformation());

                                Future<void> createFeedbackAndSuggestionsThread(FeedbackAndSuggestionsThreads fast) async{
                                  await feedbackAndSuggestionsThreadsInfo.createMyFeedbackAndSuggestionsThread(fast);
                                }

                                if(feedbackAndSuggestionsThreads.length > 0){
                                  if(firebaseDesktopHelper.onDesktop){
                                    var threadIdResult = await firebaseDesktopHelper.getFirestoreCollection("Feedback_And_Suggestions");
                                    var threadIdFound = threadIdResult.firstWhere((myThread) => myThread["threadId"] == (threadIdResult.length - 1), orElse: () => {} as Map<String, dynamic>);
                                    feedbackAndSuggestionsThreadId = threadIdFound["threadId"] + 1;
                                  }
                                  else{
                                    await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").orderBy("threadId", descending: true).limit(1).get().then((myId){
                                      feedbackAndSuggestionsThreadId = myId.docs.first.data()["threadId"] + 1;
                                    });
                                  }
                                }

                                var theNewFeedbackAndSuggestionsThread = FeedbackAndSuggestionsThreads(
                                  threadId: feedbackAndSuggestionsThreadId,
                                  poster: usernameController.text,
                                  threadTitle: threadNameController.text,
                                  threadContent: threadContentController.text,
                                );

                                createFeedbackAndSuggestionsThread(theNewFeedbackAndSuggestionsThread);

                                //Sentry feedback:
                                /*if(!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
                                  SentryId mySentryId = SentryId
                                      .empty(); //Sentry.captureMessage(threadNameController.text);

                                  await Sentry.init((myOptions) {
                                    myOptions.dsn = dotenv.env["OPTIONS_DSN"];
                                    myOptions.beforeSend = (event, hint) async {
                                      mySentryId = event.eventId;
                                      return event;
                                    };
                                  });

                                  var theUsersFeedback = SentryFeedback(
                                    associatedEventId: mySentryId,
                                    name: usernameController.text,
                                    message: "${threadNameController
                                        .text}\n${threadContentController
                                        .text}",
                                  );

                                  Sentry.captureFeedback(theUsersFeedback);
                                }*/

                                /*BetterFeedback.of(context).showAndUploadToSentry(
                                      name: usernameController.text,
                                    );*/

                                if(myUsername != "" && myNewUsername == ""){
                                  if(firebaseDesktopHelper.onDesktop){
                                    List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                    var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                    if(theCorrectUser.isNotEmpty){
                                      userData = theCorrectUser;
                                      docName = theCorrectUser["docId"] ?? "N/A";

                                      print("userData: ${userData}");
                                      print("docName for your username: ${docName}");

                                      //Updating the document:
                                      try{
                                        //Getting the current information about a user:
                                        Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                        print("theCorrectUser: ${theCorrectUser}");
                                        print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                        print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                        print("Full user info: ${currentInfoOfUser}");
                                        print("Full user keys: ${currentInfoOfUser.keys}");

                                        //Incrementing the number of posts a user has:
                                        int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                        currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                        //Updating the information about a user:
                                        await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                          "usernameProfileInformation": currentInfoOfUser,
                                        });

                                        print("You have updated the number of posts for the user!");

                                        //Determining if the full document still has all of the fields
                                        List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                        var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                        print("The full document after the update: $theVerifiedUser");
                                      }
                                      catch (error){
                                        print("Error updating information of user: ${error}");
                                        print("Stack trace: ${StackTrace.current}");
                                      }
                                    }
                                    else{
                                      print("User not found");
                                    }
                                  }
                                  else{
                                    myInfo = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                    myInfo.docs.forEach((resultExistingUsername){
                                      userData = resultExistingUsername.data();
                                      docName = resultExistingUsername.id;
                                    });

                                    print("userData: ${userData}");
                                    print("docName: ${docName}");

                                    FirebaseFirestore.instance.collection("User").doc(docName).update({
                                      "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                    }).then((a){
                                      print("You have updated the post number for the existing user!");
                                    });
                                  }
                                }
                                else if(myUsername == "" && myNewUsername != ""){
                                  if(firebaseDesktopHelper.onDesktop){
                                    List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                    var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                    if(theCorrectUser.isNotEmpty){
                                      userData = theCorrectUser;
                                      docName = theCorrectUser["docId"] ?? "N/A";

                                      print("userData: ${userData}");
                                      print("docName for your username: ${docName}");

                                      //Updating the document:
                                      try{
                                        //Getting the current information about a user:
                                        Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                        print("theCorrectUser: ${theCorrectUser}");
                                        print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                        print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                        print("Full user info: ${currentInfoOfUser}");
                                        print("Full user keys: ${currentInfoOfUser.keys}");

                                        //Incrementing the number of posts a user has:
                                        int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                        currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                        //Updating the information about a user:
                                        await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                          "usernameProfileInformation": currentInfoOfUser,
                                        });

                                        print("You have updated the number of posts for the user!");

                                        //Determining if the full document still has all of the fields
                                        List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                        var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                        print("The full document after the update: $theVerifiedUser");
                                      }
                                      catch (error){
                                        print("Error updating information of user: ${error}");
                                        print("Stack trace: ${StackTrace.current}");
                                      }
                                    }
                                    else{
                                      print("User not found");
                                    }
                                  }
                                  else{
                                    myInfo = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                    myInfo.docs.forEach((resultNewUsername){
                                      userData = resultNewUsername.data();
                                      docName = resultNewUsername.id;
                                    });

                                    print("userData: ${userData}");
                                    print("docName: ${docName}");

                                    FirebaseFirestore.instance.collection("User").doc(docName).update({
                                      "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                    }).then((a){
                                      print("You have updated the post number for the new user!");
                                    });
                                  }
                                }

                                feedbackAndSuggestionsPendingThreads.add(usernameController.text);
                                feedbackAndSuggestionsPendingThreads.add(threadNameController.text);
                                feedbackAndSuggestionsPendingThreads.add(threadContentController.text);
                                feedbackAndSuggestionsPendingThreads.add(feedbackAndSuggestionsPage.fasThreads.length.toString());
                                feedbackAndSuggestionsPendingThreads.add(List.empty(growable: true));
                                print(feedbackAndSuggestionsPendingThreads);
                                feedbackAndSuggestionsPage.fasThreads.add(feedbackAndSuggestionsPendingThreads);

                                if(firebaseDesktopHelper.onDesktop){
                                  feedbackAndSuggestionsThreads = await firebaseDesktopHelper.getFirestoreCollection("Feedback_And_Suggestions");
                                  feedbackAndSuggestionsThreadCount = feedbackAndSuggestionsThreads.length;
                                  (feedbackAndSuggestionsThreads as List<dynamic>).sort((b, a) => (a["threadId"]).compareTo(b["threadId"]));
                                }
                                else{
                                  feedbackAndSuggestionsThreadCount = await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").count().get();
                                  QuerySnapshot fasQuerySnapshot = await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").get();
                                  feedbackAndSuggestionsThreads = fasQuerySnapshot.docs.map((myDoc) => myDoc.data()).toList();
                                  (feedbackAndSuggestionsThreads as List<dynamic>).sort((b, a) => (a["threadId"]).compareTo(b["threadId"]));
                                }

                                print("Threads in feedback and suggestions subforum: " + feedbackAndSuggestionsPage.fasThreads.toString());
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const feedbackAndSuggestionsPage.feedbackAndSuggestionsPage()));

                                feedbackAndSuggestionsPage.fasBool = false;
                                print(feedbackAndSuggestionsPage.reversedFasThreadsIterable.toList());
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                  else{
                    threadInfo.add(usernameController.text);
                    threadInfo.add(threadNameController.text);
                    threadInfo.add(threadContentController.text);

                    messageCreateThread = createThreadDialogMessage(threadInfo);

                    showDialog(
                        context: context,
                        builder: (BuildContext theContext){
                          return AlertDialog(
                            title: const Text("Unable to post thread"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(messageCreateThread.length, (i){
                                return messageCreateThread[i];
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}