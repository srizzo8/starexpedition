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

import 'main.dart' as myMain;

String myUsername = "";

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
      }
    );
  }
}

class loginPageRoutes{
  static String homePage = myMain.theStarExpeditionState.nameOfRoute;
  static String myRegisterPage = theRegisterPage.registerPageState.nameOfRoute;
}

class loginPageState extends State<loginPage>{
  static String nameOfRoute = '/loginPage';
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
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
                int u1 = myMain.theUsers!.indexWhere((person) => person.username == usernameController.text);
                int p1 = myMain.theUsers!.indexWhere((pass) => pass.password == passwordController.text);
                if(u1 == p1 && u1 != -1 && p1 != -1) { //If u1 and p1 have matching numbers, but if u1 and p1 do not equal -1.
                  //if(myMain.theUsers!.){
                    print("Logging in123");
                    myUsername = usernameController.text;
                    print("Logging in as " + myUsername);
                    Navigator.pushReplacementNamed(context, loginPageRoutes.homePage);
                  //}
                }
                else{
                  //int n = myMain.theUsers!.indexWhere((person) => person.username == "John");
                  print(u1);
                  print(p1);
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
            onTap: (){
              //Navigator.pushReplacementNamed(context, loginPageRoutes.myRegisterPage);
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => theRegisterPage.registerPage()));
              print("Signing up");
            }
          ),
        ],
      ),
    );
  }
}