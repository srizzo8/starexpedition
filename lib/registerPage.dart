import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
//import 'package:backendless_sdk/backendless_sdk.dart';
import 'discussionBoardUpdatesPage.dart' as discussionBoardUpdatesPage;
import 'main.dart';
import 'questionsAndAnswersPage.dart' as questionsAndAnswersPage;
import 'technologiesPage.dart' as technologiesPage;
import 'projectsPage.dart' as projectsPage;
import 'newDiscoveriesPage.dart' as newDiscoveriesPage;

import 'main.dart' as myMain;
import 'discussionBoardPage.dart' as theDiscussionBoardPage;
import 'emailNotifications.dart' as emailNotifications;
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'users_firestore_database_information/theUserInformation.dart';
import 'users_firestore_database_information/userDatabaseFirestoreInfo.dart';
//import 'database_information/usersDatabaseInfo.dart';


String myNewUsername = "";
String myNewEmail = "";
String myNewPassword = "";
bool registerBool = false;
var userId;
List<String> regExp = ['[', ']', '!', '@', '#', "%", '^', '&', '*', '(', ')', '<', '>', '?', '~', '_', '+', '-', '`', '{', '}', '[', ']', ':'];
final myRegExp = RegExp(
    r'[\^$*.\[\]{}()?\-"!@#%&/\,><:;_~`+='
);
List<String> numRegExp = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

bool checkSpecialCharacters(String p){
  var myPassList = p.split("");//json.decode(p).cast<String>().toList();
  for(String i in regExp){
    if(myPassList.contains(i)){
      return true;
    }
    else{
      //continue
    }
  }
  return false;
}

bool checkNumbers(String p){
  var mySecondPassList = p.split("");
  for(String s in numRegExp){
    if(mySecondPassList.contains(s)){
      return true;
    }
    else{
      //continue
    }
  }
  return false;
}

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

class registerPageState extends State<registerPage>{
  List userEmailPasswordList = [];
  static String nameOfRoute = '/registerPage';
  TextEditingController theUsername = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  //final dbService = databaseService();

  final userInfo = Get.put(theUserInformation());

  Future<void> createUser(User u) async{
      await userInfo.createMyUser(u);
  }

  Widget build(BuildContext buildContext){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
          Center(
            child: InkWell(
              child: Ink(
                color: Colors.black,
                padding: EdgeInsets.all(5.0),
                //height: 20,
                child: Text("Sign Up for Star Expedition", style: TextStyle(color: Colors.white)), //style: TextStyle(fontSize: 12.0)),
              ),
                onTap: () async{
                  if(theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text != "" && password.text != "" && checkSpecialCharacters(password.text) == true && checkNumbers(password.text) == true){
                    if(myMain.discussionBoardLogin == true){
                      //userId = userId + 1;
                      await FirebaseFirestore.instance.collection("User").orderBy("id", descending: true).limit(1).get().then((myNumber){
                        userId = myNumber.docs.first.data()["id"] + 1;
                      });
                      myNewUsername = theUsername.text;
                      myNewEmail = email.text;
                      myNewPassword = password.text;
                      Navigator.pushReplacementNamed(buildContext, registerPageRoutes.discussionBoard);
                      var theNewUser = User(
                          id: userId,
                          username: theUsername.text,
                          emailAddress: email.text,
                          password: password.text,
                          usernameLowercased: theUsername.text.toLowerCase()
                      );
                      createUser(theNewUser);
                      //dbService.addUser(theNewUser);
                      //dbService.getUsers();
                      userEmailPasswordList.add([theUsername.text, email.text, password.text]);
                      myMain.Users dasUser = new Users(username: theUsername.text, email: email.text, password: password.text);
                      myMain.theUsers!.add(dasUser);
                      print(myMain.theUsers);
                      myMain.discussionBoardLogin = false;
                      registerBool = true;
                      print("Registering successfully as: " + userEmailPasswordList.toString());
                      emailNotifications.registrationConfirmationEmail();
                    }
                    else{
                      //userId = userId + 1;
                      await FirebaseFirestore.instance.collection("User").orderBy("id", descending: true).limit(1).get().then((myNumber){
                        userId = myNumber.docs.first.data()["id"] + 1;
                      });
                      myNewUsername = theUsername.text;
                      myNewEmail = email.text;
                      myNewPassword = password.text;
                      Navigator.pushReplacementNamed(buildContext, registerPageRoutes.homePage);
                      var theNewUser = User(
                          id: userId,
                          username: theUsername.text,
                          emailAddress: email.text,
                          password: password.text,
                          usernameLowercased: theUsername.text.toLowerCase()
                      );
                      createUser(theNewUser);
                      //dbService.addUser(theNewUser);
                      //dbService.getUsers();
                      userEmailPasswordList.add([theUsername.text, email.text, password.text]);
                      myMain.Users dasUser = new Users(username: theUsername.text, email: email.text, password: password.text);
                      myMain.theUsers!.add(dasUser);
                      print(myMain.theUsers);
                      myMain.discussionBoardLogin = false;
                      registerBool = true;
                      print("Registering successfully as: " + userEmailPasswordList.toString());
                      emailNotifications.registrationConfirmationEmail();
                    }
                  }
                  else{
                    print(myMain.theUsers!.indexWhere((person) => person.username == theUsername.text));
                    showDialog(
                      context: buildContext,
                      builder: (myContent) => AlertDialog(
                        title: const Text("Registration unsuccessful"),
                        content: theUsername.text == "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text != "" && password.text != "" && checkSpecialCharacters(password.text) == true && checkNumbers(password.text) == true?
                        Text("Username empty"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) != -1 && email.text != "" && password.text != "" && checkSpecialCharacters(password.text) == true && checkNumbers(password.text) == true?
                        Text("Username already exists"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text == "" && password.text != "" && checkSpecialCharacters(password.text) == true && checkNumbers(password.text) == true?
                        Text("Email empty"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text != "" && password.text == ""?
                        Text("Password empty"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text != "" && password.text != "" && checkSpecialCharacters(password.text) == false && checkNumbers(password.text) == true?
                        Text("Password must contain at least one special character"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text != "" && password.text != "" && checkSpecialCharacters(password.text) == true && checkNumbers(password.text) == false?
                        Text("Password must contain at least one number"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text != "" && password.text != "" && checkSpecialCharacters(password.text) == false && checkNumbers(password.text) == false?
                        Text("Password must contain at least one special character\nPassword must contain at least one number"):
                        theUsername.text == "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text == "" && password.text != "" && checkSpecialCharacters(password.text) == true && checkNumbers(password.text) == true?
                        Text("Username empty\nEmail empty"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) != -1 && email.text == "" && password.text != "" && checkSpecialCharacters(password.text) == true && checkNumbers(password.text) == true?
                        Text("Username already exists\nEmail empty"):
                        theUsername.text == "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text != "" && password.text == ""?
                        Text("Username empty\nPassword empty"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) != -1 && email.text != "" && password.text == ""?
                        Text("Username already exists\nPassword empty"):
                        theUsername.text == "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text != "" && password.text != "" && checkSpecialCharacters(password.text) == false && checkNumbers(password.text) == true?
                        Text("Username empty\nPassword must contain at least one special character"):
                        theUsername.text == "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text != "" && password.text != "" && checkSpecialCharacters(password.text) == true && checkNumbers(password.text) == false?
                        Text("Username empty\nPassword must contain at least one number"):
                        theUsername.text == "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text != "" && password.text != "" && checkSpecialCharacters(password.text) == false && checkNumbers(password.text) == false?
                        Text("Username empty\nPassword must contain at least one special character\nPassword must contain at least one number"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) != -1 && email.text != "" && password.text != "" && checkSpecialCharacters(password.text) == false && checkNumbers(password.text) == true?
                        Text("Username already exists\nPassword must contain at least one special character"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) != -1 && email.text != "" && password.text != "" && checkSpecialCharacters(password.text) == true && checkNumbers(password.text) == false?
                        Text("Username already exists\nPassword must contain at least one number"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) != -1 && email.text != "" && password.text != "" && checkSpecialCharacters(password.text) == false && checkNumbers(password.text) == false?
                        Text("Username already exists\nPassword must contain at least one special character\nPassword must contain at least one number"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text == "" && password.text == ""?
                        Text("Email empty\nPassword empty"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text == "" && password.text != "" && checkSpecialCharacters(password.text) == false && checkNumbers(password.text) == true?
                        Text("Email empty\nPassword must contain at least one special character"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text == "" && password.text != "" && checkSpecialCharacters(password.text) == true && checkNumbers(password.text) == false?
                        Text("Email empty\nPassword must contain at least one number"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text == "" && password.text != "" && checkSpecialCharacters(password.text) == false && checkNumbers(password.text) == false?
                        Text("Email empty\nPassword must contain at least one special character\nPassword must contain at least one number"):
                        theUsername.text == "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text == "" && password.text == ""?
                        Text("Username empty\nEmail empty\nPassword empty"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) != -1 && email.text == "" && password.text == ""?
                        Text("Username already exists\nEmail empty\nPassword empty"):
                        theUsername.text == "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text == "" && password.text != "" && checkSpecialCharacters(password.text) == false && checkNumbers(password.text) == true?
                        Text("Username empty\nEmail empty\nPassword must contain at least one special character"):
                        theUsername.text == "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text == "" && password.text != "" && checkSpecialCharacters(password.text) == true && checkNumbers(password.text) == false?
                        Text("Username empty\nEmail empty\nPassword must contain at least one number"):
                        theUsername.text == "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && email.text == "" && password.text != "" && checkSpecialCharacters(password.text) == false && checkNumbers(password.text) == false?
                        Text("Username empty\nEmail empty\nPassword must contain at least one special character\nPassword must contain at least one number"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) != -1 && email.text == "" && password.text != "" && checkSpecialCharacters(password.text) == false && checkNumbers(password.text) == true?
                        Text("Username already exists\nEmail empty\nPassword must contain at least one special character"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) != -1 && email.text == "" && password.text != "" && checkSpecialCharacters(password.text) == true && checkNumbers(password.text) == false?
                        Text("Username already exists\nEmail empty\nPassword must contain at least one number"):
                        theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) != -1 && email.text == "" && password.text != "" && checkSpecialCharacters(password.text) == false && checkNumbers(password.text) == false?
                        Text("Username already exists\nEmail empty\nPassword must contain at least one special character\nPassword must contain at least one number"):
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
            ),
          )
        ]
      ),
    );
  }
}