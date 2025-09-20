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

var theUser;
var theNewUser;
var usersEmail;
var usersEmailForEmailChangeMessage;
var usersNewEmail;
var userForEmailChange;

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
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => myMain.StarExpedition())),
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(175, 36),
              maximumSize: Size(175, 36),
              primary: Colors.black,
            ),
            child: InkWell(
              child: Ink(
                child: Text("Change Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
              ),
            ),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => changePasswordPage()));
            }
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(175, 36),
              maximumSize: Size(175, 36),
              primary: Colors.black,
            ),
            child: InkWell(
              child: Ink(
                child: Text("Change Email Address", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
              ),
            ),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => changeEmailAddressPage()));
            }
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(175, 36),
              maximumSize: Size(175, 36),
              primary: Colors.black,
            ),
            child: InkWell(
              child: Ink(
                child: Text("Update Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
              ),
            ),
            onPressed: () async{
              //Adding info about user blurb, interests, and location
              if(myUsername != "" && myNewUsername == ""){
                await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get().then((result){
                  myMain.usersBlurb = result.docs.first.data()["usernameProfileInformation"]["userInformation"];
                  myMain.usersInterests = result.docs.first.data()["usernameProfileInformation"]["userInterests"];
                  myMain.usersLocation = result.docs.first.data()["usernameProfileInformation"]["userLocation"];
                  //myMain.numberOfPostsUserHasMade = result.docs.first.data()["usernameProfileInformation"]["numberOfPosts"];
                  //myMain.starsUserTracked = result.docs.first.data()["usernameProfileInformation"]["starsTracked"];
                  //myMain.planetsUserTracked = result.docs.first.data()["usernameProfileInformation"]["planetsTracked"];
                });
              }
              else if(myUsername == "" && myNewUsername != ""){
                await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get().then((result){
                  myMain.usersBlurb = result.docs.first.data()["usernameProfileInformation"]["userInformation"];
                  myMain.usersInterests = result.docs.first.data()["usernameProfileInformation"]["userInterests"];
                  myMain.usersLocation = result.docs.first.data()["usernameProfileInformation"]["userLocation"];
                  //myMain.numberOfPostsUserHasMade = result.docs.first.data()["usernameProfileInformation"]["numberOfPosts"];
                  //myMain.starsUserTracked = result.docs.first.data()["usernameProfileInformation"]["starsTracked"];
                  //myMain.planetsUserTracked = result.docs.first.data()["usernameProfileInformation"]["planetsTracked"];
                });
              }
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => editingMyUserProfile()));
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
  List messageForUsers = [];

  List<Text> dialogMessageChangePassword(List<String> info){
    List<Text> usersMessage = [];
    if(currentPasswordController.text == ""){
      usersMessage.add(Text("Current password is empty"));
    }
    if(currentPasswordController.text != usersPass && currentPasswordController.text != ""){
      usersMessage.add(Text("The current password that you entered is not correct"));
    }
    if(newPasswordController.text == ""){
      usersMessage.add(Text("New password is empty"));
    }
    if(secondNewPasswordController.text == ""){
      usersMessage.add(Text("Confirm new password is empty"));
    }
    if((checkLetters(newPasswordController.text) == false || checkLetters(secondNewPasswordController.text) == false) && newPasswordController.text != "" && secondNewPasswordController.text != ""){
      usersMessage.add(Text("Your new password must have at least one character"));
    }
    if((checkNumbers(newPasswordController.text) == false || checkNumbers(secondNewPasswordController.text) == false) && newPasswordController.text != "" && secondNewPasswordController.text != ""){
      usersMessage.add(Text("Your new password must have at least one number"));
    }
    if((checkSpecialCharacters(newPasswordController.text) == false || checkSpecialCharacters(secondNewPasswordController.text) == false) && newPasswordController.text != "" && secondNewPasswordController.text != ""){
      usersMessage.add(Text("Your new password must have at least one special character"));
    }
    if(((newPasswordController.text).length < 8 || (secondNewPasswordController.text).length < 8) && newPasswordController.text != "" && secondNewPasswordController.text != ""){
      usersMessage.add(Text("Your new password must have at least 8 characters"));
    }
    if(newPasswordController.text != secondNewPasswordController.text && newPasswordController.text != "" && secondNewPasswordController.text != ""){
      usersMessage.add(Text("The passwords that you entered in the \"New Password\" and \"Confirm New Password\" sections do not match"));
    }
    if((currentPasswordController.text == newPasswordController.text || currentPasswordController.text == secondNewPasswordController.text) && currentPasswordController.text == usersPass && newPasswordController.text != "" && secondNewPasswordController.text != ""){
      usersMessage.add(Text("Your new password cannot be your current password"));
    }
    return usersMessage;
  }

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
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Change Your Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
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
                            maxWidth: 320,
                          ),
                          child: SizedBox(
                            child: TextField(
                              minLines: 1,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Current Password",
                              ),
                              controller: currentPasswordController,
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
                            maxWidth: 320,
                          ),
                          child: SizedBox(
                            child: TextField(
                              minLines: 1,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "New Password",
                              ),
                              controller: newPasswordController,
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
                            maxWidth: 320,
                          ),
                          child: SizedBox(
                            child: TextField(
                              minLines: 1,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Confirm New Password",
                              ),
                              controller: secondNewPasswordController,
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
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
              child: InkWell(
                child: Ink(
                  color: Colors.black,
                  padding: EdgeInsets.all(5.0),
                  child: Text("Confirm Your Password Change", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                ),
              ),
              onPressed: () async{
                  print("currentPasswordController.text: ${currentPasswordController.text}");
                  print("newPasswordController.text: ${newPasswordController.text}");
                  print("secondNewPasswordController.text: ${secondNewPasswordController.text}");
                  print("myUsername = ${myUsername}, myNewUsername = ${myNewUsername}");
                  if(myUsername != "" && myNewUsername == ""){
                    myUserResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                    myUserResult.docs.forEach((result){
                      userDoc = result.data();
                      print("This is the result: ${result.data()}");
                      gettingDocName = result.id;
                    });
                    print("userDoc[password]: ${userDoc["password"].toString()}");

                    usersPass = decryptMyPassword(myKey, userDoc["password"]);
                    print("usersPass: ${usersPass}");

                    messageForUsers = dialogMessageChangePassword([currentPasswordController.text, newPasswordController.text, secondNewPasswordController.text]);

                    if(messageForUsers.isEmpty){
                      //Password successfully changed
                      print("gettingDocName: ${gettingDocName.toString()}");

                      FirebaseFirestore.instance.collection("User").doc(gettingDocName).update({"password" : encryptMyPassword(myKey, newPasswordController.text).base64}).whenComplete(() async{
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
                    else{
                      showDialog(
                        context: context,
                        builder: (myContent) => AlertDialog(
                          title: Text("Password Change Unsuccessful"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(messageForUsers.length, (i){
                              return messageForUsers[i];
                            }),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: (){
                                Navigator.of(myContent).pop();
                                currentPasswordController.text = "";
                                newPasswordController.text = "";
                                secondNewPasswordController.text = "";
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
                  else if(myUsername == "" && myNewUsername != ""){
                    myUserResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                    myUserResult.docs.forEach((result){
                      userDoc = result.data();
                      print("This is the result: ${result.data()}");
                      gettingDocName = result.id;
                    });
                    print("userDoc[password]: ${userDoc["password"].toString()}");

                    usersPass = decryptMyPassword(myKey, userDoc["password"]);
                    print("usersPass: ${usersPass}");

                    messageForUsers = dialogMessageChangePassword([currentPasswordController.text, newPasswordController.text, secondNewPasswordController.text]);

                    if(messageForUsers.isEmpty){
                      //Password successfully changed
                      print("gettingDocName: ${gettingDocName.toString()}");

                      FirebaseFirestore.instance.collection("User").doc(gettingDocName).update({"password" : encryptMyPassword(myKey, newPasswordController.text).base64}).whenComplete(() async{
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
                    else{
                      showDialog(
                        context: context,
                        builder: (myContent) => AlertDialog(
                          title: Text("Password Change Unsuccessful"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(messageForUsers.length, (i){
                              return messageForUsers[i];
                            }),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: (){
                                Navigator.of(myContent).pop();
                                currentPasswordController.text = "";
                                newPasswordController.text = "";
                                secondNewPasswordController.text = "";
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
                }
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class changeEmailAddressPage extends StatefulWidget{
  const changeEmailAddressPage({Key? key}) : super(key: key);

  @override
  changeEmailAddressPageState createState() => changeEmailAddressPageState();
}

class changeEmailAddressPageState extends State<changeEmailAddressPage>{
  TextEditingController currentEmailAddressController = TextEditingController();
  TextEditingController newEmailAddressController = TextEditingController();
  TextEditingController myPasswordController = TextEditingController();

  var myEmailResult;
  var gettingDocName;
  var docForUsername;
  var docForPassword;

  var du;
  var usersEmailAddress;
  List messageForUsers = [];

  List<Text> dialogMessageChangeEmailAddress(List<String> info){
    List<Text> usersMessage = [];
    if(currentEmailAddressController.text == ""){
      usersMessage.add(Text("Current email address is empty"));
    }
    if((currentEmailAddressController.text).toLowerCase() != (docForUsername["emailAddress"]).toLowerCase() && currentEmailAddressController.text != ""){
      usersMessage.add(Text("The current email address that you entered is not correct"));
    }
    if(newEmailAddressController.text == ""){
      usersMessage.add(Text("New email address is empty"));
    }
    if((newEmailAddressController.text).toLowerCase() == (docForUsername["emailAddress"]).toLowerCase() && newEmailAddressController.text != ""){
      usersMessage.add(Text("Your new email address cannot be your current email address"));
    }
    if((currentEmailAddressController.text).toLowerCase() == (newEmailAddressController.text).toLowerCase() && currentEmailAddressController.text != "" && newEmailAddressController.text != ""){
      usersMessage.add(Text("Current email address and new email address cannot match"));
    }
    if(checkEmailValidity(newEmailAddressController.text) == false && newEmailAddressController.text != ""){
      usersMessage.add(Text("Your new email address is invalid"));
    }
    if(myPasswordController.text == ""){
      usersMessage.add(Text("Password is empty"));
    }
    if(myPasswordController.text != decryptMyPassword(myKey, docForUsername["password"]) && myPasswordController.text != ""){
      usersMessage.add(Text("The password that you have entered is not correct"));
    }

    return usersMessage;
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            Navigator.push(context, MaterialPageRoute(builder: (context) => settingsPage())),
          }
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Change Your Email Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          /*Center(
            child: Container(
              padding: const EdgeInsets.all(0.0),
              alignment: Alignment.centerLeft,
              child: Text("Current Email Address", style: TextStyle(fontSize: 14.0)),
              height: 20,
              width: 380,
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            child: TextField(
              controller: currentEmailAddressController,
              decoration: InputDecoration(
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
                        padding: EdgeInsets.only(left: 10.0, top: 20.0, right: 10.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 320,
                          ),
                          child: SizedBox(
                            child: TextField(
                              minLines: 1,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Current Email Address",
                              ),
                              controller: currentEmailAddressController,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
            ),
          ),
          /*Center(
            child: Container(
              padding: const EdgeInsets.all(0.0),
              alignment: Alignment.centerLeft,
              child: Text("New Email Address", style: TextStyle(fontSize: 14.0)),
              height: 20,
              width: 380,
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            child: TextField(
              controller: newEmailAddressController,
              decoration: InputDecoration(
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
                        padding: EdgeInsets.only(left: 10.0, top: 20.0, right: 10.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 320,
                          ),
                          child: SizedBox(
                            child: TextField(
                              minLines: 1,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "New Email Address",
                              ),
                              controller: newEmailAddressController,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
            ),
          ),
          /*Center(
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
              controller: myPasswordController,
              obscureText: true,
              decoration: InputDecoration(
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
                        padding: EdgeInsets.only(left: 10.0, top: 20.0, right: 10.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 320,
                          ),
                          child: SizedBox(
                            child: TextField(
                              minLines: 1,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Password",
                              ),
                              controller: myPasswordController,
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
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
              child: InkWell(
                child: Ink(
                  color: Colors.black,
                  padding: EdgeInsets.all(5.0),
                  child: Text("Confirm Your Email Address Change", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                ),
              ),
                onPressed: () async{
                  //if(currentEmailAddressController.text != "" && newEmailAddressController.text != "" && myPasswordController.text != ""){
                  if(myUsername != "" && myNewUsername == ""){
                    myEmailResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                    myEmailResult.docs.forEach((myResult){
                      docForUsername = myResult.data();
                      print("This is the result: ${myResult.data()}");
                      gettingDocName = myResult.id;
                    });
                    print("docForUsername[emailAddress]: ${docForUsername["emailAddress"].toString()}");
                    usersEmailForEmailChangeMessage = docForUsername["emailAddress"];
                    userForEmailChange = myUsername;

                    messageForUsers = dialogMessageChangeEmailAddress([currentEmailAddressController.text, newEmailAddressController.text, myPasswordController.text]);

                    if(messageForUsers.isEmpty){
                      //email address successfully changed
                      print("Your email will change");

                      FirebaseFirestore.instance.collection("User").doc(gettingDocName).update({"emailAddress" : newEmailAddressController.text}).whenComplete(() async{
                        print("Updated the email address");
                      }).catchError((e) => print("This is your error: ${e}"));

                      var newEmailResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                      newEmailResult.docs.forEach((theResult){
                        du = theResult.data();
                        print("This is the result: ${theResult.data()}");
                        //var gettingDn = theResult.id;
                      });

                      print("This is new user email address: ${docForUsername["emailAddress"]}");

                      showDialog(
                          context: context,
                          builder: (BuildContext bc){
                            return AlertDialog(
                              title: Text("Email Address Change Successful"),
                              content: Text("You have successfully changed your email address"),
                              actions: [
                                TextButton(
                                  onPressed: () => {
                                    usersEmailAddress = docForUsername["emailAddress"],
                                    usersNewEmail = du["emailAddress"],
                                    print("usersNewEmail: ${usersNewEmail}"),
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => settingsPage())),
                                    emailNotifications.emailAddressChangeConfirmationEmail(),
                                    currentEmailAddressController.text = "",
                                    newEmailAddressController.text = "",
                                    myPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                      );
                    }
                    else{
                      showDialog(
                        context: context,
                        builder: (myContent) => AlertDialog(
                          title: Text("Email Address Change Unsuccessful"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(messageForUsers.length, (i){
                              return messageForUsers[i];
                            }),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                                currentEmailAddressController.text = "";
                                newEmailAddressController.text = "";
                                myPasswordController.text = "";
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
                  else if(myUsername == "" && myNewUsername != ""){
                    myEmailResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                    myEmailResult.docs.forEach((myResult){
                      docForUsername = myResult.data();
                      print("This is the result: ${myResult.data()}");
                      gettingDocName = myResult.id;
                    });
                    print("docForUsername[emailAddress]: ${docForUsername["emailAddress"].toString()}");
                    usersEmailForEmailChangeMessage = docForUsername["emailAddress"];
                    userForEmailChange = myNewUsername;

                    messageForUsers = dialogMessageChangeEmailAddress([currentEmailAddressController.text, newEmailAddressController.text, myPasswordController.text]);

                    if(messageForUsers.isEmpty){
                      //email address successfully changed
                      print("Your email will change");

                      FirebaseFirestore.instance.collection("User").doc(gettingDocName).update({"emailAddress" : newEmailAddressController.text}).whenComplete(() async{
                        print("Updated the email address");
                      }).catchError((e) => print("This is your error: ${e}"));

                      var newEmailResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                      newEmailResult.docs.forEach((theResult){
                        du = theResult.data();
                        print("This is the result: ${theResult.data()}");
                        //var gettingDn = theResult.id;
                      });

                      print("This is new user email address: ${docForUsername["emailAddress"]}");

                      showDialog(
                          context: context,
                          builder: (BuildContext bc){
                            return AlertDialog(
                              title: Text("Email Address Change Successful"),
                              content: Text("You have successfully changed your email address"),
                              actions: [
                                TextButton(
                                  onPressed: () => {
                                    usersEmailAddress = docForUsername["emailAddress"],
                                    usersNewEmail = du["emailAddress"],
                                    print("usersNewEmail: ${usersNewEmail}"),
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => settingsPage())),
                                    emailNotifications.emailAddressChangeConfirmationEmail(),
                                    currentEmailAddressController.text = "",
                                    newEmailAddressController.text = "",
                                    myPasswordController.text = "",
                                  },
                                  child: Text("Ok"),
                                ),
                              ],
                            );
                          }
                      );
                    }
                    else{
                      showDialog(
                        context: context,
                        builder: (myContent) => AlertDialog(
                          title: Text("Email Address Change Unsuccessful"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(messageForUsers.length, (i){
                              return messageForUsers[i];
                            }),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                                currentEmailAddressController.text = "";
                                newEmailAddressController.text = "";
                                myPasswordController.text = "";
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
                }
            ),
          ),
        ],
      ),
    ),
    );
  }
}