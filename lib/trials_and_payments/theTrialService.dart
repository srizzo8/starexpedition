import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class theTrialService{
  static const String myInstallDateKey = "installDate";
  static const int myTrialDays = 7;

  //Getting the id of one's device:
  Future<String> getDeviceId() async{
    final myDeviceInfo = DeviceInfoPlugin();
    final myAndroidInfo = await myDeviceInfo.androidInfo;

    return myAndroidInfo.id!;
  }

  //Called once; this records the installation date:
  Future<void> getInstallationDate() async{
    final myDeviceId = await getDeviceId();

    //Checking Firestore to see if the device has been seen previously:
    final myDoc = await FirebaseFirestore.instance.collection("Trials").doc(myDeviceId).get();

    if(myDoc.exists){
      //The device already has a record of using the app, and should be saved:
      final myPrefs = await SharedPreferences.getInstance();
      await myPrefs.setString(myInstallDateKey, myDoc.data()!["installDate"]);
    }
    else{
      //The first time the device is using the app:
      final currentTime = DateTime.now().toIso8601String();

      //Permanently saving device info to Firestore:
      await FirebaseFirestore.instance.collection("Trials").doc(myDeviceId).set({"installDate": currentTime, "deviceId": myDeviceId});

      //Saving information locally:
      final myPrefs = await SharedPreferences.getInstance();
      await myPrefs.setString(myInstallDateKey, currentTime);
    }
  }

  //Returns true if a user's trial is still in the one-week time window:
  Future<bool> isInTrial() async{
    final myDeviceId = await getDeviceId();

    //Checking Firestore database:
    final myDoc = await FirebaseFirestore.instance.collection("Trials").doc(myDeviceId).get();

    if(!myDoc.exists){
      return false;
    }

    final myInstallDate = DateTime.parse(myDoc.data()!["installDate"]);
    final daysSinceInstall = DateTime.now().difference(myInstallDate).inDays;
    final inTrial = daysSinceInstall < myTrialDays;

    return inTrial;
  }

  //Checking how many days are left for a user's trial:
  Future<int> daysLeftOfTrial() async{
    final myDeviceId = await getDeviceId();

    final myDoc = await FirebaseFirestore.instance.collection("Trials").doc(myDeviceId).get();

    if(!myDoc.exists){
      return 0;
    }

    final myInstallDate = DateTime.parse(myDoc.data()!["installDate"]);
    final daysSinceInstall = DateTime.now().difference(myInstallDate).inDays;
    final myDaysLeft = (myTrialDays - daysSinceInstall).clamp(0, myTrialDays);

    return myDaysLeft;
  }
}