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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class deviceIdHelper{
  static const myStorage = FlutterSecureStorage();
  static const myStorageKey = "myCachedDeviceId";

  //Getting the id of one's device:
  Future<String> getPlatformDeviceId() async{
    //The secure storage will be checked first because this persists across all application reinstalls
    //Something like iOS's identifierForVendor, on the other hand, can change after a reinstall:
    final myCachedId = await myStorage.read(key: myStorageKey);

    if(myCachedId != null && myCachedId.isNotEmpty){
      return myCachedId;
    }

    //If the cached ID has not been found yet, it will be found in the original way.
    //This covers all existing users on their first launches after this update.
    //As a result, their existing ID will remain the same, and this avoids any disruptions
    //to trials and/or subscriptions:
    final myDeviceInfo = DeviceInfoPlugin();
    String myId;

    if(Platform.isAndroid){
      final myAndroidInfo = await myDeviceInfo.androidInfo;
      myId = myAndroidInfo.id!;
    }
    else if(Platform.isIOS){
      final myIosInfo = await myDeviceInfo.iosInfo;
      myId = myIosInfo.identifierForVendor ?? "Unknown iOS device";
    }
    else{
      myId = "Unknown device";
    }

    //Caching myId in secure storage so a user will reuse this ID on every future launch
    //of Star Expedition, even after he or she reinstalls it:
    await myStorage.write(key: myStorageKey, value: myId);
    return myId;
  }
}