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
import 'package:starexpedition4/emailNotifications.dart' as emailNotifications;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';

var theUser;
var theNewUser;
var usersEmail;

class settingsPage extends StatefulWidget{
  const settingsPage ({Key? key}) : super(key: key);

  @override
  settingsPageState createState() => settingsPageState();
}

class settingsPageState extends State<settingsPage>{
  static String nameOfRoute = '/settings';

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
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => changePasswordPage()));
            }
          ),
        ],
      ),
    );
  }
}

class changePasswordPage extends StatefulWidget{
  const changePasswordPage({Key? key}) : super(key: key);

  @override
  changePasswordPageState createState() => changePasswordPageState();
}

class changePasswordPageState extends State<changePasswordPage>{
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController secondNewPasswordController = TextEditingController();
  var myUserResult;
  var userDoc;
  var gettingDocName;
  var usersPass;

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            Navigator.push(context, MaterialPageRoute(builder: (context) => settingsPage())),
          }
        )
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Change Your Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(0.0),
              alignment: Alignment.centerLeft,
              child: Text("Current Password", style: TextStyle(fontSize: 14.0)),
              height: 20,
              width: 380,
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            child: TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(0.0),
              alignment: Alignment.centerLeft,
              child: Text("New Password", style: TextStyle(fontSize: 14.0)),
              height: 20,
              width: 380,
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            child: TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(0.0),
              alignment: Alignment.centerLeft,
              child: Text("Confirm New Password", style: TextStyle(fontSize: 14.0)),
              height: 20,
              width: 380,
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            child: TextField(
              controller: secondNewPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Center(
            child: InkWell(
              child: Ink(
                color: Colors.black,
                padding: EdgeInsets.all(5.0),
                child: Text("Confirm Your Password Change", style: TextStyle(color: Colors.white)),
              ),
              onTap: () async{
                print("currentPasswordController.text: ${currentPasswordController.text}");
                print("newPasswordController.text: ${newPasswordController.text}");
                print("secondNewPasswordController.text: ${secondNewPasswordController.text}");
                print("myUsername = ${myUsername}, myNewUsername = ${myNewUsername}");
                if(currentPasswordController.text != "" && newPasswordController.text != "" && secondNewPasswordController.text != ""){
                  if(myUsername != "" && myNewUsername == ""){
                    myUserResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                    myUserResult.docs.forEach((result){
                      userDoc = result.data();
                      print("This is the result: ${result.data()}");
                      gettingDocName = result.id;
                    });
                    print("userDoc[password]: ${userDoc["password"].toString()}");

                    usersPass = userDoc["password"];

                    if(currentPasswordController.text == usersPass && newPasswordController.text == secondNewPasswordController.text){
                      if(currentPasswordController.text == newPasswordController.text && newPasswordController.text == secondNewPasswordController.text && currentPasswordController.text == secondNewPasswordController.text){
                        //The new password cannot be the current password
                        print("Old and new are the same");
                        showDialog(
                          context: context,
                          builder: (BuildContext myContext){
                            return AlertDialog(
                              title: Text("Password Change Unsuccessful"),
                              content: Text("Your new password cannot be your current password"),
                              actions: [
                                TextButton(
                                  onPressed: () =>{
                                    Navigator.pop(context),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                      else if(checkSpecialCharacters(newPasswordController.text) == false && checkNumbers(newPasswordController.text) == true && (newPasswordController.text).length >= 8){
                        showDialog(
                          context: context,
                          builder: (BuildContext myContext){
                            return AlertDialog(
                              title: Text("Password Change Unsuccessful"),
                              content: Text("Your new password must have at least one special character"),
                              actions: [
                                TextButton(
                                  onPressed: () =>{
                                    Navigator.pop(context),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                      else if(checkSpecialCharacters(newPasswordController.text) == true && checkNumbers(newPasswordController.text) == false && (newPasswordController.text).length >= 8){
                        showDialog(
                          context: context,
                          builder: (BuildContext myContext){
                            return AlertDialog(
                              title: Text("Password Change Unsuccessful"),
                              content: Text("Your new password must have at least one number"),
                              actions: [
                                TextButton(
                                  onPressed: () =>{
                                    Navigator.pop(context),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                      else if(checkSpecialCharacters(newPasswordController.text) == true && checkNumbers(newPasswordController.text) == true && (newPasswordController.text).length < 8){
                        showDialog(
                          context: context,
                          builder: (BuildContext myContext){
                            return AlertDialog(
                              title: Text("Password Change Unsuccessful"),
                              content: Text("Your new password must be at least 8 characters long"),
                              actions: [
                                TextButton(
                                  onPressed: () =>{
                                    Navigator.pop(context),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                      else if(checkSpecialCharacters(newPasswordController.text) == false && checkNumbers(newPasswordController.text) == false && (newPasswordController.text).length < 8){
                        showDialog(
                          context: context,
                          builder: (BuildContext myContext){
                            return AlertDialog(
                              title: Text("Password Change Unsuccessful"),
                              content: Text("Your new password must have at least one special character and be at least 8 characters long"),
                              actions: [
                                TextButton(
                                  onPressed: () =>{
                                    Navigator.pop(context),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                      else if(checkSpecialCharacters(newPasswordController.text) == true && checkNumbers(newPasswordController.text) == false && (newPasswordController.text).length < 8){
                        showDialog(
                          context: context,
                          builder: (BuildContext myContext){
                            return AlertDialog(
                              title: Text("Password Change Unsuccessful"),
                              content: Text("Your new password must have at least one number and be at least 8 characters long"),
                              actions: [
                                TextButton(
                                  onPressed: () =>{
                                    Navigator.pop(context),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                      else if(checkSpecialCharacters(newPasswordController.text) == false && checkNumbers(newPasswordController.text) == false && (newPasswordController.text).length < 8){
                        showDialog(
                          context: context,
                          builder: (BuildContext myContext){
                            return AlertDialog(
                              title: Text("Password Change Unsuccessful"),
                              content: Text("Your new password must have at least one special character, at least one number, and be at least 8 characters long"),
                              actions: [
                                TextButton(
                                  onPressed: () =>{
                                    Navigator.pop(context),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                      else{
                        //Password successfully changed
                        print("The old password is correct");

                        print("gettingDocName: ${gettingDocName.toString()}");

                        FirebaseFirestore.instance.collection("User").doc(gettingDocName).update({"password" : newPasswordController.text}).whenComplete(() async{
                          print("Updated");
                        }).catchError((e) => print("This is your error: ${e}"));

                        print("This is new user password: ${userDoc["password"]}");

                        showDialog(
                          context: context,
                          builder: (BuildContext bc){
                            return AlertDialog(
                              title: Text("Password Change Successful"),
                              content: Text("You have successfully changed your password"),
                              actions: [
                                TextButton(
                                  onPressed: () => {
                                    theUser = myUsername,
                                    theNewUser = "",
                                    usersEmail = userDoc["emailAddress"],
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => settingsPage())),
                                    emailNotifications.passwordChangeConfirmationEmail(),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                    }
                    else if(currentPasswordController.text != usersPass && newPasswordController.text == secondNewPasswordController.text){
                      //Current password entered does not match with your password
                      showDialog(
                        context: context,
                        builder: (BuildContext myContext){
                          return AlertDialog(
                            title: Text("Password Change Unsuccessful"),
                            content: Text("The current password that you entered does not match with your password"),
                            actions: [
                              TextButton(
                                onPressed: () => {
                                  Navigator.pop(context),
                                  currentPasswordController.text = "",
                                  newPasswordController.text = "",
                                  secondNewPasswordController.text = "",
                                },
                                child: Text("Ok"),
                              ),
                            ],
                          );
                        }
                      );
                    }
                    else if(currentPasswordController.text == usersPass && newPasswordController.text != secondNewPasswordController.text){
                      //The passwords entered in the "new password" and "confirm new password" sections do not match
                      showDialog(
                        context: context,
                        builder: (BuildContext myContext){
                          return AlertDialog(
                            title: Text("Password Change Unsuccessful"),
                            content: Text("The passwords that you entered in the \"New Password\" and \"Confirm New Password\" sections do not match"),
                            actions: [
                              TextButton(
                                onPressed: () => {
                                  Navigator.pop(context),
                                  currentPasswordController.text = "",
                                  newPasswordController.text = "",
                                  secondNewPasswordController.text = "",
                                },
                                child: Text("Ok"),
                              ),
                            ],
                          );
                        }
                      );
                    }
                    else if(currentPasswordController.text != usersPass && newPasswordController.text != secondNewPasswordController.text){
                      //Current password entered does not match with your password
                      //The passwords entered in the "new password" and "confirm new password" sections do not match
                      showDialog(
                        context: context,
                        builder: (BuildContext myContext){
                          return AlertDialog(
                            title: Text("Password Change Unsuccessful"),
                            content: Text("The current password that you entered does not match with your password\nThe passwords that you entered in the \"New Password\" and \"Confirm New Password\" sections do not match"),
                            actions: [
                              TextButton(
                                onPressed: () => {
                                  Navigator.pop(context),
                                  currentPasswordController.text = "",
                                  newPasswordController.text = "",
                                  secondNewPasswordController.text = "",
                                },
                                child: Text("Ok"),
                              ),
                            ],
                          );
                        }
                      );
                    }
                  }
                  else if(myUsername == "" && myNewUsername != ""){
                    myUserResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                    myUserResult.docs.forEach((result){
                      userDoc = result.data();
                      print("This is the result: ${result.data()}");
                      gettingDocName = result.id;
                    });
                    print("userDoc[password]: ${userDoc["password"].toString()}");

                    usersPass = userDoc["password"];

                    if(currentPasswordController.text == usersPass && newPasswordController.text == secondNewPasswordController.text){
                      if(currentPasswordController.text == newPasswordController.text && newPasswordController.text == secondNewPasswordController.text && currentPasswordController.text == secondNewPasswordController.text){
                        //The new password cannot be the current password
                        showDialog(
                          context: context,
                          builder: (BuildContext myContext){
                            return AlertDialog(
                              title: Text("Password Change Unsuccessful"),
                              content: Text("Your new password cannot be your current password"),
                              actions: [
                                TextButton(
                                  onPressed: () =>{
                                    Navigator.pop(context),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                      else if(checkSpecialCharacters(newPasswordController.text) == false && checkNumbers(newPasswordController.text) == true && (newPasswordController.text).length >= 8){
                        showDialog(
                          context: context,
                          builder: (BuildContext myContext){
                            return AlertDialog(
                              title: Text("Password Change Unsuccessful"),
                              content: Text("Your new password must have at least one special character"),
                              actions: [
                                TextButton(
                                  onPressed: () =>{
                                    Navigator.pop(context),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                      else if(checkSpecialCharacters(newPasswordController.text) == true && checkNumbers(newPasswordController.text) == false && (newPasswordController.text).length >= 8){
                        showDialog(
                          context: context,
                          builder: (BuildContext myContext){
                            return AlertDialog(
                              title: Text("Password Change Unsuccessful"),
                              content: Text("Your new password must have at least one number"),
                              actions: [
                                TextButton(
                                  onPressed: () =>{
                                    Navigator.pop(context),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                      else if(checkSpecialCharacters(newPasswordController.text) == true && checkNumbers(newPasswordController.text) == true && (newPasswordController.text).length < 8){
                        showDialog(
                          context: context,
                          builder: (BuildContext myContext){
                            return AlertDialog(
                              title: Text("Password Change Unsuccessful"),
                              content: Text("Your new password must be at least 8 characters long"),
                              actions: [
                                TextButton(
                                  onPressed: () =>{
                                    Navigator.pop(context),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                      else if(checkSpecialCharacters(newPasswordController.text) == false && checkNumbers(newPasswordController.text) == false && (newPasswordController.text).length <= 8){
                        showDialog(
                          context: context,
                          builder: (BuildContext myContext){
                            return AlertDialog(
                              title: Text("Password Change Unsuccessful"),
                              content: Text("Your new password must have at least one special character and one number"),
                              actions: [
                                TextButton(
                                  onPressed: () =>{
                                    Navigator.pop(context),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                      else if(checkSpecialCharacters(newPasswordController.text) == false && checkNumbers(newPasswordController.text) == true && (newPasswordController.text).length < 8){
                        showDialog(
                          context: context,
                          builder: (BuildContext myContext){
                            return AlertDialog(
                              title: Text("Password Change Unsuccessful"),
                              content: Text("Your new password must have at least one special character and be at least 8 characters long"),
                              actions: [
                                TextButton(
                                  onPressed: () =>{
                                    Navigator.pop(context),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                      else if(checkSpecialCharacters(newPasswordController.text) == true && checkNumbers(newPasswordController.text) == false && (newPasswordController.text).length < 8){
                        showDialog(
                          context: context,
                          builder: (BuildContext myContext){
                            return AlertDialog(
                              title: Text("Password Change Unsuccessful"),
                              content: Text("Your new password must have at least one number and be at least 8 characters long"),
                              actions: [
                                TextButton(
                                  onPressed: () =>{
                                    Navigator.pop(context),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                      else if(checkSpecialCharacters(newPasswordController.text) == false && checkNumbers(newPasswordController.text) == false && (newPasswordController.text).length < 8){
                        showDialog(
                          context: context,
                          builder: (BuildContext myContext){
                            return AlertDialog(
                              title: Text("Password Change Unsuccessful"),
                              content: Text("Your new password must have at least one special character, at least one number, and be at least 8 characters long"),
                              actions: [
                                TextButton(
                                  onPressed: () =>{
                                    Navigator.pop(context),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                      else{
                        //Password successfully changed
                        print("The old password is correct");

                        print("gettingDocName: ${gettingDocName.toString()}");

                        FirebaseFirestore.instance.collection("User").doc(gettingDocName).update({"password" : newPasswordController.text}).whenComplete(() async{
                          print("Updated");
                        }).catchError((e) => print("This is your error: ${e}"));

                        print("This is new user password: ${userDoc["password"]}");

                        showDialog(
                          context: context,
                          builder: (BuildContext bc){
                            return AlertDialog(
                              title: Text("Password Change Successful"),
                              content: Text("You have successfully changed your password"),
                              actions: [
                                TextButton(
                                  onPressed: () => {
                                    theUser = "",
                                    theNewUser = myNewUsername,
                                    usersEmail = userDoc["emailAddress"],
                                    Navigator.pop(context),
                                    emailNotifications.passwordChangeConfirmationEmail(),
                                    currentPasswordController.text = "",
                                    newPasswordController.text = "",
                                    secondNewPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                        );
                      }
                    }
                    else if(currentPasswordController.text != usersPass && newPasswordController.text == secondNewPasswordController.text){
                      //Current password entered does not match with your password
                      showDialog(
                        context: context,
                        builder: (BuildContext myContext){
                          return AlertDialog(
                            title: Text("Password Change Unsuccessful"),
                            content: Text("The current password that you entered does not match with your password"),
                            actions: [
                              TextButton(
                                onPressed: () => {
                                  Navigator.pop(context),
                                  currentPasswordController.text = "",
                                  newPasswordController.text = "",
                                  secondNewPasswordController.text = "",
                                },
                                child: Text("Ok"),
                              ),
                            ],
                          );
                        }
                      );
                    }
                    else if(currentPasswordController.text == usersPass && newPasswordController.text != secondNewPasswordController.text){
                      //The passwords entered in the "new password" and "confirm new password" sections do not match
                      showDialog(
                        context: context,
                        builder: (BuildContext myContext){
                          return AlertDialog(
                            title: Text("Password Change Unsuccessful"),
                            content: Text("The passwords that you entered in the \"New Password\" and \"Confirm New Password\" sections do not match"),
                            actions: [
                              TextButton(
                                onPressed: () => {
                                  Navigator.pop(context),
                                  currentPasswordController.text = "",
                                  newPasswordController.text = "",
                                  secondNewPasswordController.text = "",
                                },
                                child: Text("Ok"),
                              ),
                            ],
                          );
                        }
                      );
                    }
                    else if(currentPasswordController.text != usersPass && newPasswordController.text != secondNewPasswordController.text){
                      //Current password entered does not match with your password
                      //The passwords entered in the "new password" and "confirm new password" sections do not match
                      showDialog(
                        context: context,
                        builder: (BuildContext myContext){
                          return AlertDialog(
                            title: Text("Password Change Unsuccessful"),
                            content: Text("The current password that you entered does not match with your password\nThe passwords that you entered in the \"New Password\" and \"Confirm New Password\" sections do not match"),
                            actions: [
                              TextButton(
                                onPressed: () => {
                                  Navigator.pop(context),
                                  currentPasswordController.text = "",
                                  newPasswordController.text = "",
                                  secondNewPasswordController.text = "",
                                },
                                child: Text("Ok"),
                              ),
                            ],
                          );
                        }
                      );
                    }
                  }
                }
                else if(currentPasswordController.text == "" && newPasswordController.text != "" && secondNewPasswordController.text != ""){
                  showDialog(
                    context: context,
                    builder: (BuildContext myContext){
                      return AlertDialog(
                        title: Text("Password Change Unsuccessful"),
                        content: Text("The password change was unsuccessful because you have forgotten to enter in your current password"),
                        actions: [
                          TextButton(
                            onPressed: () =>{
                              Navigator.pop(context),
                              currentPasswordController.text = "",
                              newPasswordController.text = "",
                              secondNewPasswordController.text = "",
                            },
                            child: Text("Ok"),
                          ),
                        ],
                      );
                    }
                  );
                }
                else if(currentPasswordController.text == "" && newPasswordController.text == "" && secondNewPasswordController.text != ""){
                  showDialog(
                    context: context,
                    builder: (BuildContext myContext){
                      return AlertDialog(
                        title: Text("Password Change Unsuccessful"),
                        content: Text("The password change was unsuccessful because you have forgotten to enter in your current password and the new password that you have chosen in the \"New Password\" section"),
                        actions: [
                          TextButton(
                            onPressed: () =>{
                              Navigator.pop(context),
                              currentPasswordController.text = "",
                              newPasswordController.text = "",
                              secondNewPasswordController.text = "",
                            },
                            child: Text("Ok"),
                          ),
                        ],
                      );
                    }
                  );
                }
                else if(currentPasswordController.text == "" && newPasswordController.text != "" && secondNewPasswordController.text == ""){
                  showDialog(
                    context: context,
                    builder: (BuildContext myContext){
                      return AlertDialog(
                        title: Text("Password Change Unsuccessful"),
                        content: Text("The password change was unsuccessful because you have forgotten to enter in your current password and the new password that you have chosen in the \"Confirm New Password\" section"),
                        actions: [
                          TextButton(
                            onPressed: () =>{
                              Navigator.pop(context),
                              currentPasswordController.text = "",
                              newPasswordController.text = "",
                              secondNewPasswordController.text = "",
                            },
                            child: Text("Ok"),
                          ),
                        ],
                      );
                    }
                  );
                }
                else if(currentPasswordController.text != "" && newPasswordController.text == "" && secondNewPasswordController.text != ""){
                  showDialog(
                    context: context,
                    builder: (BuildContext myContext){
                      return AlertDialog(
                        title: Text("Password Change Unsuccessful"),
                        content: Text("The password change was unsuccessful because you have forgotten to enter in the new password that you have chosen in the \"New Password\" section"),
                        actions: [
                          TextButton(
                            onPressed: () =>{
                              Navigator.pop(context),
                              currentPasswordController.text = "",
                              newPasswordController.text = "",
                              secondNewPasswordController.text = "",
                            },
                            child: Text("Ok"),
                          ),
                        ],
                      );
                    }
                  );
                }
                else if(currentPasswordController.text != "" && newPasswordController.text != "" && secondNewPasswordController.text == ""){
                  showDialog(
                    context: context,
                    builder: (BuildContext myContext){
                      return AlertDialog(
                        title: Text("Password Change Unsuccessful"),
                        content: Text("The password change was unsuccessful because you have forgotten to enter in the new password that you have chosen in the \"Confirm New Password\" section"),
                        actions: [
                          TextButton(
                            onPressed: () =>{
                              Navigator.pop(context),
                              currentPasswordController.text = "",
                              newPasswordController.text = "",
                              secondNewPasswordController.text = "",
                            },
                            child: Text("Ok"),
                          ),
                        ],
                      );
                    }
                  );
                }
                else if(currentPasswordController.text != "" && newPasswordController.text == "" && secondNewPasswordController.text == ""){
                  showDialog(
                    context: context,
                    builder: (BuildContext myContext){
                      return AlertDialog(
                        title: Text("Password Change Unsuccessful"),
                        content: Text("The password change was unsuccessful because you have forgotten to enter in the new password that you have chosen in the \"New Password\" section and the new password that you have chosen in the \"Confirm New Password\" section"),
                        actions: [
                          TextButton(
                            onPressed: () =>{
                              Navigator.pop(context),
                              currentPasswordController.text = "",
                              newPasswordController.text = "",
                              secondNewPasswordController.text = "",
                            },
                            child: Text("Ok"),
                          ),
                        ],
                      );
                    }
                  );
                }
                else if(currentPasswordController.text == "" && newPasswordController.text == "" && secondNewPasswordController.text == ""){
                  showDialog(
                    context: context,
                    builder: (BuildContext myContext){
                      return AlertDialog(
                        title: Text("Password Change Unsuccessful"),
                        content: Text("The password change was unsuccessful because you have forgotten to enter in your current password, the new password that you have chosen in the \"New Password\" section, and the new password that you have chosen in the \"Confirm New Password\" section"),
                        actions: [
                          TextButton(
                            onPressed: () =>{
                              Navigator.pop(context),
                              currentPasswordController.text = "",
                              newPasswordController.text = "",
                              secondNewPasswordController.text = "",
                            },
                            child: Text("Ok"),
                          ),
                        ],
                      );
                    }
                  );
                }
              }
            ),
          ),
        ],
      ),
    );
  }
}