import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
import 'package:flutter/services.dart' show MaxLengthEnforcement, rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';

import 'package:starexpedition4/firebaseDesktopHelper.dart';

var theUsersUsername;
var theUsersEmail;

var checkForEmail;

String mySixDigitCode = "";

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

  Future<bool> usernameEmailMatch(String username, String emailAddress) async{
    bool match = false;

    if((myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == myUsernameController.text.toLowerCase()) != -1)){
      if(firebaseDesktopHelper.onDesktop){
        List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

        docForUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == username.toLowerCase(), orElse: () => <String, dynamic>{});
      }
      else{
        var theUserResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: username.toLowerCase()).get();
        theUserResult.docs.forEach((uOutcome){
          docForUser = uOutcome.data();
        });
      }
    }
    else{
      match = false;
    }

    if((myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == myUsernameController.text.toLowerCase()) != -1)){
      if(docForUser["emailAddress"] == myEmailController.text){
        match = true;
      }
      else{
        match = false;
      }
    }

    return match;
  }

  Future<List<Text>> dialogMessageForgottenPassword(List<String> l) async{
    List<Text> messageForUser = [];

    var usernameEmailResults = await usernameEmailMatch(myUsernameController.text, myEmailController.text);
    print(usernameEmailResults);

    //Checking if a username is registered on Star Expedition:
    List<String> listOfUsernames = [];

    var usernameResults;

    if(firebaseDesktopHelper.onDesktop){
      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

      allUsers.sort((b, a) => a["usernameLowercased"].toString().compareTo(b["usernameLowercased"].toString()));

      //Getting all of the usernames:
      listOfUsernames = allUsers.map((user) => user["usernameLowercased"] as String).toList();
      print("The list of users: ${listOfUsernames}");
    }
    else{
      usernameResults = await FirebaseFirestore.instance.collection("User").orderBy("usernameLowercased", descending: true).get();
      usernameResults.docs.forEach((person){
        var userDoc = person.data();
        var theUsername = userDoc["usernameLowercased"];
        listOfUsernames.add(theUsername);
      });
    }

    print("Username list: ${listOfUsernames}");

    //Checking if an email address is registered on Star Expedition:
    List<String> listOfEmailAddresses = [];

    var emailAddressResults;

    if(firebaseDesktopHelper.onDesktop){
      List<Map<String, dynamic>> allEmailAddresses = await firebaseDesktopHelper.getFirestoreCollection("User");

      allEmailAddresses.sort((b, a) => a["emailAddress"].toString().compareTo(b["emailAddress"].toString()));

      //Getting all of the usernames:
      listOfEmailAddresses = allEmailAddresses.map((user) => user["emailAddress"] as String).toList();
      print("The list of email addresses: ${listOfEmailAddresses}");
    }
    else{
      emailAddressResults = await FirebaseFirestore.instance.collection("User").orderBy("emailAddress", descending: true).get();
      emailAddressResults.docs.forEach((ea){
        var emailAddressDoc = ea.data();
        var theEmailAddress = emailAddressDoc["emailAddress"];
        listOfEmailAddresses.add(theEmailAddress);
      });
    }

    print("Email Address list: ${listOfEmailAddresses}");

    //Generating messages for the user:
    if(myUsernameController.text == ""){
      messageForUser.add(Text("Username is empty"));
    }
    if(!(listOfUsernames.contains(myUsernameController.text.toLowerCase())) && myUsernameController.text != ""){
      messageForUser.add(Text("Username not registered on Star Expedition"));
    }
    if(myEmailController.text == ""){
      messageForUser.add(Text("Email is empty"));
    }
    if(!(listOfEmailAddresses.contains(myEmailController.text)) && myEmailController.text != ""){
      messageForUser.add(Text("Email address not registered on Star Expedition"));
    }
    if(usernameEmailResults == false && listOfUsernames.contains(myUsernameController.text.toLowerCase()) && listOfEmailAddresses.contains(myEmailController.text) && myUsernameController.text != "" && myEmailController.text != ""){
      messageForUser.add(Text("The email address that you have entered does not belong to the username that you have entered"));
    }

    return messageForUser;
  }

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            showDialog(
              context: context,
              builder: (BuildContext myContext){
                return AlertDialog(
                  title: const Text("Are you sure you want to quit attempting to reset your password?"),
                  content: const Text("You will be redirected to the login page"),
                  actions: [
                    TextButton(
                      onPressed: () async{
                        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => loginPage()));
                        print("Going to login page");
                      },
                      child: Text("Yes"),
                    ),
                    TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text("No"),
                    )
                  ],
                );
              }
            ),
          },
        ),
      ),
      body: Wrap(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Forgot Your Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          /*Center(
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
          ),*/
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                    child: Center(
                        child: Container(
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.031250, top: MediaQuery.of(context).size.height * 0.015625, right: MediaQuery.of(context).size.width * 0.031250),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
                            ),
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                reverse: true,
                                child: SizedBox(
                                  child: TextField(
                                    minLines: 1,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Username",
                                    ),
                                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                    controller: myUsernameController,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                    )
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          /*Center(
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
          ),*/
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                    child: Center(
                        child: Container(
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.031250, top: MediaQuery.of(context).size.height * 0.015625, right: MediaQuery.of(context).size.width * 0.031250),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
                            ),
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                reverse: true,
                                child: SizedBox(
                                  child: TextField(
                                    minLines: 1,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Email address",
                                    ),
                                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                    controller: myEmailController,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                    )
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
              child: InkWell(
                child: Ink(
                  color: Colors.black,
                  //padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015625),
                  child: Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                ),
              ),
              onPressed: () async{
                print("Pressed");
                usersMessage = await dialogMessageForgottenPassword([myUsernameController.text, myEmailController.text]);

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

                                if(firebaseDesktopHelper.onDesktop){
                                  List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                  docForUser = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myUsernameController.text).toLowerCase(), orElse: () => <String, dynamic>{});

                                  print("This is docForUser: ${docForUser}");
                                }
                                else{
                                  var theUserResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myUsernameController.text).toLowerCase()).get();
                                  theUserResult.docs.forEach((outcome){
                                    docForUser = outcome.data();
                                    print("docForUser: ${docForUser}");
                                  });
                                }
                                //Leads to a page that has a six-digit code emailed to a user
                                theUsersUsername = docForUser["username"];
                                theUsersEmail = myEmailController.text;
                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => forgottenPasswordCodeEntry()));
                                mySixDigitCode = await emailNotifications.sixDigitCode();
                                print("mySixDigitCode: ${mySixDigitCode}");

                                emailNotifications.sendAnEmail(theUsersEmail, "Password Reset Code", "Hi ${theUsersUsername},<br><br>We have noticed that you have forgotten your password. Please enter in this 6-digit verification code into Star Expedition: <br>${mySixDigitCode}<br>Once you have entered it in, you may reset your password.<br><br>Best,<br>Star Expedition");
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

  List<Text> dialogMessageForgottenPasswordCode(String enteredPasscode){
    List<Text> messageForUser = [];

    if(numberController.text == ""){
      messageForUser.add(Text("Passcode is empty"));
    }
    if(enteredPasscode != mySixDigitCode && numberController.text != "" && (numberController.text).length >= 6){
      messageForUser.add(Text("The code that you have entered in is not correct"));
    }
    if((numberController.text).length < 6 && numberController.text != ""){
      messageForUser.add(Text("The code that you have entered in has less than six digits"));
    }

    return messageForUser;
  }

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () =>{
              showDialog(
                  context: context,
                  builder: (BuildContext myContext){
                    return AlertDialog(
                      title: const Text("Are you sure you want to quit attempting to reset your password?"),
                      content: const Text("You will be redirected to the login page"),
                      actions: [
                        TextButton(
                          onPressed: () async{
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => loginPage()));
                            print("Going to login page");
                          },
                          child: Text("Yes"),
                        ),
                        TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: Text("No"),
                        )
                      ],
                    );
                  }
              ),
            }
        ),
      ),
      body: Wrap(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Enter in the 6-digit code that was emailed to you", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0), textAlign: TextAlign.center),
          ),
          /*Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),*/
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                    child: Center(
                        child: Container(
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.031250, top: MediaQuery.of(context).size.height * 0.031250, right: MediaQuery.of(context).size.width * 0.031250),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
                            ),
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                reverse: true,
                                child: SizedBox(
                                  child: TextField(
                                    minLines: 1,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Six-digit code",
                                    ),
                                    maxLength: 6,
                                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                    controller: numberController,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                    )
                ),
              ],
            ),
          ),
          /*Container(
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
          ),*/
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
              child: InkWell(
                child: Ink(
                  color: Colors.black,
                  //padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015625),
                  child: Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                ),
              ),
              onPressed: (){
                //Go to "changing password" screen
                usersMessage = dialogMessageForgottenPasswordCode(numberController.text);
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

  bool whitespaceChecker(String? myString){
    if(myString == null){
      return true;
    }

    return myString.contains(RegExp(r'\s'));
  }

  Future<String> getUsersPassword(String username) async{
    var theUserDoc;
    String usersDecryptedPass = "";

    if(firebaseDesktopHelper.onDesktop){
      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

      theUserDoc = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == username.toLowerCase(), orElse: () => <String, dynamic>{});

      print("This is theUserDoc: ${theUserDoc}");
    }
    else{
      var theUserResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: username.toLowerCase()).get();
      theUserResult.docs.forEach((outcome){
        theUserDoc = outcome.data();
        print("This is the outcome: ${theUserDoc}");
      });
    }

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
    if((checkLetters(newPassController.text) == false || checkLetters(confirmNewPassController.text) == false) && newPassController.text != "" && confirmNewPassController.text != ""){
      messageForUser.add(Text("Your new password must contain at least one letter"));
    }
    if((checkNumbers(newPassController.text) == false || checkNumbers(confirmNewPassController.text) == false) && newPassController.text != "" && confirmNewPassController.text != ""){
      messageForUser.add(Text("Your new password must contain at least one number"));
    }
    if((checkSpecialCharacters(newPassController.text) == false || checkSpecialCharacters(confirmNewPassController.text) == false) && newPassController.text != "" && confirmNewPassController.text != ""){
      messageForUser.add(Text("Your new password must contain at least one special character"));
    }
    if(((newPassController.text).length < 8 || (confirmNewPassController.text).length < 8) && newPassController.text != "" && confirmNewPassController.text != ""){
      messageForUser.add(Text("Your new password must be at least 8 characters long"));
    }
    if((whitespaceChecker(newPassController.text) && newPassController.text != "") || (whitespaceChecker(confirmNewPassController.text) && confirmNewPassController.text != "")){
      messageForUser.add(Text("Your new password must not contain any whitespace"));
    }

    return messageForUser;
  }

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () =>{
              showDialog(
                  context: context,
                  builder: (BuildContext myContext){
                    return AlertDialog(
                      title: const Text("Are you sure you want to quit attempting to reset your password?"),
                      content: const Text("You will be redirected to the login page"),
                      actions: [
                        TextButton(
                          onPressed: () async{
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => loginPage()));
                            print("Going to login page");
                          },
                          child: Text("Yes"),
                        ),
                        TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: Text("No"),
                        )
                      ],
                    );
                  }
              ),
            }
        ),
      ),
      body: Wrap(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Reset Your Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0), textAlign: TextAlign.center),
          ),
          /*Center(
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
          ),*/
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                    child: Center(
                        child: Container(
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.031250, top: MediaQuery.of(context).size.height * 0.031250, right: MediaQuery.of(context).size.width * 0.031250),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
                            ),
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                reverse: true,
                                child: SizedBox(
                                  child: TextField(
                                    minLines: 1,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "New password",
                                    ),
                                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                    controller: newPassController,
                                    obscureText: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                    )
                ),
              ],
            ),
          ),
          /*Container(
            height: 5,
          ),*/
          /*Center(
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
          ),*/
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                    child: Center(
                        child: Container(
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.031250, top: MediaQuery.of(context).size.height * 0.031250, right: MediaQuery.of(context).size.width * 0.031250),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
                            ),
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                reverse: true,
                                child: SizedBox(
                                  child: TextField(
                                    minLines: 1,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Confirm new password",
                                    ),
                                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                    controller: confirmNewPassController,
                                    obscureText: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                    )
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
              child: InkWell(
                child: Ink(
                  color: Colors.black,
                  //padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015625),
                  child: Text("Reset Your Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                ),
              ),
              onPressed: () async{
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

                                if(firebaseDesktopHelper.onDesktop){
                                  List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                  docForUser = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == theUsersUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                  print("This is docForUser: ${docForUser}");

                                  gettingTheDocName = docForUser["docId"];

                                  print("This is gettingTheDocName: ${gettingTheDocName}");

                                  //Getting the current password of the user:
                                  //Map<String, dynamic> passwordInfoOfUser = Map<String, dynamic>.from(docForUser["password"] ?? {});

                                  //Updating a user's changes to his or her password:
                                  await firebaseDesktopHelper.updateFirestoreDocument("User/$gettingTheDocName", {
                                    "password": encryptMyPassword(myKey, newPassController.text).base64,
                                  });
                                }
                                else{
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
                                }

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
                            Navigator.pop(context);
                            newPassController.text = "";
                            confirmNewPassController.text = "";
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