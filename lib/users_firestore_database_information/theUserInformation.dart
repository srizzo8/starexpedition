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
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'userDatabaseFirestoreInfo.dart';
import 'package:starexpedition4/firebaseDesktopHelper.dart';

class theUserInformation extends GetxController{
  theUserInformation get instance => Get.find();

  bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  //final myDb = FirebaseFirestore.instance;

  FirebaseFirestore? get myDb{
    if(!isDesktop){
      return FirebaseFirestore.instance;
    }
    return null;
  }

  Future<void> createMyUser(User user) async{
    if(Platform.isWindows || Platform.isMacOS || Platform.isLinux){
      await createUserDesktop(user);
    }
    else{ //On mobile and web
      await myDb!.collection("User").add(user.toJson()).whenComplete(
        () => print("User added!"),
      ).catchError((error, stackTrace){
        print("This is your error: ${error.toString()}");
      });
    }
  }

  Future<void> createUserDesktop(User user) async{
    try{
      final myUrl = "${firebaseDesktopHelper.myFirestoreUrl}/User";
      final body = json.encode({
        "fields": convertToFirestoreFields(user.toJson())
      });

      final myResponse = await http.post(Uri.parse(myUrl), headers: {"Content-Type": "application/json"}, body: body);

      if(myResponse.statusCode == 200){
        print("User added!");
      }
      else{
        print("This is your error: ${myResponse.body}");
      }
    }
    catch (e){
      print("This is your error: ${e.toString()}");
    }
  }

  /*createMyUser(User user) async{
    if(kIsWeb){
      await myDb.collection("User").add(user.toJson()).whenComplete(
        () => print("User added!"),
      )
      .catchError((error, stackTrace){
        print("This is your error: ${error.toString()}");
      });
    }
    else if(Platform.isWindows || Platform.isMacOS || Platform.isLinux){
      await FirebaseFirestore.instance.collection("User").add(user.toJson()).whenComplete(
        () => print("User added!"),
      )
      .catchError((error, stackTrace){
        print("This is your error: ${error.toString()}");
      });
    }
    else{
      await myDb.collection("User").add(user.toJson()).whenComplete(
        () => print("User added!"),
      )
      .catchError((error, stackTrace){
        print("This is your error: ${error.toString()}");
      });
    }
  }*/

  Map<String, dynamic> convertToFirestoreFields(Map<String, dynamic> myData){
    final myFields = <String, dynamic>{};

    myData.forEach((key, value){
      myFields[key] = convertToFirestoreValue(value);
    });

    return myFields;
  }

  Map<String, dynamic> convertToFirestoreValue(dynamic myValue){
    if(myValue is String){
      return {"stringValue": myValue};
    }
    else if(myValue is int){
      return {"integerValue": myValue.toString()};
    }
    else if(myValue is double){
      return {"doubleValue": myValue};
    }
    else if(myValue is bool){
      return {"booleanValue": myValue};
    }
    else if(myValue is DateTime){
      return {"timestampValue": myValue.toIso8601String()};
    }
    else if(myValue is List){
      return{
        "arrayValue": {"values": myValue.map((val) => convertToFirestoreValue(val)).toList()}
      };
    }
    else if(myValue is Map){
      final myFields = <String, dynamic>{};

      myValue.forEach((key, value){
        myFields[key.toString()] = convertToFirestoreValue(value);
      });

      return {"mapValue": {"fields": myFields}};
    }
    else if(myValue == null){
      return {"nullValue": null};
    }

    throw Exception("This value type is not supported: ${myValue.runtimeType}");
  }
}