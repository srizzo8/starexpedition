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

bool fromStarList = false;
bool fromPlanetList = false;

class starsList extends StatefulWidget{
  const starsList ({Key? key}) : super(key: key);

  @override
  starsListPageState createState() => starsListPageState();
}

class planetsList extends StatefulWidget{
  const planetsList ({Key? key}) : super(key: key);

  @override
  planetsListPageState createState() => planetsListPageState();
}

class starsListPageState extends State<starsList>{
  myMain.myStars clickedStar = myMain.myStars(starName: "not available");
  List<String> clickedStarInfo = [];

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () async =>{
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext c) => myMain.StarExpedition())),
          }
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            child: Text("List of stars featured on Star Expedition", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: 5,
          ),
          Expanded(
            child: ListView.separated(
            itemCount: myMain.allStars.length,
            separatorBuilder: (context, index) => Container(height: 10),
            itemBuilder: (context, index){
              return UnconstrainedBox(
                child: InkWell(
                  onTap: () async{
                    fromStarList = true;
                    myMain.correctStar = myMain.allStars[index];
                    print(myMain.correctStar);
                    clickedStar.starName = myMain.correctStar;
                    print("clickedStar's name: ${clickedStar.starName}");

                    clickedStarInfo = await myMain.getStarInformation();
                    print("clickedStarInfo: ${clickedStarInfo}");
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => myMain.articlePage(clickedStarInfo), settings: RouteSettings(arguments: clickedStar)));
                  },
                  child: Container(
                    child: Text(myMain.allStars[index]),
                  ),
                ),
              );
            }
          ),
      ),
    ],
    ),
    );
  }
}

class planetsListPageState extends State<planetsList>{

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () async =>{
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext c) => myMain.StarExpedition())),
            }
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            child: Text("List of planets featured on Star Expedition", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: 5,
          ),
          Expanded(
            child: ListView.separated(
              itemCount: myMain.allPlanets.length,
              separatorBuilder: (context, index) => Container(height: 10),
              itemBuilder: (context, index){
                return UnconstrainedBox(
                  child: InkWell(
                      child: Container(
                        child: Text(myMain.allPlanets[index]),
                      ),
                      onTap: () async{
                        fromPlanetList = true;
                        print("Clicked planet");
                        //Host star info
                        print(myMain.starsAndTheirPlanets);
                        myMain.correctPlanet = myMain.allPlanets[index];
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

                        //Planet info
                        var theStarInfo = await myMain.getStarInformation();
                        myMain.informationAboutPlanet = await myMain.articlePage(theStarInfo).getPlanetData();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => myMain.planetArticle(myMain.informationAboutPlanet)));
                        //myMain.correctPlanet = myMain.allPlanets[index];
                        //myMain.informationAboutPlanet = await myMain.articlePage().getPlanetData();
                        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => myMain.planetArticle(myMain.informationAboutPlanet)));
                      }
                  ),
                );
              }
          ),
          ),
        ],
      ),
    );
  }
}