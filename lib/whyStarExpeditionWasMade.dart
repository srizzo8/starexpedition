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
        title: Text("Star Expedition"),
      ),
      body: Container(
        child: Text("As a young child, I always had an interest in the Universe and all of its celestial bodies." +
            "However, one thing that interested me the most was how stars and planets can be capable of supporting " +
            "life for flora and fauna. This can take millions and even billions of years to accomplish, depending on " +
            "the evolution of the star, planet, or both."),
      ),
      drawer: myMain.starExpeditionNavigationDrawer(),
    );
  }
}