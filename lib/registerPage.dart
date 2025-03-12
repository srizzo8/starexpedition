import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
//import 'package:backendless_sdk/backendless_sdk.dart';
import 'discussionBoardUpdatesPage.dart' as discussionBoardUpdatesPage;
import 'main.dart';
import 'questionsAndAnswersPage.dart' as questionsAndAnswersPage;
import 'technologiesPage.dart' as technologiesPage;
import 'projectsPage.dart' as projectsPage;
import 'newDiscoveriesPage.dart' as newDiscoveriesPage;

import 'main.dart' as myMain;
import 'discussionBoardPage.dart' as theDiscussionBoardPage;
import 'emailNotifications.dart' as emailNotifications;
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'users_firestore_database_information/theUserInformation.dart';
import 'users_firestore_database_information/userDatabaseFirestoreInfo.dart';
//import 'database_information/usersDatabaseInfo.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

String myNewUsername = "";
String myNewEmail = "";
String myNewPassword = "";
bool registerBool = false;
var userId;
List<String> regExp = ['[', ']', '!', '@', '#', '\$', "%", '^', '&', '*', '(', ')', '<', '>', ',', '.', '?', '/', '~', '_', '+', '-', '`', '{', '}', ':', ';', '=', '|'];
final myRegExp = RegExp(
    r'[\^$*.\[\]{}()?\-"!@#%&/\,><:;_~`+='
);
List<String> numRegExp = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

List<String> letterRegExp = ['A', 'a', 'B', 'b', 'C', 'c', 'D', 'd', 'E', 'e', 'F', 'f', 'G', 'g', 'H', 'h', 'I', 'i', 'J', 'j', 'K', 'k', 'L', 'l', 'M', 'm', 'N', 'n', 'O', 'o', 'P', 'p', 'Q', 'q', 'R', 'r', 'S', 's', 'T', 't', 'U', 'u', 'V', 'v', 'W', 'w', 'X', 'x', 'Y', 'y', 'Z', 'z'];

List<String> possibleUsernameChars = numRegExp + letterRegExp + ['_', '.'];

final myKey = "Sixteen char key";

bool checkSpecialCharacters(String p){
  var myPassList = p.split("");//json.decode(p).cast<String>().toList();
  for(String i in regExp){
    if(myPassList.contains(i)){
      return true;
    }
    else{
      //continue
    }
  }
  return false;
}

bool checkNumbers(String p){
  var mySecondPassList = p.split("");
  for(String s in numRegExp){
    if(mySecondPassList.contains(s)){
      return true;
    }
    else{
      //continue
    }
  }
  return false;
}

bool checkLetters(String p){
  var myThirdPassList = p.split("");
  for(String x in letterRegExp){
    if(myThirdPassList.contains(x)){
      return true;
    }
    else{
      //continue
    }
  }
  return false;
}

bool checkUsernameValidity(String u){
  var usernameList = u.split("");
  print("usernameList: ${usernameList}");
  int i = 0;

  for(String y in usernameList){
    if(possibleUsernameChars.contains(y)){
      i++;
      print("i is now: ${i}");
    }
    else if(y == " "){
      break;
    }
    else{
      break;
    }
  }
  if(i == usernameList.length){
    return true;
  }
  return false;
}

bool checkEmailValidity(String e){
  if(e.contains("@") && "@".allMatches(e).length == 1){
    var emailAddressParts = e.split("@");
    print("emailAddressParts: ${emailAddressParts}");
    if(emailAddressParts.length == 2){
      if(emailAddressParts[0] != "" && !(emailAddressParts[0].contains(" ")) && emailAddressParts[1] != ""){
        if((emailAddressParts[1]).toLowerCase() == ("gmail.com").toLowerCase() || (emailAddressParts[1]).toLowerCase() == ("yahoo.com").toLowerCase() || (emailAddressParts[1]).toLowerCase() == ("icloud.com").toLowerCase() || (emailAddressParts[1]).toLowerCase() == ("hotmail.com").toLowerCase() || (emailAddressParts[1]).toLowerCase() == ("outlook.com").toLowerCase() || (emailAddressParts[1]).toLowerCase() == ("aol.com").toLowerCase()){
          return true;
        }
        else{
          return false;
        }
      }
      else{
        return false;
      }
    }
    else{
      return false;
    }
  }
  else{
    return false;
  }
}

encrypt.Encrypted encryptMyPassword(String myKey, String myPass){
  final theKey = encrypt.Key.fromUtf8(myKey);
  final myEncrypter = encrypt.Encrypter(encrypt.AES(theKey, mode: encrypt.AESMode.cbc));
  final initialVector = encrypt.IV.fromUtf8(myKey.substring(0, 16));
  encrypt.Encrypted myEncryptedData = myEncrypter.encrypt(myPass, iv: initialVector);
  return myEncryptedData;
}

String decryptMyPassword(String myKey, String encryptedInfo){
  final theKey = encrypt.Key.fromUtf8(myKey);
  final myEncrypter = encrypt.Encrypter(encrypt.AES(theKey, mode: encrypt.AESMode.cbc));
  final initialVector = encrypt.IV.fromUtf8(myKey.substring(0, 16));
  return myEncrypter.decrypt(encrypt.Encrypted.fromBase64(encryptedInfo), iv: initialVector);
}

class registerPage extends StatefulWidget{
  const registerPage ({Key? key}) : super(key: key);

  @override
  registerPageState createState() => registerPageState();
}

class MyRegisterPage extends StatelessWidget{
  const MyRegisterPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext buildC){
    return MaterialApp(
      title: "Registration Page", //Page for registering
    );
  }
}

class registerPageRoutes{
  static String homePage = myMain.theStarExpeditionState.nameOfRoute;
  static String discussionBoard = theDiscussionBoardPage.discussionBoardPageState.nameOfRoute;
}

class registerPageState extends State<registerPage>{
  List userEmailPasswordList = [];
  static String nameOfRoute = '/registerPage';
  TextEditingController theUsername = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  //final dbService = databaseService();

  List<String> userCredentials = [];
  List<Text> myMessage = [];

  final userInfo = Get.put(theUserInformation());

  Future<void> createUser(User u) async{
      await userInfo.createMyUser(u);
  }

  List<Text> dialogMessage(List<String> c){
    List<Text> messageForUser = [];
    if(theUsername.text == ""){
      messageForUser.add(Text("Username is empty"));
    }
    if(((myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) != -1) && theUsername.text != ""){
      messageForUser.add(Text("Username already exists"));
    }
    if((checkUsernameValidity(theUsername.text) == false || (theUsername.text).contains(" ")) && theUsername.text != ""){
      messageForUser.add(Text("Usernames must only consist of letters, numbers, _, and/or ."));
    }
    if((theUsername.text.length < 3 || theUsername.text.length > 25) && theUsername.text != ""){
      messageForUser.add(Text("Usernames must contain anywhere between 3 and 25 characters"));
    }
    if(email.text == ""){
      messageForUser.add(Text("Email is empty"));
    }
    if(checkEmailValidity(email.text) == false && email.text != ""){
      messageForUser.add(Text("Email address is invalid"));
    }
    if(password.text == ""){
      messageForUser.add(Text("Password is empty"));
    }
    if(checkLetters(password.text) == false && password.text != ""){
      messageForUser.add(Text("Password must contain at least one letter"));
    }
    if(checkNumbers(password.text) == false && password.text != ""){
      messageForUser.add(Text("Password must contain at least one number"));
    }
    if(checkSpecialCharacters(password.text) == false && password.text != ""){
      messageForUser.add(Text("Password must contain at least one special character"));
    }
    if((password.text).length < 8 && password.text != ""){
      messageForUser.add(Text("Password must be at least 8 characters long"));
    }

    return messageForUser;
  }

  Widget build(BuildContext buildContext){
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
            child: Text("Register", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
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
              controller: theUsername,
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
                              controller: theUsername,
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
                                labelText: "E-mail address",
                              ),
                              controller: email,
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
                              controller: password,
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
                  child: Text("Sign Up for Star Expedition", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)), //style: TextStyle(fontSize: 12.0)),
                  ),
                ),
                onPressed: () async{
                  //Encrypting one's pass
                  String eBaseSixtyFour = "";
                  if(password.text != ""){
                    encrypt.Encrypted e = encryptMyPassword(myKey, password.text);
                    eBaseSixtyFour = e.base64;
                  }

                  print("theUsers: ${myMain.theUsers}");
                  //If there are no users:
                  if(theUsername.text != "" && myMain.theUsers!.isEmpty && checkUsernameValidity(theUsername.text) == true && email.text != "" && checkEmailValidity(email.text) == true && password.text != "" && checkSpecialCharacters(password.text) == true && checkNumbers(password.text) == true && (password.text).length >= 8){
                    if(myMain.discussionBoardLogin == true){
                      userId = 0;
                      myNewUsername = theUsername.text;
                      myNewEmail = email.text;
                      myNewPassword = eBaseSixtyFour;//password.text;
                      Navigator.pushReplacementNamed(buildContext, registerPageRoutes.discussionBoard);
                      var theNewUser = User(
                        id: userId,
                        username: theUsername.text,
                        emailAddress: email.text,
                        password: eBaseSixtyFour,
                        usernameLowercased: theUsername.text.toLowerCase(),
                        usernameProfileInformation: {"userInformation": "", "userInterests": "", "userLocation": "", "numberOfPosts": 0, "starsTracked": {}, "planetsTracked": {}},
                      );
                      createUser(theNewUser);
                      userEmailPasswordList.add([theUsername.text, email.text, eBaseSixtyFour]);
                      myMain.Users dasUser = new Users(username: theUsername.text, email: email.text, password: eBaseSixtyFour);
                      myMain.theUsers!.add(dasUser);
                      print(myMain.theUsers);
                      myMain.discussionBoardLogin = false;
                      registerBool = true;
                      print("Registering successfully as: " + userEmailPasswordList.toString());
                      emailNotifications.registrationConfirmationEmail();
                    }
                    else{
                      userId = 0;
                      myNewUsername = theUsername.text;
                      myNewEmail = email.text;
                      myNewPassword = eBaseSixtyFour;
                      Navigator.pushReplacementNamed(buildContext, registerPageRoutes.homePage);
                      var theNewUser = User(
                        id: userId,
                        username: theUsername.text,
                        emailAddress: email.text,
                        password: eBaseSixtyFour,
                        usernameLowercased: theUsername.text.toLowerCase(),
                        usernameProfileInformation: {"userInformation": "", "userInterests": "", "userLocation": "", "numberOfPosts": 0, "starsTracked": {}, "planetsTracked": {}},
                      );
                      createUser(theNewUser);
                      //dbService.addUser(theNewUser);
                      //dbService.getUsers();
                      userEmailPasswordList.add([theUsername.text, email.text, eBaseSixtyFour]);
                      myMain.Users dasUser = new Users(username: theUsername.text, email: email.text, password: eBaseSixtyFour);
                      myMain.theUsers!.add(dasUser);
                      print(myMain.theUsers);
                      myMain.discussionBoardLogin = false;
                      registerBool = true;
                      print("Registering successfully as: " + userEmailPasswordList.toString());
                      emailNotifications.registrationConfirmationEmail();
                    }
                  }
                  //If there is at least one user on Star Expedition:
                  else if(theUsername.text != "" && (myMain.theUsers!.indexWhere((person) => person.username?.toLowerCase() == theUsername.text.toLowerCase())) == -1 && checkUsernameValidity(theUsername.text) == true && email.text != "" && checkEmailValidity(email.text) == true && password.text != "" && checkSpecialCharacters(password.text) == true && checkNumbers(password.text) == true && (password.text).length >= 8){
                    if(myMain.discussionBoardLogin == true){
                      //userId = userId + 1;
                      await FirebaseFirestore.instance.collection("User").orderBy("id", descending: true).limit(1).get().then((myNumber){
                        userId = myNumber.docs.first.data()["id"] + 1;
                      });

                      myNewUsername = theUsername.text;
                      myNewEmail = email.text;
                      myNewPassword = eBaseSixtyFour;
                      Navigator.pushReplacementNamed(buildContext, registerPageRoutes.discussionBoard);
                      var theNewUser = User(
                          id: userId,
                          username: theUsername.text,
                          emailAddress: email.text,
                          password: eBaseSixtyFour,
                          usernameLowercased: theUsername.text.toLowerCase(),
                          usernameProfileInformation: {"userInformation": "", "userInterests": "", "userLocation": "", "numberOfPosts": 0, "starsTracked": {}, "planetsTracked": {}},
                      );
                      createUser(theNewUser);
                      //dbService.addUser(theNewUser);
                      //dbService.getUsers();
                      userEmailPasswordList.add([theUsername.text, email.text, eBaseSixtyFour]);
                      myMain.Users dasUser = new Users(username: theUsername.text, email: email.text, password: eBaseSixtyFour);
                      myMain.theUsers!.add(dasUser);
                      print(myMain.theUsers);
                      myMain.discussionBoardLogin = false;
                      registerBool = true;
                      print("Registering successfully as: " + userEmailPasswordList.toString());
                      emailNotifications.registrationConfirmationEmail();
                    }
                    else{
                      //userId = userId + 1;
                      await FirebaseFirestore.instance.collection("User").orderBy("id", descending: true).limit(1).get().then((myNumber){
                        userId = myNumber.docs.first.data()["id"] + 1;
                      });
                      myNewUsername = theUsername.text;
                      myNewEmail = email.text;
                      myNewPassword = eBaseSixtyFour;
                      Navigator.pushReplacementNamed(buildContext, registerPageRoutes.homePage);
                      var theNewUser = User(
                          id: userId,
                          username: theUsername.text,
                          emailAddress: email.text,
                          password: eBaseSixtyFour,
                          usernameLowercased: theUsername.text.toLowerCase(),
                          usernameProfileInformation: {"userInformation": "", "userInterests": "", "userLocation": "", "numberOfPosts": 0, "starsTracked": {}, "planetsTracked": {}},
                      );
                      createUser(theNewUser);
                      //dbService.addUser(theNewUser);
                      //dbService.getUsers();
                      userEmailPasswordList.add([theUsername.text, email.text, eBaseSixtyFour]);
                      myMain.Users dasUser = new Users(username: theUsername.text, email: email.text, password: eBaseSixtyFour);
                      myMain.theUsers!.add(dasUser);
                      print(myMain.theUsers);
                      myMain.discussionBoardLogin = false;
                      registerBool = true;
                      print("Registering successfully as: " + userEmailPasswordList.toString());
                      emailNotifications.registrationConfirmationEmail();
                    }
                  }
                  else{
                    print(myMain.theUsers!.indexWhere((person) => person.username == theUsername.text));
                    userCredentials.add(theUsername.text);
                    userCredentials.add(email.text);
                    userCredentials.add(password.text);

                    myMessage = dialogMessage(userCredentials);
                    print("myMessage.length: ${myMessage.length}");

                    showDialog(
                      context: buildContext,
                      builder: (myContent) => AlertDialog(
                        title: const Text("Registration unsuccessful"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(myMessage.length, (i){
                            return myMessage[i];
                          }),
                        ),

                        actions: <Widget>[
                          TextButton(
                            onPressed: (){
                              Navigator.of(myContent).pop();
                            },
                            child: Container(
                              child: const Text("Ok"),
                            ),
                          )
                        ],
                      ),
                    );
                    print("Registration incomplete");
                  }
                }
            ),
          )
        ]
      ),
    );
  }
}