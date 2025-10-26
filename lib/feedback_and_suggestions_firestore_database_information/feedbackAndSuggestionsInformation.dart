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
import 'feedbackAndSuggestionsDatabaseFirestoreInfo.dart';
import 'package:starexpedition4/firebaseDesktopHelper.dart';

class feedbackAndSuggestionsInformation extends GetxController{
  feedbackAndSuggestionsInformation get instance => Get.find();

  //final myDb = FirebaseFirestore.instance;
  FirebaseFirestore? get myDb{
    if(!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)){
      return null;
    }
    return FirebaseFirestore.instance;
  }

  bool get onDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  createMyFeedbackAndSuggestionsThread(FeedbackAndSuggestionsThreads fast) async{
    if(onDesktop){
      try{
        await firebaseDesktopHelper.createFirestoreDocument("Feedback_And_Suggestions", fast.toJson());
        print("Thread added!");
      }
      catch (error){
        print("This is your error: $error");
      }
    }
    else{
      await myDb!.collection("Feedback_And_Suggestions").add(fast.toJson()).whenComplete(
            () => print("Thread added!"),
      )
          .catchError((error, stackTrace){
        print("This is your error: ${error.toString()}");
      });
    }
  }

}