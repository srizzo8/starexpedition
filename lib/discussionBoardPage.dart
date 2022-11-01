import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'main.dart' as myMain;

class discussionBoardPage extends StatefulWidget{
  const discussionBoardPage ({Key? key}) : super(key: key);

  @override
  discussionBoardPageState createState() => discussionBoardPageState();
}

class discussionBoardPageState extends State<discussionBoardPage>{
  static String nameOfRoute = '/discussionBoardPage';

  Widget build(BuildContext context){
    return Scaffold(

    );
  }
}