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
import 'package:device_info_plus/device_info_plus.dart';

class deviceIdHelper{
  //Getting the id of one's device:
  Future<String> getPlatformDeviceId() async{
    final myDeviceInfo = DeviceInfoPlugin();

    if(Platform.isAndroid){
      final myAndroidInfo = await myDeviceInfo.androidInfo;
      return myAndroidInfo.id!;
    }
    else if(Platform.isIOS){
      final myIosInfo = await myDeviceInfo.iosInfo;
      return myIosInfo.identifierForVendor ?? "Unknown iOS device";
    }
    else{
      return "Unknown device";
    }
  }
}