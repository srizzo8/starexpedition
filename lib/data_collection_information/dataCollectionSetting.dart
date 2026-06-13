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

class dataCollectionSetting{
  static const String myDataCollectionSettingKey = "dataCollectionSetting";
  bool turnDataCollectionOn = true;

  //Getting the id of one's device:
  static Future<String> getMyDeviceId() async{
    final myDeviceInfo = DeviceInfoPlugin();
    final myAndroidInfo = await myDeviceInfo.androidInfo;

    return myAndroidInfo.id!;
  }

  //Creates a Firestore document on the first launch and reads the saved value in every launch afterward:
  static Future<void> getDataCollectionOn() async{
    final myDeviceId = await getMyDeviceId();

    final myPrefs = await SharedPreferences.getInstance();

    //Checking Firestore to see if the device has been seen previously:
    final myDoc = await FirebaseFirestore.instance.collection("Data_Collection_Settings").doc(myDeviceId).get();

    if(myDoc.exists){
      //For any launch after the first launch (syncs the Firestore value into local prefs):
      final myDataCollectionOnValue = myDoc.data()!["dataCollectionOn"];
      await myPrefs.setBool(myDataCollectionSettingKey, myDataCollectionOnValue);
    }
    else{
      //For the first launch (creates a Firestore document with dataCollectionOn being set to true by default):
      await FirebaseFirestore.instance.collection("Data_Collection_Settings").doc(myDeviceId).set({"deviceId": myDeviceId, "dataCollectionOn": true});

      final myPrefs = await SharedPreferences.getInstance();
      await myPrefs.setBool(myDataCollectionSettingKey, true);
    }
  }

  //Reading the current setting locally:
  static Future<bool> isEnabled() async{
    final myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getBool(myDataCollectionSettingKey) ?? true;
  }

  //This method gets called when a user decides to turn dataCollectionOn on or off:
  static Future<void> setEnabled(bool myBoolValue) async{
    final myDeviceId = await getMyDeviceId();
    final myPrefs = await SharedPreferences.getInstance();

    //Updating myPrefs and the Firestore database:
    await myPrefs.setBool(myDataCollectionSettingKey, myBoolValue);

    await FirebaseFirestore.instance.collection("Data_Collection_Settings").doc(myDeviceId).update({"dataCollectionOn": myBoolValue});
  }
}