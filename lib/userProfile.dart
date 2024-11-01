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
import 'package:starexpedition4/settingsPage.dart';
import 'package:starexpedition4/spectralClassPage.dart';

import 'package:starexpedition4/main.dart' as myMain;
import 'package:starexpedition4/discussionBoardPage.dart';
import 'package:starexpedition4/loginPage.dart';
import 'package:starexpedition4/registerPage.dart';
import 'package:starexpedition4/loginPage.dart' as theLoginPage;
import 'package:flutter/services.dart' show MaxLengthEnforcement, rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';
import 'package:starexpedition4/userSearchBar.dart';

import 'discussionBoardUpdatesPage.dart';
import 'newDiscoveriesPage.dart';
import 'projectsPage.dart';
import 'questionsAndAnswersPage.dart';
import 'technologiesPage.dart';

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
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => settingsPage())),
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
              maxLines: null,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
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

                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => settingsPage()));
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

                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => settingsPage()));
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
      body: SingleChildScrollView(
        child: Column(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: myUsername != "" && myNewUsername == ""?
                Text("${myUsername}'s Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)):
                Text("${myNewUsername}'s Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: Text("\nInformation About You:", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: myUsername != "" && myNewUsername == ""?
                (myMain.usersBlurb != ""? Text("${myMain.usersBlurb}", textAlign: TextAlign.center): Text("N/A", textAlign: TextAlign.center)):
                (myMain.usersBlurb != ""? Text("${myMain.usersBlurb}", textAlign: TextAlign.center): Text("N/A", textAlign: TextAlign.center)),
          ),
          Container(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: Text("\nTotal Posts on the Discussion Board:", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: Text("${myMain.numberOfPostsUserHasMade}", textAlign: TextAlign.center),
          ),
          Container(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: Text("\nStars Tracked:", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            height: 5,
          ),
          /*SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: ListView.builder(
                itemCount: myMain.starsUserTracked.length,
                shrinkWrap: true,
                itemBuilder: (bc, myIndexStars){
                  return Container(
                    child: Text("${myMain.starsUserTracked.keys}\n${myMain.starsUserTracked.values}\n\n"),
                  );
                }),
          ),*/
          Column(
            children: <Widget>[
              //var starsUserTrackedKeys = myMain.starsUserTracked.keys as List;
              if(!(myMain.starsUserTracked.isEmpty))
                for(int s = 0; s < (myMain.starsUserTracked.keys.toList()).length; s++)
                  Text("${myMain.starsUserTracked.keys.toList()[s]}\n${myMain.starsUserTracked.values.toList()[s]}\n", textAlign: TextAlign.center),

              if(myMain.starsUserTracked.isEmpty)
                Text("N/A", textAlign: TextAlign.center),
              /*}
              else{
                Text("N/A", textAlign: TextAlign.center),
              }*/
            ],
          ),
          Container(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: Text("\nPlanets Tracked:", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            height: 5,
          ),
          Column(
            children: <Widget>[
              //var starsUserTrackedKeys = myMain.starsUserTracked.keys as List;
              if(!(myMain.planetsUserTracked.isEmpty))
                for(int p = 0; p < (myMain.planetsUserTracked.keys.toList()).length; p++)
                  Text("${myMain.planetsUserTracked.keys.toList()[p]}\n${myMain.planetsUserTracked.values.toList()[p]}\n", textAlign: TextAlign.center),

              if(myMain.planetsUserTracked.isEmpty)
                Text("N/A", textAlign: TextAlign.center),
            ],
          ),
        ],
        ),
      ),
    );
  }
}

class userProfileInOtherUsersPerspective extends StatelessWidget{
  static String nameOfRoute = '/userProfileInOtherUsersPerspective';

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () =>{
              if(dbuClickedOnUser == true && ndClickedOnUser == false && projectsClickedOnUser == false && qaaClickedOnUser == false && technologiesClickedOnUser == false){
                dbuClickedOnUser = false,
                Navigator.of(bc).pop(),
              }
              else if(dbuClickedOnUser == false && ndClickedOnUser == true && projectsClickedOnUser == false && qaaClickedOnUser == false && technologiesClickedOnUser == false){
                ndClickedOnUser = false,
                Navigator.of(bc).pop(),
              }
              else if(dbuClickedOnUser == false && ndClickedOnUser == false && projectsClickedOnUser == true && qaaClickedOnUser == false && technologiesClickedOnUser == false){
                projectsClickedOnUser = false,
                Navigator.of(bc).pop(),
              }
              else if(dbuClickedOnUser == false && ndClickedOnUser == false && projectsClickedOnUser == false && qaaClickedOnUser == true && technologiesClickedOnUser == false){
                qaaClickedOnUser = false,
                Navigator.of(bc).pop(),
              }
              else if(dbuClickedOnUser == false && ndClickedOnUser == false && projectsClickedOnUser == false && qaaClickedOnUser == false && technologiesClickedOnUser == true){
                technologiesClickedOnUser = false,
                Navigator.of(bc).pop(),
              }
              else{
                Navigator.push(bc, MaterialPageRoute(builder: (BuildContext context) => userSearchBarPage())),
              }
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
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: Text("${theUsersData["username"]}'s Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: Text("\nInformation About ${theUsersData["username"]}:", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: !(theUsersData["usernameProfileInformation"]["userInformation"].isEmpty)?
              Text("${theUsersData["usernameProfileInformation"]["userInformation"]}"):
              Text("N/A", textAlign: TextAlign.center),
          ),
          Container(
            height: 5,
          ),
          Container(
            child: Text("\nTotal Posts on the Discussion Board:", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: Text("${theUsersData["usernameProfileInformation"]["numberOfPosts"]}"),
          ),
          Container(
            height : 5,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: Text("\nStars Tracked:", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            height: 5,
          ),
          Column(
            children: <Widget>[
              if(!(theUsersData["usernameProfileInformation"]["starsTracked"].isEmpty))
                for(int s = 0; s < (theUsersData["usernameProfileInformation"]["starsTracked"].keys.toList()).length; s++)
                  Text("${theUsersData["usernameProfileInformation"]["starsTracked"].keys.toList()[s]}\n${theUsersData["usernameProfileInformation"]["starsTracked"].values.toList()[s]}\n", textAlign: TextAlign.center),

              if(theUsersData["usernameProfileInformation"]["starsTracked"].isEmpty)
                Text("N/A", textAlign: TextAlign.center),
            ],
          ),
          Container(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: Text("\nPlanets Tracked:", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Column(
            children: <Widget>[
              //var starsUserTrackedKeys = myMain.starsUserTracked.keys as List;
              if(!(theUsersData["usernameProfileInformation"]["planetsTracked"].isEmpty))
                for(int p = 0; p < (theUsersData["usernameProfileInformation"]["planetsTracked"].keys.toList()).length; p++)
                  Text("${theUsersData["usernameProfileInformation"]["planetsTracked"].keys.toList()[p]}\n${theUsersData["usernameProfileInformation"]["planetsTracked"].values.toList()[p]}\n", textAlign: TextAlign.center),

              if(theUsersData["usernameProfileInformation"]["planetsTracked"].isEmpty)
                Text("N/A", textAlign: TextAlign.center),
            ],
          ),
        ],
        ),
      ),
    );
  }
}