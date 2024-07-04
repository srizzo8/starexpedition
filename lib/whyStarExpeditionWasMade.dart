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

class whyStarExpeditionWasMadePage extends StatefulWidget{
  const whyStarExpeditionWasMadePage ({Key? key}) : super(key: key);

  @override
  whyStarExpeditionWasMadePageState createState() => whyStarExpeditionWasMadePageState();
}

class whyStarExpeditionWasMadePageState extends State<whyStarExpeditionWasMadePage>{
  static String nameOfRoute = '/whyStarExpeditionWasMade';

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: Text("Why Star Expedition Was Made",
                        style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            child: Text("As a young child, I always had an interest in the Universe and all of its celestial bodies." +
            "However, one thing that interested me the most was how stars and planets can be capable of supporting " +
            "life for flora and fauna. This can take millions and even billions of years to accomplish, depending on " +
            "the evolution of the star, planet, or both." + "\n" + "\n" +
            "The formation of our Solar System was something that I especially found fascinating." +
            "It is magnificient how the Sun was born, how it resulted in creating Earth, and how it ultimately made Earth evolve the way that it did. " +
            "It is also intriguing to realize how far nature and civilization have progressed over the past 4.6 billion years."
            "I truly wonder if there are other suns and other Earths out there." +
            "I hope that Star Expedition can be helpful in providing people with information about " +
            "nearby stars that have confirmed terrestrial planets that can potentially support life for the flora and fauna found in Earth."),
          ),
        ]
      ),
      drawer: myMain.starExpeditionNavigationDrawer(),
    );
  }
}