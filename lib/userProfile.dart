import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:starexpedition4/spectralClassPage.dart';

import 'package:starexpedition4/main.dart' as myMain;
import 'package:starexpedition4/discussionBoardPage.dart';
import 'package:starexpedition4/loginPage.dart';
import 'package:starexpedition4/registerPage.dart';
import 'package:starexpedition4/loginPage.dart' as theLoginPage;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';

var myInformation;
var dataOfUser;
var myDocName;
var userInformation;

class userProfilePage extends StatefulWidget{
  const userProfilePage ({Key? key}) : super(key: key);

  @override
  userProfilePageState createState() => userProfilePageState();
}

class userProfilePageState extends State<userProfilePage>{
  String nameOfRoute = '/userProfilePage';

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            Navigator.push(bc, MaterialPageRoute(builder: (BuildContext context) => myMain.StarExpedition())),
          }
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            child: Text("User Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: 5,
          ),
          Container(
            child: Text("User")
          ),
          InkWell(
            child: Ink(
              child: Container(
                child: Text("Edit My User Profile", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                color: Colors.black,
              ),
            ),
            onTap: (){
              print("Button clicked!");
            }
          ),
          Container(
            height: 5,
          ),
          Container(
            child: Text("Information about me", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
          ),
          Container(
            child: Text(""),
          ),
        ],
      ),
    );
  }
}

class editingMyUserProfile extends StatelessWidget{
  TextEditingController informationAboutMyselfController = TextEditingController();

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            print("Going back to settings page"),
          }
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            child: Text("Editing Your Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: 5,
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Information about yourself",
                contentPadding: EdgeInsets.symmetric(vertical: 80),
              ),
              controller: informationAboutMyselfController,
            ),
          ),
          Center(
            child: InkWell(
              child: Ink(
                color: Colors.black,
                padding: EdgeInsets.all(5.0),
                child: Text("Update Profile", style: TextStyle(color: Colors.white)),
              ),
              onTap: () async{
                if(myUsername != "" && myNewUsername == ""){
                  myInformation = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                  myInformation.docs.forEach((myResult){
                    dataOfUser = myResult.data();
                    myDocName = myResult.id;
                  });

                  FirebaseFirestore.instance.collection("User").doc(myDocName).update({
                    "usernameProfileInformation.userInformation": informationAboutMyselfController.text,
                  }).then((i){
                    print("You have updated the user information (for already existing users)!");
                  });
                }
                else if(myUsername == "" && myNewUsername != ""){
                  myInformation = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                  myInformation.docs.forEach((myResult){
                    dataOfUser = myResult.data();
                    myDocName = myResult.id;
                  });

                  FirebaseFirestore.instance.collection("User").doc(myDocName).update({
                    "usernameProfileInformation.userInformation": informationAboutMyselfController.text,
                  }).then((j){
                    print("You have updated the user information (for new users)!");
                  });
                }
              }
            ),
          ),
        ],
      )
    );
  }
}

class userProfileInUserPerspective extends StatelessWidget{
  static String nameOfRoute = '/userProfileInUserPerspective';

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            Navigator.push(bc, MaterialPageRoute(builder: (BuildContext context) => myMain.StarExpedition())),
          }
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            child: Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: 5,
          ),
          Container(
            child: myUsername != "" && myNewUsername == ""?
                Text("Username:\n${myUsername}"):
                Text("Username:\n${myNewUsername}"),
          ),
          Container(
            height: 5,
          ),
          Container(
            child: myUsername != "" && myNewUsername == ""?
                Text("Information About You:\n${myMain.usersBlurb}"):
                Text("Information About You:\n${myMain.usersBlurb}"),
          ),
        ],
      ),
    );
  }
}