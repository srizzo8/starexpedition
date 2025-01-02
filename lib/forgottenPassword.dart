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
import 'package:starexpedition4/userProfile.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';

var theUsersUsername;
var theUsersEmail;

int mySixDigitCode = 0;

class forgottenPassword extends StatefulWidget{
  const forgottenPassword ({Key? key}) : super(key: key);

  @override
  forgottenPasswordState createState() => forgottenPasswordState();
}

class forgottenPasswordCodeEntry extends StatefulWidget{
  const forgottenPasswordCodeEntry ({Key? key}) : super(key: key);

  @override
  forgottenPasswordCodeEntryState createState() => forgottenPasswordCodeEntryState();
}

class resetPassword extends StatefulWidget{
  const resetPassword ({Key? key}) : super(key: key);

  @override
  resetPasswordState createState() => resetPasswordState();
}

class forgottenPasswordState extends State<forgottenPassword>{
  TextEditingController myUsernameController = TextEditingController();
  TextEditingController myEmailController = TextEditingController();
  List<Text> usersMessage = [];

  var docForUser;
  var docForEmail;

  Future<bool> compareDocuments(String username, String emailAddress) async{
    bool match = false;

    var theUserResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: username.toLowerCase()).get();
    theUserResult.docs.forEach((uOutcome){
      docForUser = uOutcome.data();
    });

    var theEmailResult = await FirebaseFirestore.instance.collection("User").where("emailAddress", isEqualTo: emailAddress).get();
    theEmailResult.docs.forEach((eOutcome){
      docForEmail = eOutcome.data();
    });

    if(docForUser == docForEmail){
      match = true;
    }
    else{
      match = false;
    }

    return match;
  }

  List<Text> dialogMessageForgottenPassword(List<String> l){
    List<Text> messageForUser = [];

    if(myUsernameController.text == ""){
      messageForUser.add(Text("Username is empty"));
    }
    if(myEmailController.text == ""){
      messageForUser.add(Text("Email is empty"));
    }
    if((myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == myUsernameController.text.toLowerCase()) == -1) && myUsernameController.text != ""){
      messageForUser.add(Text("Username not registered on Star Expedition"));
    }
    if((myMain.theUsers!.indexWhere((person) => person.email?.toLowerCase() == myEmailController.text.toLowerCase()) == -1) && myEmailController.text != ""){
      messageForUser.add(Text("Email address not registered on Star Expedition"));
    }
    if(compareDocuments(myUsernameController.text, myEmailController.text) == false){
      messageForUser.add(Text("The email address that you have entered does not belong to the username that you have entered"));
    }

    return messageForUser;
  }

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        /*leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            print("Hello"),
          }
        ),*/
      ),
      body: Wrap(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Forgot Your Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: 5,
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
              controller: myUsernameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            height: 5,
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(0.0),
              alignment: Alignment.centerLeft,
              child: Text("Email address", style: TextStyle(fontSize: 14.0)),
              height: 20,
              width: 380,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: myEmailController,
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
                child: Text("Submit", style: TextStyle(color: Colors.white)),
              ),
              onTap: () async{
                print("Pressed");
                usersMessage = dialogMessageForgottenPassword([myUsernameController.text, myEmailController.text]);
                if(usersMessage.isEmpty){
                  showDialog(
                      context: context,
                      builder: (BuildContext myContext){
                        return AlertDialog(
                          title: const Text("Successful"),
                          content: const Text("You will receive an email containing further instructions regarding retrieving the password of your account"),
                          actions: [
                            TextButton(
                              onPressed: () async{
                                //Getting the person's username
                                var docForUser;
                                var theUserResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myUsernameController.text).toLowerCase()).get();
                                theUserResult.docs.forEach((outcome){
                                  docForUser = outcome.data();
                                  print("docForUser: ${docForUser}");
                                });
                                //Leads to a page that has a six-digit code emailed to a user
                                theUsersUsername = docForUser["username"];
                                theUsersEmail = myEmailController.text;
                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => forgottenPasswordCodeEntry()));
                                mySixDigitCode = await emailNotifications.sixDigitCode();
                                print("mySixDigitCode: ${mySixDigitCode}");
                                emailNotifications.sixDigitCodeEmail(mySixDigitCode);
                              },
                              child: const Text("Ok"),
                            )
                          ],
                        );
                      }
                  );
                }
                else{
                  showDialog(
                    context: context,
                    builder: (myContent) => AlertDialog(
                      title: Text("Unsuccessful"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(usersMessage.length, (i){
                          return usersMessage[i];
                        }),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                            myUsernameController.text = "";
                            myEmailController.text = "";
                          },
                          child: Container(
                            child: const Text("Ok"),
                          ),
                        ),
                      ],
                    ),
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

class forgottenPasswordCodeEntryState extends State<forgottenPasswordCodeEntry>{
  TextEditingController numberController = TextEditingController();
  List<Text> usersMessage = [];

  List<Text> dialogMessageForgottenPasswordCode(int enteredPasscode){
    List<Text> messageForUser = [];

    if(numberController.text == ""){
      messageForUser.add(Text("Passcode is empty"));
    }
    if(enteredPasscode != mySixDigitCode){
      messageForUser.add(Text("The code that you have entered in is not correct"));
    }
    if((numberController.text).length < 6){
      messageForUser.add(Text("The code that you have entered in has less than six digits"));
    }

    return messageForUser;
  }

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
      ),
      body: Wrap(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Enter in the 6-digit code that was emailed to you", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: 5,
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              controller: numberController,
              maxLength: 6,
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
          ),
          Center(
            child: InkWell(
              child: Ink(
                color: Colors.black,
                padding: EdgeInsets.all(5.0),
                child: Text("Submit", style: TextStyle(color: Colors.white)),
              ),
              onTap: (){
                //Go to "changing password" screen
                usersMessage = dialogMessageForgottenPasswordCode(int.parse(numberController.text));
                if(usersMessage.isEmpty){
                  showDialog(
                      context: context,
                      builder: (BuildContext myContext){
                        return AlertDialog(
                          title: const Text("Successful"),
                          content: const Text("You can now reset your password"),
                          actions: [
                            TextButton(
                              onPressed: () async => {
                                //Leads to a page where one can reset his or her password
                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => resetPassword())),
                              },
                              child: const Text("Ok"),
                            )
                          ],
                        );
                      }
                  );
                }
                else{
                  showDialog(
                    context: context,
                    builder: (myContent) => AlertDialog(
                      title: Text("Unsuccessful"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(usersMessage.length, (i){
                          return usersMessage[i];
                        }),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                            numberController.text = "";
                          },
                          child: Container(
                            child: const Text("Ok"),
                          ),
                        ),
                      ],
                    ),
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

class resetPasswordState extends State<resetPassword>{
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmNewPassController = TextEditingController();
  List<Text> usersMessage = [];

  Future<String> getUsersPassword(String username) async{
    var theUserDoc;
    String usersDecryptedPass = "";
    var theUserResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: username.toLowerCase()).get();
    theUserResult.docs.forEach((outcome){
      theUserDoc = outcome.data();
      print("This is the outcome: ${theUserDoc}");
    });

    usersDecryptedPass = decryptMyPassword(myKey, theUserDoc["password"]);

    return usersDecryptedPass;
  }

  Future<List<Text>> dialogMessageForgottenPassword(List<String> myList) async {
    List<Text> messageForUser = [];
    String usersPass = await getUsersPassword(theUsersUsername);

    if(newPassController.text == ""){
      messageForUser.add(Text("New password is empty"));
    }
    if(confirmNewPassController.text == ""){
      messageForUser.add(Text("Confirm new password is empty"));
    }
    if(newPassController.text == usersPass && newPassController.text != "" || confirmNewPassController.text == usersPass && confirmNewPassController.text != ""){
      messageForUser.add(Text("Your new password cannot be your current password"));
    }
    if(newPassController.text != confirmNewPassController.text && newPassController.text != "" && confirmNewPassController.text != ""){
      messageForUser.add(Text("The new password and confirm new password that you have entered do not match"));
    }

    return messageForUser;
  }

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
      ),
      body: Wrap(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Reset your password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: 5,
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
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              controller: newPassController,
              obscureText: true,
            ),
          ),
          Container(
            height: 5,
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
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              controller: confirmNewPassController,
              obscureText: true,
            ),
          ),
          Container(
            height: 5,
          ),
          Center(
            child: InkWell(
              child: Ink(
                color: Colors.black,
                padding: EdgeInsets.all(5.0),
                child: Text("Reset Your Password", style: TextStyle(color: Colors.white)),
              ),
              onTap: () async{
                usersMessage = await dialogMessageForgottenPassword([newPassController.text, confirmNewPassController.text]);
                if(usersMessage.isEmpty){
                  showDialog(
                      context: context,
                      builder: (BuildContext myContext){
                        return AlertDialog(
                          title: const Text("Successful"),
                          content: const Text("You have successfully resetted your password"),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                //Changing a user's password
                                /*var docForUser;
                                var theUserResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theUsersUsername.toLowerCase()).get();
                                theUserResult.docs.forEach((outcome){
                                  docForUser = outcome.data();
                                  print("This is the outcome: ${outcome.data()}");
                                });*/
                                var docForUser;
                                var gettingTheDocName;
                                var theUserResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theUsersUsername.toLowerCase()).get();
                                theUserResult.docs.forEach((result){
                                  docForUser = result.data();
                                  print("This is the result: ${docForUser}");
                                  gettingTheDocName = result.id;
                                  print("gettingTheDocName: ${gettingTheDocName}");
                                });

                                FirebaseFirestore.instance.collection("User").doc(gettingTheDocName).update({"password" : encryptMyPassword(myKey, newPassController.text).base64}).whenComplete(() async{
                                  print("Updated");
                                }).catchError((e) => print("This is your error: ${e}"));

                                //Leads to the Star Expedition login page:
                                //myUsername = theUsersUsername;
                                //loginBool = true;
                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => loginPage()));
                              },
                              child: const Text("Ok"),
                            )
                          ],
                        );
                      }
                  );
                }
                else{
                  showDialog(
                    context: context,
                    builder: (myContent) => AlertDialog(
                      title: Text("Unsuccessful"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(usersMessage.length, (i){
                          return usersMessage[i];
                        }),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: (){
                            newPassController.text = "";
                            confirmNewPassController.text = "";
                            Navigator.pop(context);
                          },
                          child: Container(
                            child: const Text("Ok"),
                          ),
                        ),
                      ],
                    ),
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