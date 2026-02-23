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
import 'package:starexpedition4/firebaseDesktopHelper.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';

bool fromMostTrackedStarsAndPlanetsPageStars = false;
bool fromMostTrackedStarsAndPlanetsPagePlanets = false;

class mostTrackedStarsAndPlanetsPage extends StatefulWidget{
  const mostTrackedStarsAndPlanetsPage ({Key? key}) : super(key: key);

  @override
  mostTrackedStarsAndPlanetsPageState  createState() => mostTrackedStarsAndPlanetsPageState();
}

class mostTrackedStarsAndPlanetsPageState extends State<mostTrackedStarsAndPlanetsPage>{
  static String nameOfRoute = '/mostTrackedStarsAndPlanetsPage';

  var topFiveTrackedStars = (myMain.starsAndAmountOfTracks.entries.toList()..sort((starA, starB) => starB.value.compareTo(starA.value))).take(5).toList();
  var topFiveTrackedPlanets = (myMain.planetsAndAmountOfTracks.entries.toList()..sort((planetA, planetB) => planetB.value.compareTo(planetA.value))).take(5).toList();

  var myClickedStar = myMain.myStars(starName: "not available");
  var myClickedPlanet;

  Widget build(BuildContext context){
    List<String> informationAboutClickedStar = [];
    List<String> informationAboutClickedPlanet = [];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.015625,
            ),
            Center(
              child: Text("Most Tracked Stars", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.015625,
            ),
            DataTable(
              columns: [
                DataColumn(
                  label: Text("Rank", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text("Star Name", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text("Users Tracking", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
              rows: topFiveTrackedStars.asMap().entries.map((myEntry){
                int myIndex = myEntry.key;
                var myStar = myEntry.value;

                return DataRow(cells: [
                  DataCell(
                    Center(
                      child: Text("${myIndex + 1}"),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: Text(myStar.key),
                    ),
                    onTap: () async{
                      myMain.correctStar = myStar.key;
                      print(myMain.correctStar);
                      myClickedStar.starName = myMain.correctStar;
                      print(myClickedStar.starName);

                      informationAboutClickedStar = await myMain.getStarInformation();
                      print(informationAboutClickedStar);

                      fromMostTrackedStarsAndPlanetsPageStars = true;

                      myMain.starFileContent = await myMain.readStarFile();
                      myMain.listOfStarUrls = myMain.starFileContent.replaceAll("\n", "").replaceAll("\r", "|").split("|");

                      myMain.listOfStarUrls.removeWhere((myUrl) => myUrl == "" || myUrl == " ");

                      //Is a user tracking this star?
                      if(myNewUsername != "" && myUsername == ""){
                        if(firebaseDesktopHelper.onDesktop){
                          List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                          var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                          Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(usersProfileInfo["usernameProfileInformation"] ?? {});

                          myMain.starTracked = currentInfoOfNewUser?["starsTracked"].containsKey(myMain.correctStar);
                          print("starTracked: ${myMain.starTracked}");
                        }
                        else{
                          var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                          var docNameForNewUsers;
                          theNewUser.docs.forEach((result){
                            docNameForNewUsers = result.id;
                          });

                          DocumentSnapshot<Map<dynamic, dynamic>> snapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForNewUsers).get();
                          Map<dynamic, dynamic>? individual = snapshotNewUsers.data();

                          myMain.starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(myMain.correctStar);
                          print("starTracked: ${myMain.starTracked}");
                        }
                      }
                      else if(myNewUsername == "" && myUsername != ""){
                        if(firebaseDesktopHelper.onDesktop){
                          List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                          var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                          Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(usersProfileInfo["usernameProfileInformation"] ?? {});

                          myMain.starTracked = currentInfoOfExistingUser?["starsTracked"].containsKey(myMain.correctStar);
                          print("starTracked: ${myMain.starTracked}");
                        }
                        else{
                          var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                          var docNameForExistingUsers;
                          theExistingUser.docs.forEach((result){
                            docNameForExistingUsers = result.id;
                          });

                          DocumentSnapshot<Map<dynamic, dynamic>> snapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForExistingUsers).get();
                          Map<dynamic, dynamic>? individual = snapshotExistingUsers.data();

                          myMain.starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(myMain.correctStar);
                          print("starTracked: ${myMain.starTracked}");
                        }
                      }
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => myMain.articlePage(informationAboutClickedStar), settings: RouteSettings(arguments: myClickedStar)));
                    }
                  ),
                  DataCell(
                    Center(
                      child: Text(myStar.value),
                    ),
                  ),
                ]);
              }).toList(),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.015625,
            ),
            Center(
              child: Text("Most Tracked Planets", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.015625,
            ),
            DataTable(
              columns: [
                DataColumn(
                  label: Text("Rank", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text("Planet Name", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text("Users Tracking", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
              rows: topFiveTrackedPlanets.asMap().entries.map((myEntry){
                int myIndex = myEntry.key;
                var myPlanet = myEntry.value;

                return DataRow(cells: [
                  DataCell(
                    Center(
                      child: Text("${myIndex + 1}"),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: Text(myPlanet.key),
                    ),
                    onTap: () async{
                      myMain.correctPlanet = myPlanet.key;

                      myMain.starsAndTheirPlanets.forEach((key, value){
                        print("key: ${key}, value: ${value}");
                        for(var v in value){
                          if(v == myMain.correctPlanet){
                            myMain.correctStar = key;
                            break;
                          }
                          else{
                            //continue
                          }
                        }
                      });

                      var theStarInfo = await myMain.getStarInformation();
                      informationAboutClickedPlanet = await myMain.articlePage(theStarInfo).getPlanetData();

                      fromMostTrackedStarsAndPlanetsPagePlanets = true;

                      myMain.planetFileContent = await myMain.readPlanetFile(informationAboutClickedPlanet[6].toString());
                      myMain.listOfPlanetUrls = myMain.planetFileContent.replaceAll("\n", "").replaceAll("\r", "|").split("|");

                      myMain.listOfPlanetUrls.removeWhere((myUrl) => myUrl == "" || myUrl == " ");

                      //Is the planet tracked by a user?
                      if(myNewUsername != "" && myUsername == ""){
                        if(firebaseDesktopHelper.onDesktop){
                          var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                          var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                          //Getting the current profile info of the user:
                          Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                          myMain.planetTracked = currentInfoOfNewUser["planetsTracked"].containsKey(myMain.correctPlanet);
                          print("planetTracked: ${myMain.planetTracked}");
                        }
                        else{
                          var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                          var theDocNameForNewUsers;
                          theNewUser.docs.forEach((result){
                            theDocNameForNewUsers = result.id;
                          });

                          DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForNewUsers).get();
                          Map<dynamic, dynamic>? individual = theSnapshotNewUsers.data();

                          myMain.planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(myMain.correctPlanet);
                          print("planetTracked: ${myMain.planetTracked}");
                        }
                      }
                      else if(myNewUsername == "" && myUsername != ""){
                        if(firebaseDesktopHelper.onDesktop){
                          var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                          var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                          //Getting the current profile info of the user:
                          Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                          myMain.planetTracked = currentInfoOfExistingUser["planetsTracked"].containsKey(myMain.correctPlanet);
                          print("planetTracked: ${myMain.planetTracked}");
                        }
                        else{
                          var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                          var theDocNameForExistingUsers;
                          theExistingUser.docs.forEach((result){
                            theDocNameForExistingUsers = result.id;
                          });

                          DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForExistingUsers).get();
                          Map<dynamic, dynamic>? individual = theSnapshotExistingUsers.data();

                          myMain.planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(myMain.correctPlanet);
                          print("planetTracked: ${myMain.planetTracked}");
                        }
                      }
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => myMain.planetArticle(informationAboutClickedPlanet)));
                    }
                  ),
                  DataCell(
                    Center(
                      child: Text(myPlanet.value),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ]
        ),
      ),
      drawer: myMain.starExpeditionNavigationDrawer(),
    );
  }
}