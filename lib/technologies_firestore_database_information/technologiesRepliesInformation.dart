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
import 'technologiesDatabaseFirestoreInfo.dart';
import 'technologiesRepliesDatabaseFirestoreInfo.dart';
import 'package:starexpedition4/firebaseDesktopHelper.dart';

class technologiesRepliesInformation extends GetxController{
  technologiesRepliesInformation get instance => Get.find();

  //final myDb = FirebaseFirestore.instance;
  FirebaseFirestore? get myDb{
    if(!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)){
      return null;
    }
    return FirebaseFirestore.instance;
  }

  bool get onDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  createMyTechnologiesReply(TechnologiesReplies tr, var docName) async{
    if(onDesktop){
      try{
        print("Type of docName: ${docName.runtimeType}");
        await firebaseDesktopHelper.createFirestoreDocumentForSubcollection("Technologies", tr.toJson(), docName, "Replies");
        print("Reply added!");
      }
      catch (error){
        print("This is your error: $error");
      }
    }
    else{
      await myDb?.collection("Technologies").doc(docName).collection("Replies").add(tr.toJson()).whenComplete(
            () => print("Reply added!"),
      )
          .catchError((error, stackTrace){
        print("This is your error: ${error.toString()}");
      });
    }
  }

}