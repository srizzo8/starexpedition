import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
  int discussionBoardUpdatesThreadId = 0;
  int questionsAndAnswersThreadId = 0;
  int technologiesThreadId = 0;
  int projectsThreadId = 0;
  int newDiscoveriesThreadId = 0;
  var discussionBoardUpdatesPendingThreads = [];
  var questionsAndAnswersPendingThreads = [];
  var technologiesPendingThreads = [];
  var projectsPendingThreads = [];
  var newDiscoveriesPendingThreads = [];

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
              child: Text("Making a thread", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0), textAlign: TextAlign.center),
              width: 480,
              alignment: Alignment.center,
            ),
            Padding(
                padding: EdgeInsets.all(20.0),
                child: theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""?
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
            InkWell(
              child: Ink(
                color: Colors.black,
                height: 30,
                width: 140,
                child: Container(
                  alignment: Alignment.center,
                  //margin: EdgeInsets.only(left: 200.0),
                  child: Text("Post to Subforum", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                ),
              ),
              onTap: () async{

                //print('Posting the thread');
                print(discussionBoardUpdatesPage.discussionBoardUpdatesBool);
                if(theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""){
                  usernameController.text = theLoginPage.myUsername;
                }
                else if(theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != ""){
                  usernameController.text = theRegisterPage.myNewUsername;
                }
                if(usernameController.text != "" && threadNameController.text != "" && threadContentController.text != ""){
                  //print(usernameController.text);
                  if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == true && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == false && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == false) {
                    final discussionBoardUpdatesThreadsInfo = Get.put(discussionBoardUpdatesInformation());

                    Future<void> createDiscussionBoardUpdatesThread(DiscussionBoardUpdatesThreads dbut) async{
                      await discussionBoardUpdatesThreadsInfo.createMyDiscussionBoardUpdatesThread(dbut);
                    }

                    //discussionBoardUpdatesThreadId++;
                    if(discussionBoardUpdatesThreads.length > 0){
                      await FirebaseFirestore.instance.collection("Discussion_Board_Updates").orderBy("threadId", descending: true).limit(1).get().then((myId){
                        discussionBoardUpdatesThreadId = myId.docs.first.data()["threadId"] + 1;
                      });
                    }
                    //Map<String, List<String>> dbuReplies = new Map<String, List<String>>();

                    var theNewDiscussionBoardUpdatesThread = DiscussionBoardUpdatesThreads(
                      threadId: discussionBoardUpdatesThreadId,
                      poster: usernameController.text,
                      threadTitle: threadNameController.text,
                      threadContent: threadContentController.text,
                    );

                    createDiscussionBoardUpdatesThread(theNewDiscussionBoardUpdatesThread);

                    print('You are ready to post this thread');
                    discussionBoardUpdatesPendingThreads.add(usernameController.text);
                    discussionBoardUpdatesPendingThreads.add(threadNameController.text);
                    discussionBoardUpdatesPendingThreads.add(threadContentController.text);
                    discussionBoardUpdatesPendingThreads.add((discussionBoardUpdatesPage.discussionBoardUpdatesThreads.length).toString());
                    discussionBoardUpdatesPendingThreads.add(List.empty(growable: true));
                    print(discussionBoardUpdatesPendingThreads);
                    discussionBoardUpdatesPage.discussionBoardUpdatesThreads.add(discussionBoardUpdatesPendingThreads);
                    print("Threads in discussion board updates subforum: " + discussionBoardUpdatesPage.discussionBoardUpdatesThreads.toString());
                    print("Length: ${discussionBoardUpdatesThreads.length}");
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardPage())); //originally going to discussionBoardUpdatesPage
                    discussionBoardUpdatesPage.discussionBoardUpdatesBool = false;
                    //print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesThreadsList);
                    print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesThreadsIterable.toList());
                  }
                  else{
                    if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == true && technologiesPage.technologiesBool == false && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == false){
                      final questionsAndAnswersThreadsInfo = Get.put(questionsAndAnswersInformation());

                      Future<void> createQuestionsAndAnswersThread(QuestionsAndAnswersThreads qaat) async{
                        await questionsAndAnswersThreadsInfo.createMyQuestionsAndAnswersThread(qaat);
                      }

                      if(questionsAndAnswersThreads.length > 0){
                        await FirebaseFirestore.instance.collection("Questions_And_Answers").orderBy("threadId", descending: true).limit(1).get().then((myId){
                          questionsAndAnswersThreadId = myId.docs.first.data()["threadId"] + 1;
                        });
                      }

                      var theNewQuestionsAndAnswersThread = QuestionsAndAnswersThreads(
                        threadId: questionsAndAnswersThreadId,
                        poster: usernameController.text,
                        threadTitle: threadNameController.text,
                        threadContent: threadContentController.text,
                      );

                      createQuestionsAndAnswersThread(theNewQuestionsAndAnswersThread);

                      questionsAndAnswersPendingThreads.add(usernameController.text);
                      questionsAndAnswersPendingThreads.add(threadNameController.text);
                      questionsAndAnswersPendingThreads.add(threadContentController.text);
                      questionsAndAnswersPendingThreads.add(questionsAndAnswersPage.questionsAndAnswersThreads.length.toString());
                      questionsAndAnswersPendingThreads.add(List.empty(growable: true));
                      print(questionsAndAnswersPendingThreads);
                      questionsAndAnswersPage.questionsAndAnswersThreads.add(questionsAndAnswersPendingThreads);
                      print("Threads in questions and answers subforum: " + questionsAndAnswersPage.questionsAndAnswersThreads.toString());
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardPage()));
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => const questionsAndAnswersPage.questionsAndAnswersPage()));
                      questionsAndAnswersPage.questionsAndAnswersBool = false;
                      print(questionsAndAnswersPage.reversedQuestionsAndAnswersThreadsIterable.toList());
                    }
                    else{
                      if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == true && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == false){
                        final technologiesThreadsInfo = Get.put(technologiesInformation());

                        Future<void> createTechnologiesThread(TechnologiesThreads tt) async{
                          await technologiesThreadsInfo.createMyTechnologiesThread(tt);
                        }

                        if(technologiesThreads.length > 0){
                          await FirebaseFirestore.instance.collection("Technologies").orderBy("threadId", descending: true).limit(1).get().then((myId){
                            technologiesThreadId = myId.docs.first.data()["threadId"] + 1;
                          });
                        }

                        var theNewTechnologiesThread = TechnologiesThreads(
                          threadId: technologiesThreadId,
                          poster: usernameController.text,
                          threadTitle: threadNameController.text,
                          threadContent: threadContentController.text,
                        );

                        createTechnologiesThread(theNewTechnologiesThread);

                        technologiesPendingThreads.add(usernameController.text);
                        technologiesPendingThreads.add(threadNameController.text);
                        technologiesPendingThreads.add(threadContentController.text);
                        technologiesPendingThreads.add(technologiesPage.technologiesThreads.length.toString());
                        technologiesPendingThreads.add(List.empty(growable: true));
                        print(technologiesPendingThreads);
                        technologiesPage.technologiesThreads.add(technologiesPendingThreads);
                        print("Threads in technologies subforum: " + technologiesPage.technologiesThreads.toString());
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardPage()));
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => const technologiesPage.technologiesPage()));
                        technologiesPage.technologiesBool = false;
                        print(technologiesPage.reversedTechnologiesThreadsIterable.toList());
                      }
                      else{
                        if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == false && projectsPage.projectsBool == true && newDiscoveriesPage.newDiscoveriesBool == false){
                          final projectsThreadsInfo = Get.put(projectsInformation());

                          Future<void> createProjectsThread(ProjectsThreads pt) async{
                            await projectsThreadsInfo.createMyProjectsThread(pt);
                          }

                          if(projectsThreads.length > 0){
                            await FirebaseFirestore.instance.collection("Projects").orderBy("threadId", descending: true).limit(1).get().then((myId){
                              projectsThreadId = myId.docs.first.data()["threadId"] + 1;
                            });
                          }

                          var theNewProjectsThread = ProjectsThreads(
                            threadId: projectsThreadId,
                            poster: usernameController.text,
                            threadTitle: threadNameController.text,
                            threadContent: threadContentController.text,
                          );

                          createProjectsThread(theNewProjectsThread);

                          projectsPendingThreads.add(usernameController.text);
                          projectsPendingThreads.add(threadNameController.text);
                          projectsPendingThreads.add(threadContentController.text);
                          projectsPendingThreads.add(projectsPage.projectsThreads.length.toString());
                          projectsPendingThreads.add(List.empty(growable: true));
                          print(projectsPendingThreads);
                          projectsPage.projectsThreads.add(projectsPendingThreads);
                          print("Threads in questions and answers subforum: " + projectsPage.projectsThreads.toString());
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardPage()));
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => const projectsPage.projectsPage()));
                          projectsPage.projectsBool = false;
                          print(projectsPage.reversedProjectsThreadsIterable.toList());
                        }
                        else{
                          if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == false && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == true){
                            final newDiscoveriesThreadsInfo = Get.put(newDiscoveriesInformation());

                            Future<void> createNewDiscoveriesThread(NewDiscoveriesThreads ndt) async{
                              await newDiscoveriesThreadsInfo.createMyNewDiscoveriesThread(ndt);
                            }

                            if(newDiscoveriesThreads.length > 0){
                              await FirebaseFirestore.instance.collection("New_Discoveries").orderBy("threadId", descending: true).limit(1).get().then((myId){
                                newDiscoveriesThreadId = myId.docs.first.data()["threadId"] + 1;
                              });
                            }

                            var theNewNewDiscoveriesThread = NewDiscoveriesThreads(
                              threadId: newDiscoveriesThreadId,
                              poster: usernameController.text,
                              threadTitle: threadNameController.text,
                              threadContent: threadContentController.text,
                            );

                            createNewDiscoveriesThread(theNewNewDiscoveriesThread);

                            newDiscoveriesPendingThreads.add(usernameController.text);
                            newDiscoveriesPendingThreads.add(threadNameController.text);
                            newDiscoveriesPendingThreads.add(threadContentController.text);
                            newDiscoveriesPendingThreads.add(newDiscoveriesPage.newDiscoveriesThreads.length.toString());
                            newDiscoveriesPendingThreads.add(List.empty(growable: true));
                            print(newDiscoveriesPendingThreads);
                            newDiscoveriesPage.newDiscoveriesThreads.add(newDiscoveriesPendingThreads);
                            print("Threads in discussion board updates subforum: " + newDiscoveriesPage.newDiscoveriesThreads.toString());
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardPage()));
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => const newDiscoveriesPage.newDiscoveriesPage()));
                            newDiscoveriesPage.newDiscoveriesBool = false;
                            print(newDiscoveriesPage.reversedNewDiscoveriesThreadsIterable.toList());
                          }
                        }
                      }
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