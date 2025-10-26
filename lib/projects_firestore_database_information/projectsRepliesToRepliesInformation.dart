import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:get/get.dart';
import 'projectsDatabaseFirestoreInfo.dart';
import 'projectsRepliesDatabaseFirestoreInfo.dart';
import 'projectsRepliesToRepliesDatabaseFirestoreInfo.dart';
import 'package:starexpedition4/firebaseDesktopHelper.dart';

class projectsRepliesToRepliesInformation extends GetxController{
  projectsRepliesToRepliesInformation get instance => Get.find();

  //final myDb = FirebaseFirestore.instance;
  FirebaseFirestore? get myDb{
    if(!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)){
      return null;
    }
    return FirebaseFirestore.instance;
  }

  bool get onDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  createMyProjectsReplyToReply(ProjectsReplies pr, var docName) async{
    if(onDesktop){
      try{
        await firebaseDesktopHelper.createFirestoreDocumentForSubcollection("Projects", pr.toJson(), docName, "Replies");
        print("Reply to reply added!");
      }
      catch (error){
        print("This is your error: $error");
      }
    }
    else{
      await myDb!.collection("Projects").doc(docName).collection("Replies").add(pr.toJson()).whenComplete(
            () => print("Reply to reply added!"),
      )
          .catchError((error, stackTrace){
        print("This is your error: ${error.toString()}");
      });
    }
  }

}