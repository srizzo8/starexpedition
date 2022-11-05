import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'main.dart' as myMain;

class createThread extends StatefulWidget{
  const createThread ({Key? key}) : super(key: key);

  @override
  createThreadState createState() => createThreadState();
}

class createThreadState extends State<createThread>{
  static String threadCreator = '/createThread';

  Widget build(BuildContext createThreadBuildContext){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Expanded(
        child: Container(
          child: Text("Making a thread", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}