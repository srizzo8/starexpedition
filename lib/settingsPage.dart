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
import 'package:provider/provider.dart';
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
import 'package:starexpedition4/firebaseDesktopHelper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'login_information/loginStatus.dart';

var theUser;
var theNewUser;
var usersEmail;
var usersEmailForEmailChangeMessage;
var usersNewEmail;
var userForEmailChange;

var myUsernameForProfilePicture;
bool hasProfilePicture = false;

bool whitespaceChecker(String? myString){
  if(myString == null){
    return true;
  }

  return myString.contains(RegExp(r'\s'));
}

//Check if a user has a profile picture:
Future<bool> checkUserProfilePicture(String nameOfUser) async{
  var myInformation;
  var usersData;

  if(firebaseDesktopHelper.onDesktop){
    List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

    var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == nameOfUser.toLowerCase(), orElse: () => <String, dynamic>{});

    //Getting the user's current profile information:
    Map<String, dynamic> usersCurrentInfo = Map<String, dynamic>.from(usersProfileInfo["usernameProfileInformation"]);

    if(usersCurrentInfo["userProfilePicture"] == ""){
      return false;
    }
    else{
      return true;
    }
  }
  else{
    myInformation = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: nameOfUser.toLowerCase()).get();
    myInformation.docs.forEach((myResult){
      usersData = myResult.data();
    });

    if(usersData["usernameProfileInformation"]["userProfilePicture"] == ""){
      return false;
    }
    else{
      return true;
    }
  }
}

class settingsPage extends StatefulWidget{
  const settingsPage ({Key? key}) : super(key: key);

  @override
  settingsPageState createState() => settingsPageState();
}

class settingsPageState extends State<settingsPage> with RouteAware{
  static String nameOfRoute = '/settings';

  bool changePasswordButton = false;
  bool changeEmailAddressButton = false;
  bool updateProfileButton = false;

  //Lifecycle methods (didChangeDependencies() and dispose()):
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    myMain.routesToOtherPages.myRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose(){
    myMain.routesToOtherPages.myRouteObserver.unsubscribe(this);
    super.dispose();
  }

  //RouteAware methods (didPopNext() and didPush()):
  @override
  void didPopNext(){
    //Called when returning to this page:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  @override
  void didPush(){
    //Called when the page is pushed:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  Widget build(BuildContext context){
    final myLoginStatus = context.watch<loginStatus>();
    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            child: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          AbsorbPointer(
            absorbing: changePasswordButton,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: (kIsWeb || firebaseDesktopHelper.onDesktop)? Size(MediaQuery.of(context).size.width * 0.5, MediaQuery.of(context).size.height * 0.0625) : Size(175, 50),
                maximumSize: (kIsWeb || firebaseDesktopHelper.onDesktop)? Size(MediaQuery.of(context).size.width * 0.5, MediaQuery.of(context).size.height * 0.0625) : Size(175, 50),
                backgroundColor: Colors.black,
              ),
              child: InkWell(
                child: Ink(
                  child: Text("Change Password", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                ),
              ),
              onPressed: (){
                if(changePasswordButton){
                  return;
                }

                setState(() => changePasswordButton = true);

                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => changePasswordPage())).then((_){
                  if(mounted){
                    setState(() => changePasswordButton = false);
                  }
                });
              }
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          AbsorbPointer(
            absorbing: changeEmailAddressButton,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: (kIsWeb || firebaseDesktopHelper.onDesktop)? Size(MediaQuery.of(context).size.width * 0.5, MediaQuery.of(context).size.height * 0.0625) : Size(175, 50),
                maximumSize: (kIsWeb || firebaseDesktopHelper.onDesktop)? Size(MediaQuery.of(context).size.width * 0.5, MediaQuery.of(context).size.height * 0.0625) : Size(175, 50),
                backgroundColor: Colors.black,
              ),
              child: InkWell(
                child: Ink(
                  child: Text("Change Email\nAddress", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                ),
              ),
              onPressed: (){
                if(changeEmailAddressButton){
                  return;
                }

                setState(() => changeEmailAddressButton = true);

                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => changeEmailAddressPage())).then((_){
                  if(mounted){
                    setState(() => changeEmailAddressButton = false);
                  }
                });
              }
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          AbsorbPointer(
          absorbing: updateProfileButton,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: (kIsWeb || firebaseDesktopHelper.onDesktop)? Size(MediaQuery.of(context).size.width * 0.5, MediaQuery.of(context).size.height * 0.0625) : Size(175, 50),
              maximumSize: (kIsWeb || firebaseDesktopHelper.onDesktop)? Size(MediaQuery.of(context).size.width * 0.5, MediaQuery.of(context).size.height * 0.0625) : Size(175, 50),
              backgroundColor: Colors.black,
            ),
            child: InkWell(
              child: Ink(
                child: Text("Update Profile", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
              ),
            ),
            onPressed: () async{
              if(updateProfileButton){
                return;
              }

              setState(() => updateProfileButton = true);

              //Adding info about user blurb, interests, and location
              if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                if(firebaseDesktopHelper.onDesktop){
                  List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");
                  var theUser = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});
                  var getUsersInfo = theUser["usernameProfileInformation"];

                  myMain.usersBlurb = getUsersInfo["userInformation"];
                  myMain.usersInterests = getUsersInfo["userInterests"];
                  myMain.usersLocation = getUsersInfo["userLocation"];
                }
                else{
                  await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get().then((result){
                    myMain.usersBlurb = result.docs.first.data()["usernameProfileInformation"]["userInformation"];
                    myMain.usersInterests = result.docs.first.data()["usernameProfileInformation"]["userInterests"];
                    myMain.usersLocation = result.docs.first.data()["usernameProfileInformation"]["userLocation"];
                  });
                }

                //Check if a user has a profile picture or not:
                hasProfilePicture = await checkUserProfilePicture(myLoginStatus.myUsername);
                myUsernameForProfilePicture = myLoginStatus.myUsername;
                print("Does the user have a profile picture? ${hasProfilePicture}");
              }
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => editingMyUserProfile())).then((_){
                if(mounted){
                  setState(() => updateProfileButton = false);
                }
              });
            }
          ),
          ),
        ],
      ),
      drawer: myMain.starExpeditionNavigationDrawer(),
    );
  }
}

class changePasswordPage extends StatefulWidget{
  const changePasswordPage({Key? key}) : super(key: key);

  @override
  changePasswordPageState createState() => changePasswordPageState();
}

class changePasswordPageState extends State<changePasswordPage> with RouteAware{
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController secondNewPasswordController = TextEditingController();
  var myUserResult;
  var userDoc;
  var gettingDocName;
  var usersPass;
  List messageForUsers = [];

  bool submitChangesButton = false;

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
    if((whitespaceChecker(newPasswordController.text) || whitespaceChecker(secondNewPasswordController.text)) && (newPasswordController.text != "" || secondNewPasswordController.text != "")){
      usersMessage.add(Text("Your new password must not contain any whitespace"));
    }
    return usersMessage;
  }

  //Lifecycle methods (didChangeDependencies() and dispose()):
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    myMain.routesToOtherPages.myRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose(){
    myMain.routesToOtherPages.myRouteObserver.unsubscribe(this);
    super.dispose();
  }

  //RouteAware methods (didPopNext() and didPush()):
  @override
  void didPopNext(){
    //Called when returning to this page:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  @override
  void didPush(){
    //Called when the page is pushed:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  Widget build(BuildContext context){
    final myLoginStatus = context.watch<loginStatus>();
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
                height: MediaQuery.of(context).size.height * 0.015625,
              ),
              Container(
                alignment: Alignment.center,
                child: Text("Change Your Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.015625,
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.031250, right: MediaQuery.of(context).size.width * 0.031250),
                child: Text("${registrationRequirements[2]}", textAlign: TextAlign.center),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.031250, right: MediaQuery.of(context).size.width * 0.031250),
                child: Text("After you have successfully changed your password, a confirmation email will be sent to you. Please check both your main and spam inboxes for it.", textAlign: TextAlign.center),
              ),
              IntrinsicHeight(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.015625, MediaQuery.of(context).size.height * 0.031250, MediaQuery.of(context).size.width * 0.015625, 0.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
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
                            padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.015625, MediaQuery.of(context).size.height * 0.031250, MediaQuery.of(context).size.width * 0.015625, 0.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
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
                            padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.015625, MediaQuery.of(context).size.height * 0.031250, MediaQuery.of(context).size.width * 0.015625, 0.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
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
              Container(
                height: MediaQuery.of(context).size.height * 0.015625,
              ),
              Center(
                child: AbsorbPointer(
                  absorbing: submitChangesButton,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: InkWell(
                      child: Ink(
                        color: Colors.black,
                        //padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015625),
                        child: Text("Confirm Your Password Change", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                      ),
                    ),
                    onPressed: () async{
                      if(submitChangesButton){
                        return;
                      }

                      setState(() => submitChangesButton = true);

                      print("currentPasswordController.text: ${currentPasswordController.text}");
                      print("newPasswordController.text: ${newPasswordController.text}");
                      print("secondNewPasswordController.text: ${secondNewPasswordController.text}");
                      print("myUsername = ${myLoginStatus.myUsername}");

                      if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                        if(firebaseDesktopHelper.onDesktop){
                          myUserResult = await firebaseDesktopHelper.getFirestoreCollection("User");
                          userDoc = myUserResult.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});
                          gettingDocName = userDoc["docId"];
                        }
                        else{
                          myUserResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                          myUserResult.docs.forEach((result){
                            userDoc = result.data();
                            print("This is the result: ${result.data()}");
                            gettingDocName = result.id;
                          });
                        }
                        print("userDoc[password]: ${userDoc["password"].toString()}");

                        usersPass = decryptMyPassword(myKey, userDoc["password"]);
                        print("usersPass: ${usersPass}");

                        messageForUsers = dialogMessageChangePassword([currentPasswordController.text, newPasswordController.text, secondNewPasswordController.text]);

                        if(messageForUsers.isEmpty){
                          //Password successfully changed
                          print("gettingDocName: ${gettingDocName.toString()}");

                          if(firebaseDesktopHelper.onDesktop){
                            //List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");

                            //Updating a user's password:
                            await firebaseDesktopHelper.updateFirestoreDocument("User/${gettingDocName.toString()}", {
                              "password": encryptMyPassword(myKey, newPasswordController.text).base64,
                            });
                          }
                          else{
                            FirebaseFirestore.instance.collection("User").doc(gettingDocName).update({"password" : encryptMyPassword(myKey, newPasswordController.text).base64}).whenComplete(() async{
                              print("Updated");
                            }).catchError((e) => print("This is your error: ${e}"));
                          }

                          print("This is new user password: ${userDoc["password"]}");

                          myMain.myAccessCheckNotifier.value = DateTime.now();

                          showDialog(
                              context: context,
                              builder: (BuildContext bc){
                                return AlertDialog(
                                  title: Text("Password Change Successful"),
                                  content: Text("You have successfully changed your password"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => {
                                        theUser = myLoginStatus.myUsername,
                                        theNewUser = "",
                                        usersEmail = userDoc["emailAddress"],
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => settingsPage())),
                                        emailNotifications.sendAnEmail(usersEmail, "Password Change Confirmation", "Hi ${theUser},<br><br>We have noticed that you have changed your password. If you did not do this, please contact starexpedition.theapp@gmail.com as soon as possible.<br><br>Best,<br>Star Expedition"),
                                        currentPasswordController.text = "",
                                        newPasswordController.text = "",
                                        secondNewPasswordController.text = "",

                                        if(mounted){
                                          setState(() => submitChangesButton = false),
                                        }
                                      },
                                      child: Text("Ok"),
                                    ),
                                  ],
                                );
                              }
                          );
                        }
                        else{
                          myMain.myAccessCheckNotifier.value = DateTime.now();

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
                                    //currentPasswordController.text = "";
                                    //newPasswordController.text = "";
                                    //secondNewPasswordController.text = "";
                                    if(mounted){
                                      setState(() => submitChangesButton = false);
                                    }
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
              ),
            ],
          ),
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

class changeEmailAddressPageState extends State<changeEmailAddressPage> with RouteAware{
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

  bool submitChangesButton = false;

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

  //Lifecycle methods (didChangeDependencies() and dispose()):
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    myMain.routesToOtherPages.myRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose(){
    myMain.routesToOtherPages.myRouteObserver.unsubscribe(this);
    super.dispose();
  }

  //RouteAware methods (didPopNext() and didPush()):
  @override
  void didPopNext(){
    //Called when returning to this page:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  @override
  void didPush(){
    //Called when the page is pushed:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  Widget build(BuildContext context){
    final myLoginStatus = context.watch<loginStatus>();
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
                height: MediaQuery.of(context).size.height * 0.015625,
              ),
              Container(
                alignment: Alignment.center,
                child: Text("Change Your Email Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.015625,
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.031250, right: MediaQuery.of(context).size.width * 0.031250),
                child: Text("${registrationRequirements[1]}", textAlign: TextAlign.center),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.031250, right: MediaQuery.of(context).size.width * 0.031250),
                child: Text("After you have successfully changed your email address, confirmation emails will be sent to both your current and new email addresses. Please check both your main and spam inboxes for them.", textAlign: TextAlign.center),
              ),
              IntrinsicHeight(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.015625, MediaQuery.of(context).size.height * 0.031250, MediaQuery.of(context).size.width * 0.015625, 0.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
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
            IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.015625, MediaQuery.of(context).size.height * 0.031250, MediaQuery.of(context).size.width * 0.015625, 0.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
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
            IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.015625, MediaQuery.of(context).size.height * 0.031250, MediaQuery.of(context).size.width * 0.015625, 0.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
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
              Container(
                height: MediaQuery.of(context).size.height * 0.015625,
              ),
              Center(
                child: AbsorbPointer(
                  absorbing: submitChangesButton,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: InkWell(
                      child: Ink(
                        color: Colors.black,
                        child: Text("Confirm Your Email Address Change", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                      ),
                    ),
                    onPressed: () async{
                      if(submitChangesButton){
                        return;
                      }

                      setState(() => submitChangesButton = true);

                      if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                        if(firebaseDesktopHelper.onDesktop){
                          myEmailResult = await firebaseDesktopHelper.getFirestoreCollection("User");
                          docForUsername = myEmailResult.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});
                          gettingDocName = docForUsername["docId"];
                        }
                        else{
                          myEmailResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                          myEmailResult.docs.forEach((myResult){
                            docForUsername = myResult.data();
                            print("This is the result: ${myResult.data()}");
                            gettingDocName = myResult.id;
                          });
                        }
                        print("docForUsername[emailAddress]: ${docForUsername["emailAddress"].toString()}");
                        usersEmailForEmailChangeMessage = docForUsername["emailAddress"];
                        userForEmailChange = myLoginStatus.myUsername;

                        messageForUsers = dialogMessageChangeEmailAddress([currentEmailAddressController.text, newEmailAddressController.text, myPasswordController.text]);

                        if(messageForUsers.isEmpty){
                          //email address successfully changed
                          print("Your email will change");

                          if(firebaseDesktopHelper.onDesktop){
                            //Updating a user's email address:
                            await firebaseDesktopHelper.updateFirestoreDocument("User/${gettingDocName.toString()}", {
                              "emailAddress": newEmailAddressController.text,
                            });

                            List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");
                            var theMatchingUser = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                            if(theMatchingUser.isNotEmpty){
                              du = theMatchingUser;
                              print("This is du: ${du}");
                            }
                            else{
                              print("User is not found");
                            }
                          }
                          else{
                            FirebaseFirestore.instance.collection("User").doc(gettingDocName).update({"emailAddress" : newEmailAddressController.text}).whenComplete(() async{
                              print("Updated the email address");
                            }).catchError((e) => print("This is your error: ${e}"));

                            var newEmailResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                            newEmailResult.docs.forEach((theResult){
                              du = theResult.data();
                              print("This is the result: ${theResult.data()}");
                            });
                          }

                          print("This is new user email address: ${docForUsername["emailAddress"]}");

                          myMain.myAccessCheckNotifier.value = DateTime.now();

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

                                        //For previous email address:
                                        emailNotifications.sendAnEmail(usersEmailForEmailChangeMessage, "Email Change Confirmation", "Hi ${userForEmailChange},<br><br>We have noticed that you have changed your email address from ${usersEmailForEmailChangeMessage} to ${usersNewEmail}. If you did not do this, please contact starexpedition.theapp@gmail.com as soon as possible.<br><br>Best,<br>Star Expedition"),

                                        //For new email address:
                                        emailNotifications.sendAnEmail(usersNewEmail, "Email Change Confirmation", "Hi ${userForEmailChange},<br><br>This message is to confirm that you have changed your email address from ${usersEmailForEmailChangeMessage} to ${usersNewEmail}.<br><br>Best,<br>Star Expedition"),

                                        currentEmailAddressController.text = "",
                                        newEmailAddressController.text = "",
                                        myPasswordController.text = "",

                                        if(mounted){
                                          setState(() => submitChangesButton = false),
                                        }
                                      },
                                      child: Text("Ok"),
                                    ),
                                  ],
                                );
                              }
                          );
                        }
                        else{
                          myMain.myAccessCheckNotifier.value = DateTime.now();
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
                                    //currentEmailAddressController.text = "";
                                    //newEmailAddressController.text = "";
                                    //myPasswordController.text = "";
                                    if(mounted){
                                      setState(() => submitChangesButton = false);
                                    }
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}