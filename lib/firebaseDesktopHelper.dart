import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class firebaseDesktopHelper{
  static String myDatabaseUrl = "";
  static String myApiKey = "";
  static String myProjectId = "";

  static bool get onDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  static String get myFirestoreUrl => "https://firestore.googleapis.com/v1/projects/$myProjectId/databases/(default)/documents";
  //Signing in anonymously:
  /*static Future<void> signingInAnonymously() async{
    final myUrl = "";
    final myResponse = await http.post(Uri.parse(myUrl), headers: {"Content_Type": "application/json"}, body: json.encode({"returnSecureToken": "true"}));
  }*/

  //Getting data from Firebase database:
  static Future<dynamic> getFirebaseData(String myPath) async{
    final myUrl = "$myDatabaseUrl/$myPath.json";
    final myResponse = await http.get(Uri.parse(myUrl));

    if(myResponse.statusCode == 200){
      return json.decode(myResponse.body);
    }

    return null;
  }

  //Getting a Firestore collection from a Firestore database:
  static Future<List<Map<String, dynamic>>> getFirestoreCollection(String myCollection) async{
    final myUrl = "$myFirestoreUrl/$myCollection";
    final myResponse = await http.get(Uri.parse(myUrl));

    if(myResponse.statusCode == 200){
      final myData = json.decode(myResponse.body);
      final myDocuments = myData["documents"] as List? ?? [];
      return myDocuments.map((theDoc) => parseMyFirestoreDoc(theDoc)).toList();
    }

    return [];
  }

  //Parsing a Firestore document:
  static Map<String, dynamic> parseMyFirestoreDoc(Map<String, dynamic> myDoc){
    final myFields = myDoc["fields"] as Map<String, dynamic>? ?? {};
    final myResult = <String, dynamic>{};

    myFields.forEach((key, value){
      myResult[key] = parseMyFirestoreValue(value);
    });

    return myResult;
  }

  //Parsing the Firestore value types:
  static dynamic parseMyFirestoreValue(Map<String, dynamic> myValue){
    if(myValue["stringValue"] != null){
      return myValue["stringValue"];
    }
    if(myValue["integerValue"] != null){
      return myValue["integerValue"];
    }
    if(myValue["doubleValue"] != null){
      return myValue["doubleValue"];
    }
    if(myValue["booleanValue"] != null){
      return myValue["booleanValue"];
    }
    if(myValue["timestampValue"] != null){
      return myValue["timestampValue"];
    }
    if(myValue["arrayValue"] != null){
      final myValues = myValue["arrayValue"]["values"] as List? ?? [];
      return myValues.map((val) => parseMyFirestoreValue(val)).toList();
    }
    if(myValue["mapValue"] != null){
      final myMapFields = myValue["mapValue"]["fields"] as Map<String, dynamic>? ?? {};
      final myMapResult = <String, dynamic>{};

      myMapFields.forEach((key, value){
        myMapResult[key] = parseMyFirestoreValue(value);
      });

      return myMapResult;
    }
    if(myValue["nullValue"] != null){
      return null;
    }

    return null;
  }

  //Setting data:
  /*static Future<void> setFirebaseData(String myPath, dynamic myData) async{
    final myUrl = "$myDatabaseUrl/$myPath.json";
    await http.put(Uri.parse(myUrl), headers: {"Content_Type": "application/json"}, body: json.encode(myData));
  }

  //Pushing data:
  static Future<String> pushFirebaseData(String myPath, dynamic myData) async{
    final myUrl = "$myDatabaseUrl/$myPath.json";
    final myResponse = await http.put(Uri.parse(myUrl), headers: {"Content_Type": "application/json"}, body: json.encode(myData));

    if(myResponse.statusCode == 200){
      final myResult = json.decode(myResponse.body);
      return myResult;
    }

    throw Exception("Unfortunately, data was not pushed.");
  }

  //Updating Firebase data:
  static Future<void> updateFirebaseData(String myPath, Map<String, dynamic> myData) async{
    final myUrl = "$myDatabaseUrl/$myPath.json";
    await http.patch(Uri.parse(myUrl), headers: {"Content_Type": "application/json"}, body: json.encode(myData));
  }

  //Deleting Firebase data:
  static Future<void> deleteFirebaseData(String myPath) async{
    final myUrl = "$myDatabaseUrl/$myPath.json";
    await http.delete(Uri.parse(myUrl));
  }*/
}