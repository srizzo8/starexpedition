import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
//import 'dart:html';

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
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';

class mostTrackedStarsAndPlanetsPage extends StatefulWidget{
  const mostTrackedStarsAndPlanetsPage ({Key? key}) : super(key: key);

  @override
  mostTrackedStarsAndPlanetsPageState  createState() => mostTrackedStarsAndPlanetsPageState();
}

class mostTrackedStarsAndPlanetsPageState extends State<mostTrackedStarsAndPlanetsPage>{
  static String nameOfRoute = '/mostTrackedStarsAndPlanetsPage';

  var topFiveTrackedStars = (myMain.starsAndAmountOfTracks.entries.toList()..sort((starA, starB) => starB.value.compareTo(starA.value))).take(5).toList();
  var topFiveTrackedPlanets = (myMain.planetsAndAmountOfTracks.entries.toList()..sort((planetA, planetB) => planetB.value.compareTo(planetA.value))).take(5).toList();

  Widget build(BuildContext context){
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
      drawer: myMain.starExpeditionNavigationDrawer(),
    );
  }
}