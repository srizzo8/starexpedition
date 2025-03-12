import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:starexpedition4/forgottenPassword.dart';
import 'discussionBoardUpdatesPage.dart' as discussionBoardUpdatesPage;
import 'questionsAndAnswersPage.dart' as questionsAndAnswersPage;
import 'technologiesPage.dart' as technologiesPage;
import 'projectsPage.dart' as projectsPage;
import 'newDiscoveriesPage.dart' as newDiscoveriesPage;
import 'registerPage.dart' as theRegisterPage;
import 'discussionBoardPage.dart' as theDiscussionBoardPage;
import 'database_information/databaseService.dart';
import 'database_information/usersDatabaseInfo.dart';
import 'users_firestore_database_information/theUserInformation.dart';
import 'users_firestore_database_information/userDatabaseFirestoreInfo.dart';
import 'forgottenPassword.dart' as forgottenPassword;

import 'main.dart' as myMain;

String myUsername = "";
bool loginBool = false;

//Accessing users array from main.dart:
//print(myMain.theUsers.toString());

class loginPage extends StatefulWidget{
  const loginPage ({Key? key}) : super(key: key);

  @override
  loginPageState createState() => loginPageState();
}

class MyLoginPage extends StatelessWidget{
  const MyLoginPage({Key? key}) : super(key : key);

  @override
  Widget build(BuildContext bContext){
    return MaterialApp(
        title: 'The Login Page',
        routes: {
          loginPageRoutes.homePage: (context) => myMain.StarExpedition(),
          loginPageRoutes.myRegisterPage: (context) => theRegisterPage.registerPage(),
          loginPageRoutes.discussionBoard: (context) => theDiscussionBoardPage.discussionBoardPage(),
        }
    );
  }
}

class loginPageRoutes{
  static String homePage = myMain.theStarExpeditionState.nameOfRoute;
  static String myRegisterPage = theRegisterPage.registerPageState.nameOfRoute;
  static String discussionBoard = theDiscussionBoardPage.discussionBoardPageState.nameOfRoute;
}

class loginPageState extends State<loginPage>{
  static String nameOfRoute = '/loginPage';
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final userInfo = Get.put(theUserInformation());

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text("Star Expedition"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () =>{
                Navigator.push(bc, MaterialPageRoute(builder: (bc) => const myMain.StarExpedition())),
              }
          )
      ),
      body: Wrap(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Login", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
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
                            maxWidth: 400,
                          ),
                          child: SizedBox(
                            child: TextField(
                              minLines: 1,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Username",
                              ),
                              controller: usernameController,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
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
                            maxWidth: 400,
                          ),
                          child: SizedBox(
                            child: TextField(
                              minLines: 1,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Password",
                              ),
                              controller: passwordController,
                              obscureText: true,
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
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                ),
                child: InkWell(
                  child: Ink(
                    padding: EdgeInsets.all(5.0),
                    child: Text("Log in", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),// style: TextStyle(fontSize: 12.0)), //style: TextStyle(fontSize: 14.0, color: Colors.white)),
                  ),
                ),
                onPressed: () async{
                  if(usernameController.text != "" && passwordController.text != "") {
                    var userDocument;

                    //userResult
                    if(myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == usernameController.text.toLowerCase()) != -1){
                      var userResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: usernameController.text.toLowerCase()).get();
                      userResult.docs.forEach((outcome){
                        userDocument = outcome.data();
                        //userLowercased = outcome.data()["username"].toLowerCase();
                        print("This is the outcome: ${outcome.data()}");
                      });

                      print("keys: ${userDocument["password"]}");
                      print("userDocument: $userDocument");
                    }

                    encrypt.Encrypted encryptedEnteredPass = theRegisterPage.encryptMyPassword(theRegisterPage.myKey, passwordController.text);
                    print("Encrypted pass: ${encryptedEnteredPass.base64}");

                    //print("userdocument[password]: ${userDocument["password"]}");
                    //print("checking: ${theRegisterPage.decryptMyPassword(theRegisterPage.myKey, userDocument["password"])}");

                    //if(usernameList.contains(usernameController.text.toLowerCase())

                    /*var passwordDocument;
                      var passwordResult = await FirebaseFirestore.instance.collection("User").where("password", isEqualTo: passwordController.text).get();
                      passwordResult.docs.forEach((outcome){
                        passwordDocument = outcome.data();
                      });*/
                    //print("passwordDocument: $passwordDocument");

                    //if(userLowercased == usernameController.text.toLowerCase())
                    //if(userDocument.toString() == passwordDocument.toString() && userDocument != null && passwordDocument != null){
                    if(userDocument != null && userDocument["usernameLowercased"] == usernameController.text.toLowerCase() && passwordController.text == theRegisterPage.decryptMyPassword(theRegisterPage.myKey, userDocument["password"]) && usernameController.text != "" && passwordController.text != ""){ //myMain.theUsers!.contains(usernameController.text)
                      print("userDocument is NOT null");
                      if(myMain.discussionBoardLogin == true){
                        await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: usernameController.text.toLowerCase()).get().then((theUn){
                          myUsername = theUn.docs.first.data()["username"];
                        });
                        print("Logging in as: " + myUsername);
                        print("myNewUsername: " + theRegisterPage.myNewUsername);
                        Navigator.pushReplacementNamed(context, loginPageRoutes.discussionBoard);
                        myMain.discussionBoardLogin = false;
                        loginBool = true;
                      }
                      else{
                        print("Logging in 123");
                        await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: usernameController.text.toLowerCase()).get().then((theUn){
                          myUsername = theUn.docs.first.data()["username"];
                        });

                        print("Logging in as " + myUsername);
                        Navigator.pushReplacementNamed(context, loginPageRoutes.homePage);
                        print("myUsername: " + myUsername);
                        print("myNewUsername: " + theRegisterPage.myNewUsername);
                        loginBool = true;
                        //print("Outcome: ${userDocument.keys.sort()}");
                      }
                    }
                    else{
                      //print("userDocument info: ${userDocument["usernameLowercased"]}, ${userDocument["password"]}");
                      //print("passwordDocument: $passwordDocument");
                      if(myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == usernameController.text.toLowerCase()) != -1){
                        showDialog(
                            context: context,
                            builder: (BuildContext theContext){
                              return AlertDialog(
                                title: const Text("Login unsuccessful"),
                                content: const Text("Your username-password combination is not correct"),
                                actions: [
                                  TextButton(
                                    onPressed: () => {
                                      Navigator.pop(context),
                                    },
                                    child: const Text("Ok"),
                                  )
                                ],
                              );
                            }
                        );
                      }
                      else if(myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == usernameController.text.toLowerCase()) == -1){
                        userDocument = null;
                        showDialog(
                            context: context,
                            builder: (BuildContext theContext){
                              return AlertDialog(
                                title: const Text("Login unsuccessful"),
                                content: const Text("The username you have entered does not exist"),
                                actions: [
                                  TextButton(
                                    onPressed: () => {
                                      Navigator.pop(context),
                                    },
                                    child: const Text("Ok"),
                                  )
                                ],
                              );
                            }
                        );
                      }
                    }
                  }
                  else if(usernameController.text == "" && passwordController.text != ""){
                    showDialog(
                        context: context,
                        builder: (BuildContext theContext){
                          return AlertDialog(
                            title: const Text("Login unsuccessful"),
                            content: const Text("Username is empty"),
                            actions: [
                              TextButton(
                                onPressed: () => {
                                  Navigator.pop(context),
                                },
                                child: const Text("Ok"),
                              )
                            ],
                          );
                        }
                    );
                  }
                  else if(myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == usernameController.text.toLowerCase()) != -1 && usernameController.text != "" && passwordController.text == ""){
                    showDialog(
                        context: context,
                        builder: (BuildContext theContext){
                          return AlertDialog(
                            title: const Text("Login unsuccessful"),
                            content: const Text("Password is empty"),
                            actions: [
                              TextButton(
                                onPressed: () => {
                                  Navigator.pop(context),
                                },
                                child: const Text("Ok"),
                              )
                            ],
                          );
                        }
                    );
                  }
                  else if(myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == usernameController.text.toLowerCase()) == -1 && usernameController.text != "" && passwordController.text == ""){
                    showDialog(
                        context: context,
                        builder: (BuildContext theContext){
                          return AlertDialog(
                            title: const Text("Login unsuccessful"),
                            content: const Text("The username you have entered does not exist\nPassword is empty"),
                            actions: [
                              TextButton(
                                onPressed: () => {
                                  Navigator.pop(context),
                                },
                                child: const Text("Ok"),
                              )
                            ],
                          );
                        }
                    );
                  }
                  else if(usernameController.text == "" && passwordController.text == ""){
                    showDialog(
                        context: context,
                        builder: (BuildContext theContext){
                          return AlertDialog(
                            title: const Text("Login unsuccessful"),
                            content: const Text("Username is empty\nPassword is empty"),
                            actions: [
                              TextButton(
                                onPressed: () => {
                                  Navigator.pop(context),
                                },
                                child: const Text("Ok"),
                              )
                            ],
                          );
                        }
                    );
                  }
                }
            ),
          ),
          Center(
            child: Container(
              height: 20,
            )
          ),
          Center(
            child: Container(
              child: Text("If you have forgotten your password, click the button below:"),
            ),
          ),
          Center(
            child: Container(
              height: 5,
            ),
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
              child: InkWell(
                child: Ink(
                  //color: Colors.black,
                  padding: EdgeInsets.all(5.0),
                  //height: 20,
                  child: Text("Forgotten Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)), //style: TextStyle(fontSize: 12.0)),//, style: TextStyle(fontSize: 14.0)),
                ),
                /*onPressed: () async{
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => forgottenPassword.forgottenPassword()));
                }*/
              ),
              onPressed: () async{
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => forgottenPassword.forgottenPassword()));
              }
            ),
          ),
          Center(
            child: Container(
              child: Text("If you do not have an account, you can create an account:", style: TextStyle(fontSize: 14.0)),
            ),
          ),
          Center(
            child: Container(
              height: 5,
            ),
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
              child: InkWell(
                child: Ink(
                  color: Colors.black,
                  padding: EdgeInsets.all(5.0),
                  //height: 20,
                  child: Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)), //style: TextStyle(fontSize: 12.0)),//, style: TextStyle(fontSize: 14.0)),
                ),
              ),
              onPressed: () async{
                //Navigator.pushReplacementNamed(context, loginPageRoutes.myRegisterPage);
                databaseService().initMyDatabase();
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => theRegisterPage.registerPage()));
                print("Signing up");
              }
            ),
          ),
        ],
      ),
    );
  }
}