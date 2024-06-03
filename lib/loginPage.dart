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
import 'registerPage.dart' as theRegisterPage;
import 'discussionBoardPage.dart' as theDiscussionBoardPage;
import 'database_information/databaseService.dart';
import 'database_information/usersDatabaseInfo.dart';

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

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
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
            alignment: Alignment.center,
            child: Text("Login", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
          ),
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
              controller: usernameController,
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
            )
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          GestureDetector(
            child: Center(
              child: Container(
                color: Colors.black,
                child: Text("Log in", style: TextStyle(fontSize: 14.0, color: Colors.white)),
              ),
            ),
            onTap: (){
              if(usernameController.text != "" && passwordController.text != "") {
                int u1 = myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == usernameController.text.toLowerCase()); //checks what the index number is when person.username equals usernameController.text.
                int p1 = myMain.theUsers!.indexWhere((pass) => pass.password == passwordController.text);
                if(u1 == p1 && u1 != -1 && p1 != -1) { //If u1 and p1 have matching numbers, but if u1 and p1 do not equal -1.
                  //if(myMain.theUsers!.){
                    if(myMain.discussionBoardLogin == true){
                      print(myMain.theUsers!.elementAt(u1).username.toString());
                      myUsername = myMain.theUsers!.elementAt(u1).username.toString();
                      print("Logging in as " + myUsername);
                      print("myNewUsername: " + theRegisterPage.myNewUsername);
                      Navigator.pushReplacementNamed(context, loginPageRoutes.discussionBoard);
                      myMain.discussionBoardLogin = false;
                      loginBool = true;
                    }
                    else{
                      print(myMain.theUsers!.elementAt(u1).username.toString());
                      print("Logging in123");
                      myUsername = myMain.theUsers!.elementAt(u1).username.toString();//usernameController.text;
                      print("Logging in as " + myUsername);
                      Navigator.pushReplacementNamed(context, loginPageRoutes.homePage);
                      print("myUsername: " + myUsername);
                      print("myNewUsername: " + theRegisterPage.myNewUsername);
                      loginBool = true;
                    }
                }
                else{
                  //int n = myMain.theUsers!.indexWhere((person) => person.username == "John");
                  print(u1);
                  print(p1);
                  showDialog(
                    context: context,
                    builder: (BuildContext theContext){
                      return AlertDialog(
                        title: const Text("Login Error"),
                        content: const Text("Your username-password combination is not correct."),
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
          ),
          Center(
            child: Container(
              child: Text("If you do not have an account, you can create an account", style: TextStyle(fontSize: 14.0)),
            ),
          ),
          GestureDetector(
            child: Center(
              child: Container(
                color: Colors.tealAccent,
                child: Text("Sign up", style: TextStyle(fontSize: 14.0)),
              ),
            ),
            onTap: () async{
              //Navigator.pushReplacementNamed(context, loginPageRoutes.myRegisterPage);
              databaseService().initMyDatabase();
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => theRegisterPage.registerPage()));
              print("Signing up");
            }
          ),
        ],
      ),
    );
  }
}