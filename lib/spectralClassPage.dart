import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'main.dart';

class spectralClassPage extends StatelessWidget {
  static String nameOfRoute = '/spectralClassPage';

  @override
  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Wrap(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: Text("Spectral Classes of Stars", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
            height: 30,
          ),
        ],
      ),
      drawer: starExpeditionNavigationDrawer(),
    );
  }
}