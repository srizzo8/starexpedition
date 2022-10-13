import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class spectralClassPage extends StatelessWidget {
  static String nameOfRoute = '/spectralClassPage';

  @override
  Widget build(BuildContext bc){
    return new Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      )
    );
  }
}