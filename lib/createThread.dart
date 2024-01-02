import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'discussionBoardUpdatesPage.dart' as discussionBoardUpdatesPage;
import 'questionsAndAnswersPage.dart' as questionsAndAnswersPage;
import 'technologiesPage.dart' as technologiesPage;
import 'projectsPage.dart' as projectsPage;
import 'newDiscoveriesPage.dart' as newDiscoveriesPage;
import 'package:starexpedition4/loginPage.dart' as theLoginPage;
import 'main.dart' as myMain;
import 'package:starexpedition4/registerPage.dart' as theRegisterPage;

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
  var discussionBoardUpdatesPendingThreads = [];
  var questionsAndAnswersPendingThreads = [];
  var technologiesPendingThreads = [];
  var projectsPendingThreads = [];
  var newDiscoveriesPendingThreads = [];

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
                if(theLoginPage.myUsername != "" && theRegisterPage.myNewUsername == ""){
                  usernameController.text = theLoginPage.myUsername;
                }
                else if(theLoginPage.myUsername == "" && theRegisterPage.myNewUsername != ""){
                  usernameController.text = theRegisterPage.myNewUsername;
                }
                if(usernameController.text != "" && threadNameController.text != "" && threadContentController.text != ""){
                  //print(usernameController.text);
                  if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == true && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == false && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == false) {
                    print('You are ready to post this thread');
                    discussionBoardUpdatesPendingThreads.add(usernameController.text);
                    discussionBoardUpdatesPendingThreads.add(threadNameController.text);
                    discussionBoardUpdatesPendingThreads.add(threadContentController.text);
                    discussionBoardUpdatesPendingThreads.add(discussionBoardUpdatesPage.discussionBoardUpdatesThreads.length.toString());
                    discussionBoardUpdatesPendingThreads.add(List.empty(growable: true));
                    print(discussionBoardUpdatesPendingThreads);
                    discussionBoardUpdatesPage.discussionBoardUpdatesThreads.add(discussionBoardUpdatesPendingThreads);
                    print("Threads in discussion board updates subforum: " + discussionBoardUpdatesPage.discussionBoardUpdatesThreads.toString());
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardUpdatesPage.discussionBoardUpdatesPage()));
                    discussionBoardUpdatesPage.discussionBoardUpdatesBool = false;
                    //print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesThreadsList);
                    print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesThreadsIterable.toList());
                  }
                  else{
                    if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == true && technologiesPage.technologiesBool == false && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == false){
                      questionsAndAnswersPendingThreads.add(usernameController.text);
                      questionsAndAnswersPendingThreads.add(threadNameController.text);
                      questionsAndAnswersPendingThreads.add(threadContentController.text);
                      questionsAndAnswersPendingThreads.add(questionsAndAnswersPage.questionsAndAnswersThreads.length.toString());
                      questionsAndAnswersPendingThreads.add(List.empty(growable: true));
                      print(questionsAndAnswersPendingThreads);
                      questionsAndAnswersPage.questionsAndAnswersThreads.add(questionsAndAnswersPendingThreads);
                      print("Threads in questions and answers subforum: " + questionsAndAnswersPage.questionsAndAnswersThreads.toString());
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const questionsAndAnswersPage.questionsAndAnswersPage()));
                      questionsAndAnswersPage.questionsAndAnswersBool = false;
                      print(questionsAndAnswersPage.reversedQuestionsAndAnswersThreadsIterable.toList());
                    }
                    else{
                      if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == true && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == false){
                        technologiesPendingThreads.add(usernameController.text);
                        technologiesPendingThreads.add(threadNameController.text);
                        technologiesPendingThreads.add(threadContentController.text);
                        technologiesPendingThreads.add(technologiesPage.technologiesThreads.length.toString());
                        technologiesPendingThreads.add(List.empty(growable: true));
                        print(technologiesPendingThreads);
                        technologiesPage.technologiesThreads.add(technologiesPendingThreads);
                        print("Threads in technologies subforum: " + technologiesPage.technologiesThreads.toString());
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const technologiesPage.technologiesPage()));
                        technologiesPage.technologiesBool = false;
                        print(technologiesPage.reversedTechnologiesThreadsIterable.toList());
                      }
                      else{
                        if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == false && projectsPage.projectsBool == true && newDiscoveriesPage.newDiscoveriesBool == false){
                          projectsPendingThreads.add(usernameController.text);
                          projectsPendingThreads.add(threadNameController.text);
                          projectsPendingThreads.add(threadContentController.text);
                          projectsPendingThreads.add(projectsPage.projectsThreads.length.toString());
                          projectsPendingThreads.add(List.empty(growable: true));
                          print(projectsPendingThreads);
                          projectsPage.projectsThreads.add(projectsPendingThreads);
                          print("Threads in questions and answers subforum: " + projectsPage.projectsThreads.toString());
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const projectsPage.projectsPage()));
                          projectsPage.projectsBool = false;
                          print(projectsPage.reversedProjectsThreadsIterable.toList());
                        }
                        else{
                          if(discussionBoardUpdatesPage.discussionBoardUpdatesBool == false && questionsAndAnswersPage.questionsAndAnswersBool == false && technologiesPage.technologiesBool == false && projectsPage.projectsBool == false && newDiscoveriesPage.newDiscoveriesBool == true){
                            /*newDiscoveriesPendingThreads.add(usernameController.text);
                            newDiscoveriesPendingThreads.add(threadNameController.text);
                            newDiscoveriesPendingThreads.add(threadContentController.text);
                            newDiscoveriesPage.newDiscoveriesThreads.add(newDiscoveriesPendingThreads);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const newDiscoveriesPage.newDiscoveriesPage()));
                            newDiscoveriesPage.newDiscoveriesBool = false;*/
                            print('You are ready to post this thread');
                            newDiscoveriesPendingThreads.add(usernameController.text);
                            newDiscoveriesPendingThreads.add(threadNameController.text);
                            newDiscoveriesPendingThreads.add(threadContentController.text);
                            newDiscoveriesPendingThreads.add(newDiscoveriesPage.newDiscoveriesThreads.length.toString());
                            newDiscoveriesPendingThreads.add(List.empty(growable: true));
                            print(newDiscoveriesPendingThreads);
                            newDiscoveriesPage.newDiscoveriesThreads.add(newDiscoveriesPendingThreads);
                            print("Threads in discussion board updates subforum: " + newDiscoveriesPage.newDiscoveriesThreads.toString());
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const newDiscoveriesPage.newDiscoveriesPage()));
                            newDiscoveriesPage.newDiscoveriesBool = false;
                            //print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesThreadsList);
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