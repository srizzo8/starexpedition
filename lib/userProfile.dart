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
import 'feedbackAndSuggestionsPage.dart';

import 'package:starexpedition4/firebaseDesktopHelper.dart';

var myInformation;
var myInterests;
var myLocation;
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
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            child: Text("User Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
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
            height: MediaQuery.of(context).size.height * 0.015625,
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
  TextEditingController interestsController = TextEditingController();
  TextEditingController locationController = TextEditingController();

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
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.015625,
              ),
              Container(
                child: Text("Editing Your Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.015625,
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
                                maxWidth: MediaQuery.of(context).size.width * 0.375000,
                              ),
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  reverse: true,
                                  child: SizedBox(
                                    child: TextField(
                                      minLines: 5,
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Information about yourself",
                                        //contentPadding: EdgeInsets.symmetric(vertical: 80),
                                      ),
                                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                      controller: informationAboutMyselfController..text = "${myMain.usersBlurb}",
                                    ),
                                  ),
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
                                maxWidth: MediaQuery.of(context).size.width * 0.375000,
                              ),
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  reverse: true,
                                  child: SizedBox(
                                    child: TextField(
                                      minLines: 5,
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Your interests",
                                      ),
                                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                      controller: interestsController..text = "${myMain.usersInterests}",
                                    ),
                                  ),
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
                                maxWidth: MediaQuery.of(context).size.width * 0.375000,
                              ),
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  reverse: true,
                                  child: SizedBox(
                                    child: TextField(
                                      minLines: 5,
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Your location",
                                      ),
                                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                      controller: locationController..text = "${myMain.usersLocation}",
                                    ),
                                  ),
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
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                    ),
                    child: InkWell(
                      child: Ink(
                        color: Colors.black,
                        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015625),
                        child: Text("Update Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                      ),
                    ),
                    onPressed: () async{
                      if(myUsername != "" && myNewUsername == ""){
                        if(firebaseDesktopHelper.onDesktop){
                          List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                          var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                          myDocName = usersProfileInfo["docId"];

                          //Getting the current profile info of the user:
                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(usersProfileInfo["usernameProfileInformation"] ?? {});

                          currentInfoOfUser["userInformation"] = informationAboutMyselfController.text;
                          currentInfoOfUser["userInterests"] = interestsController.text;
                          currentInfoOfUser["userLocation"] = locationController.text;

                          //Seeing what is in currentInfoOfUser:
                          print("User information: ${currentInfoOfUser["userInformation"]}");
                          print("User interests: ${currentInfoOfUser["userInterests"]}");
                          print("User location: ${currentInfoOfUser["userLocation"]}");

                          //Updating a user's changes:
                          await firebaseDesktopHelper.updateFirestoreDocument("User/$myDocName", {
                            "usernameProfileInformation": currentInfoOfUser,
                          });
                        }
                        else{
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

                          myInterests = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                          myInterests.docs.forEach((myResult){
                            dataOfUser = myResult.data();
                            myDocName = myResult.id;
                          });

                          FirebaseFirestore.instance.collection("User").doc(myDocName).update({
                            "usernameProfileInformation.userInterests": interestsController.text,
                          }).then((i){
                            print("You have updated the user interests (for already existing users)!");
                          });

                          myLocation = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                          myLocation.docs.forEach((myResult){
                            dataOfUser = myResult.data();
                            myDocName = myResult.id;
                          });

                          FirebaseFirestore.instance.collection("User").doc(myDocName).update({
                            "usernameProfileInformation.userLocation": locationController.text,
                          }).then((i){
                            print("You have updated the user location (for already existing users)!");
                          });
                        }

                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => settingsPage()));
                      }
                      else if(myUsername == "" && myNewUsername != ""){
                        if(firebaseDesktopHelper.onDesktop){
                          List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                          var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                          myDocName = usersProfileInfo["docId"];

                          //Getting the current profile info of the user:
                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(usersProfileInfo["usernameProfileInformation"] ?? {});

                          currentInfoOfUser["userInformation"] = informationAboutMyselfController.text;
                          currentInfoOfUser["userInterests"] = interestsController.text;
                          currentInfoOfUser["userLocation"] = locationController.text;

                          //Seeing what is in currentInfoOfUser:
                          print("User information: ${currentInfoOfUser["userInformation"]}");
                          print("User interests: ${currentInfoOfUser["userInterests"]}");
                          print("User location: ${currentInfoOfUser["userLocation"]}");

                          //Updating a user's changes:
                          await firebaseDesktopHelper.updateFirestoreDocument("User/$myDocName", {
                            "usernameProfileInformation": currentInfoOfUser,
                          });
                        }
                        else{
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

                          myInterests = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                          myInformation.docs.forEach((myResult){
                            dataOfUser = myResult.data();
                            myDocName = myResult.id;
                          });

                          FirebaseFirestore.instance.collection("User").doc(myDocName).update({
                            "usernameProfileInformation.userInterests": interestsController.text,
                          }).then((j){
                            print("You have updated the user interests (for new users)!");
                          });

                          myLocation = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                          myLocation.docs.forEach((myResult){
                            dataOfUser = myResult.data();
                            myDocName = myResult.id;
                          });

                          FirebaseFirestore.instance.collection("User").doc(myDocName).update({
                            "usernameProfileInformation.userLocation": locationController.text,
                          }).then((j){
                            print("You have updated the user location (for new users)!");
                          });
                        }

                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => settingsPage()));
                      }
                    }
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.015625,
              ),
            ],
          ),
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
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: myUsername != "" && myNewUsername == ""?
              Text("${myUsername}'s Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)):
              Text("${myNewUsername}'s Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nInformation About You:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: myUsername != "" && myNewUsername == ""?
                (myMain.usersBlurb != ""? Text("${myMain.usersBlurb}", textAlign: TextAlign.center): Text("N/A", textAlign: TextAlign.center)):
                (myMain.usersBlurb != ""? Text("${myMain.usersBlurb}", textAlign: TextAlign.center): Text("N/A", textAlign: TextAlign.center)),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nYour Interests:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: myUsername != "" && myNewUsername == ""?
                (myMain.usersInterests != ""? Text("${myMain.usersInterests}", textAlign: TextAlign.center): Text("N/A", textAlign: TextAlign.center)):
                (myMain.usersInterests != ""? Text("${myMain.usersInterests}", textAlign: TextAlign.center): Text("N/A", textAlign: TextAlign.center)),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nYour Location:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: myUsername != "" && myNewUsername == ""?
                (myMain.usersLocation != ""? Text("${myMain.usersLocation}", textAlign: TextAlign.center): Text("N/A", textAlign: TextAlign.center)):
                (myMain.usersLocation != ""? Text("${myMain.usersLocation}", textAlign: TextAlign.center): Text("N/A", textAlign: TextAlign.center)),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nTotal Posts on the Discussion Board:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("${myMain.numberOfPostsUserHasMade}", textAlign: TextAlign.center),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nStars Tracked:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
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
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nPlanets Tracked:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
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
              if(dbuClickedOnUser == true && ndClickedOnUser == false && projectsClickedOnUser == false && qaaClickedOnUser == false && technologiesClickedOnUser == false && fasClickedOnUser == false){
                dbuClickedOnUser = false,
                Navigator.of(bc).pop(),
              }
              else if(dbuClickedOnUser == false && ndClickedOnUser == true && projectsClickedOnUser == false && qaaClickedOnUser == false && technologiesClickedOnUser == false && fasClickedOnUser == false){
                ndClickedOnUser = false,
                Navigator.of(bc).pop(),
              }
              else if(dbuClickedOnUser == false && ndClickedOnUser == false && projectsClickedOnUser == true && qaaClickedOnUser == false && technologiesClickedOnUser == false && fasClickedOnUser == false){
                  projectsClickedOnUser = false,
                  Navigator.of(bc).pop(),
                }
                else if(dbuClickedOnUser == false && ndClickedOnUser == false && projectsClickedOnUser == false && qaaClickedOnUser == true && technologiesClickedOnUser == false && fasClickedOnUser == false){
                    qaaClickedOnUser = false,
                    Navigator.of(bc).pop(),
                  }
                  else if(dbuClickedOnUser == false && ndClickedOnUser == false && projectsClickedOnUser == false && qaaClickedOnUser == false && technologiesClickedOnUser == true && fasClickedOnUser == false){
                      technologiesClickedOnUser = false,
                      Navigator.of(bc).pop(),
                    }
                    else if(dbuClickedOnUser == false && ndClickedOnUser == false && projectsClickedOnUser == false && qaaClickedOnUser == false && technologiesClickedOnUser == false && fasClickedOnUser == true){
                        fasClickedOnUser = false,
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
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("${theUsersData["username"]}'s Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nInformation About ${theUsersData["username"]}:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: !(theUsersData["usernameProfileInformation"]["userInformation"].isEmpty)?
                Text("${theUsersData["usernameProfileInformation"]["userInformation"]}", textAlign: TextAlign.center):
                Text("N/A", textAlign: TextAlign.center),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\n${theUsersData["username"]}'s Interests:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: !(theUsersData["usernameProfileInformation"]["userInterests"].isEmpty)?
              Text("${theUsersData["usernameProfileInformation"]["userInterests"]}", textAlign: TextAlign.center):
              Text("N/A", textAlign: TextAlign.center),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\n${theUsersData["username"]}'s Location:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: !(theUsersData["usernameProfileInformation"]["userLocation"].isEmpty)?
                Text("${theUsersData["usernameProfileInformation"]["userLocation"]}", textAlign: TextAlign.center):
                Text("N/A", textAlign: TextAlign.center),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nTotal Posts on the Discussion Board:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("${theUsersData["usernameProfileInformation"]["numberOfPosts"]}"),
            ),
            /*Container(
              height : MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nStars Tracked:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Column(
              children: <Widget>[
                if(!(theUsersData["usernameProfileInformation"]["starsTracked"].isEmpty))
                  for(int s = 0; s < (theUsersData["usernameProfileInformation"]["starsTracked"].keys.toList()).length; s++)
                    Text("${theUsersData["usernameProfileInformation"]["starsTracked"].keys.toList()[s]}\n${theUsersData["usernameProfileInformation"]["starsTracked"].values.toList()[s]}\n", textAlign: TextAlign.center),

                if(theUsersData["usernameProfileInformation"]["starsTracked"].isEmpty)
                  Text("N/A", textAlign: TextAlign.center),
              ],
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
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