import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart';
import 'discussionBoardUpdatesDatabaseFirestoreInfo.dart';

class discussionBoardUpdatesInformation extends GetxController{
  discussionBoardUpdatesInformation get instance => Get.find();

  final myDb = FirebaseFirestore.instance;

  createMyDiscussionBoardUpdatesThread(DiscussionBoardUpdatesThreads dbut) async{
    await myDb.collection("Discussion_Board_Updates").add(dbut.toJson()).whenComplete(
          () => print("Thread added!"),
    )
        .catchError((error, stackTrace){
      print("This is your error: ${error.toString()}");
    });
  }

}