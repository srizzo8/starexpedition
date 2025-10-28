import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

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
      return myDocuments.map((theDoc){
        final myParsedDoc = parseMyFirestoreDoc(theDoc);

        //Extracting the document name from the "name" field of theDoc:
        //Its format is like this: "projects/project_id/databases/(default)/documents/collection/document_id"
        final theName = theDoc["name"] as String? ?? "";
        final myDocId = theName.split("/").last;

        //Adding the document ID to the returned data:
        myParsedDoc["docId"] = myDocId;

        return myParsedDoc;
      }).toList();
    }

    return [];
  }

  //Getting a Firestore subcollection from a Firestore database:
  static Future<List<Map<String, dynamic>>> getFirestoreSubcollection(String myCollectionPath, var myDocId, String mySubCollectionPath) async{
    final myUrl = "$myFirestoreUrl/$myCollectionPath/$myDocId/$mySubCollectionPath";
    final myResponse = await http.get(Uri.parse(myUrl));

    if(myResponse.statusCode == 200){
      final myData = json.decode(myResponse.body);
      final myDocuments = myData["documents"] as List? ?? [];
      return myDocuments.map((theDoc) => parseMyFirestoreDoc(theDoc)).toList();
    }

    return [];
  }

  //Getting a Firestore document snapshot from a Firestore subcollection:
  static Future<Map<String, dynamic>?> getFirestoreSubcollectionDocument(String myCollectionPath, var myDocId, String mySubCollectionPath, var mySubDocId) async{
    final myUrl = "$myFirestoreUrl/$myCollectionPath/$myDocId/$mySubCollectionPath/$mySubDocId";
    final myResponse = await http.get(Uri.parse(myUrl));

    if(myResponse.statusCode == 200){
      final myData = json.decode(myResponse.body);
      //final myDoc = myData["documents"] as List? ?? [];
      return parseMyFirestoreDoc(myData);
    }
    else if(myResponse.statusCode == 404){
      return null;
    }

    return null;
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

  //Creating a document in a Firestore collection:
  static Future<String> createFirestoreDocument(String myCollectionPath, Map<String, dynamic> myData) async{
    final myUrl = "$myFirestoreUrl/$myCollectionPath";
    final myBody = json.encode({'fields': convertToFirestoreFields(myData)});

    final myResponse = await http.post(Uri.parse(myUrl), headers: {"Content-Type": "application/json"}, body: myBody);

    if(myResponse.statusCode == 200){
      final myResponseData = json.decode(myResponse.body);
      final myName = myResponseData["name"].toString();
      return myName.split("/").last;
    }
    else{
      throw Exception("Document unable to be created: ${myResponse.body}");
    }
  }

  //Creating a document for a Firestore subcollection:
  static Future<String> createFirestoreDocumentForSubcollection(String myCollectionPath, Map<String, dynamic> myData, var myDocId, String mySubcollectionPath) async{
    final myUrl = "$myFirestoreUrl/$myCollectionPath/$myDocId/$mySubcollectionPath";
    final myBody = json.encode({'fields': convertToFirestoreFields(myData)});

    final myResponse = await http.post(Uri.parse(myUrl), headers: {"Content-Type": "application/json"}, body: myBody);

    print("myUrl: ${myUrl}");
    print("myBody: ${myBody}");
    print("myResponse: ${myResponse}");

    if(myResponse.statusCode == 200){
      final myResponseData = json.decode(myResponse.body);
      final myName = myResponseData["name"].toString();
      //print("Success!");
      return myName.split("/").last;
    }
    else{
      throw Exception("Document in subcollection unable to be created: ${myResponse.body}");
    }
  }

  //Updating a Firestore document:
  static Future<void> updateFirestoreDocument(String myDocumentPath, Map<String, dynamic> myData) async{
    //Building field paths for the updateMyMask String:
    List<String> myFieldPaths = myData.keys.toList();
    String updateMask = myFieldPaths.map((myPath) => "updateMask.fieldPaths=${myPath}").join("&");

    final myUrl = "$myFirestoreUrl/$myDocumentPath?$updateMask";

    print("Update URL: ${myUrl}");
    print("Update data: ${myData}");

    final myBody = json.encode({"fields": convertToFirestoreFields(myData)});

    print("Update body: ${myBody}");

    final myResponse = await http.patch(
      Uri.parse(myUrl),
      headers: {"Content-Type": "application/json"},
      body: myBody,
    );

    print("Update response status: ${myResponse.statusCode}");
    print("Update response body: ${myResponse.body}");

    if(myResponse.statusCode != 200){
      throw Exception("Failed to update the document: ${myResponse.body}");
    }
  }

  //Method for converting a map to having a Firestore fields format
  static Map<String, dynamic> convertToFirestoreFields(Map<String, dynamic> myData){
    final myFields = <String, dynamic>{};
    myData.forEach((k, v){
      myFields[k] = convertToFirestoreValues(v);
    });

    return myFields;
  }

  //Method for converting values to Firestore format
  static Map<String, dynamic> convertToFirestoreValues(dynamic myValue){
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
      String myIsoString = myValue.toUtc().toIso8601String();
      if(!myIsoString.endsWith("Z")){
        myIsoString = myIsoString + "Z";
      }
      //return {"timestampValue": myIsoString};
      String myDate = formatMyTimestamp(myIsoString);
      return {"stringValue": myDate};
    }
    else if(myValue is List){
      return {
        "arrayValue": {"values": myValue.map((v) => convertToFirestoreValues(v)).toList()},
      };
    }
    else if(myValue is Map){
      final myFields = <String, dynamic>{};
      myValue.forEach((k, v){
        myFields[k.toString()] = convertToFirestoreValues(v);
      });
      return {"mapValue": {"fields": myFields}};
    }
    else if(myValue == null){
      return {"nullValue": null};
    }
    throw Exception("The value type is unsupported: ${myValue.runtimeType}");
  }

  //Formatting the timestamp for Firestore databases
  static String formatMyTimestamp(var myTimeValue){
    DateTime dt;

    if(onDesktop){ //For Desktop
      if(myTimeValue is String){
        dt = convertStringToDateTime(myTimeValue);
      }
      else{
        return myTimeValue.toString();
      }
    }
    else{ //For Mobile and Web
      if(myTimeValue is Timestamp){
        dt = myTimeValue.toDate();
      }
      else{
        return myTimeValue.toString();
      }
    }

    //Converting to local time
    dt =  dt.toLocal();

    //Formatting the date so it can be like: January 1, 2025 at 12:00:00 AM UTC-4
    final myMonths = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

    //The day
    String theMonth = myMonths[dt.month];
    String theDay = dt.day.toString();
    String theYear = dt.year.toString();

    //The time of the day
    String theHour = dt.hour > 12 ? (dt.hour - 12).toString() : (dt.hour == 0 ? "12" : dt.hour.toString());
    String theMinute = dt.minute.toString().padLeft(2, "0");
    String theSecond = dt.second.toString().padLeft(2, "0");
    String amOrPm = dt.hour >= 12 ? "PM" : "AM";

    //Getting the timezone offset
    int theOffsetHours = dt.timeZoneOffset.inHours;
    String theTimezone = theOffsetHours >= 0 ? "UTC+${theOffsetHours}" : "UTC${theOffsetHours}";

    return "${theMonth} ${theDay}, ${theYear} at ${theHour}:${theMinute}:${theSecond} ${amOrPm} ${theTimezone}";
  }

  //Converting String version of a date/time to DateTime for subforums:
  static DateTime convertStringToDateTime(String theDateTimeString){
    /*String cleanedString = theDateTimeString.replaceAll(" at ", " ").split(" UTC")[0];

    DateFormat myFormat = DateFormat("MMMM d, yyyy h:mm:ss a");
    DateTime dt = myFormat.parse(cleanedString);

    return dt;*/
    /*final myOffsetRegex = RegExp(r'UTC([+-]\d+)');
    final myMatch = myOffsetRegex.firstMatch(theDateTimeString);
    final offsetHours = myMatch != null ? int.parse(myMatch.group(1)!) : 0;

    String cleanedString = theDateTimeString.replaceAll(" at ", " ").split(" UTC")[0];

    DateFormat myFormat = DateFormat("MMMM d, yyyy h:mm:ss a");
    DateTime dt = myFormat.parse(cleanedString);

    final theUTCTime = dt.subtract(Duration(hours: offsetHours));

    return theUTCTime;*/
    return DateTime.parse(theDateTimeString);
  }

  //Parsing the Firestore value types:
  static dynamic parseMyFirestoreValue(Map<String, dynamic> myValue){
    if(myValue["stringValue"] != null){
      return myValue["stringValue"];
    }
    if(myValue["integerValue"] != null){
      return int.parse(myValue["integerValue"]);
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