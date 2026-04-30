import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
//import 'dart:html';

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

  //Called once; this records the installation date:
  Future<void> getInstallationDate() async{
    final myPreferences = await SharedPreferences.getInstance();
    if(myPreferences.getString(myInstallDateKey) == null){
      await myPreferences.setString(myInstallDateKey, DateTime.now().toIso8601String(),);
    }
  }

  //Returns true if a user's trial is still in the one-week time window:
  Future<bool> isInTrial() async{
    final myPrefs = await SharedPreferences.getInstance();
    final myInstallDateString = myPrefs.getString(myInstallDateKey);

    if(myInstallDateString == null){
      return false;
    }

    final myInstallDate = DateTime.parse(myInstallDateString);
    final daysSinceInstall = DateTime.now().difference(myInstallDate).inDays;

    return daysSinceInstall < myTrialDays;
  }

  //Returns the number of trial days that are remaining for a user:
  Future<int> remainingTrialDays() async{
    final myPrefs = await SharedPreferences.getInstance();
    final myInstallDateString = myPrefs.getString(myInstallDateKey);

    if(myInstallDateString == null){
      return 0;
    }

    final myInstallDate = DateTime.parse(myInstallDateString);
    final daysSinceInstall = DateTime.now().difference(myInstallDate).inDays;

    return (myTrialDays - daysSinceInstall).clamp(0, myTrialDays);
  }
}