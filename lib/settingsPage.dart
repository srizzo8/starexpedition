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

class settingsPage extends StatefulWidget{
  const settingsPage ({Key? key}) : super(key: key);

  @override
  settingsPageState createState() => settingsPageState();
}

class settingsPageState extends State<settingsPage>{
  static String nameOfRoute = '/settings';

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController secondNewPasswordController = TextEditingController();
  var myUserResult;
  var userDoc;
  var gettingDocName;
  var usersPass;

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () async =>{
            Navigator.pop(context),
          }
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            child: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          InkWell(
            child: Ink(
              //alignment: Alignment.center,
              child: Text("Change Password"),
            ),
            onTap: (){
              showDialog(
                context: context,
                builder: (BuildContext bc){
                  return AlertDialog(
                    title: Text("Change your password"),
                    content: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Enter in your current password",
                              border: OutlineInputBorder(),
                            ),
                            controller: oldPasswordController,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Enter in your new password",
                              border: OutlineInputBorder(),
                            ),
                            controller: newPasswordController,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Re-enter your new password",
                              border: OutlineInputBorder(),
                            ),
                            controller: secondNewPasswordController,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async =>{
                          if(oldPasswordController.text != "" && newPasswordController.text != "" && secondNewPasswordController.text != ""){
                            if(myUsername != "" && myNewUsername == ""){
                              myUserResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get(),
                              myUserResult.docs.forEach((result){
                                userDoc = result.data();
                                print("This is the result: ${result.data()}");
                                gettingDocName = result.id;
                              }),
                              print("userDoc[password]: ${userDoc["password"].toString()}"),

                              usersPass = userDoc["password"],

                              if(oldPasswordController.text != "" && newPasswordController.text != "" && secondNewPasswordController.text != ""){
                                if(oldPasswordController.text == usersPass && newPasswordController.text == secondNewPasswordController.text){
                                  print("The old password is correct"),

                                  print("gettingDocName: ${gettingDocName.toString()}"),

                                  FirebaseFirestore.instance.collection("User").doc(gettingDocName).update({"password" : newPasswordController.text}).whenComplete(() async{
                                    print("Updated");
                                  }).catchError((e) => print("This is your error: ${e}")),

                                  print("This is new user password: ${userDoc["password"]}"),
                                  Navigator.pop(context),
                                  oldPasswordController.text = "",
                                  newPasswordController.text = "",
                                  secondNewPasswordController.text = "",
                                }
                                else if(oldPasswordController.text != usersPass && newPasswordController.text == secondNewPasswordController.text){
                                  print("The old password is not correct, but the new passwords match"),
                                }
                                else if(oldPasswordController.text == usersPass && newPasswordController.text != secondNewPasswordController.text){
                                  print("The old password is correct, but the two new passwords do not match.")
                                },
                              } else{
                                print("You are missing at least one thing"),
                              },

                              print("This is an already existing username"),
                            }
                            else if(myNewUsername == "" && myNewUsername != ""){
                              myUserResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get(),
                              myUserResult.docs.forEach((result){
                                userDoc = result.data();
                                print("This is the result: ${result.data()}");
                              }),
                              print("userDoc[password]: ${userDoc["password"].toString()}"),

                              usersPass = userDoc["password"],

                              if(oldPasswordController.text == usersPass && newPasswordController.text == secondNewPasswordController.text){
                                print("The old password is correct"),
                                Navigator.pop(context),
                                oldPasswordController.text = "",
                                newPasswordController.text = "",
                                secondNewPasswordController.text = "",
                              }
                              else{
                                print("The old password is not correct"),
                              },

                              print("This is a new username"),
                              Navigator.pop(context),
                            }
                            else{
                              print("There is a problem with this if-else statement"),
                            }
                          }
                          else{
                            //User needs to enter in his or her old password and/or his or her new password.
                          }
                        },
                        child: Text("Confirm"),
                      ),
                      TextButton(
                        onPressed: () =>{
                          Navigator.pop(context),
                        },
                        child: Text("Cancel"),
                      ),
                    ],
                  );
                }
              );
            }
          ),
        ],
      ),
    );
  }
}