import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:backendless_sdk/backendless_sdk.dart';
import 'discussionBoardUpdatesPage.dart' as discussionBoardUpdatesPage;
import 'main.dart';
import 'questionsAndAnswersPage.dart' as questionsAndAnswersPage;
import 'technologiesPage.dart' as technologiesPage;
import 'projectsPage.dart' as projectsPage;
import 'newDiscoveriesPage.dart' as newDiscoveriesPage;

import 'main.dart' as myMain;
import 'discussionBoardPage.dart' as theDiscussionBoardPage;

String myNewUsername = "";
bool registerBool = false;
bool clickedRegisterButton = false;

class registerPage extends StatefulWidget{
  const registerPage ({Key? key}) : super(key: key);

  @override
  registerPageState createState() => registerPageState();
}

class MyRegisterPage extends StatelessWidget{
  const MyRegisterPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext buildC){
    return MaterialApp(
      title: "Registration Page", //Page for registering
    );
  }
}

class registerPageRoutes{
  static String homePage = myMain.theStarExpeditionState.nameOfRoute;
  static String discussionBoard = theDiscussionBoardPage.discussionBoardPageState.nameOfRoute;
}

/*
void registrationErrorsDialog(){
  showDialog(
    context: ,

  );
}*/

class registerPageState extends State<registerPage>{
  List userEmailPasswordList = [];
  static String nameOfRoute = '/registerPage';
  TextEditingController theUsername = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Widget build(BuildContext buildContext){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Wrap(
        children: <Widget>[
          Center(
            child: Container(
              padding: const EdgeInsets.all(0.0),
              alignment: Alignment.centerLeft,
              child: Text("Username", style: TextStyle(fontSize: 14.0)),
              height: 20,
              width: 380,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: theUsername,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(0.0),
              alignment: Alignment.centerLeft,
              child: Text("E-mail address", style: TextStyle(fontSize: 14.0)),
              height: 20,
              width: 380,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: email,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(0.0),
              alignment: Alignment.centerLeft,
              child: Text("Password", style: TextStyle(fontSize: 14.0)),
              height: 20,
              width: 380,
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            child: TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          GestureDetector(
            child: Center(
              child: Container(
                color: Colors.tealAccent,
                child: Text("Sign Up for Star Expedition", style: TextStyle(fontSize: 14.0)),
              ),
            ),
            onTap: () async{
              if(theUsername.text != "" && email.text != "" && password.text != ""){
                if(myMain.discussionBoardLogin == true){
                  myNewUsername = theUsername.text;
                  Navigator.pushReplacementNamed(context, registerPageRoutes.discussionBoard);
                  userEmailPasswordList.add([theUsername.text, email.text, password.text]);
                  myMain.Users dasUser = new Users(username: theUsername.text, email: email.text, password: password.text);
                  myMain.theUsers!.add(dasUser);
                  print(myMain.theUsers);
                  myMain.discussionBoardLogin = false;
                  registerBool = true;
                  print("Registering successfully as: " + userEmailPasswordList.toString());
                }
                else{
                  myNewUsername = theUsername.text;
                  Navigator.pushReplacementNamed(context, registerPageRoutes.homePage);
                  userEmailPasswordList.add([theUsername.text, email.text, password.text]);
                  myMain.Users dasUser = new Users(username: theUsername.text, email: email.text, password: password.text);
                  myMain.theUsers!.add(dasUser);
                  print(myMain.theUsers);
                  myMain.discussionBoardLogin = false;
                  registerBool = true;
                  print("Registering successfully as: " + userEmailPasswordList.toString());
                }
              }
              else{
                showDialog(
                  context: context,
                  builder: (myContent) => AlertDialog(
                    title: const Text("Registration unsuccessful"),
                    content: theUsername.text == "" && email.text != "" && password.text != ""?
                        Text("Username empty") :
                        theUsername.text != "" && email.text == "" && password.text != ""?
                          Text("Email empty"):
                            theUsername.text != "" && email.text != "" && password.text == ""?
                            Text("Password empty"):
                                theUsername.text == "" && email.text == "" && password.text != ""?
                                    Text("Username empty\nEmail empty"):
                                    theUsername.text == "" && email.text != "" && password.text == ""?
                                        Text("Username empty\nPassword empty"):
                                        theUsername.text != "" && email.text == "" && password.text == ""?
                                            Text("Email empty\nPassword empty"):
                                            theUsername.text == "" && email.text == "" && password.text == ""?
                                                Text("Username empty\nEmail empty\nPassword empty"):
                                                Text(""),
                    actions: <Widget>[
                      TextButton(
                        onPressed: (){
                          Navigator.of(myContent).pop();
                        },
                        child: Container(
                          child: const Text("Ok"),
                        ),
                      )
                    ],
                  ),
                );
                print("Registration incomplete");
              }
            }
          )
        ]
      ),
    );
  }
}