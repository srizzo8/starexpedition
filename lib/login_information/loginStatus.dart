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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

//var yourUsername;

class loginStatus extends ChangeNotifier{
  static const myLoginKey = "loginKey";
  static const myUsernameKey = "usernameKey";
  static const myInstallMarkerKey = "deviceInstallMarker";
  static const mySecureStorage = FlutterSecureStorage(iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device));

  bool userIsLoggedIn = false;
  String myUsername = "";

  bool get isLoggedIn => userIsLoggedIn;
  String get theUsername => myUsername;

  //A static cache that can be accessed anywhere without an async or context:
  static String? myCachedUsername;

  Future<void> loadInfo() async{
    //Detecting stale data that was restored from a device backup:
    final myMarker = await mySecureStorage.read(key: myInstallMarkerKey);

    if(myMarker == null){
      //Lacks a keychain marker, meaning this is either a fresh install or a situation where application data was restored from a previous backup.
      final myPrefs = await SharedPreferences.getInstance();
      await myPrefs.setBool(myLoginKey, false);
      await myPrefs.remove(myUsernameKey);
      await mySecureStorage.write(key: myInstallMarkerKey, value: "1");
    }

    final myPrefs = await SharedPreferences.getInstance();
    userIsLoggedIn = myPrefs.getBool(myLoginKey) ?? false;
    myUsername = myPrefs.getString(myUsernameKey) ?? "";
    myCachedUsername = myUsername.isNotEmpty? myUsername : null;
    notifyListeners();
  }

  Future<void> loggingIn(String theUsername) async{
    userIsLoggedIn = true;
    myUsername = theUsername;
    myCachedUsername = theUsername;
    notifyListeners();

    final myPrefs = await SharedPreferences.getInstance();
    await myPrefs.setBool(myLoginKey, true);
    await myPrefs.setString(myUsernameKey, theUsername);
  }

  Future<void> loggingOut() async{
    userIsLoggedIn = false;
    myUsername = "";
    myCachedUsername = null;
    notifyListeners();

    final myPrefs = await SharedPreferences.getInstance();
    await myPrefs.setBool(myLoginKey, false);
    await myPrefs.remove(myUsernameKey);
  }

  static Future<String?> getMyPersistedUsername() async{
    final myPrefs = await SharedPreferences.getInstance();
    final myUsername = myPrefs.getString(myUsernameKey);
    return (myUsername != null && myUsername.isNotEmpty) ? myUsername : null;
  }
}