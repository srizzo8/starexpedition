import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:io' show HttpHeaders, Platform;
import 'dart:math';
//if(kIsWeb) import 'dart:html' as html;
import 'dart:typed_data';
import 'package:starexpedition4/web_related_information/webErrorHandlersImplementation.dart';
//if(kIsWeb) import 'package:js/js_util.dart' as jsUtil;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:path_provider/path_provider.dart';
import 'package:starexpedition4/pdfViewer.dart';
import 'package:starexpedition4/sourceMapDecoder.dart';
import 'package:starexpedition4/spectralClassPage.dart';

import 'package:starexpedition4/discussionBoardPage.dart';
import 'package:starexpedition4/loginPage.dart';
import 'package:starexpedition4/registerPage.dart';
import 'package:starexpedition4/loginPage.dart' as theLoginPage;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';
import 'package:starexpedition4/spectralClassPage.dart';
import 'package:starexpedition4/whyStarExpeditionWasMade.dart';
import 'package:starexpedition4/conversionCalculator.dart';
import 'package:starexpedition4/settingsPage.dart';
import 'package:starexpedition4/userProfile.dart';
import 'package:starexpedition4/userSearchBar.dart';
import 'package:starexpedition4/pdfViewer.dart';
import 'package:starexpedition4/firebaseDesktopHelper.dart';

import 'loginPage.dart';

//import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:url_launcher/url_launcher.dart';

//import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

//import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';

import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

import 'package:pdfx/pdfx.dart';

import 'package:http/http.dart' as http;

/*import 'webErrorStub.dart'
  if(dart.library.html) 'forWebErrors.dart';*/

//import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

/* String correctString = "";
FirebaseDatabase database = FirebaseDatabase.instance;
DatabaseReference ref = FirebaseDatabase.instance.ref(myString);*/

String correctStar = "";
String correctPlanet = "";
List<String> informationAboutPlanet = [];
List<String> starInfo = [];
//String accountsDataString = "";
//var myData;
List<Users>? theUsers = [];

bool discussionBoardLogin = false;

Map<String, List> otherNamesMap = HashMap();
Iterable<List> alternateNames = [];

bool featuredStarOfTheDayBool = false;
bool clickOnName = false;

var userProfileData;
var userProfileDoc;
var usersBlurb;
var usersInterests;
var usersLocation;
var numberOfPostsUserHasMade;
var starsUserTracked;
var planetsUserTracked;

var theListOfUsers = [];

var docNameForStarsTrackedNewUser;
var docNameForStarsTrackedExistingUser;

//var myStarsTracked = {};
bool starTracked = false;
//var usersOnStarExpedition = [];

var docNameForPlanetsTrackedNewUser;
var docNameForPlanetsTrackedExistingUser;

bool planetTracked = false;

List allStars = [];
List allPlanets = [];
Map starsAndTheirPlanets = {};

bool fromSearchBarToPlanetArticle = false;

String starFileContent = "";
String planetFileContent = "";

List<String> listOfStarUrls = [];
List<String> listOfPlanetUrls = [];

int starListUrlIndex = 0;
int planetListUrlIndex = 0;

bool starPdfBool = false;
bool planetPdfBool = false;

var myStarPdfFile;
var myPlanetPdfFile;

//List<String> userItemsNewUsers = ["My profile", "Settings", "Logout"];
//List<String> userItemsExistingUsers = ["My profile", "Settings", "Logout"];

//String newUserDropdownValue = userItemsNewUsers[0];
//String existingUserDropdownValue = userItemsExistingUsers[0];

//String myOptionsNewUsers = userItemsNewUsers[0];
//String myOptionsExistingUsers = userItemsExistingUsers[0];

//enum userItemsExistingUsers{myProfile, mySettings, logOut}
//enum userItemsNewUsers{myProfile, mySettings, logOut}

/*
Future<String> get myDirectoryPath async{
  Directory d = await getApplicationDocumentsDirectory();
  return d.path;
}

Future<File> get accountsJsonFile async{
  final filePath = await myDirectoryPath;
  return File('$filePath/accountsData.json');
}

 */
/*
readFilesFromAsset() async{
  String accountsDataString = await rootBundle.loadString('assets/accountsData.json');
  print("accountsDataString:  ${accountsDataString}");
}

readFilesFromDevicePath() async{
  /*Directory d = await getApplicationSupportDirectory();
  print(d);*/
  //File myFile = await File("${d.path}/accountsData.json").create();

  Directory d = new Directory("assets");
  File myFile = await File("$d/accountsData2.json").create();
  String contentOfAccountsFile = await myFile.readAsString();
  print("contentOfAccountsFile: ${contentOfAccountsFile}");
}

writeFilesToCustomDevicePath() async{
  /*Directory sd = await getApplicationSupportDirectory();
  print(sd);
  File sMyFile = await File("${sd.path}/accountsData.json").create();*/
  Directory d2 = new Directory("assets");
  File sMyFile = await File("$d2/accountsData2.json").create();
  String contentOfAccountsFile = jsonEncode({
    "username": "Ken",
    "email": "ken@test.com",
    "password": "kenworth"
  });

  return await sMyFile.writeAsString(contentOfAccountsFile);
}
*/

//Trying to find local path
Future<String> get findLocalPath async{
  final theDirectory = await getApplicationDocumentsDirectory();
  return (theDirectory.path).toString();
}

Future<File> get findLocalFile async{
  final myPath = await findLocalPath;
  return File('$myPath/accountsData.json');
}

Future<File> insertData(String name, String email, String pword) async{
  final theFile = await findLocalFile;
  return theFile.writeAsString("$name " + "$email " + "$pword ");
}

Future<String> readTheInfo() async{
  try{
    final jsonFile = await findLocalFile;
    final users = await jsonFile.readAsString();
    return users;
  }
  catch(e){
    return "No users";
  }
}


//For reference

class Users{
  String? username;
  String? email;
  String? password;

  Users({
    required this.username,
    required this.email,
    required this.password
  });

  @override
  String toString(){
    return "username: $username, email: $email, password: $password";
  }

/*
  Users.fromJson(Map<String, dynamic> info){
    username = info['username'];
    email = info['email'];
    password = info['password'];
  }

  Map<String, dynamic> toJsonFile(){
    final Map<String, dynamic> myData = <String, dynamic>{};
    myData['username'] = username;
    myData['email'] = email;
    myData['password'] = password;
    return myData;
  } */
}

/*
Future<void> readUserData(String userInfo) async{
  var responseToString = await jsonDecode(userInfo);

  for(var v in responseToString){
    Users u = Users(v['username'], v['email'], v['password']);
    theUsers.add(u);
  }
}*/

/*
readUserData() async{
  String fileInfo = "User Information";
  File f = await accountsJsonFile;

  if(await f.exists()){
    try{
      fileInfo = await f.readAsString();
    }
    catch(e){
      print(e);
    }
  }

  return json.decode(fileInfo);
}

writeUserData() async{
  final Users us = Users(registerPage.theUsername.text.toString(), registerPage.email.text.toString(), registerPage.password.text.toString());
  File theFile = await accountsJsonFile;
  await theFile.writeAsString(jsonEncode(us));
  return us;
}
*/

/*
Future<List<dynamic>> loadAccountsData() async{
  final String accountsDataString = await rootBundle.loadString('assets/accountsData.json');
  var data = jsonDecode(accountsDataString);
  var accounts = data["users"];
  return accounts;
}*/

//String starsAndPlanetsDatabase = "https://star-expedition-default-rtdb.firebaseio.com/";

/*late DatabaseReference starsAndPlanetsDatabase = FirebaseDatabase.instanceFor(
  app: Firebase.app(),
  databaseURL: 'https://star-expedition-default-rtdb.firebaseio.com/'
).ref();*/

/*late DatabaseReference theAccountsDatabase = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://star-expedition-accounts-default-rtdb.firebaseio.com/'
).ref();*/

//Reading star article file
Future<String> readStarFile() async{
  int starsIndex = starsForSearchBar.indexWhere((star) => star.starName! == correctStar);
  print("starsIndex: ${starsIndex}");
  try{
    //Reading the file
    final fileContent = await rootBundle.loadString(starsForSearchBar[starsIndex].articlePath!);
    print("fileContent: ${fileContent}");

    return fileContent;
  }
  catch(e){
    //Return "N/A" if there is an error
    return "N/A";
  }
}

Future<String> readPlanetFile(String planetPath) async{
  //Getting the path of the planet text file path
  /*final getPlanetAttribute = FirebaseDatabase.instance.ref("${correctStar}/Planets/${planetClicked}");
  final planetTextFilePath = await getPlanetAttribute.child("planet_text_file_path").get();
  String planetTextFilePathAsString = "";*/

  /*Future.delayed(Duration(seconds: 1), () {
    planetTextFilePathAsString = planetTextFilePath.value.toString();
  });

  print("planettextfilepathasstring: ${planetTextFilePathAsString}");
  */
  //planetPath = informationAboutPlanet[6].toString();
  print("planet path: ${planetPath}");
  //Reading the planet text file
  try{
    final planetFileContent = await rootBundle.loadString(planetPath);
    print("planetFileContent: ${planetFileContent}");

    return planetFileContent;
  }
  catch(e){
    return "N/A";
  }

  /*starsAndTheirPlanets.values.forEach((planet){
    for(int p = 0; p < planet.length; p++){
      if(p == planetClicked){
      }
      else{
        //continue
      }
    }
  });*/

  /*starsAndTheirPlanets.keys.forEach((star){
    if(starsAndTheirPlanets[star] == correctStar){
      planetsIndex = starsAndTheirPlanets.keys.indexOf(star);
    }
  });
  print("planetsIndex: ${planetsIndex}");
  try{
    //Reading the file
    final fileContent =
  }
  catch(e){
    return "N/A";
  }*/
}

/*void forWebPlatforms(){
  getWebOnly().performATask();
}*/

/*List<String> reachEachLineInTextFile(String contentFromFile){
  List<String> fileContentAsList = contentFromFile.split("\n");
  return fileContentAsList;
  /*try{
    final myFile = File(filePath);
    List<String> fileLines = myFile.readAsLinesSync();

    for(String s in fileLines){
      if(s == ""){
        fileLines.remove("");
      }
      else{
        //continue
      }
    }

    return fileLines;
  }
  catch (e){
    return [];
  }*/
}*/
String? determiningUsername(){
  //String? myUsername;
  //String? myNewUsername;
  print("This is myUsername: ${myUsername}");
  print("This is myNewUsername: ${myNewUsername}");

  if((myUsername.isNotEmpty) && (myNewUsername.isEmpty)){
    return myUsername;
  }
  else if((myUsername.isEmpty) && (myNewUsername.isNotEmpty)){
    return myNewUsername;
  }
  else{
    return null;
  }
}

Future<Map<String, dynamic>> parseMyStackTrace(String st) async{
  final myLines = st.split("\n");

  for(final myLine in myLines){
    final myMatch = RegExp(r'\((package:[^:]+):(\d+):(\d+)\)').firstMatch(myLine);

    if(myMatch != null){
      return { "file_name": myMatch.group(1), "line": myMatch.group(2), "column": myMatch.group(3), };
    }
  }

  return { "file_name": null, "line": null, "column": null, };

  /*final myJsRegex = RegExp(r'(packages\/starexpedition4\/.+\.js):(\d+):(\d+)');
  final myMatch = myJsRegex.firstMatch(st);

  if(myMatch != null){
    final myJsFile = myMatch.group(1)!;
    final myJsLine = myMatch.group(2)!;
    final myJsColumn = myMatch.group(3)!;

    final myDecoder = sourceMapDecoder(myJsFile);
    final decoded = await myDecoder.decodeTheLocation(int.parse(myJsLine), int.parse(myJsColumn));

    if(decoded != null){
      return { "file_name": decoded["file_name"], "line": decoded["line"], "column": decoded["column"], };
    }
  }

  //Falling back to the original regex:
  return { "file_name": null, "line": null, "column": null, };*/
}

Future<void> loggingError(String myMessage, StackTrace myStacktrace, String? theUser, {Map<String, dynamic>? myExtraInfo}) async{
  final myUrl = Uri.parse("https://hjncbvhtwdenqzacfxab.supabase.co/functions/v1/log_error");

  final myDeviceInfo = kIsWeb? "Web" : "${Platform.operatingSystem} ${Platform.operatingSystemVersion}";

  final myPublicToken = "bkg94itlep73igf81qw60";

  //Stack trace handling:
  final Map<String, dynamic> myParsedStack = kIsWeb? <String, dynamic>{ "file_name": null, "line": null, "column": null } : await parseMyStackTrace(myStacktrace.toString());
  //final myParsedStack = parseMyStackTrace(myStacktrace.toString());

  //Converting from web to raw JS stacktrace and from mobile and desktop to raw Dart stacktrace:
  final myFullStackString = myStacktrace.toString();

  //Checking if myPublicToken is empty or not:
  if(myPublicToken.isEmpty){
    print("Unfortunately, the value of myPublicToken is missing");
  }

  //Determining the value of theUser:
  theUser = determiningUsername();

  //Build headers with an API key:
  final Map<String, String> myHeaders = {
    HttpHeaders.contentTypeHeader: "application/json",
    "x-api-key": myPublicToken,
  };

  print("These are the outgoing headers: $myHeaders");

  final body = jsonEncode({
    "message": myMessage,
    "stacktrace": myFullStackString,
    "device_info": myDeviceInfo,
    "file_name": myParsedStack["file_name"],
    "line": myParsedStack["line"],
    "column_number": myParsedStack["column"],
    "extra": myExtraInfo ?? {},
    "username": theUser,
  });

  print("Your stacktrace: ${myStacktrace}");

  print("Length of body: ${utf8.encode(body).length}");

  print("This is the outgoing body: ${body}");

  try{
    final myResponse = await http.post(myUrl, headers: myHeaders, body: body,);

    print("Response status code: ${myResponse.statusCode}");
    print("Response body: ${myResponse.body}");

    if(myResponse.statusCode != 200){
      print("Unable to log the error: ${myResponse.statusCode} - ${myResponse.body}");
    }
    else{
      print("The error was successfully sent to Supabase: ${myResponse.body}");
    }
  }
  catch(myError, myStack){
    //If the error logging fails:
    print("Unfortunately the error logging has failed: ${myError}");
    print("Here is the stack: ${myStack}");
  }
}

void setupMyErrorHandlers(){
  //Catching Flutter Framework/UI errors with Supabase:
  FlutterError.onError = (FlutterErrorDetails myDetails){
    FlutterError.dumpErrorToConsole(myDetails);
    loggingError(myDetails.exceptionAsString(), myDetails.stack ?? StackTrace.current, null, myExtraInfo: { "origin": "flutter_error" },);
  };

  //For web errors:
  setupWebErrorHandlers();
  /*if(kIsWeb){
    //For JS runtime errors:
    html.window.addEventListener("error", (myEvent){
      final myJsError = myEvent as html.ErrorEvent;

      final myStack = jsUtil.getProperty(myJsError.error ?? {}, "stack") as String?;

      loggingError(myJsError.message ?? "Unknown JS-related error", StackTrace.fromString(myStack ?? ""), determiningUsername(), myExtraInfo: {"origin": "js_error", "source": myJsError.filename, "line": myJsError.lineno, "column": myJsError.colno},);
    });
    /*html.window.addEventListener("error", (myEvent){
      final myErrorEvent = myEvent as html.ErrorEvent;
      loggingError(myErrorEvent.message ?? "Unknown JS-related error", StackTrace.current, determiningUsername(), myExtraInfo: {"origin": "js_error", "source": myErrorEvent.filename, "line": myErrorEvent.lineno, "column": myErrorEvent.colno},);
    });*/

    //Promise errors:
    html.window.addEventListener("unhandledrejection", (myEvent){
      final myJsEvent = myEvent as html.PromiseRejectionEvent;
      final myReason = myJsEvent.reason;

      final myStack = jsUtil.getProperty(myReason ?? {}, "stack") as String?;

      loggingError(myReason.toString(), StackTrace.fromString(myStack ?? ""), determiningUsername(), myExtraInfo: {"origin": "js_promise"},);
    });
  }*/
}

/*void setupWebJSErrors(){
  if(!kIsWeb){
    return;
  }
  else{
    html.window.onError.listen((myEvent){
      final ee = myEvent as html.ErrorEvent;

      final mySafeStack = ee.error is Error ? (ee.error as Error).stackTrace?.toString() ?? "No JS stack trace" : ee.message ?? "Unknown JS-related error";

      final myStack = StackTrace.fromString(mySafeStack);

      loggingError(ee.message ?? "Unknown JS-related error", myStack, determiningUsername(), myExtraInfo: { "origin": "js_window", "filename": ee.filename, "linenumber": ee.lineno, "columnnumber": ee.colno, },);
    });
  }
}*/

/*void setupDartWebErrorCatcher(){
  if(kIsWeb){
    //Catches asynchronous web errors that Flutter typically ignores:
    ErrorWidget.builder = (FlutterErrorDetails myDetails){
      loggingError(myDetails.exceptionAsString(), myDetails.stack ?? StackTrace.current, determiningUsername(), myExtraInfo: {"origin": "dart_web_async"});

      //Returning the error as text so Star Expedition does not crash:
      return Text("We apologize for the error that has occurred");
    };
  }
}*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Loading the .env file:
  await dotenv.load(fileName: "assets/dotenv.env");

  //Initializing firebaseDesktopHelper:
  firebaseDesktopHelper.myDatabaseUrl = dotenv.env["FIREBASE_DATABASE_URL"]!;
  firebaseDesktopHelper.myApiKey = dotenv.env["FIREBASE_API_KEY"]!;
  firebaseDesktopHelper.myProjectId = dotenv.env["FIREBASE_PROJECT_ID"]!;

  List usersOnStarExpeditionDocs = [];

  if(kIsWeb){
    await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: dotenv.env["FIREBASE_API_KEY"]!,
      appId: dotenv.env["FIREBASE_APP_ID"]!,
      databaseURL: dotenv.env["FIREBASE_DATABASE_URL"]!,
      messagingSenderId: dotenv.env["FIREBASE_MESSAGING_SENDER_ID"]!,
      projectId: dotenv.env["FIREBASE_PROJECT_ID"]!
    ));

    await FirebaseFirestore.instance.collection("User").get().then((snapshot){
      snapshot.docs.forEach((item){
        usersOnStarExpeditionDocs.add(item.data());
      });
    });
    print("usersOnStarExpeditionDocs: ${usersOnStarExpeditionDocs}");

    starsForSearchBar.sort((s1, s2) => s1.starName!.compareTo(s2.starName!));

    for(int n = 0; n < usersOnStarExpeditionDocs.length; n++){
      Users u = new Users(username: usersOnStarExpeditionDocs[n]["username"], email: usersOnStarExpeditionDocs[n]["emailAddress"], password: usersOnStarExpeditionDocs[n]["password"]);
      theUsers!.add(u);
    }

    //List of stars in Star Expedition
    for(var s in starsForSearchBar){
      var star = s.starName!;
      allStars.add(star);
    }

    allStars.sort((s1, s2) => s1.toLowerCase().compareTo(s2.toLowerCase()));

    print("All stars: ${allStars}");

    //List of planets each star has
    for(var v in starsForSearchBar){
      var ref = FirebaseDatabase.instance.ref(v.starName!);
      var mySnapshot = await ref.child("Planets").get();
      var info = mySnapshot.value as Map;
      for(var i in info.keys){
        allPlanets.add(i);
      }

      //All stars and their planets
      starsAndTheirPlanets[v.starName!] = info.keys;
    }

    allPlanets.sort((p1, p2) => p1.toLowerCase().compareTo(p2.toLowerCase()));

    print("stars and their planets: ${starsAndTheirPlanets}");

    print("starsForSearchBar: ${starsForSearchBar}");
    print("The snapshot: ${allPlanets}");
  }
  else if(firebaseDesktopHelper.onDesktop){
    print("This is the desktop version of Star Expedition");

    usersOnStarExpeditionDocs = await firebaseDesktopHelper.getFirestoreCollection("User");

    starsForSearchBar.sort((s1, s2) => s1.starName!.compareTo(s2.starName!));

    for(int n = 0; n < usersOnStarExpeditionDocs.length; n++){
      Users u = new Users(username: usersOnStarExpeditionDocs[n]["username"], email: usersOnStarExpeditionDocs[n]["emailAddress"], password: usersOnStarExpeditionDocs[n]["password"]);
      theUsers!.add(u);
    }

    for(var s in starsForSearchBar){
      var star = s.starName!;
      allStars.add(star);
    }

    allStars.sort((s1, s2) => s1.toLowerCase().compareTo(s2.toLowerCase()));

    print("All stars: ${allStars}");

    for(var v in starsForSearchBar){
      final myData = await firebaseDesktopHelper.getFirebaseData("${v.starName}/Planets");
      var info = myData as Map;
      for(var i in info.keys){
        allPlanets.add(i);
      }
      starsAndTheirPlanets[v.starName!] = info.keys;
    }
  }
  else{
    await Firebase.initializeApp();

    await FirebaseFirestore.instance.collection("User").get().then((snapshot){
      snapshot.docs.forEach((item){
        usersOnStarExpeditionDocs.add(item.data());
      });
    });
    print("usersOnStarExpeditionDocs: ${usersOnStarExpeditionDocs}");

    starsForSearchBar.sort((s1, s2) => s1.starName!.compareTo(s2.starName!));

    for(int n = 0; n < usersOnStarExpeditionDocs.length; n++){
      Users u = new Users(username: usersOnStarExpeditionDocs[n]["username"], email: usersOnStarExpeditionDocs[n]["emailAddress"], password: usersOnStarExpeditionDocs[n]["password"]);
      theUsers!.add(u);
    }

    //List of stars in Star Expedition
    for(var s in starsForSearchBar){
      var star = s.starName!;
      allStars.add(star);
    }

    allStars.sort((s1, s2) => s1.toLowerCase().compareTo(s2.toLowerCase()));

    print("All stars: ${allStars}");

    //List of planets each star has
    for(var v in starsForSearchBar){
      var ref = FirebaseDatabase.instance.ref(v.starName!);
      var mySnapshot = await ref.child("Planets").get();
      var info = mySnapshot.value as Map;
      for(var i in info.keys){
        allPlanets.add(i);
      }

      //All stars and their planets
      starsAndTheirPlanets[v.starName!] = info.keys;
    }

    allPlanets.sort((p1, p2) => p1.toLowerCase().compareTo(p2.toLowerCase()));

    print("stars and their planets: ${starsAndTheirPlanets}");

    print("starsForSearchBar: ${starsForSearchBar}");
    print("The snapshot: ${allPlanets}");
  }

  print("The Supabase Function URL: ${dotenv.env["MY_SUPABASE_URL"]}");

  //Registering every error before runApp is run:
  setupMyErrorHandlers();

  //runZonedGuarded, which catches desktop and mobile asynchronous errors:
  runZonedGuarded((){
    runApp(const MyApp());
  }, (error, stack){
    print("Zone caught error");
    print("This is the error: ${error}");
    print("This is the stack: ${stack}");
    //Logging the error to the Supabase Edge function:
    loggingError(error.toString(), stack, determiningUsername(), myExtraInfo: { "origin": "zoned_guarded" },);
  }
  );
}

class myStars {
  String? starName;
  String? imagePath;
  String? articlePath;

  myStars({
    this.starName,
    this.imagePath,
    this.articlePath,
  });
}

List<myStars> starsForSearchBar = [
  myStars(starName: "Proxima Centauri", imagePath: "assets/images/proxima_centauri.jpg", articlePath: "assets/text_files/star_files/proxima_centauri.txt"),
  myStars(starName: "Tau Ceti", imagePath: "assets/images/tau_ceti.jpg", articlePath: "assets/text_files/star_files/tau_ceti.txt"),
  myStars(starName: "Ross 128", imagePath: "assets/images/ross_128.jpg", articlePath: "assets/text_files/star_files/ross_128.txt"),
  myStars(starName: "Luyten's Star", imagePath: "assets/images/luytens_star.jpg", articlePath: "assets/text_files/star_files/luytens_star.txt"),
  myStars(starName: "Kapteyn's Star", imagePath: "assets/images/kapteyns_star.jpg", articlePath: "assets/text_files/star_files/kapteyns_star.txt"),
  myStars(starName: "Wolf 1061", imagePath: "assets/images/wolf_1061.jpg", articlePath: "assets/text_files/star_files/wolf_1061.txt"),
  myStars(starName: "Gliese 876", imagePath: "assets/images/gliese_876.jpg", articlePath: "assets/text_files/star_files/gliese_876.txt"),
  myStars(starName: "Gliese 581", imagePath: "assets/images/gliese_581.jpg", articlePath: "assets/text_files/star_files/gliese_581.txt"),
  myStars(starName: "Lacaille 9352", imagePath: "assets/images/lacaille_9352.jpg", articlePath: "assets/text_files/star_files/lacaille_9352.txt"),
  myStars(starName: "Gliese 667 C", imagePath: "assets/images/gliese_667_c.jpg", articlePath: "assets/text_files/star_files/gliese_667_c.txt"),
  myStars(starName: "HD 85512", imagePath: "assets/images/hd_85512.jpg", articlePath: "assets/text_files/star_files/hd_85512.txt"),
  myStars(starName: "LHS 475", imagePath: "assets/images/lhs_475.JPG", articlePath: "assets/text_files/star_files/lhs_475.txt"),
  myStars(starName: "Wolf 359", imagePath: "assets/images/wolf_359.JPG", articlePath: "assets/text_files/star_files/wolf_359.txt"),
  myStars(starName: "Teegarden's Star", imagePath: "assets/images/teegardens_star.JPG", articlePath: "assets/text_files/star_files/teegardens_star.txt"),
  myStars(starName: "TRAPPIST-1", imagePath: "assets/images/trappist_1.JPG", articlePath: "assets/text_files/star_files/trappist_1.txt"),
  myStars(starName: "Gliese 12", imagePath: "assets/images/gliese_12.JPG", articlePath: "assets/text_files/star_files/gliese_12.txt"),
  myStars(starName: "HD 48948", imagePath: "assets/images/hd_48948.JPG", articlePath: "assets/text_files/star_files/hd_48948.txt"),
  myStars(starName: "LHS 1140", imagePath: "assets/images/lhs_1140.JPG", articlePath: "assets/text_files/star_files/lhs_1140.txt"),
  myStars(starName: "82 G Eridani", imagePath: "assets/images/82_g_eridani.png", articlePath: "assets/text_files/star_files/82_g_eridani.txt"),
  myStars(starName: "Ross 508", imagePath: "assets/images/ross_508.JPG", articlePath: "assets/text_files/star_files/ross_508.txt"),
  myStars(starName: "GJ 251", imagePath: "assets/images/gj_251.JPG", articlePath: "assets/text_files/star_files/gj_251.txt")
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This is the root widget
  // of your application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.red,//Colors.red,
        ),
        home: StarExpedition(),
        routes:{
          routesToOtherPages.spectralClass: (context) => spectralClassPage(),
          routesToOtherPages.whyMade: (context) => whyStarExpeditionWasMadePage(),
          routesToOtherPages.discussionBoard: (context) => discussionBoardPage(),
          routesToOtherPages.homePage: (context) => StarExpedition(),
          routesToOtherPages.theLoginPage: (context) => loginPage(),
          routesToOtherPages.theRegisterPage: (context) => registerPage(),
          routesToOtherPages.theStarArticlePage: (context) => articlePage(starInfo),
          routesToOtherPages.thePlanetArticlePage: (context) => planetArticle(informationAboutPlanet),
          routesToOtherPages.conversionCalculator: (context) => conversionCalculatorPage(),
          routesToOtherPages.settingsPage: (context) => settingsPage(),
          routesToOtherPages.userProfileInUserPerspectivePage: (context) => userProfileInUserPerspective(),
          routesToOtherPages.userSearchBarPage: (context) => userSearchBarPage(),
          routesToOtherPages.nonexistentUserPage: (context) => nonexistentUser(),
        }
    );
  }
}

class routesToOtherPages{
  static String spectralClass = spectralClassPageState.nameOfRoute;
  static String whyMade = whyStarExpeditionWasMadePageState.nameOfRoute;
  static String discussionBoard = discussionBoardPageState.nameOfRoute;
  static String homePage = theStarExpeditionState.nameOfRoute;
  static String theLoginPage = loginPageState.nameOfRoute;
  static String theRegisterPage = registerPageState.nameOfRoute;
  static String theStarArticlePage = articlePage.nameOfRoute;
  static String thePlanetArticlePage = planetArticle.nameOfRoute;
  static String conversionCalculator = conversionCalculatorPageState.nameOfRoute;
  static String settingsPage = settingsPageState.nameOfRoute;
  static String userProfileInUserPerspectivePage = userProfileInUserPerspective.nameOfRoute;
  static String userSearchBarPage = userSearchBarPageState.nameOfRoute;
  static String nonexistentUserPage = nonexistentUser.nameOfRoute;
}

// This is the widget that will be shown
// as the homepage of your application.
/*_getStars() async {
  // This method gets data for Alpha Centauri from the database. If you did it outside the main class, you will probably not be able to see it. async means that it will run once you press the button or run the function.
  DatabaseEvent event = await ref.once(); //the _getStars() method is for the first button. it is put somewhere where i can call it.
  print(event.snapshot.value);
  // This is where one will print the data of the snapshot (in this case, Alpha Centauri's data)
  //print(event.snapshot.value); // This will show Alpha Centauri's data
}*/

class StarExpedition extends StatefulWidget {
  const StarExpedition({Key? key}) : super(key: key);

  @override
  State<StarExpedition> createState() => theStarExpeditionState(starInfo);
}

Future<List<String>> getStarInformation() async{
  final starReference;

  final starConstellation;
  final starDistance;
  final starOtherNames;
  final starSpectralClass;
  final starAbsoluteMagnitude;
  final starAge;
  final starApparentMagnitude;
  final starDiscoverer;
  final starDiscoveryDate;
  final starTemperature;
  final starImageSource;

  if(firebaseDesktopHelper.onDesktop){
    starReference = await firebaseDesktopHelper.getFirebaseData(correctStar);

    starConstellation = starReference["constellation"];
    starDistance = starReference["distance"];
    starOtherNames = starReference["other_names"];
    starSpectralClass = starReference["spectral_class"];
    starAbsoluteMagnitude = starReference["star_absolute_magnitude"];
    starAge = starReference["star_age"];
    starApparentMagnitude = starReference["star_apparent_magnitude"];
    starDiscoverer = starReference["star_discoverer"];
    starDiscoveryDate = starReference["star_discovery_date"];
    starTemperature = starReference["star_temperature"];
    starImageSource = starReference["image_source"];

    return [starConstellation.toString(), starDistance.toString(), starOtherNames.toString(), starSpectralClass.toString(), starAbsoluteMagnitude.toString(), starAge.toString(), starApparentMagnitude.toString(), starDiscoverer.toString(), starDiscoveryDate.toString(), starTemperature.toString(), starImageSource.toString()];
  }
  else{
    starReference = FirebaseDatabase.instance.ref(correctStar);

    starConstellation = await starReference.child("constellation").get();
    starDistance = await starReference.child("distance").get();
    starOtherNames = await starReference.child("other_names").get();
    starSpectralClass = await starReference.child("spectral_class").get();
    starAbsoluteMagnitude = await starReference.child("star_absolute_magnitude").get();
    starAge = await starReference.child("star_age").get();
    starApparentMagnitude = await starReference.child("star_apparent_magnitude").get();
    starDiscoverer = await starReference.child("star_discoverer").get();
    starDiscoveryDate = await starReference.child("star_discovery_date").get();
    starTemperature = await starReference.child("star_temperature").get();
    starImageSource = await starReference.child("image_source").get();

    return [starConstellation.value.toString(), starDistance.value.toString(), starOtherNames.value.toString(), starSpectralClass.value.toString(), starAbsoluteMagnitude.value.toString(), starAge.value.toString(), starApparentMagnitude.value.toString(), starDiscoverer.value.toString(), starDiscoveryDate.value.toString(), starTemperature.value.toString(), starImageSource.value.toString()];
  }
}

Future<Map<String, List>> getOtherNames() async{
  /*Finding if other star name leads user to star
      name on the search suggestions*/
  Map<String, List> otherNames = HashMap();

  for(var star in starsForSearchBar){
    var myStarReference;
    var otherNamesForStar;
    var otherNamesSplit;

    if(firebaseDesktopHelper.onDesktop){
      myStarReference = await firebaseDesktopHelper.getFirebaseData(star.starName!);
      otherNamesForStar = myStarReference["other_names"];

      otherNamesSplit = otherNamesForStar.toString().split(",");
    }
    else{
      myStarReference = FirebaseDatabase.instance.ref(star.starName!);
      otherNamesForStar = await myStarReference.child("other_names").get();

      otherNamesSplit = otherNamesForStar.value.toString().split(",");
    }
    List<String> otherNamesList = [];
    for(int i = 0; i < otherNamesSplit.length; i++){
      otherNamesList.add(otherNamesSplit[i]);
    }
    otherNamesList.length = otherNamesSplit.length;
    otherNames.addAll({star.starName!: otherNamesList});
  }

  return otherNames;
}

class theStarExpeditionState extends State<StarExpedition> {
  static String nameOfRoute = '/StarExpedition';
  List<String> starInfo = [];
  theStarExpeditionState(this.starInfo);
  final CustomSearchDelegate csd = new CustomSearchDelegate();

  //.sort((a, b) => a.starName!.compareTo(b.starName!));
  //userItemsExistingUsers? myChosenItemExistingUsers;

  /*@override
  void initState(){
    super.initState();

    setupMyErrorHandlers();
  }*/

  @override
  Widget build(BuildContext context) {
    print("discussionBoardLogin: ${discussionBoardLogin}");
    final dateForUse = DateTime(2020, 1, 1);
    DateTime? timeNow = DateTime.now();
    int numberOfDays = daysSinceJanOneTwenty(dateForUse, timeNow);
    print(numberOfDays.toString());
    int numberOfStars = starsForSearchBar.length;
    int randomNumber = numberOfDays % numberOfStars;
    /*
    int numberOfDays = timeNow.day;
    numberOfDays = endOfMonthAdjustment(numberOfDays);
    print(numberOfDays.toString());
    int numberOfStars = starsForSearchBar.length;
    int randomNumber = numberOfDays % numberOfStars;*/
    //Maybe you can make an if statement that ensures that today's star name and image are not the same as yesterday's.
    print(timeNow);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Star Expedition",
        ),
        actions: [
          IconButton(
            onPressed: () async{
              // method to show the search bar
              //_getStars(); // I am putting it here is just for testing; it is just to see if we are getting any data from firebase (the data we want, such as data relating to Alpha Centauri).

              //Other star names
              //var starOtherNames = await getOtherNames();
              otherNamesMap = await getOtherNames();
              alternateNames = otherNamesMap.values;
              print(alternateNames);

              //Dialog for users to select whether they want to search for stars or planets
              showDialog(
                  context: context,
                  builder: (BuildContext bc){
                    return SimpleDialog(
                      title: Text("Select what you would like to search for"),
                      children: <Widget>[
                        SimpleDialogOption(
                            child: Text("Stars"),
                            onPressed: (){
                              //showSearch
                              showSearch(
                                  context: context,
                                  // delegate to customize the search bar
                                  delegate: CustomSearchDelegate()
                              );
                            }
                        ),
                        SimpleDialogOption(
                            child: Text("Planets"),
                            onPressed: (){
                              showSearch(
                                  context: context,
                                  delegate: CustomSearchDelegateForPlanets()
                              );
                            }
                        ),
                      ],
                    );
                  }
              );
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: Wrap(
        children: <Widget>[
          /*myUsername == "" && myNewUsername == ""? // If myUsername is empty, it will show the Login container. If myUsername is not empty, it will show an empty SizedBox.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    child: InkWell(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Ink(
                          child: Text('Login', style: TextStyle(color: Colors.black, fontSize: 18.0)), //fontFamily: 'Railway'
                        ),
                      ),
                      onTap: (){
                        print('Logging in');
                        Navigator.pushReplacementNamed(context, routesToOtherPages.theLoginPage);
                      }
                    ),
                  ),
                ],
            ): (myUsername == "" && myNewUsername != "")?
              Row( //If login is successful
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FittedBox( //For new users, not those that logged into already existing accounts
                    alignment: Alignment.topRight,
                    child: Text('Hi ${myNewUsername}', style: TextStyle(color: Colors.black, fontSize: 18.0)),
                    fit: BoxFit.contain,
                  ),
                  PopupMenuButton<userItemsNewUsers>(
                    icon: Icon(Icons.settings),
                    onSelected: (myItemNewUsers) async{
                      if(myItemNewUsers == userItemsNewUsers.myProfile){
                        await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get().then((result){
                          usersBlurb = result.docs.first.data()["usernameProfileInformation"]["userInformation"];
                          numberOfPostsUserHasMade = result.docs.first.data()["usernameProfileInformation"]["numberOfPosts"];
                        });
                        print("usersBlurb: ${usersBlurb}");
                        print("numberOfPostsUserHasMade: ${numberOfPostsUserHasMade}");
                        Navigator.pushReplacementNamed(context, routesToOtherPages.userProfileInUserPerspectivePage);
                      }
                      else if(myItemNewUsers == userItemsNewUsers.mySettings){
                        Navigator.pushReplacementNamed(context, routesToOtherPages.settingsPage);
                      }
                      else if(myItemNewUsers == userItemsNewUsers.logOut){
                        myUsername = "";
                        myNewUsername = "";
                        registerBool = false;
                        Navigator.pushReplacementNamed(context, loginPageRoutes.homePage);
                        print("Logging out");
                      }
                    },
                    itemBuilder: (BuildContext bc) => <PopupMenuEntry<userItemsNewUsers>>[
                      PopupMenuItem<userItemsNewUsers>(
                        value: userItemsNewUsers.myProfile,
                        child: Text("My profile"),
                      ),
                      PopupMenuItem<userItemsNewUsers>(
                        value: userItemsNewUsers.mySettings,
                        child: Text("Settings"),
                      ),
                      PopupMenuItem<userItemsNewUsers>(
                        value: userItemsNewUsers.logOut,
                        child: Text("Logout"),
                      ),
                    ],
                  ),
                ],
              ): (myUsername != "" && myNewUsername == "") && theLoginPage.loginBool == true?
                Row( //For returning users
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FittedBox(
                      child: Text('Hi ${myUsername}', style: TextStyle(color: Colors.black, fontSize: 18.0)),
                      fit: BoxFit.contain,
                    ),
                    PopupMenuButton<userItemsExistingUsers>(
                      icon: Icon(Icons.settings),
                      onSelected: (myItem) async{
                        if(myItem == userItemsExistingUsers.myProfile){
                          await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get().then((result){
                            usersBlurb = result.docs.first.data()["usernameProfileInformation"]["userInformation"];
                            numberOfPostsUserHasMade = result.docs.first.data()["usernameProfileInformation"]["numberOfPosts"];
                          });
                          print("usersBlurb: ${usersBlurb}");
                          print("numberOfPostsUserHasMade: ${numberOfPostsUserHasMade}");
                          Navigator.pushReplacementNamed(context, routesToOtherPages.userProfileInUserPerspectivePage);
                        }
                        else if(myItem == userItemsExistingUsers.mySettings){
                          print("Settings");
                          Navigator.pushReplacementNamed(context, routesToOtherPages.settingsPage);
                        }
                        else if(myItem == userItemsExistingUsers.logOut){
                          myUsername = "";
                          myNewUsername = "";
                          theLoginPage.loginBool = false;
                          print("Logging out from already existing account");
                          Navigator.pushReplacementNamed(context, loginPageRoutes.homePage);
                        }
                      },
                      itemBuilder: (BuildContext bc) => <PopupMenuEntry<userItemsExistingUsers>>[
                        PopupMenuItem<userItemsExistingUsers>(
                            value: userItemsExistingUsers.myProfile,
                            child: Text("My profile"),
                        ),
                        PopupMenuItem<userItemsExistingUsers>(
                            value: userItemsExistingUsers.mySettings,
                            child: Text("Settings"),
                        ),
                        PopupMenuItem<userItemsExistingUsers>(
                            value: userItemsExistingUsers.logOut,
                            child: Text("Logout"),
                        ),
                      ],
                    ),
                  ],
                ):*/
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            alignment: Alignment.topCenter,
            child: const Text('Welcome to Star Expedition!', style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold)), //fontFamily: 'Raleway'
            //height: 30,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015625),
            child: Text('Star Expedition is an app that allows its users to view and research stars and planets that are potentially capable of supporting life outside our Solar System. Star Expedition will include stars whose spectral classes range from M8 to A5, are within 100 light-years from Earth, and have confirmed terrestrial planets in their habitable zones and planets that are terrestrial and in the habitable zones of their respective stars. Currently, Star Expedition features ${allStars.length} stars and ${allPlanets.length} planets.\n', style: TextStyle(color: Colors.black, fontFamily: 'Raleway'), textAlign: TextAlign.center),
            //height: 200,
          ),
          /*Container(
            alignment: Alignment.center,
            child: InkWell(
              child: Ink(
                child: Text("Click here to see the list of stars", textAlign: TextAlign.center),
              ),
              onTap: (){
                print("Stars: ${allStars}");
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => starsList()));
              }
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: InkWell(
              child: Ink(
                child: Text("Click here to see the list of planets", textAlign: TextAlign.center),
              ),
              onTap: (){
                print("Planets");
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => planetsList()));
              }
            ),
          ),*/
          Container(
            child: Text("\n"),
          ),
          Container(
            alignment: Alignment.topCenter,
            child: const Text('Featured Star of the Day', style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold)), //fontFamily: 'Railway'
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Center(
              //child: Padding(
                //padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 2.0),
                child: InkWell(
                    child: Ink.image(
                      image: AssetImage(starsForSearchBar[randomNumber].imagePath!),//, height: 150, width: 150),
                      fit: BoxFit.cover,
                      height: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.height * 0.25 : 150,
                      width: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.height * 0.25 : 150,
                    ),
                    onTap: () async{
                      correctStar = starsForSearchBar[randomNumber].starName!;
                      starInfo = await getStarInformation();
                      featuredStarOfTheDayBool = true;
                      starFileContent = await readStarFile();
                      listOfStarUrls = starFileContent.replaceAll("\n", "").replaceAll("\r", "|").split("|");

                      listOfStarUrls.removeWhere((myUrl) => myUrl == "" || myUrl == " ");

                      print("listofstarurls: ${listOfStarUrls.toString()}");
                      print("size of listofstarurls: ${listOfStarUrls.length}");

                      //Is the star tracked by a user?
                      if(myNewUsername != "" && myUsername == ""){
                        if(firebaseDesktopHelper.onDesktop){
                          var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                          var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                          //Getting the current profile info of the user:
                          Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                          starTracked = currentInfoOfNewUser["starsTracked"].containsKey(correctStar);
                          print("starTracked: ${starTracked}");
                        }
                        else{
                          var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                          var docNameForNewUsers;
                          theNewUser.docs.forEach((result){
                            docNameForNewUsers = result.id;
                          });

                          DocumentSnapshot<Map<dynamic, dynamic>> snapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForNewUsers).get();
                          Map<dynamic, dynamic>? individual = snapshotNewUsers.data();

                          starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(correctStar);
                          print("starTracked: ${starTracked}");
                        }
                      }
                      else if(myNewUsername == "" && myUsername != ""){
                        if(firebaseDesktopHelper.onDesktop){
                          var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                          var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                          //Getting the current profile info of the user:
                          Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                          starTracked = currentInfoOfExistingUser["starsTracked"].containsKey(correctStar);
                          print("starTracked: ${starTracked}");
                        }
                        else{
                          var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                          var docNameForExistingUsers;
                          theExistingUser.docs.forEach((result){
                            docNameForExistingUsers = result.id;
                          });

                          DocumentSnapshot<Map<dynamic, dynamic>> snapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForExistingUsers).get();
                          Map<dynamic, dynamic>? individual = snapshotExistingUsers.data();

                          starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(correctStar);
                          print("starTracked: ${starTracked}");
                        }
                      }

                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => articlePage(starInfo), settings: RouteSettings(arguments: starsForSearchBar[randomNumber])));
                      // correctStar = starsForSearchBar[randomNumber].starName!;
                      //starInfo = await getStarInformation();
                      if(starInfo.length == 0){
                        print("Sorry; the length is 0");
                      }
                      else{
                        print(starInfo);
                      }
                    }
                ),
            ),
          //),

          Center(
            child: InkWell(
              //height: 20,
              //alignment: Alignment.topCenter,
                child: Ink(
                  child: Text(starsForSearchBar[randomNumber].starName!),
                ),
                onTap: () async{
                  correctStar = starsForSearchBar[randomNumber].starName!;
                  starInfo = await getStarInformation();
                  featuredStarOfTheDayBool = true;
                  starFileContent = await readStarFile();
                  listOfStarUrls = starFileContent.replaceAll("\n", "").replaceAll("\r", "|").split("|");

                  listOfStarUrls.removeWhere((myUrl) => myUrl == "" || myUrl == " ");

                  //Is the star tracked by a user?
                  if(myNewUsername != "" && myUsername == ""){
                    if(firebaseDesktopHelper.onDesktop){
                      var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                      var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                      //Getting the current profile info of the user:
                      Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                      starTracked = currentInfoOfNewUser["starsTracked"].containsKey(correctStar);
                      print("starTracked: ${starTracked}");
                    }
                    else{
                      var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                      var docNameForNewUsers;
                      theNewUser.docs.forEach((result){
                        docNameForNewUsers = result.id;
                      });

                      DocumentSnapshot<Map<dynamic, dynamic>> snapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForNewUsers).get();
                      Map<dynamic, dynamic>? individual = snapshotNewUsers.data();

                      starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(correctStar);
                      print("starTracked: ${starTracked}");
                    }
                  }
                  else if(myNewUsername == "" && myUsername != ""){
                    if(firebaseDesktopHelper.onDesktop){
                      var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                      var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                      //Getting the current profile info of the user:
                      Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                      starTracked = currentInfoOfExistingUser["starsTracked"].containsKey(correctStar);
                      print("starTracked: ${starTracked}");
                    }
                    else{
                      var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                      var docNameForExistingUsers;
                      theExistingUser.docs.forEach((result){
                        docNameForExistingUsers = result.id;
                      });

                      DocumentSnapshot<Map<dynamic, dynamic>> snapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForExistingUsers).get();
                      Map<dynamic, dynamic>? individual = snapshotExistingUsers.data();

                      starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(correctStar);
                      print("starTracked: ${starTracked}");
                    }
                  }

                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => articlePage(starInfo), settings: RouteSettings(arguments: starsForSearchBar[randomNumber])));
                  // correctStar = starsForSearchBar[randomNumber].starName!;
                  //starInfo = await getStarInformation();
                  if(starInfo.length == 0){
                    print("Sorry; the length is 0");
                  }
                  else{
                    print(starInfo);
                  }
                }
            ),
          ),
        ],
      ),
      drawer: starExpeditionNavigationDrawer(),
    );
  }

  int daysSinceJanOneTwenty(DateTime a, DateTime b){
    a = DateTime(a.year, a.month, a.day);
    b = DateTime(b.year, b.month, b.day);
    return (b.difference(a).inHours / 24).round();
  }
}

class starExpeditionNavigationDrawer extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Drawer(
        child: ListView(
            padding: EdgeInsets.zero,
            children: [
              if(myNewUsername == "" && myUsername == "")
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.red,
                  ),
                  child: Text("Star Expedition Navigation Drawer", style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: "Railway")),
                ),
              if(myNewUsername != "" && myUsername == "")
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.red,
                  ),
                  child: Text("Star Expedition Navigation Drawer\n\nHi ${myNewUsername}", style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: "Railway")),
                ),
              if(myNewUsername == "" && myUsername != "")
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.red,
                  ),
                  child: Text("Star Expedition Navigation Drawer\n\nHi ${myUsername}", style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: "Railway")),
                ),
              ListTile(
                  title: myNewUsername == "" && myUsername == ""? Text("Login") : Text("Logout"),
                  onTap: (){
                    if(myNewUsername == "" && myUsername == "") {
                      discussionBoardLogin = false;
                      Navigator.pushReplacementNamed(context, routesToOtherPages.theLoginPage);
                    }
                    else if((myNewUsername != "" && myUsername == "") || (myNewUsername == "" && myUsername != "")){
                      myUsername = "";
                      myNewUsername = "";
                      theLoginPage.loginBool = false;
                      discussionBoardLogin = false;
                      registerBool = false;
                      print("Logging out from already existing account");
                      Navigator.pushReplacementNamed(context, loginPageRoutes.homePage);
                    }
                  }
              ),
              if((myNewUsername != "" && myUsername == "") || (myNewUsername == "" && myUsername != ""))
                ListTile(
                    title: Text("My Profile"),
                    onTap: () async{
                      if(myUsername != "" && myNewUsername == ""){
                        if(firebaseDesktopHelper.onDesktop){
                          List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");

                          var myCorrectUser = everyUser.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});
                          var getExistingUserProfileInformationAttribute = myCorrectUser["usernameProfileInformation"];

                          usersBlurb = getExistingUserProfileInformationAttribute["userInformation"];
                          usersInterests = getExistingUserProfileInformationAttribute["userInterests"];
                          usersLocation = getExistingUserProfileInformationAttribute["userLocation"];
                          numberOfPostsUserHasMade = getExistingUserProfileInformationAttribute["numberOfPosts"];
                          starsUserTracked = getExistingUserProfileInformationAttribute["starsTracked"];
                          planetsUserTracked = getExistingUserProfileInformationAttribute["planetsTracked"];

                          print("Desktop usersBlurb: ${usersBlurb}");
                          print("Desktop usersInterests: ${usersInterests}");
                          print("Desktop usersLocation: ${usersLocation}");
                          print("Desktop numberOfPostsUserHasMade: ${numberOfPostsUserHasMade}");
                          print("Desktop starsUserTracked: ${starsUserTracked}");
                          print("Desktop planetsUserTracked: ${planetsUserTracked}");
                        }
                        else{
                          await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get().then((result){
                            usersBlurb = result.docs.first.data()["usernameProfileInformation"]["userInformation"];
                            usersInterests = result.docs.first.data()["usernameProfileInformation"]["userInterests"];
                            usersLocation = result.docs.first.data()["usernameProfileInformation"]["userLocation"];
                            numberOfPostsUserHasMade = result.docs.first.data()["usernameProfileInformation"]["numberOfPosts"];
                            starsUserTracked = result.docs.first.data()["usernameProfileInformation"]["starsTracked"];
                            planetsUserTracked = result.docs.first.data()["usernameProfileInformation"]["planetsTracked"];
                          });
                        }
                        print("usersBlurb: ${usersBlurb}");
                        print("usersInterests: ${usersInterests}");
                        print("usersLocation: ${usersLocation}");
                        print("numberOfPostsUserHasMade: ${numberOfPostsUserHasMade}");
                        print("starsUserTracked: ${starsUserTracked}");
                        print("planetsUserTracked: ${planetsUserTracked}");
                        Navigator.pushReplacementNamed(context, routesToOtherPages.userProfileInUserPerspectivePage);
                      }
                      else if(myUsername == "" && myNewUsername != ""){
                        if(firebaseDesktopHelper.onDesktop){
                          List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");

                          var myCorrectNewUser = everyUser.firstWhere((myNewUser) => myNewUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});
                          var getNewUserProfileInformationAttribute = myCorrectNewUser["usernameProfileInformation"];

                          usersBlurb = getNewUserProfileInformationAttribute["userInformation"];
                          usersInterests = getNewUserProfileInformationAttribute["userInterests"];
                          usersLocation = getNewUserProfileInformationAttribute["userLocation"];
                          numberOfPostsUserHasMade = getNewUserProfileInformationAttribute["numberOfPosts"];
                          starsUserTracked = getNewUserProfileInformationAttribute["starsTracked"];
                          planetsUserTracked = getNewUserProfileInformationAttribute["planetsTracked"];

                          print("Desktop usersBlurb: ${usersBlurb}");
                          print("Desktop usersInterests: ${usersInterests}");
                          print("Desktop usersLocation: ${usersLocation}");
                          print("Desktop numberOfPostsUserHasMade: ${numberOfPostsUserHasMade}");
                          print("Desktop starsUserTracked: ${starsUserTracked}");
                          print("Desktop planetsUserTracked: ${planetsUserTracked}");
                        }
                        else{
                          await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get().then((result){
                            usersBlurb = result.docs.first.data()["usernameProfileInformation"]["userInformation"];
                            usersInterests = result.docs.first.data()["usernameProfileInformation"]["userInterests"];
                            usersLocation = result.docs.first.data()["usernameProfileInformation"]["userLocation"];
                            numberOfPostsUserHasMade = result.docs.first.data()["usernameProfileInformation"]["numberOfPosts"];
                            starsUserTracked = result.docs.first.data()["usernameProfileInformation"]["starsTracked"];
                            planetsUserTracked = result.docs.first.data()["usernameProfileInformation"]["planetsTracked"];
                          });
                        }
                        print("usersBlurb: ${usersBlurb}");
                        print("usersInterests: ${usersInterests}");
                        print("usersLocation: ${usersLocation}");
                        print("numberOfPostsUserHasMade: ${numberOfPostsUserHasMade}");
                        print("starsUserTracked: ${starsUserTracked}");
                        print("planetsUserTracked: ${planetsUserTracked}");
                        Navigator.pushReplacementNamed(context, routesToOtherPages.userProfileInUserPerspectivePage);
                      }
                    }
                ),
              if((myNewUsername != "" && myUsername == "") || (myNewUsername == "" && myUsername != ""))
                ListTile(
                    title: Text("Settings"),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, routesToOtherPages.settingsPage);
                    }
                ),
              ListTile(
                  title: Text("Home"),
                  onTap: (){
                    discussionBoardLogin = false;
                    Navigator.pushReplacementNamed(context, routesToOtherPages.homePage);
                  }
              ),
              ListTile(
                  title: Text("Why Star Expedition Was Made"),
                  onTap: () {
                    discussionBoardLogin = false;
                    Navigator.pushReplacementNamed(context, routesToOtherPages.whyMade);
                    //throw Exception("Testing the error");
                  }
              ),
              ListTile(
                  title: Text("Information about the Spectral Classes of Stars"),
                  onTap: () {
                    discussionBoardLogin = false;
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => spectralClassPage()));
                    Navigator.pushReplacementNamed(context, routesToOtherPages.spectralClass);
                  }
              ),
              ListTile(
                  title: Text("Discussion Board"),
                  onTap: () {
                    discussionBoardLogin = true;
                    if(theLoginPage.loginBool == true || registerBool == true){
                      Navigator.pushReplacementNamed(context, routesToOtherPages.discussionBoard);
                    }
                    else{
                      Navigator.pushReplacementNamed(context, routesToOtherPages.theLoginPage);
                    }
                  }
              ),
              ListTile(
                  title: Text("Conversion Calculator"),
                  onTap: (){
                    discussionBoardLogin = false;
                    Navigator.pushReplacementNamed(context, routesToOtherPages.conversionCalculator);
                  }
              ),
              ListTile(
                  title: Text("User Search"),
                  onTap: () async{
                    //List<dynamic> myUserList = [];
                    discussionBoardLogin = false;
                    if(firebaseDesktopHelper.onDesktop){
                      var myUsersDocs = await firebaseDesktopHelper.getFirestoreCollection("User");
                      for(int u = 0; u < myUsersDocs.length; u++){
                        if(!(theListOfUsers.contains(myUsersDocs[u]["username"]))){
                          theListOfUsers.add(myUsersDocs[u]["username"]);
                        }
                      }
                      print("this is my users: $myUsersDocs");
                    }
                    else{
                      await FirebaseFirestore.instance.collection("User").get().then((qSnapshot){
                        for(var documentSnapshot in qSnapshot.docs){
                          print("documentSnapshot: ${documentSnapshot.data()}");
                          if(!(theListOfUsers.contains(documentSnapshot.data()["username"]))) {
                            theListOfUsers.add(documentSnapshot.data()["username"]);
                          }
                          else{
                            //continue
                          }
                        }
                      });
                    }
                    print("theListOfUsers: ${theListOfUsers}");
                    Navigator.pushReplacementNamed(context, routesToOtherPages.userSearchBarPage);
                  }
              )
            ]
        )
    );
  }
}

/*int _randomImageGenerator(){
  Random randomStar = Random();
  return randomStar.nextInt(starsForSearchBar.length);
}*/
/*Widget _starOfTheDayWidget() => Expanded(

);*/

class CustomSearchDelegate extends SearchDelegate {

  List<String> starInfo = [];

  // This is the first overwrite (to clear the search text)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  // This is the second overwrite (to pop out of search menu)
  //The "back" button
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const StarExpedition()));
        //close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  // This is the third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<myStars> myMatchQuery = [];

    for(var star in starsForSearchBar) {
      if (star.starName!.toLowerCase().contains(query)) {
        myMatchQuery.add(star!);
      }
    }

    otherNamesMap.forEach((key, value){
      for(var v in value){
        if(v != "N/A"){
          if(myMatchQuery.indexWhere((sa) => sa.starName == key) == -1){ //if the star is not in myMatchQuery
            if(v!.toLowerCase().contains(query)){ //if the value contains query
              int indexPlaceKey = starsForSearchBar.indexWhere((sa) => sa.starName == key);
              myMatchQuery.add(myStars(starName: key, imagePath: starsForSearchBar[indexPlaceKey].imagePath));
            }
            else{
              //continue
            }
          }
          else{
            //continue
          }
        }
        else{
          //continue
        }
      }
    });
    /*
      int indexPlace = starsForSearchBar.indexWhere((sa) => sa.starName == key);
      if(myMatchQuery.contains(myStars(starName: key, imagePath: starsForSearchBar[indexPlace].imagePath))){
        print("Continue");
      }
      else{
        for(var v in value){
          if(v.toLowerCase().contains(query) && !myMatchQuery.contains(myStars(starName: key, imagePath: starsForSearchBar[indexPlace].imagePath))){
            myMatchQuery.add(myStars(starName: key, imagePath: starsForSearchBar[indexPlace].imagePath));
          }
          else{
            print("Continuing");
          }
        }
      }*/
    //myStars starInMatchQuery = myStars(starName: "", imagePath: "");
    /*for (var star in starsForSearchBar) {
      if (star.starName!.toLowerCase().contains(query.toLowerCase())) {
        myMatchQuery.add(star!);
        //starInMatchQuery = myStars(starName: star!.starName, imagePath: star!.imagePath);
      }
      else{
        otherNamesMap.forEach((key, value){
          if(!value.contains("N/A")){
            for(var other in value){
              if((other.toLowerCase().contains(query.toLowerCase())) && !myMatchQuery.contains(myStars(starName: key, imagePath: star.imagePath))){
                myMatchQuery.add(star!);
              }
            }
          }
          else{
            print("Continue");
          }
        });
      }
    }*/

    /*
    otherNamesMap.forEach((key, value){
      if(!value.contains("N/A")){
        for(var s in value){
          print("The key: ${key}. The value: ${value}. The other name: ${s}");
          if(s.toLowerCase().contains(query.toLowerCase())){
            String myImagePath = "";
            for(var i in starsForSearchBar){
              if(i.starName == key){
                myImagePath = i.imagePath!;
              }
              else{
                //continue
              }
            }
            if(myMatchQuery.contains(myStars(starName: key, imagePath: myImagePath))){
              print("Continue");
            }
            else{
              myStars st = myStars(starName: "", imagePath: "");
              st.starName = key;
              int myIndexPlace = starsForSearchBar.indexWhere((sa) => sa.starName == st.starName);
              st.imagePath = starsForSearchBar[myIndexPlace].imagePath;
              myMatchQuery.add(st!);
            }
          }
        }
      }
      else{
        //continue
        print("Value is N/A.");
      }
    });*/

    /*for(List starOther in alternateNames){
      for(var s in starOther){
        if(s.toLowerCase().contains(query.toLowerCase())){
          //otherNamesMatchQuery.add(theStar!);
        }
      }
    }*/
    /*
    for(var myStar in myMatchQuery){
      for(List starOther in alternateNames){
        //otherNamesMatchQuery.addEntries({myStar: starOther}.entries);
        for(String otherStarName in starOther){
          otherNamesMatchQuery.addEntries({myStar.starName: otherStarName}.entries);
          if(otherStarName.toLowerCase().contains(query.toLowerCase()) && !myMatchQuery.contains(myStar!)){
            myMatchQuery.add(myStar!);
          }
        }
      }
    }*/
    /*
    for(List starOther in alternateNames) {
      for(var starsName in starOther){
        myStars theStar = myStars(starName: "", imagePath: "assets/images");
        theStar.starName = otherNamesMap.keys.firstWhere((k) => otherNamesMap[k] == starOther);
        int myIndexPlace = starsForSearchBar.indexWhere((s) => s.starName == theStar.starName);
        theStar.imagePath = starsForSearchBar[myIndexPlace].imagePath;
        if(starsName.toLowerCase().contains(query.toLowerCase())){
          otherNamesMatchQuery.add(theStar!);
        }
      }
    }*/

    return ListView.builder(
      itemCount: myMatchQuery.length,
      itemBuilder: (context, index) {
        var result = myMatchQuery[index]; //If user enters in a key, the result is the key.
        /*for(var s in otherNamesMatchQuery.values){
          if((otherNamesMatchQuery.entries.firstWhere((element) => element.value == s)) == myMatchQuery[index]){
            result = myMatchQuery[index]; //If user enters in a value, it will find the value's key and the result will be the key.
          }
        }*/
        //otherNamesMatchQuery.keys.elementAt(index);
        return ListTile(
          title: Text(result.starName!), // The ! is there so that it can prevent errors, especially for variables that are set to null
        );
      },
    );
  }

  // This is the last overwrite (to show the querying process at the runtime)
  @override
  Widget buildSuggestions(BuildContext context) {
    List<myStars> myMatchQuery = [];

    for(var star in starsForSearchBar) {
      if (star.starName!.toLowerCase().contains(query)) {
        myMatchQuery.add(star!);
      }
    }

    //IMPORTANT:
    otherNamesMap.forEach((key, value){
      for(var v in value){
        if(v != "N/A"){
          if(myMatchQuery.indexWhere((sa) => sa.starName == key) == -1){ //if the star is not in myMatchQuery
            if(v!.toLowerCase().contains(query)){ //if the value contains query
              int indexPlaceKey = starsForSearchBar.indexWhere((sa) => sa.starName == key);
              myMatchQuery.add(myStars(starName: key, imagePath: starsForSearchBar[indexPlaceKey].imagePath));
            }
            else{
              //continue
            }
          }
          else{
            //continue
          }
        }
        else{
          //continue
        }
      }
    });
    //

    /*
    for(var star in starsForSearchBar) {
      if (star.starName!.toLowerCase().contains(query)) {
        myMatchQuery.add(star!);
        print("This is in myMatchQuery: ${myMatchQuery}");
      }
    }
    otherNamesMap.forEach((key, value){
      print("Key: $key. Value: $value.");
      int indexPlace = starsForSearchBar.indexWhere((sa) => sa.starName == key);
      if(myMatchQuery.contains(myStars(starName: key, imagePath: starsForSearchBar[indexPlace].imagePath))){
        print("Continue");
      }
      else{
        for(var v in value){
          if(v.toLowerCase().contains(query) && !myMatchQuery.contains(myStars(starName: key, imagePath: starsForSearchBar[indexPlace].imagePath))){
            myMatchQuery.add(myStars(starName: key, imagePath: starsForSearchBar[indexPlace].imagePath));
            print("This is in myMatchQuery: ${myMatchQuery}");
          }
          else{
            print("Key: $key. Value: $v. Continuing");
          }
        }
      }
    });*/

    //THIS STARTS SOMETHING IMPORTANT
    /*for (var star in starsForSearchBar) {
      if (star.starName!.toLowerCase().contains(query.toLowerCase())) {
        myMatchQuery.add(star!);
        print("myMatchQuery size: ${myMatchQuery.length}");
        //starInMatchQuery = myStars(starName: star!.starName, imagePath: star!.imagePath);
      }
    }*/
    //IMPORTANT CONTENT ENDS

    /*for(var myStar in myMatchQuery){
      for(List starOther in alternateNames){
        //otherNamesMatchQuery.addEntries({myStar: starOther}.entries);
        for(String otherStarName in starOther){
          otherNamesMatchQuery.addEntries({myStar.starName: otherStarName}.entries);
          print(otherNamesMatchQuery);
          if(otherStarName.toLowerCase().contains(query.toLowerCase()) && !myMatchQuery.contains(myStar!)){
            myMatchQuery.add(myStar!);
          }
        }
      }
    }*/
    /*otherNamesMap.forEach((key, value){
      if(!value.contains("N/A")){
        for(var s in value){
          print("The key: ${key}. The value: ${value}. The other name: ${s}");
          if(s.toLowerCase().contains(query.toLowerCase())){
            String myImagePath = "";
            for(var i in starsForSearchBar){
              if(i.starName == key){
                myImagePath = i.imagePath!;
              }
              else{
                //continue
              }
            }
            if(myMatchQuery.contains(myStars(starName: key, imagePath: myImagePath))){
              print("Continue");
            }
            else{
              myStars st = myStars(starName: "", imagePath: "");
              st.starName = key;
              int myIndexPlace = starsForSearchBar.indexWhere((sa) => sa.starName == st.starName);
              st.imagePath = starsForSearchBar[myIndexPlace].imagePath;
              myMatchQuery.add(st!);
            }
          }
        }
      }
      else{
        //continue
        print("Value is N/A.");
      }
    });*/

    /*
    for(List starOther in alternateNames) {
      for(var starsName in starOther){
        myStars theStar = myStars(starName: "", imagePath: "assets/images");
        theStar.starName = otherNamesMap.keys.firstWhere((k) => otherNamesMap[k] == starOther);
        int myIndexPlace = starsForSearchBar.indexWhere((s) => s.starName == theStar.starName);
        theStar.imagePath = starsForSearchBar[myIndexPlace].imagePath;
        if(starsName.toLowerCase().contains(query.toLowerCase())){
          otherNamesMatchQuery.add(theStar!);
          print("otherNamesMatchQuery size: ${otherNamesMatchQuery.length}");
        }
      }
    }*/
    /*for(List starOther in alternateNames) {
      for(var starsName in starOther){
        myStars theStar = myStars(starName: "", imagePath: "assets/images");
        theStar.starName = otherNamesMap.keys.firstWhere((k) => otherNamesMap[k] == starOther);
        int myIndexPlace = starsForSearchBar.indexWhere((s) => s.starName == theStar.starName);
        theStar.imagePath = starsForSearchBar[myIndexPlace].imagePath;
          if(starsName.toLowerCase().contains(query.toLowerCase())){
            myMatchQuery.add(theStar!);
            print("myMatchQuery size: ${myMatchQuery.length}");
          }
      }
    }*/

    myMatchQuery.sort((s1, s2) => s1.starName!.compareTo(s2.starName!));

    return ListView.builder(
      itemCount: myMatchQuery.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(myMatchQuery[index].starName!,//Text(otherNamesMatchQuery.keys.elementAt(index).starName!,
                style: TextStyle(
                    color: Colors.deepPurpleAccent, fontFamily: 'Raleway')),
            onTap: () async{
              correctStar = myMatchQuery[index].starName!; //otherNamesMatchQuery.keys.elementAt(index).starName!;
              print(correctStar);
              starInfo = await getStarInformation();
              starFileContent = await readStarFile();
              listOfStarUrls = starFileContent.replaceAll("\n", "").replaceAll("\r", "|").split("|");

              listOfStarUrls.removeWhere((myUrl) => myUrl == "" || myUrl == " ");

              if(myNewUsername != "" && myUsername == ""){
                if(firebaseDesktopHelper.onDesktop){
                  var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                  var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                  //Getting the current profile info of the user:
                  Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                  starTracked = currentInfoOfNewUser["starsTracked"].containsKey(myMatchQuery[index].starName!);
                  print("starTracked: ${starTracked}");
                }
                else{
                  var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                  var docNameForNewUsers;
                  theNewUser.docs.forEach((result){
                    docNameForNewUsers = result.id;
                  });

                  DocumentSnapshot<Map<dynamic, dynamic>> snapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForNewUsers).get();
                  Map<dynamic, dynamic>? individual = snapshotNewUsers.data();

                  starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(myMatchQuery[index].starName!);
                  print("starTracked: ${starTracked}");
                }
              }
              else if(myNewUsername == "" && myUsername != ""){
                if(firebaseDesktopHelper.onDesktop){
                  var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                  var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                  //Getting the current profile info of the user:
                  Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                  starTracked = currentInfoOfExistingUser["starsTracked"].containsKey(myMatchQuery[index].starName!);
                  print("starTracked: ${starTracked}");
                }
                else{
                  var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                  var docNameForExistingUsers;
                  theExistingUser.docs.forEach((result){
                    docNameForExistingUsers = result.id;
                  });

                  DocumentSnapshot<Map<dynamic, dynamic>> snapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForExistingUsers).get();
                  Map<dynamic, dynamic>? individual = snapshotExistingUsers.data();

                  starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(myMatchQuery[index].starName!);
                  print("starTracked: ${starTracked}");
                }
              }

              Navigator.of(context).push(MaterialPageRoute(builder: (context) => articlePage(starInfo), settings: RouteSettings(arguments: myMatchQuery[index])));
            },
            leading: Image.asset(myMatchQuery[index].imagePath!, fit: BoxFit.cover, height: 50, width: 50)); //height: 50, width: 50, scale: 1.5));
        //trailing: Icon(Icons.whatshot_rounded));
      },
    );
  }
}

class CustomSearchDelegateForPlanets extends SearchDelegate{
  List<String> planetInfo = [];

  // This is the first overwrite (to clear the search text)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  // This is the second overwrite (to pop out of search menu)
  //The "back" button
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const StarExpedition()));
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  // This is the third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<myStars> myMatchQueryPlanets = [];

    for(var planet in allPlanets){
      if(planet.toLowerCase().contains(query)){
        myMatchQueryPlanets.add(myStars(starName: planet, imagePath: "assets/images/not_available.png"));
      }
    }

    return ListView.builder(
      itemCount: myMatchQueryPlanets.length,
      itemBuilder: (context, index) {
        var result = myMatchQueryPlanets[index]; //If user enters in a key, the result is the key.

        return ListTile(
          title: Text(result.starName!),
        );
      },
    );
  }

  // This is the last overwrite (to show the querying process at the runtime)
  @override
  Widget buildSuggestions(BuildContext context) {
    List<myStars> myMatchQueryPlanets = [];

    for(var planet in allPlanets){
      if(planet.toLowerCase().contains(query)){
        myMatchQueryPlanets.add(myStars(starName: planet, imagePath: "assets/images/not_available.png"));
      }
    }

    myMatchQueryPlanets.sort((s1, s2) => s1.starName!.compareTo(s2.starName!));

    return ListView.builder(
      itemCount: myMatchQueryPlanets.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(myMatchQueryPlanets[index].starName!, style: TextStyle(color: Colors.deepPurpleAccent, fontFamily: 'Raleway')),
            onTap: () async{
              fromSearchBarToPlanetArticle = true;
              correctPlanet = myMatchQueryPlanets[index].starName!;

              starsAndTheirPlanets.forEach((key, value){
                print("key: ${key}, value: ${value}");
                for(var v in value){
                  if(v == correctPlanet){
                    correctStar = key;
                    break;
                  }
                  else{
                    //continue
                  }
                }
              });

              var theStarInfo = await getStarInformation();
              informationAboutPlanet = await articlePage(theStarInfo).getPlanetData();

              planetFileContent = await readPlanetFile(informationAboutPlanet[6].toString());
              listOfPlanetUrls = planetFileContent.replaceAll("\n", "").replaceAll("\r", "|").split("|");

              listOfPlanetUrls.removeWhere((myUrl) => myUrl == "" || myUrl == " ");

              //Is the planet tracked by a user?
              if(myNewUsername != "" && myUsername == ""){
                if(firebaseDesktopHelper.onDesktop){
                  var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                  var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                  //Getting the current profile info of the user:
                  Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                  planetTracked = currentInfoOfNewUser["planetsTracked"].containsKey(correctPlanet);
                  print("planetTracked: ${planetTracked}");
                }
                else{
                  var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                  var theDocNameForNewUsers;
                  theNewUser.docs.forEach((result){
                    theDocNameForNewUsers = result.id;
                  });

                  DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForNewUsers).get();
                  Map<dynamic, dynamic>? individual = theSnapshotNewUsers.data();

                  planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                  print("planetTracked: ${planetTracked}");
                }
              }
              else if(myNewUsername == "" && myUsername != ""){
                if(firebaseDesktopHelper.onDesktop){
                  var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                  var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                  //Getting the current profile info of the user:
                  Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                  planetTracked = currentInfoOfExistingUser["planetsTracked"].containsKey(correctPlanet);
                  print("planetTracked: ${planetTracked}");
                }
                else{
                  var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                  var theDocNameForExistingUsers;
                  theExistingUser.docs.forEach((result){
                    theDocNameForExistingUsers = result.id;
                  });

                  DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForExistingUsers).get();
                  Map<dynamic, dynamic>? individual = theSnapshotExistingUsers.data();

                  planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                  print("planetTracked: ${planetTracked}");
                }
              }

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => planetArticle(informationAboutPlanet)));
            },
            leading: Image.asset(myMatchQueryPlanets[index].imagePath!, fit: BoxFit.cover, height: 50, width: 50)); //height: 50, width: 50, scale: 1.5));
      },
    );
  }
}

class articlePage extends StatelessWidget{
  static String nameOfRoute = '/articlePage';

  List<String> informationAboutPlanet = [];
  var myPlanet = <String>[];

  final List<String> starInfo;
  articlePage(this.starInfo);

  List<Text> starPdfMessageForUser = [];

  void getKeys(Map myMap){ // This is for getting planet names, which are keys
    //Making the star's planets in alphabetical order
    var planetsList = myMap.keys.toList()..sort();
    for(var planet in planetsList){
      myPlanet.add(planet);
      print("The key (or planet's name) is: " + planet);
    }
    /*myMap.keys.forEach((key) {
      //print(key);
      myPlanet.add(key);
      print("The key is " + key);
    });*/
  }

  Future<List<String>> getStarData() async{
    final ref;

    if(firebaseDesktopHelper.onDesktop){
      ref = await firebaseDesktopHelper.getFirebaseData(correctStar);

      final snapshot = ref["Planets"];
      if (snapshot != null) {
        getKeys(snapshot as Map); // Calling getKeys so that I can get the planets' names
        print(snapshot);
      } else {
        print('No data available.');
      }
    }
    else{
      ref = FirebaseDatabase.instance.ref(correctStar);

      final snapshot = await ref.child('Planets').get();
      if (snapshot.exists) {
        getKeys(snapshot.value as Map); // Calling getKeys so that I can get the planets' names
        print(snapshot.value);
      } else {
        print('No data available.');
      }
    }
    print('This is the correct star: ' + correctStar);
    /*DatabaseEvent de = await ref.once();
    return Future.delayed(Duration(seconds: 1), () {
      return de.snapshot.value as String; // Data should be returned from the snapshot.
    });*/
    return Future.delayed(Duration(seconds: 1), () {
      return myPlanet; // Data should be returned from the snapshot.
    });
    // return myPlanet;
  }

  Future<List<String>> getPlanetData() async{
    /*final planetRef = FirebaseDatabase.instance.ref("${correctStar}/Planets");
    print('This is the correct planet: ' + correctPlanet);
    print(planetRef.key);
    print(planetRef.parent!.key);
    final planetSnapshot = await planetRef.child(correctPlanet).get();

    return planetSnapshot.value.toString();*/

    //PLANET INFORMATION:
    final getPlanetAttribute;
    final discoveryDate;
    final distanceFromStar;
    final earthMasses;
    final knownGases;
    final orbitalPeriod;
    final planetTemperature;
    final planetTextFilePath;

    if(firebaseDesktopHelper.onDesktop){
      getPlanetAttribute = await firebaseDesktopHelper.getFirebaseData("${correctStar}/Planets/${correctPlanet}");
      discoveryDate = getPlanetAttribute["discovery_date"];
      distanceFromStar = getPlanetAttribute["distance_from_star"];
      earthMasses = getPlanetAttribute["earth_masses"];
      knownGases = getPlanetAttribute["known_gases"];
      orbitalPeriod = getPlanetAttribute["orbital_period"];
      planetTemperature = getPlanetAttribute["planet_temperature"];
      planetTextFilePath = getPlanetAttribute["planet_text_file_path"];

      return Future.delayed(Duration(seconds: 1), () {
        return [discoveryDate.toString(), distanceFromStar.toString(), earthMasses.toString(), knownGases.toString(), orbitalPeriod.toString(), planetTemperature.toString(), planetTextFilePath.toString()];
      });
    }
    else{
      getPlanetAttribute = FirebaseDatabase.instance.ref("${correctStar}/Planets/${correctPlanet}");
      discoveryDate = await getPlanetAttribute.child("discovery_date").get();
      distanceFromStar = await getPlanetAttribute.child("distance_from_star").get();
      earthMasses = await getPlanetAttribute.child("earth_masses").get();
      knownGases = await getPlanetAttribute.child("known_gases").get();
      orbitalPeriod = await getPlanetAttribute.child("orbital_period").get();
      planetTemperature = await getPlanetAttribute.child("planet_temperature").get();
      planetTextFilePath = await getPlanetAttribute.child("planet_text_file_path").get();

      return Future.delayed(Duration(seconds: 1), () {
        return [discoveryDate.value.toString(), distanceFromStar.value.toString(), earthMasses.value.toString(), knownGases.value.toString(), orbitalPeriod.value.toString(), planetTemperature.value.toString(), planetTextFilePath.value.toString()];
      });
    }
  }

  List<Text> starPdfDialogMessage(http.Response response){
    List<Text> messageForUser = [];

    if(response.statusCode != 200){
      //Did not load in the correct Star Expedition format
      messageForUser.add(Text("Did not load in the correct Star Expedition format"));
    }
    /*else if(response.statusCode != 200 && response.headers?["content-type"]?.contains("application/pdf") == true){
      //Did not load in the correct Star Expedition format
    }*/
    if(response.headers?["content-type"]?.contains("application/pdf") == false){
      //Failed to load as a PDF
      messageForUser.add(Text("Failed to load as a PDF"));
    }

    return messageForUser;
  }

  @override
  Widget build(BuildContext bc) {
    var info = ModalRoute.of(bc)!.settings;
    myStars theStar;

    //for(theStar in starsForSearchBar){
    theStar = info.arguments as myStars;
    //ref = FirebaseDatabase.instance.ref(theStar.starName!);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(theStar.starName!),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () =>{
              //Navigator.pop(bc),
              //Navigator.push(bc, MaterialPageRoute(builder: (bc) => const StarExpedition())),
              //Going from the star article page to the search suggestions page
              if(fromSpectralClassPage == true){
                fromSpectralClassPage = false,
                Navigator.push(bc, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage())),
              }
              else if(featuredStarOfTheDayBool == true){
                featuredStarOfTheDayBool = false,
                Navigator.push(bc, MaterialPageRoute(builder: (BuildContext context) => StarExpedition())),
              }
              else{
                  showSearch(
                    context: bc,
                    delegate: CustomSearchDelegate(),
                  )
                }
            }
        ),
      ),
      body: FutureBuilder(
        builder: (bc, mySnapshot){
          if(mySnapshot.connectionState == ConnectionState.done){
            if(mySnapshot.hasError){
              print("Error detected: ${mySnapshot.hasError}");
              print("Error stack trace: ${mySnapshot.stackTrace}");
              return Text("Sorry, an error has occurred. Please try again.");
            }
            else{
              if(mySnapshot.hasData){
                final myData = mySnapshot.data as List<String>;
                int myStarIndex = 0;
                for(var s in starsForSearchBar){
                  if(s.starName == theStar.starName){
                    break;
                  }
                  else{
                    myStarIndex++;
                  }
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(bc).size.height * 0.015625,
                      ),
                      Center(
                        child: Text("Image of Star", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                      ),
                      Container(
                        height: MediaQuery.of(bc).size.height * 0.015625,
                      ),
                      Center(
                        child: Image(
                          image: AssetImage(starsForSearchBar[myStarIndex].imagePath!),
                          height: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(bc).size.height * 0.25 : 200,
                          width: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(bc).size.height * 0.25 : 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(bc).size.height * 0.015625,
                      ),
                      Center(
                        child: Text("\nImage Source", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                      ),
                      Container(
                        height: MediaQuery.of(bc).size.height * 0.015625,
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
                          child: Text(starInfo[10].toString(), textAlign: TextAlign.center),
                        ),
                      ),
                      Center(
                        child: Text("\nStar Information", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                      ),
                      Container(
                        height: MediaQuery.of(bc).size.height * 0.015625,
                      ),
                      Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: "Constellation: ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: starInfo[0].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          //Text("\n"),
                          RichText(
                            text: TextSpan(
                              text: "Distance (in light-years): ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: starInfo[1].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          //Text("\n"),
                          RichText(
                            text: TextSpan(
                              text: "Other names: ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: starInfo[2].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          //Text("\n"),
                          RichText(
                            text: TextSpan(
                              text: "Spectral class: ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: starInfo[3].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          //Text("\n"),
                          RichText(
                            text: TextSpan(
                              text: "Absolute magnitude: ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: starInfo[4].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          //Text("\n"),
                          RichText(
                            text: TextSpan(
                              text: "Age of star: ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: starInfo[5].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          //Text("\n"),
                          RichText(
                            text: TextSpan(
                              text: "Apparent magnitude: ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: starInfo[6].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          //Text("\n"),
                          RichText(
                            text: TextSpan(
                              text: "Discoverer of star: ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: starInfo[7].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          //Text("\n"),
                          RichText(
                            text: TextSpan(
                              text: "Discovery date of star: ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: starInfo[8].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          //Text("\n"),
                          RichText(
                            text: TextSpan(
                              text: "Temperature (in Kelvin): ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: starInfo[9].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Text("\nConfirmed Terrestrial Planets",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                      ),
                      Column(
                        children: <Widget>[
                          ListView.builder(
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: myData.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: <Widget>[
                                    Container(
                                      height: MediaQuery.of(context).size.height * 0.015625,
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      //height: 40,
                                      //width: 15,
                                      //color: Colors.grey,
                                      //margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                      //radius: 10, //const EdgeInsets.all(10),
                                      child: Center(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.black,
                                          ),
                                          child: UnconstrainedBox(
                                            child: Ink(
                                              color: Colors.black,
                                              child: Text(myData[index], textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.normal)),
                                            ),
                                          ),
                                          onPressed: () async {
                                            correctPlanet = myData[index];
                                            informationAboutPlanet = await getPlanetData();

                                            planetFileContent = await readPlanetFile(informationAboutPlanet[6].toString());
                                            listOfPlanetUrls = planetFileContent.replaceAll("\n", "").replaceAll("\r", "|").split("|");

                                            listOfPlanetUrls.removeWhere((myUrl) => myUrl == "" || myUrl == " ");

                                            print("listOfPlanetUrls: ${listOfPlanetUrls}");

                                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => planetArticle(informationAboutPlanet)));
                                            //Navigator.push(context, new MaterialPageRoute(builder: (context) => articlePage(articlepage: ));
                                            //Navigator.push(context, new MaterialPageRoute(builder: (context) => new planetArticle(starAndPlanetInfo: new starAndPlanetInformation)));

                                            //Is the planet tracked by the user?
                                            if(myNewUsername != "" && myUsername == ""){
                                              if(firebaseDesktopHelper.onDesktop){
                                                var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                //Getting the current profile info of the user:
                                                Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                                                planetTracked = currentInfoOfNewUser["planetsTracked"].containsKey(correctPlanet);
                                                print("planetTracked: ${planetTracked}");
                                              }
                                              else{
                                                var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                                var theDocNameForNewUsers;
                                                theNewUser.docs.forEach((result){
                                                  theDocNameForNewUsers = result.id;
                                                });

                                                DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForNewUsers).get();
                                                Map<dynamic, dynamic>? individual = theSnapshotNewUsers.data();

                                                planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                                                print("planetTracked: ${planetTracked}");
                                              }
                                            }
                                            else if(myNewUsername == "" && myUsername != ""){
                                              if(firebaseDesktopHelper.onDesktop){
                                                var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                //Getting the current profile info of the user:
                                                Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                                                planetTracked = currentInfoOfExistingUser["planetsTracked"].containsKey(correctPlanet);
                                                print("planetTracked: ${planetTracked}");
                                              }
                                              else{
                                                var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                                var theDocNameForExistingUsers;
                                                theExistingUser.docs.forEach((result){
                                                  theDocNameForExistingUsers = result.id;
                                                });

                                                DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForExistingUsers).get();
                                                Map<dynamic, dynamic>? individual = theSnapshotExistingUsers.data();

                                                planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                                                print("planetTracked: ${planetTracked}");
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                          Center(
                            child: Text("\nOnline Articles about ${correctStar}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                          ),
                          Container(
                            height: MediaQuery.of(bc).size.height * 0.015625,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(listOfStarUrls.length, (int indexPlace) =>
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.height * 0.015625, 0.0, MediaQuery.of(bc).size.height * 0.015625, 0.0),
                                    child: InkWell(
                                        child: Text("${listOfStarUrls[indexPlace]}\n", textAlign: TextAlign.center),
                                        onTap: () async{
                                          starListUrlIndex = indexPlace;
                                          if(!(listOfStarUrls[indexPlace].contains("pdf"))){
                                            launchUrl(Uri.parse("${listOfStarUrls[indexPlace]}"), mode: LaunchMode.externalApplication);
                                            print("Not a pdf file");
                                          }
                                          else{
                                            starPdfBool = true;

                                            var myResponse = await http.get(Uri.parse(listOfStarUrls[indexPlace]));

                                            if(myResponse.statusCode == 200 && myResponse.headers["content-type"]?.contains("application/pdf") == true){
                                              if(firebaseDesktopHelper.onDesktop){
                                                //Creating a temporary file
                                                var temporaryDirectory = await getTemporaryDirectory();
                                                var temporaryFile = File("${temporaryDirectory.path}/temporaryPdf.pdf");
                                                await temporaryFile.writeAsBytes(myResponse.bodyBytes);
                                                myStarPdfFile = PdfDocument.openFile(temporaryFile.path);
                                              }
                                              else if(kIsWeb){
                                                myStarPdfFile = Future.value(PdfDocument.openData(myResponse.bodyBytes));
                                              }
                                              else{
                                                var temporaryDirectory = await getTemporaryDirectory();
                                                var temporaryFile = File("${temporaryDirectory.path}/temporaryPdf.pdf");
                                                await temporaryFile.writeAsBytes(myResponse.bodyBytes);
                                                myStarPdfFile = PdfDocument.openFile(temporaryFile.path);
                                              }
                                              /*else{
                                            if(kIsWeb){
                                              myStarPdfFile = PdfDocument.openFile(temporaryFile.path);
                                            }
                                            else{
                                              myStarPdfFile = PDFDocument.fromFile(temporaryFile);
                                            }
                                          }*/

                                              //Going to the page that has the PDF
                                              Navigator.push(bc, MaterialPageRoute(builder: (theContext) => pdfViewer()));
                                              print("A pdf file. starListUrlIndex is: ${starListUrlIndex.toString()}");
                                            }
                                            else{
                                              print("Unfortunately, the PDF file failed to load. This is the status code: ${myResponse.statusCode}");
                                              print("myResponse.headers[content-type]?: ${myResponse.headers["content-type"]}");
                                              /*if(myResponse.statusCode != 200 && myResponse.headers["content-type"]?.contains("application/pdf") == false){
                                            //Did not load in the correct Star Expedition format and failed to load as a PDF
                                          }
                                          else if(myResponse.statusCode != 200 && myResponse.headers["content-type"]?.contains("application/pdf") == true){
                                            //Did not load in the correct Star Expedition format
                                          }
                                          else if(myResponse.statusCode == 200 && myResponse.headers["content-type"]?.contains("application/pdf") == false){
                                            //Failed to load as a PDF
                                          }*/

                                              starPdfMessageForUser = starPdfDialogMessage(myResponse);

                                              showDialog(
                                                context: bc,
                                                builder: (myContent) => AlertDialog(
                                                  title: const Text("Error"),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: List.generate(starPdfMessageForUser.length, (i){
                                                      return starPdfMessageForUser[i];
                                                    }),
                                                  ),

                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: (){
                                                        Navigator.of(myContent).pop();
                                                      },
                                                      child: Container(
                                                        child: const Text("Ok"),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            }
                                          }
                                        }
                                    ),
                                  ),
                                ),
                            ),
                          ),
                          if(((myNewUsername != "" && myUsername == "") || (myNewUsername == "" && myUsername != "")) && starTracked == false)
                            Padding(
                              padding: EdgeInsets.all(MediaQuery.of(bc).size.height * 0.015625),
                              child: Center(
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.black,
                                    ),
                                    child: Ink(
                                      color: Colors.black,
                                      //padding: EdgeInsets.all(MediaQuery.of(bc).size.height * 0.015625),
                                      child: Text("Track this Star", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                                    ),
                                    onPressed: () async{
                                      if(myNewUsername != "" && myUsername == ""){
                                        TextEditingController reasonForStarTrackNewUsers = TextEditingController();
                                        var starsTracked;

                                        if(firebaseDesktopHelper.onDesktop){
                                          List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                          var user = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                          docNameForStarsTrackedNewUser = user["docId"];
                                          print("docNameForStarsTrackedNewUser: ${docNameForStarsTrackedNewUser}");

                                          Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(user["usernameProfileInformation"] ?? {});

                                          starsTracked = currentInfoOfNewUser?["starsTracked"];
                                        }
                                        else{
                                          var user = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                          user.docs.forEach((result){
                                            docNameForStarsTrackedNewUser = result.id;
                                          });
                                          print(docNameForStarsTrackedNewUser);

                                          DocumentSnapshot<Map<dynamic, dynamic>> mySnapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForStarsTrackedNewUser).get();
                                          Map<dynamic, dynamic>? individual = mySnapshotNewUsers.data();

                                          print(individual?["usernameProfileInformation"]);
                                          print(individual?["usernameProfileInformation"]["starsTracked"]);

                                          starsTracked = individual?["usernameProfileInformation"]["starsTracked"];
                                        }

                                        if(starsTracked.length < 3){
                                          showDialog(
                                              context: bc,
                                              builder: (BuildContext context){
                                                return AlertDialog(
                                                  title: Text("Tracking ${theStar.starName!}"),
                                                  content: Wrap(
                                                    children: <Widget>[
                                                      Center(
                                                        child: Container(
                                                          alignment: Alignment.centerLeft,
                                                          child: Text("Why are you interested in tracking this star?"),
                                                        ),
                                                      ),
                                                      TextField(
                                                        controller: reasonForStarTrackNewUsers,
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        child: Text("Ok"),
                                                        onPressed: () async{
                                                          if(reasonForStarTrackNewUsers.text != ""){
                                                            starsTracked.addEntries({theStar.starName!: reasonForStarTrackNewUsers.text}.entries);

                                                            if(firebaseDesktopHelper.onDesktop){
                                                              List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                                              var currentUser = allUsers.firstWhere((user) => user["docId"] == docNameForStarsTrackedNewUser, orElse: () => <String, dynamic>{});

                                                              Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(currentUser["usernameProfileInformation"] ?? {});

                                                              //Updating starsTracked:
                                                              currentInfoOfUser["starsTracked"] = starsTracked;

                                                              await firebaseDesktopHelper.updateFirestoreDocument("User/$docNameForStarsTrackedNewUser", {
                                                                "usernameProfileInformation": currentInfoOfUser,
                                                              });
                                                            }
                                                            else{
                                                              FirebaseFirestore.instance.collection("User").doc(docNameForStarsTrackedNewUser).update({
                                                                "usernameProfileInformation.starsTracked": starsTracked,
                                                              }).then((outcome) {
                                                                print("starsTracked updated!");
                                                              });
                                                            }

                                                            if(myNewUsername != "" && myUsername == ""){
                                                              if(firebaseDesktopHelper.onDesktop){
                                                                var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                                var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                                //Getting the current profile info of the user:
                                                                Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                                                                starTracked = currentInfoOfNewUser["starsTracked"].containsKey(theStar.starName!);
                                                                print("starTracked: ${starTracked}");
                                                              }
                                                              else{
                                                                var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                                                var docNameForNewUsers;
                                                                theNewUser.docs.forEach((result){
                                                                  docNameForNewUsers = result.id;
                                                                });

                                                                DocumentSnapshot<Map<dynamic, dynamic>> snapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForNewUsers).get();
                                                                Map<dynamic, dynamic>? individual = snapshotNewUsers.data();

                                                                starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(theStar.starName!);
                                                                print("starTracked: ${starTracked}");
                                                              }
                                                            }
                                                            else if(myNewUsername == "" && myUsername != ""){
                                                              if(firebaseDesktopHelper.onDesktop){
                                                                var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                                var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                                //Getting the current profile info of the user:
                                                                Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                                                                starTracked = currentInfoOfExistingUser["starsTracked"].containsKey(theStar.starName!);
                                                                print("starTracked: ${starTracked}");
                                                              }
                                                              else{
                                                                var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                                                var docNameForExistingUsers;
                                                                theExistingUser.docs.forEach((result){
                                                                  docNameForExistingUsers = result.id;
                                                                });

                                                                DocumentSnapshot<Map<dynamic, dynamic>> snapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForExistingUsers).get();
                                                                Map<dynamic, dynamic>? individual = snapshotExistingUsers.data();

                                                                starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(theStar.starName!);
                                                                print("starTracked: ${starTracked}");
                                                              }
                                                            }

                                                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => articlePage(starInfo), settings: RouteSettings(arguments: theStar)));

                                                            /*
                                                          Navigator.pop(bc);
                                                          showSearch(
                                                              context: context,
                                                              delegate: CustomSearchDelegate()
                                                          );*/
                                                          }
                                                        }
                                                    ),
                                                    TextButton(
                                                        child: Text("Cancel"),
                                                        onPressed: ()=>{
                                                          Navigator.pop(context),
                                                        }
                                                    ),
                                                  ],
                                                );
                                              }
                                          );
                                        }
                                        else{
                                          showDialog(
                                              context: bc,
                                              builder: (BuildContext context){
                                                return AlertDialog(
                                                  title: Text("Unable to track star"),
                                                  content: Text("You have reached the maximum number of stars to track!"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                        child: Container(
                                                          child: Text("Ok"),
                                                        ),
                                                        onPressed: (){
                                                          Navigator.pop(context);
                                                        }
                                                    )
                                                  ],
                                                );
                                              }
                                          );
                                        }
                                      }
                                      else if(myNewUsername == "" && myUsername != ""){
                                        TextEditingController reasonForStarTrackExistingUsers = TextEditingController();
                                        var starsTracked;

                                        if(firebaseDesktopHelper.onDesktop){
                                          List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                          var user = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                          docNameForStarsTrackedExistingUser = user["docId"];
                                          print("docNameForStarsTrackedExistingUser: ${docNameForStarsTrackedExistingUser}");

                                          Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(user["usernameProfileInformation"] ?? {});

                                          starsTracked = currentInfoOfExistingUser?["starsTracked"];
                                        }
                                        else{
                                          var user = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                          user.docs.forEach((result){
                                            docNameForStarsTrackedExistingUser = result.id;
                                          });
                                          print(docNameForStarsTrackedExistingUser);

                                          DocumentSnapshot<Map<dynamic, dynamic>> mySnapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForStarsTrackedExistingUser).get();
                                          Map<dynamic, dynamic>? individual = mySnapshotExistingUsers.data();

                                          print(individual?["usernameProfileInformation"]);
                                          print(individual?["usernameProfileInformation"]["starsTracked"]);

                                          starsTracked = individual?["usernameProfileInformation"]["starsTracked"];
                                        }

                                        if(starsTracked.length < 3){
                                          showDialog(
                                              context: bc,
                                              builder: (BuildContext context){
                                                return AlertDialog(
                                                  title: Text("Tracking ${theStar.starName!}"),
                                                  content: Wrap(
                                                    children: <Widget>[
                                                      Center(
                                                        child: Container(
                                                          alignment: Alignment.centerLeft,
                                                          child: Text("Why are you interested in tracking this star?"),
                                                        ),
                                                      ),
                                                      TextField(
                                                        controller: reasonForStarTrackExistingUsers,
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        child: Text("Ok"),
                                                        onPressed: () async{
                                                          if(reasonForStarTrackExistingUsers.text != ""){
                                                            print("docNameForStarsTrackedExistingUser: ${docNameForStarsTrackedExistingUser}");
                                                            starsTracked.addEntries({theStar.starName!: reasonForStarTrackExistingUsers.text}.entries);

                                                            if(firebaseDesktopHelper.onDesktop){
                                                              List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                                              var currentUser = allUsers.firstWhere((user) => user["docId"] == docNameForStarsTrackedExistingUser, orElse: () => <String, dynamic>{});

                                                              Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(currentUser["usernameProfileInformation"] ?? {});

                                                              //Updating starsTracked:
                                                              currentInfoOfUser["starsTracked"] = starsTracked;

                                                              await firebaseDesktopHelper.updateFirestoreDocument("User/$docNameForStarsTrackedExistingUser", {
                                                                "usernameProfileInformation": currentInfoOfUser,
                                                              });
                                                            }
                                                            else{
                                                              FirebaseFirestore.instance.collection("User").doc(docNameForStarsTrackedExistingUser).update({
                                                                "usernameProfileInformation.starsTracked": starsTracked,
                                                              }).then((outcome) {
                                                                print("starsTracked updated!");
                                                              });
                                                            }

                                                            if(myNewUsername != "" && myUsername == ""){
                                                              if(firebaseDesktopHelper.onDesktop){
                                                                var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                                var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                                //Getting the current profile info of the user:
                                                                Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                                                                starTracked = currentInfoOfNewUser["starsTracked"].containsKey(theStar.starName!);
                                                                print("starTracked: ${starTracked}");
                                                              }
                                                              else{
                                                                var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                                                var docNameForNewUsers;
                                                                theNewUser.docs.forEach((result){
                                                                  docNameForNewUsers = result.id;
                                                                });

                                                                DocumentSnapshot<Map<dynamic, dynamic>> snapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForNewUsers).get();
                                                                Map<dynamic, dynamic>? individual = snapshotNewUsers.data();

                                                                starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(theStar.starName!);
                                                                print("starTracked: ${starTracked}");
                                                              }
                                                            }
                                                            else if(myNewUsername == "" && myUsername != ""){
                                                              if(firebaseDesktopHelper.onDesktop){
                                                                var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                                var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                                //Getting the current profile info of the user:
                                                                Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                                                                starTracked = currentInfoOfExistingUser["starsTracked"].containsKey(theStar.starName!);
                                                                print("starTracked: ${starTracked}");
                                                              }
                                                              else{
                                                                var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                                                var docNameForExistingUsers;
                                                                theExistingUser.docs.forEach((result){
                                                                  docNameForExistingUsers = result.id;
                                                                });

                                                                DocumentSnapshot<Map<dynamic, dynamic>> snapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForExistingUsers).get();
                                                                Map<dynamic, dynamic>? individual = snapshotExistingUsers.data();

                                                                starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(theStar.starName!);
                                                                print("starTracked: ${starTracked}");
                                                              }
                                                            }

                                                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => articlePage(starInfo), settings: RouteSettings(arguments: theStar)));
                                                            /*Navigator.pop(bc);
                                                    showSearch(
                                                        context: context,
                                                        delegate: CustomSearchDelegate()
                                                    );*/
                                                          }
                                                        }
                                                    ),
                                                    TextButton(
                                                        child: Text("Cancel"),
                                                        onPressed: ()=>{
                                                          Navigator.pop(context),
                                                        }
                                                    ),
                                                  ],
                                                );
                                              }
                                          );
                                        }
                                        else{
                                          showDialog(
                                              context: bc,
                                              builder: (BuildContext context){
                                                return AlertDialog(
                                                  title: Text("Unable to track star"),
                                                  content: Text("You have reached the maximum number of stars to track!"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                        child: Container(
                                                          child: Text("Ok"),
                                                        ),
                                                        onPressed: (){
                                                          Navigator.pop(context);
                                                        }
                                                    )
                                                  ],
                                                );
                                              }
                                          );
                                        }
                                      }
                                      print("Tracking the star");
                                    }
                                ),
                              ),
                            ),
                          if(((myNewUsername != "" && myUsername == "") || (myNewUsername == "" && myUsername != "")) && starTracked == true)
                            Padding(
                              padding: EdgeInsets.all(MediaQuery.of(bc).size.height * 0.015625),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.black,
                                ),
                                child: InkWell(
                                  child: Ink(
                                    color: Colors.black,
                                    //padding: EdgeInsets.all(MediaQuery.of(bc).size.height * 0.015625),
                                    child: Text("Untrack this Star", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                                  ),
                                ),
                                onPressed: () async{
                                  showDialog(
                                      context: bc,
                                      builder: (BuildContext context){
                                        return AlertDialog(
                                          title: Text("Untracking Star"),
                                          content: Text("Are you sure you want to untrack this star?"),
                                          actions: <Widget>[
                                            TextButton(
                                                child: Text("Yes"),
                                                onPressed: () async{
                                                  print("Untracking star");
                                                  if(myNewUsername != "" && myUsername == ""){
                                                    if(firebaseDesktopHelper.onDesktop){
                                                      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                                      var theNewUser = allUsers.firstWhere((user) => user["usernameLowercased"] == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                      var docForTheNewUser = theNewUser["docId"];

                                                      Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(theNewUser["usernameProfileInformation"] ?? {});

                                                      //Getting and modifying starsTracked:
                                                      Map<String, dynamic> starsTracked = Map<String, dynamic>.from(currentInfoOfNewUser["starsTracked"] ?? {});
                                                      starsTracked.remove(theStar.starName!);

                                                      //Gets an updated list of the stars a user has tracked:
                                                      currentInfoOfNewUser["starsTracked"] = starsTracked;

                                                      await firebaseDesktopHelper.updateFirestoreDocument("User/$docForTheNewUser", {
                                                        "usernameProfileInformation": currentInfoOfNewUser,
                                                      });
                                                    }
                                                    else{
                                                      var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                                      var docForTheNewUser;

                                                      theNewUser.docs.forEach((result){
                                                        docForTheNewUser = result.id;
                                                      });

                                                      DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docForTheNewUser).get();
                                                      Map<dynamic, dynamic>? individual = theSnapshotNewUsers.data();

                                                      var starsTracked = individual?["usernameProfileInformation"]["starsTracked"];

                                                      starsTracked.remove(theStar.starName!);
                                                      FirebaseFirestore.instance.collection("User").doc(docForTheNewUser).update({
                                                        "usernameProfileInformation.starsTracked": starsTracked,
                                                      }).then((outcome) {
                                                        print("Untracked the star!");
                                                      });
                                                    }

                                                    if(myNewUsername != "" && myUsername == ""){
                                                      if(firebaseDesktopHelper.onDesktop){
                                                        var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                        var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                        //Getting the current profile info of the user:
                                                        Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                                                        starTracked = currentInfoOfNewUser["starsTracked"].containsKey(theStar.starName!);
                                                        print("starTracked: ${starTracked}");
                                                      }
                                                      else{
                                                        var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                                        var docNameForNewUsers;
                                                        theNewUser.docs.forEach((result){
                                                          docNameForNewUsers = result.id;
                                                        });

                                                        DocumentSnapshot<Map<dynamic, dynamic>> snapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForNewUsers).get();
                                                        Map<dynamic, dynamic>? individual = snapshotNewUsers.data();

                                                        starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(theStar.starName!);
                                                        print("starTracked: ${starTracked}");
                                                      }
                                                    }
                                                    else if(myNewUsername == "" && myUsername != ""){
                                                      if(firebaseDesktopHelper.onDesktop){
                                                        var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                        var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                        //Getting the current profile info of the user:
                                                        Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                                                        starTracked = currentInfoOfExistingUser["starsTracked"].containsKey(theStar.starName!);
                                                        print("starTracked: ${starTracked}");
                                                      }
                                                      else{
                                                        var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                                        var docNameForExistingUsers;
                                                        theExistingUser.docs.forEach((result){
                                                          docNameForExistingUsers = result.id;
                                                        });

                                                        DocumentSnapshot<Map<dynamic, dynamic>> snapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForExistingUsers).get();
                                                        Map<dynamic, dynamic>? individual = snapshotExistingUsers.data();

                                                        starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(theStar.starName!);
                                                        print("starTracked: ${starTracked}");
                                                      }
                                                    }

                                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => articlePage(starInfo), settings: RouteSettings(arguments: theStar)));

                                                    /*Navigator.pop(context);
                                                showSearch(
                                                    context: context,
                                                    delegate: CustomSearchDelegate()
                                                );*/
                                                  }
                                                  else if(myNewUsername == "" && myUsername != ""){
                                                    if(firebaseDesktopHelper.onDesktop){
                                                      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                                      var theExistingUser = allUsers.firstWhere((user) => user["usernameLowercased"] == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                      var docForTheExistingUser = theExistingUser["docId"];

                                                      Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(theExistingUser["usernameProfileInformation"] ?? {});

                                                      //Getting and modifying starsTracked:
                                                      Map<String, dynamic> starsTracked = Map<String, dynamic>.from(currentInfoOfExistingUser["starsTracked"] ?? {});
                                                      starsTracked.remove(theStar.starName!);

                                                      //Gets an updated list of the stars a user has tracked:
                                                      currentInfoOfExistingUser["starsTracked"] = starsTracked;

                                                      await firebaseDesktopHelper.updateFirestoreDocument("User/$docForTheExistingUser", {
                                                        "usernameProfileInformation": currentInfoOfExistingUser,
                                                      });
                                                    }
                                                    else{
                                                      var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                                      var docForTheExistingUser;
                                                      //var starsExistingUserIsTracking;
                                                      theExistingUser.docs.forEach((result){
                                                        docForTheExistingUser = result.id;
                                                      });

                                                      DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docForTheExistingUser).get();
                                                      Map<dynamic, dynamic>? individual = theSnapshotExistingUsers.data();

                                                      var starsTracked = individual?["usernameProfileInformation"]["starsTracked"];

                                                      starsTracked.remove(theStar.starName!);
                                                      FirebaseFirestore.instance.collection("User").doc(docForTheExistingUser).update({
                                                        "usernameProfileInformation.starsTracked": starsTracked,
                                                      }).then((outcome) {
                                                        print("Untracked the star!");
                                                      });
                                                    }
                                                    if(myNewUsername != "" && myUsername == ""){
                                                      if(firebaseDesktopHelper.onDesktop){
                                                        var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                        var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                        //Getting the current profile info of the user:
                                                        Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                                                        starTracked = currentInfoOfNewUser["starsTracked"].containsKey(theStar.starName!);
                                                        print("starTracked: ${starTracked}");
                                                      }
                                                      else{
                                                        var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                                        var docNameForNewUsers;
                                                        theNewUser.docs.forEach((result){
                                                          docNameForNewUsers = result.id;
                                                        });

                                                        DocumentSnapshot<Map<dynamic, dynamic>> snapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForNewUsers).get();
                                                        Map<dynamic, dynamic>? individual = snapshotNewUsers.data();

                                                        starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(theStar.starName!);
                                                        print("starTracked: ${starTracked}");
                                                      }
                                                    }
                                                    else if(myNewUsername == "" && myUsername != ""){
                                                      if(firebaseDesktopHelper.onDesktop){
                                                        var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                        var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                        //Getting the current profile info of the user:
                                                        Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                                                        starTracked = currentInfoOfExistingUser["starsTracked"].containsKey(theStar.starName!);
                                                        print("starTracked: ${starTracked}");
                                                      }
                                                      else{
                                                        var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                                        var docNameForExistingUsers;
                                                        theExistingUser.docs.forEach((result){
                                                          docNameForExistingUsers = result.id;
                                                        });

                                                        DocumentSnapshot<Map<dynamic, dynamic>> snapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForExistingUsers).get();
                                                        Map<dynamic, dynamic>? individual = snapshotExistingUsers.data();

                                                        starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(theStar.starName!);
                                                        print("starTracked: ${starTracked}");
                                                      }
                                                    }

                                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => articlePage(starInfo), settings: RouteSettings(arguments: theStar)));

                                                    /*Navigator.pop(context);
                                                showSearch(
                                                    context: context,
                                                    delegate: CustomSearchDelegate()
                                                );*/
                                                  }
                                                }
                                            ),
                                            TextButton(
                                                child: Text("No"),
                                                onPressed: (){
                                                  Navigator.pop(context);
                                                  print("No");
                                                }
                                            )
                                          ],
                                        );
                                      }
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      Container(
                        height: MediaQuery.of(bc).size.height * 0.015625,
                      ),
                    ],
                  ),
                );
                //];
              }
              else{ // This else statement indicates what happens if the Firebase database returns nothing.
                return Center(
                  child: Text("No data is available", textAlign: TextAlign.center), // If the snapshot does not have data, this will print.
                );
                //return Text("No data is available");
              }
            }
          }
          else{ //This represents a scenario where the connection has not finished yet.
            /*return Center(
                child: Text("Star data is still loading", textAlign: TextAlign.center),
            );*/
            return Center(child: CircularProgressIndicator());
          }
        },
        future: getStarData(),
      ),
    );
  }
}

class planetArticle extends StatelessWidget{
  static String nameOfRoute = '/planetArticle';

  final List<String> informationAboutPlanet;
  planetArticle(this.informationAboutPlanet);

  List<String>? informationAboutStarsPlanets = [];
  List<String> hostStarInformation = [];

  List<Text> planetPdfMessageForUser = [];

  List<Text> planetPdfDialogMessage(http.Response response){
    List<Text> messageForUser = [];

    if(response.statusCode != 200){
      //Did not load in the correct Star Expedition format
      messageForUser.add(Text("Did not load in the correct Star Expedition format"));
    }
    if(response.headers?["content-type"]?.contains("application/pdf") == false){
      //Failed to load as a PDF
      messageForUser.add(Text("Failed to load as a PDF"));
    }

    return messageForUser;
  }

  @override
  Widget build(BuildContext theContext) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(correctPlanet),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () async {
            if(fromSearchBarToPlanetArticle == true){
              fromSearchBarToPlanetArticle = false;
              showSearch(
                context: theContext,
                delegate: CustomSearchDelegateForPlanets(),
              );
            }
            else{
              hostStarInformation = await getStarInformation();
              print("The host star information: $hostStarInformation");

              starFileContent = await readStarFile();
              listOfStarUrls = starFileContent.replaceAll("\n", "").replaceAll("\r", "|").split("|");

              listOfStarUrls.removeWhere((myUrl) => myUrl == "" || myUrl == " ");

              if(myNewUsername != "" && myUsername == ""){
                if(firebaseDesktopHelper.onDesktop){
                  var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                  var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                  //Getting the current profile info of the user:
                  Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                  starTracked = currentInfoOfNewUser["starsTracked"].containsKey(correctStar);
                  print("starTracked: ${starTracked}");
                }
                else{
                  var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                  var docNameForNewUsers;
                  theNewUser.docs.forEach((result){
                    docNameForNewUsers = result.id;
                  });

                  DocumentSnapshot<Map<dynamic, dynamic>> snapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForNewUsers).get();
                  Map<dynamic, dynamic>? individual = snapshotNewUsers.data();

                  starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(correctStar);
                  print("starTracked: ${starTracked}");
                }
              }
              else if(myNewUsername == "" && myUsername != ""){
                if(firebaseDesktopHelper.onDesktop){
                  var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                  var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                  //Getting the current profile info of the user:
                  Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                  starTracked = currentInfoOfExistingUser["starsTracked"].containsKey(correctStar);
                  print("starTracked: ${starTracked}");
                }
                else{
                  var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                  var docNameForExistingUsers;
                  theExistingUser.docs.forEach((result){
                    docNameForExistingUsers = result.id;
                  });

                  DocumentSnapshot<Map<dynamic, dynamic>> snapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForExistingUsers).get();
                  Map<dynamic, dynamic>? individual = snapshotExistingUsers.data();

                  starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(correctStar);
                  print("starTracked: ${starTracked}");
                }
              };

              Navigator.of(theContext).push(MaterialPageRoute(builder: (theContext) => articlePage(hostStarInformation), settings: RouteSettings(arguments: myStars(starName: correctStar, imagePath: "assets/images"))));
            }
          },
        ),
      ),
      body: FutureBuilder(
        builder: (theContext, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasError){
              return Text("Sorry, an error has occurred. Please try again.");
            }
            else{
              if(snapshot.hasData){
                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(theContext).size.height * 0.015625,
                      ),
                      Center(
                        child: Text("Planet Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                      ),
                      Container(
                        height: MediaQuery.of(theContext).size.height * 0.015625,
                      ),
                      Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: "Discovery date of planet: ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: informationAboutPlanet[0].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: "Distance from star: ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: informationAboutPlanet[1].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: "Earth masses: ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: informationAboutPlanet[2].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: "Known gases: ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: informationAboutPlanet[3].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: "Orbital period: ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: informationAboutPlanet[4].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: "Temperature (in Kelvin): ",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(text: informationAboutPlanet[5].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          Center(
                            child: Text("\nOnline Articles about ${correctPlanet}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                          ),
                          Container(
                            height: MediaQuery.of(theContext).size.height * 0.015625,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(listOfPlanetUrls.length, (int indexPlace) =>
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(MediaQuery.of(theContext).size.height * 0.015625, 0.0, MediaQuery.of(theContext).size.height * 0.015625, 0.0),
                                    child: InkWell(
                                        child: Text("${listOfPlanetUrls[indexPlace]}\n", textAlign: TextAlign.center),
                                        onTap: () async{
                                          planetListUrlIndex = indexPlace;
                                          if(!(listOfPlanetUrls[indexPlace].contains("pdf"))){
                                            launchUrl(Uri.parse("${listOfPlanetUrls[indexPlace]}"), mode: LaunchMode.externalApplication);
                                            print("Not a pdf file");
                                          }
                                          else{
                                            planetPdfBool = true;

                                            var myResponse;

                                            if(!kIsWeb){
                                              myResponse = await http.get(Uri.parse(listOfPlanetUrls[indexPlace]));
                                            }
                                            else{
                                              String myCorsProxy = "https://corsproxy.io/?";
                                              String myProxiedUrl = myCorsProxy + Uri.encodeComponent(listOfPlanetUrls[indexPlace]);
                                              print("Fetching with proxy: ${myProxiedUrl}");

                                              myResponse = await http.get(Uri.parse(myProxiedUrl));
                                            }

                                            if(myResponse.statusCode == 200 && myResponse.headers["content-type"]?.contains("application/pdf") == true){
                                              if(firebaseDesktopHelper.onDesktop){
                                                var temporaryDirectory = await getTemporaryDirectory();
                                                var temporaryFile = File("${temporaryDirectory.path}/temporaryPdf.pdf");
                                                await temporaryFile.writeAsBytes(myResponse.bodyBytes);
                                                myPlanetPdfFile = PdfDocument.openFile(temporaryFile.path);
                                              }
                                              else if(kIsWeb){
                                                myPlanetPdfFile = Future.value(PdfDocument.openData(myResponse.bodyBytes));
                                              }
                                              else{
                                                var temporaryDirectory = await getTemporaryDirectory();
                                                var temporaryFile = File("${temporaryDirectory.path}/temporaryPdf.pdf");
                                                await temporaryFile.writeAsBytes(myResponse.bodyBytes);
                                                myPlanetPdfFile = PDFDocument.fromFile(temporaryFile);
                                              }

                                              //Going to the page that has the PDF
                                              Navigator.push(theContext, MaterialPageRoute(builder: (theContext) => pdfViewer()));
                                              print("A pdf file. planetListUrlIndex is: ${planetListUrlIndex.toString()}");
                                            }
                                            else{
                                              print("Unfortunately, the PDF file failed to load. This is the status code: ${myResponse.statusCode}");
                                              print("myResponse.headers[content-type]?: ${myResponse.headers["content-type"]}");
                                              /*if(myResponse.statusCode != 200 && myResponse.headers["content-type"]?.contains("application/pdf") == false){
                                            //Did not load in the correct Star Expedition format and failed to load as a PDF
                                          }
                                          else if(myResponse.statusCode != 200 && myResponse.headers["content-type"]?.contains("application/pdf") == true){
                                            //Did not load in the correct Star Expedition format
                                          }
                                          else if(myResponse.statusCode == 200 && myResponse.headers["content-type"]?.contains("application/pdf") == false){
                                            //Failed to load as a PDF
                                          }*/
                                              planetPdfMessageForUser = planetPdfDialogMessage(myResponse);

                                              showDialog(
                                                context: theContext,
                                                builder: (myContent) => AlertDialog(
                                                  title: const Text("Error"),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: List.generate(planetPdfMessageForUser.length, (i){
                                                      return planetPdfMessageForUser[i];
                                                    }),
                                                  ),

                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: (){
                                                        Navigator.of(myContent).pop();
                                                      },
                                                      child: Container(
                                                        child: const Text("Ok"),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            }
                                          }
                                        }
                                    ),
                                  ),
                                ),
                            ),
                          ),
                          if(((myNewUsername != "" && myUsername == "") || (myNewUsername == "" && myUsername != "")) && planetTracked == false)
                            Padding(
                              padding: EdgeInsets.all(MediaQuery.of(theContext).size.height * 0.015625),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                  ),
                                  child: InkWell(
                                    child: Ink(
                                      color: Colors.black,
                                      //padding: EdgeInsets.all(MediaQuery.of(theContext).size.height * 0.015625),
                                      child: Text("Track this Planet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                                    ),
                                  ),
                                  onPressed: () async{
                                    if(myNewUsername != "" && myUsername == ""){
                                      TextEditingController reasonForPlanetTrackNewUsers = TextEditingController();
                                      var planetsTracked;

                                      if(firebaseDesktopHelper.onDesktop){
                                        List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                        var user = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                        docNameForPlanetsTrackedNewUser = user["docId"];
                                        print("docNameForPlanetsTrackedNewUser: ${docNameForPlanetsTrackedNewUser}");

                                        Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(user["usernameProfileInformation"] ?? {});

                                        planetsTracked = currentInfoOfNewUser?["planetsTracked"];
                                      }
                                      else{
                                        var user = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                        user.docs.forEach((result){
                                          docNameForPlanetsTrackedNewUser = result.id;
                                        });
                                        print(docNameForPlanetsTrackedNewUser);

                                        DocumentSnapshot<Map<dynamic, dynamic>> mySnapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForPlanetsTrackedNewUser).get();
                                        Map<dynamic, dynamic>? individual = mySnapshotNewUsers.data();

                                        print(individual?["usernameProfileInformation"]);
                                        print(individual?["usernameProfileInformation"]["planetsTracked"]);

                                        planetsTracked = individual?["usernameProfileInformation"]["planetsTracked"];
                                      }

                                      if(planetsTracked.length < 3){
                                        showDialog(
                                            context: theContext,
                                            builder: (BuildContext context){
                                              return AlertDialog(
                                                title: Text("Tracking ${correctPlanet}"),
                                                content: Wrap(
                                                  children: <Widget>[
                                                    Center(
                                                      child: Container(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text("Why are you interested in tracking this planet?"),
                                                      ),
                                                    ),
                                                    TextField(
                                                      controller: reasonForPlanetTrackNewUsers,
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                      child: Text("Ok"),
                                                      onPressed: () async{
                                                        if(reasonForPlanetTrackNewUsers.text != ""){
                                                          planetsTracked.addEntries({correctPlanet: reasonForPlanetTrackNewUsers.text}.entries);

                                                          if(firebaseDesktopHelper.onDesktop){
                                                            List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                                            var currentUser = allUsers.firstWhere((user) => user["docId"] == docNameForPlanetsTrackedNewUser, orElse: () => <String, dynamic>{});

                                                            Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(currentUser["usernameProfileInformation"] ?? {});

                                                            //Updating planetsTracked:
                                                            currentInfoOfUser["planetsTracked"] = planetsTracked;

                                                            await firebaseDesktopHelper.updateFirestoreDocument("User/$docNameForPlanetsTrackedNewUser", {
                                                              "usernameProfileInformation": currentInfoOfUser,
                                                            });
                                                          }
                                                          else{
                                                            FirebaseFirestore.instance.collection("User").doc(docNameForPlanetsTrackedNewUser).update({
                                                              "usernameProfileInformation.planetsTracked": planetsTracked,
                                                            }).then((outcome) {
                                                              print("planetsTracked updated!");
                                                            });
                                                          }

                                                          //Is the planet tracked by the user?
                                                          if(myNewUsername != "" && myUsername == ""){
                                                            if(firebaseDesktopHelper.onDesktop){
                                                              var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                              var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                              //Getting the current profile info of the user:
                                                              Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                                                              planetTracked = currentInfoOfNewUser["planetsTracked"].containsKey(correctPlanet);
                                                              print("planetTracked: ${planetTracked}");
                                                            }
                                                            else{
                                                              var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                                              var theDocNameForNewUsers;
                                                              theNewUser.docs.forEach((result){
                                                                theDocNameForNewUsers = result.id;
                                                              });

                                                              DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForNewUsers).get();
                                                              Map<dynamic, dynamic>? individual = theSnapshotNewUsers.data();

                                                              planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                                                              print("planetTracked: ${planetTracked}");
                                                            }
                                                          }
                                                          else if(myNewUsername == "" && myUsername != ""){
                                                            if(firebaseDesktopHelper.onDesktop){
                                                              var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                              var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                              //Getting the current profile info of the user:
                                                              Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                                                              planetTracked = currentInfoOfExistingUser["planetsTracked"].containsKey(correctPlanet);
                                                              print("planetTracked: ${planetTracked}");
                                                            }
                                                            else{
                                                              var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                                              var theDocNameForExistingUsers;
                                                              theExistingUser.docs.forEach((result){
                                                                theDocNameForExistingUsers = result.id;
                                                              });

                                                              DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForExistingUsers).get();
                                                              Map<dynamic, dynamic>? individual = theSnapshotExistingUsers.data();

                                                              planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                                                              print("planetTracked: ${planetTracked}");
                                                            }
                                                          }
                                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => planetArticle(informationAboutPlanet)));
                                                        }
                                                      }
                                                  ),
                                                  TextButton(
                                                      child: Text("Cancel"),
                                                      onPressed: ()=>{
                                                        Navigator.pop(context),
                                                      }
                                                  ),
                                                ],
                                              );
                                            }
                                        );
                                      }
                                      else{
                                        showDialog(
                                            context: theContext,
                                            builder: (BuildContext context){
                                              return AlertDialog(
                                                title: Text("Unable to track planet"),
                                                content: Text("You have reached the maximum number of planets to track!"),
                                                actions: <Widget>[
                                                  TextButton(
                                                      child: Container(
                                                        child: Text("Ok"),
                                                      ),
                                                      onPressed: (){
                                                        Navigator.pop(context);
                                                      }
                                                  ),
                                                ],
                                              );
                                            }
                                        );
                                      }
                                    }
                                    else if(myNewUsername == "" && myUsername != ""){
                                      TextEditingController reasonForPlanetTrackExistingUsers = TextEditingController();
                                      var planetsTracked;

                                      if(firebaseDesktopHelper.onDesktop){
                                        List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                        var user = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                        docNameForPlanetsTrackedExistingUser = user["docId"];
                                        print("docNameForPlanetsTrackedExistingUser: ${docNameForPlanetsTrackedExistingUser}");

                                        Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(user["usernameProfileInformation"] ?? {});

                                        planetsTracked = currentInfoOfNewUser?["planetsTracked"];
                                      }
                                      else{
                                        var user = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                        user.docs.forEach((result){
                                          docNameForPlanetsTrackedExistingUser = result.id;
                                        });
                                        print(docNameForPlanetsTrackedExistingUser);

                                        DocumentSnapshot<Map<dynamic, dynamic>> mySnapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForPlanetsTrackedExistingUser).get();
                                        Map<dynamic, dynamic>? individual = mySnapshotExistingUsers.data();

                                        print(individual?["usernameProfileInformation"]);
                                        print(individual?["usernameProfileInformation"]["planetsTracked"]);

                                        planetsTracked = individual?["usernameProfileInformation"]["planetsTracked"];
                                      }

                                      if(planetsTracked.length < 3){
                                        showDialog(
                                            context: theContext,
                                            builder: (BuildContext context){
                                              return AlertDialog(
                                                title: Text("Tracking ${correctPlanet}"),
                                                content: Wrap(
                                                  children: <Widget>[
                                                    Center(
                                                      child: Container(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text("Why are you interested in tracking this planet?"),
                                                      ),
                                                    ),
                                                    TextField(
                                                      controller: reasonForPlanetTrackExistingUsers,
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                      child: Text("Ok"),
                                                      onPressed: () async{
                                                        if(reasonForPlanetTrackExistingUsers.text != ""){
                                                          planetsTracked.addEntries({correctPlanet: reasonForPlanetTrackExistingUsers.text}.entries);

                                                          if(firebaseDesktopHelper.onDesktop){
                                                            List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                                            var currentUser = allUsers.firstWhere((user) => user["docId"] == docNameForPlanetsTrackedExistingUser, orElse: () => <String, dynamic>{});
                                                            print("This is currentuser: ${currentUser}");

                                                            Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(currentUser["usernameProfileInformation"] ?? {});

                                                            //Updating planetsTracked:
                                                            currentInfoOfUser["planetsTracked"] = planetsTracked;

                                                            await firebaseDesktopHelper.updateFirestoreDocument("User/$docNameForPlanetsTrackedExistingUser", {
                                                              "usernameProfileInformation": currentInfoOfUser,
                                                            });
                                                          }
                                                          else{
                                                            FirebaseFirestore.instance.collection("User").doc(docNameForPlanetsTrackedExistingUser).update({
                                                              "usernameProfileInformation.planetsTracked": planetsTracked,
                                                            }).then((outcome) {
                                                              print("planetsTracked updated!");
                                                            });
                                                          }

                                                          //Is the planet tracked by the user?
                                                          if(myNewUsername != "" && myUsername == ""){
                                                            if(firebaseDesktopHelper.onDesktop){
                                                              var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                              var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                              //Getting the current profile info of the user:
                                                              Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                                                              planetTracked = currentInfoOfNewUser["planetsTracked"].containsKey(correctPlanet);
                                                              print("planetTracked: ${planetTracked}");
                                                            }
                                                            else{
                                                              var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                                              var theDocNameForNewUsers;
                                                              theNewUser.docs.forEach((result){
                                                                theDocNameForNewUsers = result.id;
                                                              });

                                                              DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForNewUsers).get();
                                                              Map<dynamic, dynamic>? individual = theSnapshotNewUsers.data();

                                                              planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                                                              print("planetTracked: ${planetTracked}");
                                                            }
                                                          }
                                                          else if(myNewUsername == "" && myUsername != ""){
                                                            if(firebaseDesktopHelper.onDesktop){
                                                              var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                              var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                              //Getting the current profile info of the user:
                                                              Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                                                              planetTracked = currentInfoOfExistingUser["planetsTracked"].containsKey(correctPlanet);
                                                              print("planetTracked: ${planetTracked}");
                                                            }
                                                            else{
                                                              var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                                              var theDocNameForExistingUsers;
                                                              theExistingUser.docs.forEach((result){
                                                                theDocNameForExistingUsers = result.id;
                                                              });

                                                              DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForExistingUsers).get();
                                                              Map<dynamic, dynamic>? individual = theSnapshotExistingUsers.data();

                                                              planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                                                              print("planetTracked: ${planetTracked}");
                                                            }
                                                          }
                                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => planetArticle(informationAboutPlanet)));
                                                        }
                                                      }
                                                  ),
                                                  TextButton(
                                                      child: Text("Cancel"),
                                                      onPressed: ()=>{
                                                        Navigator.pop(context),
                                                      }
                                                  ),
                                                ],
                                              );
                                            }
                                        );
                                      }
                                      else{
                                        showDialog(
                                            context: theContext,
                                            builder: (BuildContext context){
                                              return AlertDialog(
                                                title: Text("Unable to track planet"),
                                                content: Text("You have reached the maximum number of planets to track!"),
                                                actions: <Widget>[
                                                  TextButton(
                                                      child: Container(
                                                        child: Text("Ok"),
                                                      ),
                                                      onPressed: (){
                                                        Navigator.pop(context);
                                                      }
                                                  ),
                                                ],
                                              );
                                            }
                                        );
                                      }
                                    }
                                  }
                              ),
                            ),
                          if(((myNewUsername != "" && myUsername == "") || (myNewUsername == "" && myUsername != "")) && planetTracked == true)
                            Padding(
                              padding: EdgeInsets.all(MediaQuery.of(theContext).size.height * 0.015625),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                  ),
                                  child: InkWell(
                                    child: Ink(
                                      color: Colors.black,
                                      //padding: EdgeInsets.all(MediaQuery.of(theContext).size.height * 0.015625),
                                      child: Text("Untrack this Planet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                                    ),
                                  ),
                                  onPressed: () async{
                                    showDialog(
                                        context: theContext,
                                        builder: (BuildContext context){
                                          return AlertDialog(
                                            title: Text("Untracking Planet"),
                                            content: Text("Are you sure you want to untrack this planet?"),
                                            actions: <Widget>[
                                              TextButton(
                                                  child: Text("Yes"),
                                                  onPressed: () async{
                                                    print("Untracking planet");
                                                    if(myNewUsername != "" && myUsername == ""){
                                                      if(firebaseDesktopHelper.onDesktop){
                                                        List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                                        var theNewUser = allUsers.firstWhere((user) => user["usernameLowercased"] == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                        var docForTheNewUser = theNewUser["docId"];

                                                        Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(theNewUser["usernameProfileInformation"] ?? {});

                                                        //Getting and modifying starsTracked:
                                                        Map<String, dynamic> planetsTracked = Map<String, dynamic>.from(currentInfoOfNewUser["planetsTracked"] ?? {});
                                                        planetsTracked.remove(correctPlanet);

                                                        //Gets an updated list of the stars a user has tracked:
                                                        currentInfoOfNewUser["planetsTracked"] = planetsTracked;

                                                        await firebaseDesktopHelper.updateFirestoreDocument("User/$docForTheNewUser", {
                                                          "usernameProfileInformation": currentInfoOfNewUser,
                                                        });
                                                      }
                                                      else{
                                                        var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                                        var docForTheNewUser;

                                                        theNewUser.docs.forEach((result){
                                                          docForTheNewUser = result.id;
                                                        });

                                                        DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docForTheNewUser).get();
                                                        Map<dynamic, dynamic>? individual = theSnapshotNewUsers.data();

                                                        var planetsTracked = individual?["usernameProfileInformation"]["planetsTracked"];

                                                        planetsTracked.remove(correctPlanet);
                                                        FirebaseFirestore.instance.collection("User").doc(docForTheNewUser).update({
                                                          "usernameProfileInformation.planetsTracked": planetsTracked,
                                                        }).then((outcome) {
                                                          print("Untracked the planet!");
                                                        });
                                                      }

                                                      //Is the planet tracked by the user?
                                                      if(myNewUsername != "" && myUsername == ""){
                                                        if(firebaseDesktopHelper.onDesktop){
                                                          var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                          var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                          //Getting the current profile info of the user:
                                                          Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                                                          planetTracked = currentInfoOfNewUser["planetsTracked"].containsKey(correctPlanet);
                                                          print("planetTracked: ${planetTracked}");
                                                        }
                                                        else{
                                                          var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                                          var theDocNameForNewUsers;
                                                          theNewUser.docs.forEach((result){
                                                            theDocNameForNewUsers = result.id;
                                                          });

                                                          DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForNewUsers).get();
                                                          Map<dynamic, dynamic>? individual = theSnapshotNewUsers.data();

                                                          planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                                                          print("planetTracked: ${planetTracked}");
                                                        }
                                                      }
                                                      else if(myNewUsername == "" && myUsername != ""){
                                                        if(firebaseDesktopHelper.onDesktop){
                                                          var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                          var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                          //Getting the current profile info of the user:
                                                          Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                                                          planetTracked = currentInfoOfExistingUser["planetsTracked"].containsKey(correctPlanet);
                                                          print("planetTracked: ${planetTracked}");
                                                        }
                                                        else{
                                                          var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                                          var theDocNameForExistingUsers;
                                                          theExistingUser.docs.forEach((result){
                                                            theDocNameForExistingUsers = result.id;
                                                          });

                                                          DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForExistingUsers).get();
                                                          Map<dynamic, dynamic>? individual = theSnapshotExistingUsers.data();

                                                          planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                                                          print("planetTracked: ${planetTracked}");
                                                        }
                                                      }

                                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => planetArticle(informationAboutPlanet)));

                                                      /*hostStarInformation = await getStarInformation();
                                                  print("hoststarinformation: ${hostStarInformation}");
                                                  Navigator.pop(context);
                                                  Navigator.of(theContext).push(MaterialPageRoute(builder: (theContext) => articlePage(hostStarInformation), settings: RouteSettings(arguments: myStars(starName: correctStar, imagePath: "assets/images"))));*/
                                                    }
                                                    else if(myNewUsername == "" && myUsername != ""){
                                                      if(firebaseDesktopHelper.onDesktop){
                                                        List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                                        var theExistingUser = allUsers.firstWhere((user) => user["usernameLowercased"] == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                        var docForTheExistingUser = theExistingUser["docId"];

                                                        Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(theExistingUser["usernameProfileInformation"] ?? {});

                                                        //Getting and modifying starsTracked:
                                                        Map<String, dynamic> planetsTracked = Map<String, dynamic>.from(currentInfoOfExistingUser["planetsTracked"] ?? {});
                                                        planetsTracked.remove(correctPlanet);

                                                        //Gets an updated list of the stars a user has tracked:
                                                        currentInfoOfExistingUser["planetsTracked"] = planetsTracked;

                                                        await firebaseDesktopHelper.updateFirestoreDocument("User/$docForTheExistingUser", {
                                                          "usernameProfileInformation": currentInfoOfExistingUser,
                                                        });
                                                      }
                                                      else{
                                                        var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                                        var docForTheExistingUser;

                                                        theExistingUser.docs.forEach((result){
                                                          docForTheExistingUser = result.id;
                                                        });

                                                        DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docForTheExistingUser).get();
                                                        Map<dynamic, dynamic>? individual = theSnapshotExistingUsers.data();

                                                        var planetsTracked = individual?["usernameProfileInformation"]["planetsTracked"];

                                                        planetsTracked.remove(correctPlanet);
                                                        FirebaseFirestore.instance.collection("User").doc(docForTheExistingUser).update({
                                                          "usernameProfileInformation.planetsTracked": planetsTracked,
                                                        }).then((outcome) {
                                                          print("Untracked the planet!");
                                                        });
                                                      }

                                                      //Is the planet tracked by the user?
                                                      if(myNewUsername != "" && myUsername == ""){
                                                        if(firebaseDesktopHelper.onDesktop){
                                                          var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                          var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                          //Getting the current profile info of the user:
                                                          Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                                                          planetTracked = currentInfoOfNewUser["planetsTracked"].containsKey(correctPlanet);
                                                          print("planetTracked: ${planetTracked}");
                                                        }
                                                        else{
                                                          var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                                          var theDocNameForNewUsers;
                                                          theNewUser.docs.forEach((result){
                                                            theDocNameForNewUsers = result.id;
                                                          });

                                                          DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForNewUsers).get();
                                                          Map<dynamic, dynamic>? individual = theSnapshotNewUsers.data();

                                                          planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                                                          print("planetTracked: ${planetTracked}");
                                                        }
                                                      }
                                                      else if(myNewUsername == "" && myUsername != ""){
                                                        if(firebaseDesktopHelper.onDesktop){
                                                          var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                          var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                                          //Getting the current profile info of the user:
                                                          Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                                                          planetTracked = currentInfoOfExistingUser["planetsTracked"].containsKey(correctPlanet);
                                                          print("planetTracked: ${planetTracked}");
                                                        }
                                                        else{
                                                          var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                                          var theDocNameForExistingUsers;
                                                          theExistingUser.docs.forEach((result){
                                                            theDocNameForExistingUsers = result.id;
                                                          });

                                                          DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForExistingUsers).get();
                                                          Map<dynamic, dynamic>? individual = theSnapshotExistingUsers.data();

                                                          planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                                                          print("planetTracked: ${planetTracked}");
                                                        }
                                                      }

                                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => planetArticle(informationAboutPlanet)));

                                                      /*hostStarInformation = await getStarInformation();
                                                  print("hoststarinformation: ${hostStarInformation}");
                                                  Navigator.pop(context);
                                                  Navigator.of(theContext).push(MaterialPageRoute(builder: (theContext) => articlePage(hostStarInformation), settings: RouteSettings(arguments: myStars(starName: correctStar, imagePath: "assets/images"))));*/
                                                    }
                                                  }
                                              ),
                                              TextButton(
                                                  child: Text("No"),
                                                  onPressed: (){
                                                    Navigator.pop(context);
                                                    print("No");
                                                  }
                                              ),
                                            ],
                                          );
                                        }
                                    );
                                  }
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              else{
                return Center(
                  child: Text("No data is available", textAlign: TextAlign.center),
                );
              }
            }
          }
          else{
            return Center(child: CircularProgressIndicator());
          }
        },
        future: articlePage(hostStarInformation).getPlanetData(),
      ),
    );
  }
}