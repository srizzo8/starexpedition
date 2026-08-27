import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:io' show HttpHeaders, Platform;
import 'dart:math';
//if(kIsWeb) import 'dart:html' as html;
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:provider/provider.dart';
import 'package:starexpedition4/pdfViewer.dart';
import 'package:starexpedition4/sourceMapDecoder.dart';
import 'package:starexpedition4/spectralClassPage.dart';

import 'package:starexpedition4/discussionBoardPage.dart';
import 'package:starexpedition4/loginPage.dart';
import 'package:starexpedition4/registerPage.dart';
import 'package:starexpedition4/loginPage.dart' as theLoginPage;
import 'package:flutter/services.dart' show SystemChannels, rootBundle;
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

//import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

import 'package:pdfx/pdfx.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'login_information/loginStatus.dart';
import 'mostTrackedStarsAndPlanetsPage.dart';

import 'package:starexpedition4/trials_and_payments/theBillingService.dart';
import 'package:starexpedition4/trials_and_payments/theTrialService.dart';
import 'package:starexpedition4/paywallPage.dart';
import 'package:starexpedition4/subscriptionGate.dart';

import 'package:starexpedition4/data_collection_information/dataCollectionSetting.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
var starsUserTracked = {};
var planetsUserTracked = {};

var theListOfUsers = [];

var docNameForStarsTrackedUser;

bool starTracked = false;

var docNameForPlanetsTrackedUser;

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

List<String> starsUsersTracked = [];
List<String> planetsUsersTracked = [];
Map<String, String> starsAndAmountOfTracks = {};
Map<String, String> planetsAndAmountOfTracks = {};

bool fromProfileAndStar = false;

Map<String, double> myStarDistanceInLightYearsMap = {};
Map<String, double> myStarTemperatureInKelvinMap = {};
Map<String, double> myPlanetDistanceFromStarInAUMap = {};
Map<String, double> myPlanetTemperatureInKelvinMap = {};

enum myStarSortingCriteria { alphabeticalAToZ, alphabeticalZToA, distanceClosestToFurthest, distanceFurthestToClosest, temperatureCoolestToHottest, temperatureHottestToCoolest }
enum myPlanetSortingCriteria { alphabeticalAToZ, alphabeticalZToA, distanceClosestToFurthest, distanceFurthestToClosest, temperatureCoolestToHottest, temperatureHottestToCoolest }

final GlobalKey<NavigatorState> myNavigatorKey = GlobalKey<NavigatorState>();

final ValueNotifier<DateTime> myAccessCheckNotifier = ValueNotifier(DateTime.now());

List<String> urlTitlesForStars = [];
List<String> urlTitlesForPlanets = [];

var userForLoadingProfilePictureInUsersPerspective;

//An instance:
final accessCheckObserver myAccessCheckObserver = accessCheckObserver();

bool whitespaceChecker(String? myString){
  if(myString == null){
    return true;
  }

  //Removing unicode characters that are invisible and missed by the trim() method:
  final cleaned = myString.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u00A0]'), "");

  return cleaned.trim().isEmpty;
}

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
}

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
}

String? determiningUsername(String theUsername){
  print("This is theUsername: ${theUsername}");

  if(theUsername.isNotEmpty){
    return theUsername;
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
}

Future<void> loggingError(String myMessage, StackTrace myStacktrace, String? theUser, {Map<String, dynamic>? myExtraInfo}) async{
  final myUrl = Uri.parse("https://hjncbvhtwdenqzacfxab.supabase.co/functions/v1/log_error");

  final myDeviceInfo = kIsWeb? "Web" : "${Platform.operatingSystem} ${Platform.operatingSystemVersion}";

  final myPublicToken = "bkg94itlep73igf81qw60";

  //Stack trace handling:
  final Map<String, dynamic> myParsedStack = kIsWeb? <String, dynamic>{ "file_name": null, "line": null, "column": null } : await parseMyStackTrace(myStacktrace.toString());

  //Converting from web to raw JS stacktrace and from mobile and desktop to raw Dart stacktrace:
  final myFullStackString = myStacktrace.toString();

  //Checking if myPublicToken is empty or not:
  if(myPublicToken.isEmpty){
    print("Unfortunately, the value of myPublicToken is missing");
  }

  //Determining the value of theUser:
  theUser = await loginStatus.getMyPersistedUsername();

  //Build headers with an API key:
  final Map<String, String> myHeaders = {
    HttpHeaders.contentTypeHeader: "application/json",
    "x-api-key": myPublicToken,
  };

  print("These are the outgoing headers: $myHeaders");

  //Determining if "device_info" should be myDeviceInfo or N/A:
  final myDeviceId = await dataCollectionSetting.getMyDeviceId();
  final myDoc = await FirebaseFirestore.instance.collection("Data_Collection_Settings").doc(myDeviceId).get();

  var dataCollectionOn;
  var myValue = myDoc.data()!["dataCollectionOn"];

  if(myValue == null){
    dataCollectionOn = true;
  }
  else{
    dataCollectionOn = myValue as bool;
  }

  final body = jsonEncode({
    "message": myMessage,
    "stacktrace": myFullStackString,
    "device_info": dataCollectionOn? myDeviceInfo : "N/A",
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
}

Future<void> main() async {
  //runZonedGuarded, which catches desktop and mobile asynchronous errors:
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    final loginSetting = loginStatus();
    await loginSetting.loadInfo();

    //Loading the .env file:
    await dotenv.load(fileName: "assets/dotenv.env");

    //Initializing firebaseDesktopHelper:
    firebaseDesktopHelper.myDatabaseUrl = dotenv.env["FIREBASE_DATABASE_URL"]!;
    firebaseDesktopHelper.myApiKey = dotenv.env["FIREBASE_API_KEY"]!;
    firebaseDesktopHelper.myProjectId = dotenv.env["FIREBASE_PROJECT_ID"]!;

    List usersOnStarExpeditionDocs = [];

    if(kIsWeb){
      try{
        await Firebase.initializeApp(options: FirebaseOptions(
          apiKey: dotenv.env["FIREBASE_API_KEY"]!,
          appId: dotenv.env["FIREBASE_APP_ID"]!,
          databaseURL: dotenv.env["FIREBASE_DATABASE_URL"]!,
          messagingSenderId: dotenv.env["FIREBASE_MESSAGING_SENDER_ID"]!,
          projectId: dotenv.env["FIREBASE_PROJECT_ID"]!
        ));
      }
      on FirebaseException catch(e){
        if(e.code != "duplicate-app"){
          rethrow;
        }
      }

      try{
        await FirebaseFirestore.instance.collection("User").get(GetOptions(source: Source.server)).then((snapshot){
          snapshot.docs.forEach((item){
            usersOnStarExpeditionDocs.add(item.data());
          });
        });
      }
      catch (e){
        //Going to cache if the server is unavailable
        print("The server is unavailable. Error: ${e}");
        await FirebaseFirestore.instance.collection("User").get(GetOptions(source: Source.cache)).then((snapshot){
          snapshot.docs.forEach((item){
            usersOnStarExpeditionDocs.add(item.data());
          });
        });
      }
      //print("usersOnStarExpeditionDocs: ${usersOnStarExpeditionDocs}");

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
      try{
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: dotenv.env["FIREBASE_API_KEY"] as String,
            appId: dotenv.env["FIREBASE_APP_ID"] as String,
            messagingSenderId: dotenv.env["FIREBASE_MESSAGING_SENDER_ID"] as String,
            projectId: dotenv.env["FIREBASE_PROJECT_ID"] as String,
            storageBucket: dotenv.env["FIREBASE_STORAGE_BUCKET"] as String,
            databaseURL: dotenv.env["FIREBASE_DATABASE_URL"] as String,
          ),
        );
      }
      on FirebaseException catch(e){
        if(e.code != "duplicate-app"){
          rethrow;
        }
      }

      try{
        await FirebaseFirestore.instance.collection("User").get(GetOptions(source: Source.server)).then((snapshot){
          snapshot.docs.forEach((item){
            usersOnStarExpeditionDocs.add(item.data());
          });
        });
      }
      catch (e){
        //Going to cache if the server is unavailable
        print("The server is unavailable. Error: ${e}");

        await FirebaseFirestore.instance.collection("User").get(GetOptions(source: Source.cache)).then((snapshot){
          snapshot.docs.forEach((item){
            usersOnStarExpeditionDocs.add(item.data());
          });
        });
      }

      //print("usersOnStarExpeditionDocs: ${usersOnStarExpeditionDocs}");

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

    //This tracks one's data collection setting. It runs every time one opens up the app:
    await dataCollectionSetting.getDataCollectionOn();

    print("The Supabase Function URL: ${dotenv.env["MY_SUPABASE_URL"]}");

    //Registering every error before runApp is run:
    setupMyErrorHandlers();

    runApp(
      ChangeNotifierProvider.value(
        value: loginSetting,
        child: const MyApp(),
      ),
    );
  }, (error, stack) async{
    print("Zone caught error");
    print("This is the error: ${error}");
    print("This is the stack: ${stack}");
    final myUsername = await loginStatus.getMyPersistedUsername();

    //Logging the error to the Supabase Edge function:
    loggingError(error.toString(), stack, myUsername, myExtraInfo: { "origin": "zoned_guarded" },);

    runApp(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text("Unfortunately, this is your error:\n${error}"),
                ),
                Container(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text("Stack trace:\n${stack}"),
                ),
              ],
            )
          )
        ),
      ),
    );
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
  //myStars(starName: "Kapteyn's Star", imagePath: "assets/images/kapteyns_star.jpg", articlePath: "assets/text_files/star_files/kapteyns_star.txt"),
  myStars(starName: "Wolf 1061", imagePath: "assets/images/wolf_1061.jpg", articlePath: "assets/text_files/star_files/wolf_1061.txt"),
  //myStars(starName: "Gliese 876", imagePath: "assets/images/gliese_876.jpg", articlePath: "assets/text_files/star_files/gliese_876.txt"),
  //myStars(starName: "Gliese 581", imagePath: "assets/images/gliese_581.jpg", articlePath: "assets/text_files/star_files/gliese_581.txt"),
  //myStars(starName: "Lacaille 9352", imagePath: "assets/images/lacaille_9352.jpg", articlePath: "assets/text_files/star_files/lacaille_9352.txt"),
  myStars(starName: "Gliese 667 C", imagePath: "assets/images/gliese_667_c.jpg", articlePath: "assets/text_files/star_files/gliese_667_c.txt"),
  //myStars(starName: "HD 85512", imagePath: "assets/images/hd_85512.jpg", articlePath: "assets/text_files/star_files/hd_85512.txt"),
  //myStars(starName: "LHS 475", imagePath: "assets/images/lhs_475.JPG", articlePath: "assets/text_files/star_files/lhs_475.txt"),
  //myStars(starName: "Wolf 359", imagePath: "assets/images/wolf_359.JPG", articlePath: "assets/text_files/star_files/wolf_359.txt"),
  myStars(starName: "Teegarden's Star", imagePath: "assets/images/teegardens_star.JPG", articlePath: "assets/text_files/star_files/teegardens_star.txt"),
  myStars(starName: "TRAPPIST-1", imagePath: "assets/images/trappist_1.JPG", articlePath: "assets/text_files/star_files/trappist_1.txt"),
  myStars(starName: "Gliese 12", imagePath: "assets/images/gliese_12.JPG", articlePath: "assets/text_files/star_files/gliese_12.txt"),
  myStars(starName: "HD 48948", imagePath: "assets/images/hd_48948.JPG", articlePath: "assets/text_files/star_files/hd_48948.txt"),
  myStars(starName: "LHS 1140", imagePath: "assets/images/lhs_1140.JPG", articlePath: "assets/text_files/star_files/lhs_1140.txt"),
  myStars(starName: "82 G Eridani", imagePath: "assets/images/82_g_eridani.png", articlePath: "assets/text_files/star_files/82_g_eridani.txt"),
  myStars(starName: "Ross 508", imagePath: "assets/images/ross_508.JPG", articlePath: "assets/text_files/star_files/ross_508.txt"),
  myStars(starName: "GJ 251", imagePath: "assets/images/gj_251.JPG", articlePath: "assets/text_files/star_files/gj_251.txt"),
  myStars(starName: "GJ 1002", imagePath: "assets/images/gj_1002.JPG", articlePath: "assets/text_files/star_files/gj_1002.txt"),
  myStars(starName: "GJ 1061", imagePath: "assets/images/gj_1061.JPG", articlePath: "assets/text_files/star_files/gj_1061.txt"),
  myStars(starName: "GJ 3378", imagePath: "assets/images/gj_3378.png", articlePath: "assets/text_files/star_files/gj_3378.txt")
];



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This is the root widget
  // of your application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: myNavigatorKey,
        navigatorObservers: [routesToOtherPages.myRouteObserver, myAccessCheckObserver],
        title: 'Star Expedition',
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: Colors.red,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          progressIndicatorTheme: ProgressIndicatorThemeData(
            color: Colors.red,
          ),
        ),
        localizationsDelegates: [
          FlutterQuillLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'),
        ],
        builder: (context, child){
          return ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, __) => child!,
          );
        },
        home: subscriptionGate(
          myChild: StarExpedition(),
        ),
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
          routesToOtherPages.mostTrackedStarsAndPlanetsPage: (context) => mostTrackedStarsAndPlanetsPage(),
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
  static String userProfileInUserPerspectivePage = userProfileInUserPerspectiveState.nameOfRoute;
  static String userSearchBarPage = userSearchBarPageState.nameOfRoute;
  static String nonexistentUserPage = nonexistentUser.nameOfRoute;
  static String mostTrackedStarsAndPlanetsPage = mostTrackedStarsAndPlanetsPageState.nameOfRoute;

  static final RouteObserver<ModalRoute<Object?>> myRouteObserver = RouteObserver<ModalRoute<void>>();
}

class myAppRouteObserver extends RouteObserver<PageRoute<dynamic>>{
  @override
  void didPush(Route myRoute, Route? myPreviousRoute){
    super.didPush(myRoute, myPreviousRoute);
    checkAccess();
  }

  @override
  void didPop(Route myRoute, Route? myPreviousRoute){
    super.didPop(myRoute, myPreviousRoute);
    checkAccess();
  }

  void checkAccess(){
    //Signaling the subscription gate to check access:
    myAccessCheckNotifier.value = DateTime.now();
  }
}

class accessCheckObserver extends NavigatorObserver{
  @override
  void didPush(Route myRoute, Route? myPreviousRoute){
    super.didPush(myRoute, myPreviousRoute);
    myAccessCheckNotifier.value = DateTime.now();
  }

  @override
  void didPop(Route myRoute, Route? myPreviousRoute){
    super.didPop(myRoute, myPreviousRoute);
    myAccessCheckNotifier.value = DateTime.now();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}){
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    myAccessCheckNotifier.value = DateTime.now();
  }
}

// This is the widget that will be shown
// as the homepage of your application.

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
  final starJ2000Coordinates;
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
    starJ2000Coordinates = starReference["j2000_coordinates"];
    starImageSource = starReference["image_source"];

    return [starConstellation.toString(), starDistance.toString(), starOtherNames.toString(), starSpectralClass.toString(), starAbsoluteMagnitude.toString(), starAge.toString(), starApparentMagnitude.toString(), starDiscoverer.toString(), starDiscoveryDate.toString(), starTemperature.toString(), starJ2000Coordinates.toString(), starImageSource.toString()];
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
    starJ2000Coordinates = await starReference.child("j2000_coordinates").get();
    starImageSource = await starReference.child("image_source").get();

    return [starConstellation.value.toString(), starDistance.value.toString(), starOtherNames.value.toString(), starSpectralClass.value.toString(), starAbsoluteMagnitude.value.toString(), starAge.value.toString(), starApparentMagnitude.value.toString(), starDiscoverer.value.toString(), starDiscoveryDate.value.toString(), starTemperature.value.toString(), starJ2000Coordinates.value.toString(), starImageSource.value.toString()];
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

//Getting data collection information from Firestore and then opening up a dialog:
Future<void> showMyDataCollectionDialog(BuildContext bc) async{
  //Getting the device ID and the Firestore value of dataCollectionOn:
  final myDeviceId = await dataCollectionSetting.getMyDeviceId();
  final myDoc = await FirebaseFirestore.instance.collection("Data_Collection_Settings").doc(myDeviceId).get();

  //Reading the value of dataCollectionOn from Firestore; it defaults to true when it is not there:
  final bool myCurrentSetting = myDoc.exists? (myDoc.data()!["dataCollectionOn"] as bool? ?? true) : true;

  //Variable used for selecting "Yes" or "No":
  String mySelectedValue = myCurrentSetting? "Yes" : "No";

  showDialog(
    context: bc,
    builder: (myContent) => StatefulBuilder(
      builder: (bc, setState) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("The collection of your data can be used to help improve this app. The data that will be collected is your device information, and it will not be sold to or shared with anyone. However, you are welcome to turn off this setting."),
            SizedBox(
              height: 20,
            ),
            DropdownButton<String>(
              value: mySelectedValue,
              items: [
                DropdownMenuItem(value: "Yes", child: Text("Yes")),
                DropdownMenuItem(value: "No", child: Text("No")),
              ],
              onChanged: (myNewValue){
                setState((){
                  mySelectedValue = myNewValue!;
                });
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async{
              //mySelectedValue determines whether isEnabled should be true or false:
              var isEnabled;

              if(mySelectedValue == "Yes"){
                isEnabled = true;
              }
              else{
                isEnabled = false;
              }

              //The value of isEnabled gets sent to Firestore:
              await dataCollectionSetting.setEnabled(isEnabled);

              //Dialog closes:
              Navigator.of(myContent).pop();
            },
            child: Text("Ok"),
          ),
        ],
      ),
    ),
  );
}

double rangeAverageForStars(String myValue){
  String myString = myValue.trim();

  var myLow;
  var myHigh;

  if(myString == "N/A"){
    return double.infinity;
  }

  if(myString.contains("light-years")){
    myString = myString.replaceAll("light-years", "").trim();
  }
  else if(myString.contains("K")){
    myString = myString.replaceAll("K", "").trim();
  }

  if(myString.contains('-')){
    final mySplit = myString.split('-');

    myLow = double.tryParse(mySplit[0].trim());
    myHigh = double.tryParse(mySplit[1].trim());
  }

  if(myLow != null && myHigh != null){
    return (myLow + myHigh) / 2;
  }

  return double.tryParse(myString) ?? double.infinity;
}

Future<void> addingToStarMaps() async{
  print("This is the addingToStarMaps method");

  for(var myStar in starsForSearchBar){
    String starsName = myStar.starName!;

    //print("Getting data for this star: ${starsName}");

    if(firebaseDesktopHelper.onDesktop){
      var myData = await firebaseDesktopHelper.getFirebaseData(starsName);

      //print("The star's distance in light-years: ${myData["distance"]}");
      //print("The star's temperature in Kelvin: ${myData["star_temperature"]}");

      myStarDistanceInLightYearsMap[starsName] = rangeAverageForStars(myData["distance"].toString());
      myStarTemperatureInKelvinMap[starsName] = rangeAverageForStars(myData["star_temperature"].toString());
    }
    else{
      final myRef = FirebaseDatabase.instance.ref(starsName);
      final myDistance = await myRef.child("distance").get();
      final myTemperature = await myRef.child("star_temperature").get();

      //print("The star's distance in light-years: ${myDistance.value}");
      //print("The star's temperature in Kelvin: ${myTemperature.value}");

      myStarDistanceInLightYearsMap[starsName] = rangeAverageForStars(myDistance.value.toString());
      myStarTemperatureInKelvinMap[starsName] = rangeAverageForStars(myTemperature.value.toString());
    }
  }
}

double rangeAverageForPlanets(String myValue){
  String myString = myValue.trim();

  var myLow;
  var myHigh;

  if(myString == "N/A"){
    return double.infinity;
  }

  if(myString.contains("AU")){
    myString = myString.replaceAll("AU", "").trim();
  }
  else if(myString.contains("K")){
    myString = myString.replaceAll("K", "").trim();
  }

  if(myString.contains('-')){
    final mySplit = myString.split('-');

    myLow = double.tryParse(mySplit[0].trim());
    myHigh = double.tryParse(mySplit[1].trim());
  }

  if(myLow != null && myHigh != null){
    return (myLow + myHigh) / 2;
  }

  return double.tryParse(myString) ?? double.infinity;
}

Future<void> addingToPlanetMaps() async{
  print("This is the addingToPlanetMaps method");

  var myStarName;

  for(var myPlanet in allPlanets){
    String planetsName = myPlanet;

    starsAndTheirPlanets.forEach((key, value){
      for(var v in value){
        if(v == planetsName){
          myStarName = key;
          break;
        }
        else{
          //continue
        }
      }
    });

    if(firebaseDesktopHelper.onDesktop){
      var myData = await firebaseDesktopHelper.getFirebaseData("${myStarName}/Planets/${planetsName}");

      myPlanetDistanceFromStarInAUMap[planetsName] = rangeAverageForPlanets(myData["distance_from_star"].toString());
      myPlanetTemperatureInKelvinMap[planetsName] = rangeAverageForPlanets(myData["planet_temperature"].toString());
    }
    else{
      final myRef = FirebaseDatabase.instance.ref("${myStarName}/Planets/${planetsName}");
      final myDistance = await myRef.child("distance_from_star").get();
      final myTemperature = await myRef.child("planet_temperature").get();

      myPlanetDistanceFromStarInAUMap[planetsName] = rangeAverageForPlanets(myDistance.value.toString());
      myPlanetTemperatureInKelvinMap[planetsName] = rangeAverageForPlanets(myTemperature.value.toString());
    }
  }
}

Future<String> forPdfUrls(String myPdfUrl) async{
  try{
    final myUri = Uri.parse(myPdfUrl);
    final myHost = myUri.host.replaceAll("www.", "");

    //Fetching the "parent" page, which may have a title:
    final myParentUrl = myUri.resolve("..").toString();

    if(myParentUrl != myPdfUrl){
      try{
        final myParentResponse = await http.get(Uri.parse(myParentUrl), headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'});

        if(myParentResponse.statusCode == 200){
          final myHtml = myParentResponse.body;
          final myTitleMatch = RegExp(r'<title[^>]*>(.*?)</title>', caseSensitive: false, dotAll: true).firstMatch(myHtml);

          print("The title match: ${myTitleMatch}");

          if(myTitleMatch != null){
            //Decoding HTML entities and removing whitespace:
            String myTitle = myTitleMatch.group(1)!.replaceAll('&#39;', "'").replaceAll('&amp;', '&').replaceAll('&gt;', '>').replaceAll('&lt;', '<').replaceAll('&nbsp;', ' ').replaceAll('&quot;', '"').replaceAllMapped(RegExp(r'&#(\d+);'), (myMatch){
              return String.fromCharCode(int.parse(myMatch.group(1)!));
            }).replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (myMatch){
              return String.fromCharCode(int.parse(myMatch.group(1)!, radix: 16));
            }).replaceAll("\u201C", '"').replaceAll("\u201D", '"').replaceAll("\u2018", "'").replaceAll("\u2019", "'").trim();

            //Making all separators of website names and article names become ':':
            myTitle = myTitle.replaceAll(' | ', ': ');

            myTitle = myNewTitle(myTitle);

            print("Title: ${myTitle}");

            return myTitle;
          }
        }
      }
      catch (e){
        print("The fetching of the parent page has failed. Here is the error: ${e}");
      }
    }
    //Ignoring generic file names:
    const genericFileNames = ["document", "download", "file", "FULLTEXT01", "fulltext01", "FullText01", "paper"];

    final myFilteredSegments = myUri.pathSegments.reversed.where((mySegment) =>
    mySegment.isNotEmpty && !genericFileNames.any((file) => mySegment.toLowerCase().contains(file.toLowerCase())) && !RegExp(r'^[a-z]+\d*:\d+$').hasMatch(mySegment)).map((mySegment) =>
        mySegment.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '').replaceAll('-', ' ').replaceAll('_', ' ')).toList();

    final myImportantSegment = myFilteredSegments.isNotEmpty? myFilteredSegments.first : null;

    if(myImportantSegment != null && myImportantSegment.length > 3){
      return "${myHost}: ${myImportantSegment}";
    }

    //If nothing notable is found, just return the domain:
    return myHost;
  }
  catch (e){
    print("Unfortunately, there was an error: ${e}");
    return myPdfUrl;
  }
}

//Method to only replace the last instance of a ' - ' and any instance of a ' | ' in an article link:
String myNewTitle(String myTitle){
  //Replacing all instances of ' | ' with ': ':
  myTitle = myTitle.replaceAll(' | ', ': ');

  return myTitle;
}

Future<String> getTitleOfPage(String myUrl) async{
  //For arxiv.org PDFs:
  if(myUrl.contains("arxiv.org/pdf/")){
    myUrl = myUrl.replaceAll("arxiv.org/pdf/", "arxiv.org/abs/").replaceAll(".pdf", "");
  }

  try{
    //Doing a HEAD request to check the content type:
    final myHeadResponse = await http.head(Uri.parse(myUrl), headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'});

    final myContentType = myHeadResponse.headers["content-type"] ?? "";

    if(myContentType.contains("application/pdf") || myUrl.endsWith(".pdf")){
      print("A PDF has been detected: ${myUrl}");
      return await forPdfUrls(myUrl);
    }

    final myResponse = await http.get(Uri.parse(myUrl), headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'});

    if(myResponse.statusCode == 200){
      final myHtml = myResponse.body;
      final myTitleMatch = RegExp(r'<title[^>]*>(.*?)</title>', caseSensitive: false, dotAll: true).firstMatch(myHtml);

      print("The title match: ${myTitleMatch}");

      if(myTitleMatch != null){
        //Decoding HTML entities and removing whitespace:
        String myTitle = myTitleMatch.group(1)!.replaceAll('&#39;', "'").replaceAll('&amp;', '&').replaceAll('&gt;', '>').replaceAll('&lt;', '<').replaceAll('&nbsp;', ' ').replaceAll('&quot;', '"').replaceAllMapped(RegExp(r'&#(\d+);'), (myMatch){
          return String.fromCharCode(int.parse(myMatch.group(1)!));
        }).replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (myMatch){
          return String.fromCharCode(int.parse(myMatch.group(1)!, radix: 16));
        }).replaceAll("\u201C", '"').replaceAll("\u201D", '"').replaceAll("\u2018", "'").replaceAll("\u2019", "'").trim();

        //Making all separators of website names and article names become ':':
        myTitle = myTitle.replaceAll(' | ', ': ');

        myTitle = myNewTitle(myTitle);

        print("Title: ${myTitle}; URL: ${myUrl}");

        return myTitle;
      }
      else{
        print("Unfortunately, there is no title found for ${myUrl}");
      }
    }
    else{
      print("This is the status code for ${myUrl}: ${myResponse.statusCode}");
    }
  }
  catch (e){
    print("Unfortunately, there was an error trying to get the title of the website. Here is the error: ${e}");
  }

  print("Falling back to this URL: ${myUrl}");

  return myUrl;
}

class theStarExpeditionState extends State<StarExpedition> with RouteAware{
  static String nameOfRoute = '/StarExpedition';
  List<String> starInfo = [];
  theStarExpeditionState(this.starInfo);
  final CustomSearchDelegate csd = new CustomSearchDelegate();

  final theTrialService myTrialService = theTrialService();

  bool featuredStarOfTheDayNavigationThroughImage = false;
  bool featuredStarOfTheDayNavigationThroughText = false;
  bool searchButtonBool = false;

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await addingToStarMaps();

      if(!mounted){
        print("The widget was unmounted");
        return;
      }

      await addingToPlanetMaps();

      if(!mounted){
        print("The widget was unmounted");
        return;
      }

      showTrialDialog();
    });
  }

  Future<void> showTrialDialog() async{
    final myDays = await myTrialService.daysLeftOfTrial();

    if(!mounted){
      print("The widget was unmounted");
      return;
    }

    if(myDays <= 0){
      return;
    }

    //Check if the trial dialog has already been shown today:
    final myPrefs = await SharedPreferences.getInstance();

    if(!mounted){
      print("The widget was unmounted");
      return;
    }

    final lastShown = myPrefs.getString("freeTrialDialogLastShown");
    final todaysDate = DateTime.now().toIso8601String().substring(0, 10);

    //If the trial dialog has already been shown today:
    if(lastShown == todaysDate){
      return;
    }

    //Saving today's date:
    await myPrefs.setString("freeTrialDialogLastShown", todaysDate);

    if(!mounted){
      print("The widget was unmounted");
      return;
    }

    //The trial dialog:
    showDialog(
      context: context,
      builder: (BuildContext bc){
        return AlertDialog(
          title: Text("Your Free Trial"),
          content: Text("You have ${myDays} days left in your free trial.\nAfter your free trial ends, you will need to subscribe to continue using Star Expedition."),
          actions: [
            TextButton(
              onPressed: () => {
                Navigator.of(bc).pop(),
              },
              child: Text("Ok"),
            ),
          ],
        );
      }
    );
  }

  //Lifecycle methods (didChangeDependencies() and dispose()):
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    routesToOtherPages.myRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose(){
    routesToOtherPages.myRouteObserver.unsubscribe(this);
    super.dispose();
  }

  //RouteAware methods (didPopNext() and didPush()):
  @override
  void didPopNext(){
    //Called when returning to this page:
    myAccessCheckNotifier.value = DateTime.now();
  }

  @override
  void didPush(){
    //Called when the page is pushed:
    myAccessCheckNotifier.value = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final myLoginStatus = context.watch<loginStatus>();

    print("discussionBoardLogin: ${discussionBoardLogin}");
    final dateForUse = DateTime(2020, 1, 1);
    DateTime? timeNow = DateTime.now();
    int numberOfDays = daysSinceJanOneTwenty(dateForUse, timeNow);
    print(numberOfDays.toString());
    int numberOfStars = starsForSearchBar.length;
    int randomNumber = numberOfDays % numberOfStars;
    //Maybe you can make an if statement that ensures that today's star name and image are not the same as yesterday's.
    print(timeNow);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Star Expedition",
        ),
        actions: [
          AbsorbPointer(
            absorbing: searchButtonBool,
            child: IconButton(
              onPressed: () async{
                if(searchButtonBool){
                  return;
                }

                setState(() => searchButtonBool = true);

                //Method to show the search bar

                //Other star names
                otherNamesMap = await getOtherNames();
                alternateNames = otherNamesMap.values;
                print(alternateNames);

                myAccessCheckNotifier.value = DateTime.now();

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
                                myAccessCheckNotifier.value = DateTime.now();
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
                                myAccessCheckNotifier.value = DateTime.now();
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
                if(mounted){
                  setState(() => searchButtonBool = false);
                }
              },
              icon: const Icon(Icons.search),
            ),
          ),
        ],
      ),
      body: Wrap(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            alignment: Alignment.topCenter,
            child: const Text('Welcome to Star Expedition!', style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold)), //fontFamily: 'Raleway'
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015625),
            child: Text('Star Expedition is an app that allows its users to view and research stars and planets that are potentially capable of supporting life outside our Solar System. Star Expedition will include stars whose spectral classes range from M8 to A5, are within 100 light-years from Earth, and have confirmed terrestrial planets in their habitable zones and planets that are terrestrial and in the habitable zones of their respective stars. Currently, Star Expedition features ${allStars.length} stars and ${allPlanets.length} planets.\n', style: TextStyle(color: Colors.black, fontFamily: 'Raleway'), textAlign: TextAlign.center),
          ),
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
            child: AbsorbPointer(
                absorbing: featuredStarOfTheDayNavigationThroughImage,
                child: InkWell(
                    child: Ink.image(
                      image: AssetImage(starsForSearchBar[randomNumber].imagePath!),
                      fit: BoxFit.cover,
                      height: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.height * 0.25 : 150,
                      width: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.height * 0.25 : 150,
                    ),
                    onTap: () async{
                      if(featuredStarOfTheDayNavigationThroughImage){
                        return;
                      }

                      setState(() => featuredStarOfTheDayNavigationThroughImage = true);

                      correctStar = starsForSearchBar[randomNumber].starName!;
                      starInfo = await getStarInformation();
                      featuredStarOfTheDayBool = true;
                      starFileContent = await readStarFile();

                      listOfStarUrls = [];

                      final myLines = starFileContent.replaceAll("\r\n", "\n").replaceAll("\r", "\n").split("\n").where((s) => s.isNotEmpty && s != " ").toList();

                      Map<int, String> myTitles = {};

                      for(int i = 0; i < myLines.length; i++){
                        if(myLines[i].contains("||")){
                          final parts = myLines[i].split("||");
                          listOfStarUrls.add(parts[0].trim());
                          myTitles[i] = parts[1].trim();
                        }
                        else{
                          listOfStarUrls.add(myLines[i]);
                        }
                      }

                      urlTitlesForStars = await Future.wait(List.generate(listOfStarUrls.length, (i){
                          if(myTitles.containsKey(i)){
                            return Future.value(myTitles[i]);
                          }
                          return getTitleOfPage(listOfStarUrls[i]);
                        })
                      );

                      //Is the star tracked by a user?
                      if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                        if(firebaseDesktopHelper.onDesktop){
                          var userNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                          var usersDoc = userNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                          //Getting the current profile info of the user:
                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(usersDoc["usernameProfileInformation"] ?? {});
                          starTracked = currentInfoOfUser["starsTracked"].containsKey(correctStar);
                          print("starTracked: ${starTracked}");
                        }
                        else{
                          var theUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                          var docNameForUsers;
                          theUser.docs.forEach((result){
                            docNameForUsers = result.id;
                          });

                          DocumentSnapshot<Map<dynamic, dynamic>> snapshotUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForUsers).get();
                          Map<dynamic, dynamic>? individual = snapshotUsers.data();

                          starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(correctStar);
                          print("starTracked: ${starTracked}");
                        }
                      }

                      myAccessCheckNotifier.value = DateTime.now();
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => articlePage(starInfo), settings: RouteSettings(arguments: starsForSearchBar[randomNumber])));

                      if(starInfo.length == 0){
                        print("Sorry; the length is 0");
                      }
                      else{
                        print(starInfo);
                      }

                      if(mounted){
                        setState(() => featuredStarOfTheDayNavigationThroughImage = false);
                      }
                    }
                ),
              ),
            ),
          Center(
            child: AbsorbPointer(
              absorbing: featuredStarOfTheDayNavigationThroughText,
              child: GestureDetector(
                child: Container(
                  child: Text(starsForSearchBar[randomNumber].starName!, style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)),
                ),
                onTap: () async{
                  if(featuredStarOfTheDayNavigationThroughText){
                    return;
                  }

                  setState(() => featuredStarOfTheDayNavigationThroughText = true);

                  correctStar = starsForSearchBar[randomNumber].starName!;
                  starInfo = await getStarInformation();
                  featuredStarOfTheDayBool = true;
                  starFileContent = await readStarFile();

                  listOfStarUrls = [];

                  final myLines = starFileContent.replaceAll("\r\n", "\n").replaceAll("\r", "\n").split("\n").where((s) => s.isNotEmpty && s != " ").toList();

                  Map<int, String> myTitles = {};

                  for(int i = 0; i < myLines.length; i++){
                    if(myLines[i].contains("||")){
                      final parts = myLines[i].split("||");
                      listOfStarUrls.add(parts[0].trim());
                      myTitles[i] = parts[1].trim();
                    }
                    else{
                      listOfStarUrls.add(myLines[i]);
                    }
                  }

                  urlTitlesForStars = await Future.wait(List.generate(listOfStarUrls.length, (i){
                      if(myTitles.containsKey(i)){
                        return Future.value(myTitles[i]);
                      }
                      return getTitleOfPage(listOfStarUrls[i]);
                    })
                  );

                  //Is the star tracked by a user?
                  if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                    if(firebaseDesktopHelper.onDesktop){
                      var userNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                      var usersDoc = userNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                      //Getting the current profile info of the user:
                      Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(usersDoc["usernameProfileInformation"] ?? {});
                      starTracked = currentInfoOfUser["starsTracked"].containsKey(correctStar);
                      print("starTracked: ${starTracked}");
                    }
                    else{
                      var theUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                      var docNameForUsers;
                      theUser.docs.forEach((result){
                        docNameForUsers = result.id;
                      });

                      DocumentSnapshot<Map<dynamic, dynamic>> snapshotUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForUsers).get();
                      Map<dynamic, dynamic>? individual = snapshotUsers.data();

                      starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(correctStar);
                      print("starTracked: ${starTracked}");
                    }
                  }

                  myAccessCheckNotifier.value = DateTime.now();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => articlePage(starInfo), settings: RouteSettings(arguments: starsForSearchBar[randomNumber])));

                  if(starInfo.length == 0){
                    print("Sorry; the length is 0");
                  }
                  else{
                    print(starInfo);
                  }

                  if(mounted){
                    setState(() => featuredStarOfTheDayNavigationThroughText = false);
                  }
                }
              ),
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
  static final ValueNotifier<bool> clickingBool = ValueNotifier(false);

  @override
  Widget build(BuildContext context){
    final myLoginStatus = context.watch<loginStatus>();

    print("Checking the navigation drawer. isLoggedIn: ${myLoginStatus.userIsLoggedIn}, username: ${myLoginStatus.myUsername}");

    return Drawer(
        child: ListView(
            padding: EdgeInsets.zero,
            children: [
              if(myLoginStatus.userIsLoggedIn == false && myLoginStatus.myUsername == "")
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.red),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text("Star Expedition Navigation Menu", style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: "Railway")),
                  ),
                ),
              if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != "")
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.red),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text("Star Expedition Navigation Menu\n\nHi ${myLoginStatus.myUsername}", style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: "Railway")),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: clickingBool,
                  builder: (context, isClicking, child){
                    return AbsorbPointer(
                      absorbing: isClicking,
                      child: ListTile(
                        title: (myLoginStatus.userIsLoggedIn == false && myLoginStatus.myUsername == "")? Text("Login") : Text("Logout"),
                        onTap: (){
                          if(clickingBool.value){
                            return;
                          }

                          clickingBool.value = true;

                          if(myLoginStatus.userIsLoggedIn == false && myLoginStatus.myUsername == "") {
                            discussionBoardLogin = false;
                            Navigator.pushReplacementNamed(context, routesToOtherPages.theLoginPage);
                          }
                          else if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                            //myUsername = "";
                            //myNewUsername = "";
                            theLoginPage.loginBool = false;
                            discussionBoardLogin = false;
                            registerBool = false;
                            context.read<loginStatus>().loggingOut();
                            print("Logging out from already existing account");
                            Navigator.pushReplacementNamed(context, loginPageRoutes.homePage);
                          }
                          clickingBool.value = false;
                        }
                      ),
                    );
                  }
                ),
              if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != "")
                ValueListenableBuilder<bool>(
                  valueListenable: clickingBool,
                  builder: (context, isClicking, child){
                    return AbsorbPointer(
                      absorbing: isClicking,
                        child: ListTile(
                          title: Text("My Profile"),
                          onTap: () async{
                            if(clickingBool.value){
                              return;
                            }

                            clickingBool.value = true;

                            if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                              theUsernameResult = myLoginStatus.myUsername;
                              if(firebaseDesktopHelper.onDesktop){
                                List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");

                                var myCorrectUser = everyUser.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});
                                var getUserProfileInformationAttribute = myCorrectUser["usernameProfileInformation"];

                                usersBlurb = getUserProfileInformationAttribute["userInformation"];
                                usersInterests = getUserProfileInformationAttribute["userInterests"];
                                usersLocation = getUserProfileInformationAttribute["userLocation"];
                                numberOfPostsUserHasMade = getUserProfileInformationAttribute["numberOfPosts"];
                                starsUserTracked = getUserProfileInformationAttribute["starsTracked"];
                                planetsUserTracked = getUserProfileInformationAttribute["planetsTracked"];

                                print("Desktop usersBlurb: ${usersBlurb}");
                                print("Desktop usersInterests: ${usersInterests}");
                                print("Desktop usersLocation: ${usersLocation}");
                                print("Desktop numberOfPostsUserHasMade: ${numberOfPostsUserHasMade}");
                                print("Desktop starsUserTracked: ${starsUserTracked}");
                                print("Desktop planetsUserTracked: ${planetsUserTracked}");
                              }
                              else{
                                await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get().then((result){
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
                              userForLoadingProfilePictureInUsersPerspective = theUsernameResult;
                              Navigator.pushReplacementNamed(context, routesToOtherPages.userProfileInUserPerspectivePage);
                            }
                            clickingBool.value = false;
                          }
                        )
                      );
                    }
                  ),
              if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != "")
                ValueListenableBuilder<bool>(
                  valueListenable: clickingBool,
                  builder: (context, isClicking, child){
                    return AbsorbPointer(
                      absorbing: isClicking,
                      child: ListTile(
                        title: Text("Settings"),
                        onTap: () {
                          if(clickingBool.value){
                            return;
                          }

                          clickingBool.value = true;

                          Navigator.pushReplacementNamed(context, routesToOtherPages.settingsPage);

                          clickingBool.value = false;
                        }
                      ),
                    );
                  }
                ),
              ValueListenableBuilder<bool>(
                valueListenable: clickingBool,
                builder: (context, isClicking, child){
                  return AbsorbPointer(
                    absorbing: isClicking,
                    child: ListTile(
                      title: Text("Home"),
                      onTap: (){
                        if(clickingBool.value){
                          return;
                        }

                        clickingBool.value = true;

                        discussionBoardLogin = false;
                        Navigator.pushReplacementNamed(context, routesToOtherPages.homePage);

                        clickingBool.value = false;
                      }
                    ),
                  );
                }
              ),
              ValueListenableBuilder<bool>(
                valueListenable: clickingBool,
                builder: (context, isClicking, child){
                  return AbsorbPointer(
                    absorbing: isClicking,
                    child: ListTile(
                      title: Text("Why Star Expedition Was Made"),
                      onTap: () {
                        if(clickingBool.value){
                          return;
                        }

                        clickingBool.value = true;

                        discussionBoardLogin = false;
                        Navigator.pushReplacementNamed(context, routesToOtherPages.whyMade);
                        //throw Exception("Testing the error");

                        clickingBool.value = false;
                      }
                    ),
                  );
                }
              ),
              ValueListenableBuilder<bool>(
                valueListenable: clickingBool,
                builder: (context, isClicking, child){
                  return AbsorbPointer(
                    absorbing: isClicking,
                    child: ListTile(
                      title: Text("Information about the Spectral Classes of Stars"),
                      onTap: () {
                        if(clickingBool.value){
                          return;
                        }

                        clickingBool.value = true;

                        discussionBoardLogin = false;
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => spectralClassPage()));
                        Navigator.pushReplacementNamed(context, routesToOtherPages.spectralClass);

                        clickingBool.value = false;
                      }
                    ),
                  );
                }
              ),
              ValueListenableBuilder<bool>(
                valueListenable: clickingBool,
                builder: (context, isClicking, child){
                  return AbsorbPointer(
                    absorbing: isClicking,
                    child: ListTile(
                        title: Text("Most Tracked Stars and Planets"),
                        onTap: () async {
                          if(clickingBool.value){
                            return;
                          }

                          clickingBool.value = true;

                          discussionBoardLogin = false;
                          starsUsersTracked = [];
                          planetsUsersTracked = [];
                          if(firebaseDesktopHelper.onDesktop){
                            var myUsersDocs = await firebaseDesktopHelper.getFirestoreCollection("User");
                            for(int user = 0; user < myUsersDocs.length; user++){
                              if(myUsersDocs[user]["usernameProfileInformation"]["starsTracked"] != {}){
                                for(int myStar = 0; myStar < myUsersDocs[user]["usernameProfileInformation"]["starsTracked"].keys.length; myStar++){
                                  starsUsersTracked.add(myUsersDocs[user]["usernameProfileInformation"]["starsTracked"].keys.elementAt(myStar));
                                }
                              }

                              if(myUsersDocs[user]["usernameProfileInformation"]["planetsTracked"] != {}){
                                for(int myPlanet = 0; myPlanet < myUsersDocs[user]["usernameProfileInformation"]["planetsTracked"].keys.length; myPlanet++){
                                  planetsUsersTracked.add(myUsersDocs[user]["usernameProfileInformation"]["planetsTracked"].keys.elementAt(myPlanet));
                                }
                              }
                            }
                            print("Stars users tracked: ${starsUsersTracked}");
                            print("Planets users tracked: ${planetsUsersTracked}");

                            for(var s in allStars){
                              starsAndAmountOfTracks[s] = (starsUsersTracked.where((myElement) => myElement == s).length).toString();
                            }
                            for(var p in allPlanets){
                              planetsAndAmountOfTracks[p] = (planetsUsersTracked.where((myElement) => myElement == p).length).toString();
                            }

                            print("starsAndAmountOfTracks: ${starsAndAmountOfTracks}");
                            print("planetsAndAmountOfTracks: ${planetsAndAmountOfTracks}");
                          }
                          else{
                            await FirebaseFirestore.instance.collection("User").get().then((qSnapshot){
                              for(var user in qSnapshot.docs){
                                print("user: ${user.data()}");
                                print("user.data()[usernameProfileInformation][starsTracked]: ${user.data()["usernameProfileInformation"]["starsTracked"]}");
                                if(user.data()["usernameProfileInformation"]["starsTracked"] != {}){
                                  for(int myStar = 0; myStar < user.data()["usernameProfileInformation"]["starsTracked"].keys.length; myStar++){
                                    starsUsersTracked.add(user.data()["usernameProfileInformation"]["starsTracked"].keys.elementAt(myStar));
                                  }
                                }

                                if(user.data()["usernameProfileInformation"]["planetsTracked"] != {}){
                                  for(int myPlanet = 0; myPlanet < user.data()["usernameProfileInformation"]["planetsTracked"].keys.length; myPlanet++){
                                    planetsUsersTracked.add(user.data()["usernameProfileInformation"]["planetsTracked"].keys.elementAt(myPlanet));
                                  }
                                }
                              }
                            });
                            print("Stars users tracked: ${starsUsersTracked}");
                            print("Planets users tracked: ${planetsUsersTracked}");

                            for(var s in allStars){
                              starsAndAmountOfTracks[s] = (starsUsersTracked.where((myElement) => myElement == s).length).toString();
                            }
                            for(var p in allPlanets){
                              planetsAndAmountOfTracks[p] = (planetsUsersTracked.where((myElement) => myElement == p).length).toString();
                            }

                            print("starsAndAmountOfTracks: ${starsAndAmountOfTracks}");
                            print("planetsAndAmountOfTracks: ${planetsAndAmountOfTracks}");
                          }

                          Navigator.pushReplacementNamed(context, routesToOtherPages.mostTrackedStarsAndPlanetsPage);
                          clickingBool.value = false;
                        }
                    )
                  );
                }
              ),
              ValueListenableBuilder<bool>(
                valueListenable: clickingBool,
                builder: (context, isClicking, child){
                  return AbsorbPointer(
                    absorbing: isClicking,
                    child: ListTile(
                      title: Text("Discussion Board"),
                      onTap: () {
                        if(clickingBool.value){
                          return;
                        }

                        clickingBool.value = true;

                        discussionBoardLogin = true;
                        if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                          Navigator.pushReplacementNamed(context, routesToOtherPages.discussionBoard);
                        }
                        else{
                          Navigator.pushReplacementNamed(context, routesToOtherPages.theLoginPage);
                        }

                        clickingBool.value = false;
                      }
                    )
                  );
                }
              ),
              ValueListenableBuilder<bool>(
                valueListenable: clickingBool,
                builder: (context, isClicking, child){
                  return AbsorbPointer(
                    absorbing: isClicking,
                    child: ListTile(
                      title: Text("Conversion Calculator"),
                      onTap: (){
                        if(clickingBool.value){
                          return;
                        }

                        clickingBool.value = true;

                        discussionBoardLogin = false;
                        Navigator.pushReplacementNamed(context, routesToOtherPages.conversionCalculator);

                        clickingBool.value = false;
                      }
                    ),
                  );
                }
              ),
              ValueListenableBuilder<bool>(
                valueListenable: clickingBool,
                builder: (context, isClicking, child){
                  return AbsorbPointer(
                    absorbing: isClicking,
                    child: ListTile(
                      title: Text("User Search"),
                      onTap: () async{
                        if(clickingBool.value){
                          return;
                        }

                        clickingBool.value = true;

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
                        clickingBool.value = false;
                      }
                    ),
                  );
                }
              ),
              ValueListenableBuilder<bool>(
                valueListenable: clickingBool,
                builder: (context, isClicking, child){
                  return AbsorbPointer(
                    absorbing: isClicking,
                    child: ListTile(
                      title: Text("Data Collection Settings"),
                      onTap: () async{
                        if(clickingBool.value){
                          return;
                        }

                        clickingBool.value = true;

                        await showMyDataCollectionDialog(context);

                        clickingBool.value = false;
                      }
                    ),
                  );
                }
              ),
            ]
        )
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  List<String> starInfo = [];
  final ScrollController myScrollController = ScrollController();

  final ValueNotifier<myStarSortingCriteria> myStarSortingCriteriaNotifier = ValueNotifier(myStarSortingCriteria.alphabeticalAToZ);

  ValueNotifier<bool> starSearchBool = ValueNotifier(false);

  void mySortMatchQuery(List<myStars> myMatchQuery){
    switch(myStarSortingCriteriaNotifier.value){
      case myStarSortingCriteria.alphabeticalAToZ:
        myMatchQuery.sort((a, b) => a.starName!.compareTo(b.starName!));
        break;
      case myStarSortingCriteria.alphabeticalZToA:
        myMatchQuery.sort((a, b) => b.starName!.compareTo(a.starName!));
        break;
      case myStarSortingCriteria.distanceClosestToFurthest:
        myMatchQuery.sort((a, b) => (myStarDistanceInLightYearsMap[a.starName!] ?? double.infinity).compareTo(myStarDistanceInLightYearsMap[b.starName!] ?? double.infinity));
        break;
      case myStarSortingCriteria.distanceFurthestToClosest:
        myMatchQuery.sort((a, b) => (myStarDistanceInLightYearsMap[b.starName!] ?? double.infinity).compareTo(myStarDistanceInLightYearsMap[a.starName!] ?? double.infinity));
        break;
      case myStarSortingCriteria.temperatureCoolestToHottest:
        myMatchQuery.sort((a, b) => (myStarTemperatureInKelvinMap[a.starName!] ?? double.infinity).compareTo(myStarTemperatureInKelvinMap[b.starName!] ?? double.infinity));
        break;
      case myStarSortingCriteria.temperatureHottestToCoolest:
        myMatchQuery.sort((a, b) => (myStarTemperatureInKelvinMap[b.starName!] ?? double.infinity).compareTo(myStarTemperatureInKelvinMap[a.starName!] ?? double.infinity));
        break;
    }
  }

  @override
  TextInputAction get textInputAction => TextInputAction.search;

  // This is the first overwrite (to clear the search text)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.sort),
        tooltip: "Sort star by",
        onPressed: (){
          //Temporary variable to hold a user's selection inside the dialog:
          myStarSortingCriteria myTemporaryCriteria = myStarSortingCriteriaNotifier.value;

          showDialog(
            context: context,
            builder: (BuildContext bc){
              return StatefulBuilder(
                builder: (context, setDialogState){
                  return AlertDialog(
                    title: Text("Sort stars by"),
                    content: DropdownButtonHideUnderline(
                      child: DropdownButton<myStarSortingCriteria>(
                        value: myTemporaryCriteria,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: myStarSortingCriteria.alphabeticalAToZ,
                            child: Text("Alphabetical A to Z (default)"),
                          ),
                          DropdownMenuItem(
                            value: myStarSortingCriteria.alphabeticalZToA,
                            child: Text("Alphabetical Z to A"),
                          ),
                          DropdownMenuItem(
                            value: myStarSortingCriteria.distanceClosestToFurthest,
                            child: Text("Distance (from closest to furthest in light-years)"),
                          ),
                          DropdownMenuItem(
                            value: myStarSortingCriteria.distanceFurthestToClosest,
                            child: Text("Distance (from furthest to closest in light-years)"),
                          ),
                          DropdownMenuItem(
                            value: myStarSortingCriteria.temperatureCoolestToHottest,
                            child: Text("Temperature (from coolest to hottest in Kelvin)"),
                          ),
                          DropdownMenuItem(
                            value: myStarSortingCriteria.temperatureHottestToCoolest,
                            child: Text("Temperature (from hottest to coolest in Kelvin)"),
                          ),
                        ],
                        onChanged: (myValue){
                          if(myValue != null){
                            setDialogState(() => myTemporaryCriteria = myValue);
                          }
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: (){
                          myStarSortingCriteriaNotifier.value = myTemporaryCriteria;
                          query = query;
                          Navigator.of(bc).pop();
                        },
                        child: Text("Ok"),
                      ),
                    ],
                  );
                }
              );
            }
          );
        }
      ),
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
    return ValueListenableBuilder<myStarSortingCriteria>(
      valueListenable: myStarSortingCriteriaNotifier,
      builder: (context, mySortingCriteria, _){
        List<myStars> myMatchQuery = [];

        if(!myScrollController.hasListeners){
          myScrollController.addListener((){
            SystemChannels.textInput.invokeMethod("TextInput.hide");
          });
        }

        SystemChannels.textInput.invokeMethod("TextInput.hide");

        WidgetsBinding.instance.addPostFrameCallback((_){
          SystemChannels.textInput.invokeMethod("TextInput.hide");
          FocusScope.of(context).requestFocus(FocusNode());}
        );

        Future.delayed(Duration(milliseconds: 50), (){
          SystemChannels.textInput.invokeMethod("TextInput.hide");
        });

        Future.delayed(Duration(milliseconds: 100), (){
          SystemChannels.textInput.invokeMethod("TextInput.hide");
        });

        Future.delayed(Duration(milliseconds: 250), (){
          SystemChannels.textInput.invokeMethod("TextInput.hide");
        });

        Future.delayed(Duration(milliseconds: 500), (){
          SystemChannels.textInput.invokeMethod("TextInput.hide");
        });

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

        mySortMatchQuery(myMatchQuery);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (){
            SystemChannels.textInput.invokeMethod("TextInput.hide");
          },
          onPanDown: (_){
            SystemChannels.textInput.invokeMethod("TextInput.hide");
          },
          child: ListView.builder(
            controller: myScrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: myMatchQuery.length,
            itemBuilder: (context, index) {
              var result = myMatchQuery[index]; //If user enters in a key, the result is the key.
              return ListTile(
                title: Text(result.starName!), // The ! is there so that it can prevent errors, especially for variables that are set to null
              );
            },
          ),
        );
      },
    );
  }

  // This is the last overwrite (to show the querying process at the runtime)
  @override
  Widget buildSuggestions(BuildContext context) {
    final myLoginStatus = context.watch<loginStatus>();
    return ValueListenableBuilder<myStarSortingCriteria>(
      valueListenable: myStarSortingCriteriaNotifier,
      builder: (context, mySortingCriteria, _){
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

        mySortMatchQuery(myMatchQuery);

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: myMatchQuery.length,
            itemBuilder: (context, index) {
              return ValueListenableBuilder<bool>(
                valueListenable: starSearchBool,
                builder: (context, searchingForStar, child){
                  return AbsorbPointer(
                    absorbing: searchingForStar,
                    child: ListTile(
                    title: Text(myMatchQuery[index].starName!,
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'Raleway')),
                    onTap: () async{
                      if(starSearchBool.value){
                        return;
                      }

                      starSearchBool.value = true;

                      FocusScope.of(context).unfocus();

                      correctStar = myMatchQuery[index].starName!; //otherNamesMatchQuery.keys.elementAt(index).starName!;
                      print(correctStar);
                      starInfo = await getStarInformation();
                      starFileContent = await readStarFile();

                      listOfStarUrls = [];

                      final myLines = starFileContent.replaceAll("\r\n", "\n").replaceAll("\r", "\n").split("\n").where((s) => s.isNotEmpty && s != " ").toList();

                      Map<int, String> myTitles = {};

                      for(int i = 0; i < myLines.length; i++){
                        if(myLines[i].contains("||")){
                          final parts = myLines[i].split("||");
                          listOfStarUrls.add(parts[0].trim());
                          myTitles[i] = parts[1].trim();
                        }
                        else{
                          listOfStarUrls.add(myLines[i]);
                        }
                      }

                      urlTitlesForStars = await Future.wait(List.generate(listOfStarUrls.length, (i){
                          if(myTitles.containsKey(i)){
                            return Future.value(myTitles[i]);
                          }
                          return getTitleOfPage(listOfStarUrls[i]);
                        })
                      );

                      if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                        if(firebaseDesktopHelper.onDesktop){
                          var userNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                          var usersDoc = userNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                          //Getting the current profile info of the user:
                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(usersDoc["usernameProfileInformation"] ?? {});
                          starTracked = currentInfoOfUser["starsTracked"].containsKey(myMatchQuery[index].starName!);
                          print("starTracked: ${starTracked}");
                        }
                        else{
                          var theUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                          var docNameForUsers;
                          theUser.docs.forEach((result){
                            docNameForUsers = result.id;
                          });

                          DocumentSnapshot<Map<dynamic, dynamic>> snapshotUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForUsers).get();
                          Map<dynamic, dynamic>? individual = snapshotUsers.data();

                          starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(myMatchQuery[index].starName!);
                          print("starTracked: ${starTracked}");
                        }
                      }

                      myAccessCheckNotifier.value = DateTime.now();

                      if(!context.mounted){
                        return;
                      }

                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => articlePage(starInfo), settings: RouteSettings(arguments: myMatchQuery[index])));
                      starSearchBool.value = false;
                    },
                    leading: Image.asset(myMatchQuery[index].imagePath!, fit: BoxFit.cover, height: 50, width: 50),
                  ),
                );
              },
            );
          }
          ),
        );
      },
    );
  }
}

class CustomSearchDelegateForPlanets extends SearchDelegate{
  List<String> planetInfo = [];
  final ScrollController myScrollController = ScrollController();

  final ValueNotifier<myPlanetSortingCriteria> myPlanetSortingCriteriaNotifier = ValueNotifier(myPlanetSortingCriteria.alphabeticalAToZ);

  ValueNotifier<bool> planetSearchBool = ValueNotifier(false);

  void mySortMatchQuery(List<myStars> myPlanetMatchQuery){
    switch(myPlanetSortingCriteriaNotifier.value){
      case myPlanetSortingCriteria.alphabeticalAToZ:
        myPlanetMatchQuery.sort((a, b) => a.starName!.compareTo(b.starName!));
        break;
      case myPlanetSortingCriteria.alphabeticalZToA:
        myPlanetMatchQuery.sort((a, b) => b.starName!.compareTo(a.starName!));
        break;
      case myPlanetSortingCriteria.distanceClosestToFurthest:
        myPlanetMatchQuery.sort((a, b) => (myPlanetDistanceFromStarInAUMap[a.starName!] ?? double.infinity).compareTo(myPlanetDistanceFromStarInAUMap[b.starName!] ?? double.infinity));
        break;
      case myPlanetSortingCriteria.distanceFurthestToClosest:
        myPlanetMatchQuery.sort((a, b) => (myPlanetDistanceFromStarInAUMap[b.starName!] ?? double.infinity).compareTo(myPlanetDistanceFromStarInAUMap[a.starName!] ?? double.infinity));
        break;
      case myPlanetSortingCriteria.temperatureCoolestToHottest:
        myPlanetMatchQuery.sort((a, b) => (myPlanetTemperatureInKelvinMap[a.starName!] ?? double.infinity).compareTo(myPlanetTemperatureInKelvinMap[b.starName!] ?? double.infinity));
        break;
      case myPlanetSortingCriteria.temperatureHottestToCoolest:
        myPlanetMatchQuery.sort((a, b) => (myPlanetTemperatureInKelvinMap[b.starName!] ?? double.infinity).compareTo(myPlanetTemperatureInKelvinMap[a.starName!] ?? double.infinity));
        break;
    }
  }

  @override
  TextInputAction get textInputAction => TextInputAction.search;

  // This is the first overwrite (to clear the search text)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.sort),
        tooltip: "Sort planet by",
        onPressed: (){
          //Temporary variable to hold a user's selection inside the dialog:
          myPlanetSortingCriteria myTemporaryCriteria = myPlanetSortingCriteriaNotifier.value;

          showDialog(
            context: context,
            builder: (BuildContext bc){
              return StatefulBuilder(
                builder: (context, setDialogState){
                  return AlertDialog(
                    title: Text("Sort planets by"),
                    content: DropdownButtonHideUnderline(
                      child: DropdownButton<myPlanetSortingCriteria>(
                        value: myTemporaryCriteria,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: myPlanetSortingCriteria.alphabeticalAToZ,
                            child: Text("Alphabetical from A to Z (default)"),
                          ),
                          DropdownMenuItem(
                            value: myPlanetSortingCriteria.alphabeticalZToA,
                            child: Text("Alphabetical from Z to A"),
                          ),
                          DropdownMenuItem(
                            value: myPlanetSortingCriteria.distanceClosestToFurthest,
                            child: Text("Distance from Star (from closest to furthest in AU)"),
                          ),
                          DropdownMenuItem(
                            value: myPlanetSortingCriteria.distanceFurthestToClosest,
                            child: Text("Distance from Star (from furthest to closest in AU)"),
                          ),
                          DropdownMenuItem(
                            value: myPlanetSortingCriteria.temperatureCoolestToHottest,
                            child: Text("Temperature (from coolest to hottest in Kelvin)"),
                          ),
                          DropdownMenuItem(
                            value: myPlanetSortingCriteria.temperatureHottestToCoolest,
                            child: Text("Temperature (from hottest to coolest in Kelvin)"),
                          ),
                        ],
                        onChanged: (myValue){
                          if(myValue != null){
                            setDialogState(() => myTemporaryCriteria = myValue);
                          }
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: (){
                          myPlanetSortingCriteriaNotifier.value = myTemporaryCriteria;
                          query = query;
                          Navigator.of(bc).pop();
                        },
                        child: Text("Ok"),
                      ),
                    ],
                  );
                }
              );
            }
          );
        }
      ),
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
    return ValueListenableBuilder<myPlanetSortingCriteria>(
      valueListenable: myPlanetSortingCriteriaNotifier,
      builder: (context, mySortingCriteria, _){
        List<myStars> myMatchQueryPlanets = [];
        if(!myScrollController.hasListeners){
          myScrollController.addListener((){
            SystemChannels.textInput.invokeMethod("TextInput.hide");
          });
        }

        SystemChannels.textInput.invokeMethod("TextInput.hide");

        WidgetsBinding.instance.addPostFrameCallback((_){
          SystemChannels.textInput.invokeMethod("TextInput.hide");
          FocusScope.of(context).requestFocus(FocusNode());}
        );

        Future.delayed(Duration(milliseconds: 50), (){
          SystemChannels.textInput.invokeMethod("TextInput.hide");
        });

        Future.delayed(Duration(milliseconds: 100), (){
          SystemChannels.textInput.invokeMethod("TextInput.hide");
        });

        Future.delayed(Duration(milliseconds: 250), (){
          SystemChannels.textInput.invokeMethod("TextInput.hide");
        });

        Future.delayed(Duration(milliseconds: 500), (){
          SystemChannels.textInput.invokeMethod("TextInput.hide");
        });

        for(var planet in allPlanets){
          if(planet.toLowerCase().contains(query)){
            myMatchQueryPlanets.add(myStars(starName: planet, imagePath: "assets/images/not_available.png"));
          }
        }

        mySortMatchQuery(myMatchQueryPlanets);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (){
            SystemChannels.textInput.invokeMethod("TextInput.hide");
          },
          onPanDown: (_){
            SystemChannels.textInput.invokeMethod("TextInput.hide");
          },
          child: ListView.builder(
            controller: myScrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: myMatchQueryPlanets.length,
            itemBuilder: (context, index) {
              var result = myMatchQueryPlanets[index]; //If user enters in a key, the result is the key.

              return ListTile(
                title: Text(result.starName!),
              );
            },
          ),
        );
      },
    );
  }

  // This is the last overwrite (to show the querying process at the runtime)
  @override
  Widget buildSuggestions(BuildContext context) {
    final myLoginStatus = context.watch<loginStatus>();
    return ValueListenableBuilder<myPlanetSortingCriteria>(
      valueListenable: myPlanetSortingCriteriaNotifier,
      builder: (context, mySortingCriteria, _){
        List<myStars> myMatchQueryPlanets = [];

        for(var planet in allPlanets){
          if(planet.toLowerCase().contains(query)){
            myMatchQueryPlanets.add(myStars(starName: planet, imagePath: "assets/images/not_available.png"));
          }
        }

        mySortMatchQuery(myMatchQueryPlanets);

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: myMatchQueryPlanets.length,
            itemBuilder: (context, index) {
              return ValueListenableBuilder<bool>(
                valueListenable: planetSearchBool,
                builder: (context, searchingForPlanet, child){
                return AbsorbPointer(
                  absorbing: searchingForPlanet,
                  child: ListTile(
                    title: Text(myMatchQueryPlanets[index].starName!, style: TextStyle(color: Colors.black, fontFamily: 'Raleway')),
                    onTap: () async{
                      if(planetSearchBool.value){
                        return;
                      }

                      planetSearchBool.value = true;

                      FocusScope.of(context).unfocus();

                      fromSearchBarToPlanetArticle = true;
                      correctPlanet = myMatchQueryPlanets[index].starName!;

                      starsAndTheirPlanets.forEach((key, value){
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

                      listOfPlanetUrls = [];

                      final myLines = planetFileContent.replaceAll("\r\n", "\n").replaceAll("\r", "\n").split("\n").where((p) => p.isNotEmpty && p != " ").toList();

                      Map<int, String> myTitles = {};

                      for(int i = 0; i < myLines.length; i++){
                        if(myLines[i].contains("||")){
                          final parts = myLines[i].split("||");
                          listOfPlanetUrls.add(parts[0].trim());
                          myTitles[i] = parts[1].trim();
                        }
                        else{
                          listOfPlanetUrls.add(myLines[i]);
                        }
                      }

                      urlTitlesForPlanets = await Future.wait(List.generate(listOfPlanetUrls.length, (i){
                          if(myTitles.containsKey(i)){
                            return Future.value(myTitles[i]);
                          }
                          return getTitleOfPage(listOfPlanetUrls[i]);
                        })
                      );

                      //Is the planet tracked by a user?
                      if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                        if(firebaseDesktopHelper.onDesktop){
                          var userNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                          var usersDoc = userNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                          //Getting the current profile info of the user:
                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(usersDoc["usernameProfileInformation"] ?? {});
                          planetTracked = currentInfoOfUser["planetsTracked"].containsKey(correctPlanet);
                          print("planetTracked: ${planetTracked}");
                        }
                        else{
                          var theUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                          var theDocNameForUsers;
                          theUser.docs.forEach((result){
                            theDocNameForUsers = result.id;
                          });

                          DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForUsers).get();
                          Map<dynamic, dynamic>? individual = theSnapshotUsers.data();

                          planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                          print("planetTracked: ${planetTracked}");
                        }
                      }

                      myAccessCheckNotifier.value = DateTime.now();

                      if(!context.mounted){
                        return;
                      }

                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => planetArticle(informationAboutPlanet)));
                      planetSearchBool.value = false;
                    },
                    leading: Image.asset(myMatchQueryPlanets[index].imagePath!, fit: BoxFit.cover, height: 50, width: 50),
                    ),
                  );
                }
              );
            }
          )
        );
      }
    );
  }
}

class articlePage extends StatelessWidget{
  static String nameOfRoute = '/articlePage';

  List<String> informationAboutPlanet = [];
  var myPlanet = <String>[];

  final List<String> starInfo;
  Future<List<String>?>? starFutureData;

  articlePage(this.starInfo, {super.key});

  List<Text> starPdfMessageForUser = [];

  final ValueNotifier<bool> navigationBackToPreviousPage = ValueNotifier(false);
  final ValueNotifier<bool> navigationToPlanetArticle = ValueNotifier(false);
  final ValueNotifier<bool> trackStarButton = ValueNotifier(false);
  final ValueNotifier<bool> untrackStarButton = ValueNotifier(false);

  List<String> getKeys(Map myMap){ // This is for getting planet names, which are keys
    //Making the star's planets in alphabetical order
    var planetsList = myMap.keys.toList()..sort();
    return planetsList.map((myKeys) => myKeys.toString()).toList();
  }

  Future<List<String>?> getStarData() async{
    final ref;
    List<String>? myPlanetsResult;

    if(firebaseDesktopHelper.onDesktop){
      ref = await firebaseDesktopHelper.getFirebaseData(correctStar);

      final snapshot = ref["Planets"];
      if (snapshot != null) {
        myPlanetsResult = getKeys(snapshot as Map); // Calling getKeys so that I can get the planets' names
        print(snapshot);
      } else {
        print('No data available.');
      }
    }
    else{
      ref = FirebaseDatabase.instance.ref(correctStar);

      final snapshot = await ref.child('Planets').get();
      if (snapshot.exists) {
        myPlanetsResult = getKeys(snapshot.value as Map); // Calling getKeys so that I can get the planets' names
        print(snapshot.value);
      } else {
        print('No data available.');
      }
    }
    print('This is the correct star: ' + correctStar);
    return Future.delayed(Duration(seconds: 1), () {
      return myPlanetsResult; // Data should be returned from the snapshot.
    });
  }

  Future<List<String>> getPlanetData() async{
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
    if(response.headers?["content-type"]?.contains("application/pdf") == false){
      //Failed to load as a PDF
      messageForUser.add(Text("Failed to load as a PDF"));
    }

    return messageForUser;
  }

  @override
  Widget build(BuildContext bc) {
    starFutureData ??= getStarData();

    final myLoginStatus = bc.watch<loginStatus>();

    var info = ModalRoute.of(bc)!.settings;
    myStars theStar;

    theStar = info.arguments as myStars;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(theStar.starName!),
          leading: ValueListenableBuilder<bool>(
          valueListenable: navigationBackToPreviousPage,
          builder: (bc, isNavigatingBack, child){
            return AbsorbPointer(
              absorbing: isNavigatingBack,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () async {
                  if(navigationBackToPreviousPage.value) return;

                  navigationBackToPreviousPage.value = true;

                  //Going from the star article page to the search suggestions page
                  if(fromSpectralClassPage == true){
                    fromSpectralClassPage = false;

                    if(!bc.mounted) return;

                    Navigator.push(bc, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                  }
                  else if(featuredStarOfTheDayBool == true){
                    featuredStarOfTheDayBool = false;

                    if(!bc.mounted) return;

                    Navigator.push(bc, MaterialPageRoute(builder: (BuildContext context) => StarExpedition()));
                  }
                  else if(fromMostTrackedStarsAndPlanetsPageStars == true){
                    fromMostTrackedStarsAndPlanetsPageStars = false;

                    if(!bc.mounted) return;

                    Navigator.push(bc, MaterialPageRoute(builder: (BuildContext context) => mostTrackedStarsAndPlanetsPage()));
                  }
                  else if(fromUserProfileInUserPerspective == true && fromProfileAndStar == false){
                    fromUserProfileInUserPerspective = false;

                    if(!bc.mounted) return;

                    Navigator.pushReplacementNamed(bc, routesToOtherPages.userProfileInUserPerspectivePage);
                  }
                  else if(fromUserProfileInOtherUsersPerspective == true && fromProfileAndStar == false){
                    fromUserProfileInOtherUsersPerspective = false;
                    if(firebaseDesktopHelper.onDesktop){
                      nameClickedData = await firebaseDesktopHelper.getFirestoreCollection("User");
                      theUsersData = nameClickedData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == theUsernameResult.toLowerCase(), orElse: () => {} as Map<String, dynamic>);

                      if(!bc.mounted) return;

                      Navigator.push(bc, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective()));
                    }
                    else{
                      nameClickedData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theUsernameResult.toLowerCase()).get();
                      nameClickedData.docs.forEach((person){
                        theUsersData = person.data();
                      });

                      if(!bc.mounted) return;

                      Navigator.push(bc, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective()));
                    }
                  }
                  else if(fromProfileAndStar == true){
                    fromProfileAndStar = false;
                    if(firebaseDesktopHelper.onDesktop){
                      nameClickedData = await firebaseDesktopHelper.getFirestoreCollection("User");
                      theUsersData = nameClickedData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == theUsernameResult.toLowerCase(), orElse: () => {} as Map<String, dynamic>);

                      if(!bc.mounted) return;

                      Navigator.push(bc, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective()));
                    }
                    else{
                      nameClickedData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theUsernameResult.toLowerCase()).get();
                      nameClickedData.docs.forEach((person){
                        theUsersData = person.data();
                      });

                      if(!bc.mounted) return;

                      Navigator.push(bc, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective()));
                    }
                  }
                  else{
                      myAccessCheckNotifier.value = DateTime.now();
                      showSearch(
                        context: bc,
                        delegate: CustomSearchDelegate(),
                      );
                    }

                  navigationBackToPreviousPage.value = false;
                }
              ),
            );
          }
        ),
      ),
      body: FutureBuilder<List<String>?>(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Center(
                        child: Text("\nStar Information", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                      ),
                      Container(
                        height: MediaQuery.of(bc).size.height * 0.015625,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.031250, 0.0, MediaQuery.of(bc).size.width * 0.031250, 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              textAlign: TextAlign.left,
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
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Distance (in light-years): ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: starInfo[1].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Other names: ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: starInfo[2].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Spectral class: ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: starInfo[3].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Absolute magnitude: ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: starInfo[4].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Age of star: ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: starInfo[5].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Apparent magnitude: ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: starInfo[6].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Discoverer of star: ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: starInfo[7].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Discovery date of star: ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: starInfo[8].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Temperature (in Kelvin): ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: starInfo[9].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "J2000 coordinates: ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: starInfo[10].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Image source: ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: starInfo[11].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Text("\nConfirmed Terrestrial Planets",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                      child: Center(
                                        child: ValueListenableBuilder<bool>(
                                          valueListenable: navigationToPlanetArticle,
                                          builder: (context, isNavigatingToPlanetArticle, child){
                                            return AbsorbPointer(
                                              absorbing: isNavigatingToPlanetArticle,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.black,
                                                ),
                                                child: UnconstrainedBox(
                                                  child: Ink(
                                                    color: Colors.black,
                                                    child: Text(myData[index], textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.normal)),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  if(navigationToPlanetArticle.value){
                                                    return;
                                                  }

                                                  navigationToPlanetArticle.value = true;

                                                  correctPlanet = myData[index];
                                                  informationAboutPlanet = await getPlanetData();

                                                  planetFileContent = await readPlanetFile(informationAboutPlanet[6].toString());

                                                  listOfPlanetUrls = [];

                                                  final myLines = planetFileContent.replaceAll("\r\n", "\n").replaceAll("\r", "\n").split("\n").where((p) => p.isNotEmpty && p != " ").toList();

                                                  Map<int, String> myTitles = {};

                                                  for(int i = 0; i < myLines.length; i++){
                                                    if(myLines[i].contains("||")){
                                                      final parts = myLines[i].split("||");
                                                      listOfPlanetUrls.add(parts[0].trim());
                                                      myTitles[i] = parts[1].trim();
                                                    }
                                                    else{
                                                      listOfPlanetUrls.add(myLines[i]);
                                                    }
                                                  }

                                                  urlTitlesForPlanets = await Future.wait(List.generate(listOfPlanetUrls.length, (i){
                                                      if(myTitles.containsKey(i)){
                                                        return Future.value(myTitles[i]);
                                                      }
                                                      return getTitleOfPage(listOfPlanetUrls[i]);
                                                    })
                                                  );

                                                  print("listOfPlanetUrls: ${listOfPlanetUrls}");

                                                  if(fromUserProfileInUserPerspective == true || fromUserProfileInOtherUsersPerspective == true){
                                                    fromProfileAndStar = true;
                                                  }

                                                  myAccessCheckNotifier.value = DateTime.now();

                                                  if(!context.mounted){
                                                    return;
                                                  }

                                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => planetArticle(informationAboutPlanet)));

                                                  //Is the planet tracked by the user?
                                                  if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                                    if(firebaseDesktopHelper.onDesktop){
                                                      var userNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                      var usersDoc = userNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                                      //Getting the current profile info of the user:
                                                      Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(usersDoc["usernameProfileInformation"] ?? {});
                                                      planetTracked = currentInfoOfUser["planetsTracked"].containsKey(correctPlanet);
                                                      print("planetTracked: ${planetTracked}");
                                                    }
                                                    else{
                                                      var theUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                                      var theDocNameForUsers;
                                                      theUser.docs.forEach((result){
                                                        theDocNameForUsers = result.id;
                                                      });

                                                      DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForUsers).get();
                                                      Map<dynamic, dynamic>? individual = theSnapshotUsers.data();

                                                      planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                                                      print("planetTracked: ${planetTracked}");
                                                    }
                                                  }

                                                  navigationToPlanetArticle.value = false;
                                                },
                                              ),
                                            );
                                          }
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            ),
                          Center(
                            child: Text("\nOnline Articles about ${correctStar}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                          ),
                          Container(
                            height: MediaQuery.of(bc).size.height * 0.015625,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.031250, 0.0, MediaQuery.of(bc).size.width * 0.031250, 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(listOfStarUrls.length, (int indexPlace) =>
                                GestureDetector(
                                  child: RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(text: "${urlTitlesForStars[indexPlace]}\n", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)),
                                  ),
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
                                          myStarPdfFile = PdfDocument.openData(myResponse.bodyBytes);
                                        }
                                        else{
                                          var temporaryDirectory = await getTemporaryDirectory();
                                          var temporaryFile = File("${temporaryDirectory.path}/temporaryPdf.pdf");
                                          await temporaryFile.writeAsBytes(myResponse.bodyBytes);
                                          myStarPdfFile = PdfDocument.openFile(temporaryFile.path);
                                        }

                                        //Going to the page that has the PDF
                                        Navigator.push(bc, MaterialPageRoute(builder: (theContext) => pdfViewer()));
                                        print("A pdf file. starListUrlIndex is: ${starListUrlIndex.toString()}");
                                      }
                                      else{
                                        print("Unfortunately, the PDF file failed to load. This is the status code: ${myResponse.statusCode}");
                                        print("myResponse.headers[content-type]?: ${myResponse.headers["content-type"]}");

                                        starPdfMessageForUser = starPdfDialogMessage(myResponse);

                                        myAccessCheckNotifier.value = DateTime.now();

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
                          if(((myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != "") && starTracked == false))
                            Padding(
                              padding: EdgeInsets.all(MediaQuery.of(bc).size.height * 0.015625),
                              child: ValueListenableBuilder<bool>(
                                valueListenable: trackStarButton,
                                builder: (bc, trackingStar, child){
                                  return AbsorbPointer(
                                    absorbing: trackingStar,
                                    child: Center(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                        ),
                                        child: Ink(
                                          color: Colors.black,
                                          child: Text("Track this Star", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                                        ),
                                        onPressed: () async{
                                          if(trackStarButton.value){
                                            return;
                                          }

                                          trackStarButton.value = true;

                                          if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                            TextEditingController reasonForStarTrackUsers = TextEditingController();
                                            var starsTracked;

                                            if(firebaseDesktopHelper.onDesktop){
                                              List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                              var user = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                              docNameForStarsTrackedUser = user["docId"];
                                              print("docNameForStarsTrackedUser: ${docNameForStarsTrackedUser}");

                                              Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(user["usernameProfileInformation"] ?? {});

                                              starsTracked = currentInfoOfUser?["starsTracked"];
                                            }
                                            else{
                                              var user = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                              user.docs.forEach((result){
                                                docNameForStarsTrackedUser = result.id;
                                              });
                                              print(docNameForStarsTrackedUser);

                                              DocumentSnapshot<Map<dynamic, dynamic>> mySnapshotUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForStarsTrackedUser).get();
                                              Map<dynamic, dynamic>? individual = mySnapshotUsers.data();

                                              print(individual?["usernameProfileInformation"]);
                                              print(individual?["usernameProfileInformation"]["starsTracked"]);

                                              starsTracked = individual?["usernameProfileInformation"]["starsTracked"];
                                            }

                                            if(starsTracked.length < 3){
                                              myAccessCheckNotifier.value = DateTime.now();

                                              await showDialog(
                                                  context: bc,
                                                  builder: (BuildContext context){
                                                    return Listener(
                                                      behavior: HitTestBehavior.translucent,
                                                      onPointerDown: (_){
                                                        FocusManager.instance.primaryFocus?.unfocus();
                                                      },
                                                      child: AlertDialog(
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
                                                              controller: reasonForStarTrackUsers,
                                                            ),
                                                          ],
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                              child: Text("Ok"),
                                                              onPressed: () async{
                                                                if(whitespaceChecker(reasonForStarTrackUsers.text) == false){
                                                                  starsTracked.addEntries({theStar.starName!: reasonForStarTrackUsers.text}.entries);

                                                                  if(firebaseDesktopHelper.onDesktop){
                                                                    List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                                                    var currentUser = allUsers.firstWhere((user) => user["docId"] == docNameForStarsTrackedUser, orElse: () => <String, dynamic>{});

                                                                    Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(currentUser["usernameProfileInformation"] ?? {});

                                                                    //Updating starsTracked:
                                                                    currentInfoOfUser["starsTracked"] = starsTracked;

                                                                    await firebaseDesktopHelper.updateFirestoreDocument("User/$docNameForStarsTrackedUser", {
                                                                      "usernameProfileInformation": currentInfoOfUser,
                                                                    });
                                                                  }
                                                                  else{
                                                                    FirebaseFirestore.instance.collection("User").doc(docNameForStarsTrackedUser).update({
                                                                      "usernameProfileInformation.starsTracked": starsTracked,
                                                                    }).then((outcome) {
                                                                      print("starsTracked updated!");
                                                                    });
                                                                  }

                                                                  if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                                                    if(firebaseDesktopHelper.onDesktop){
                                                                      var userNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                                      var usersDoc = userNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                                                      //Getting the current profile info of the user:
                                                                      Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(usersDoc["usernameProfileInformation"] ?? {});
                                                                      starTracked = currentInfoOfUser["starsTracked"].containsKey(theStar.starName!);
                                                                      print("starTracked: ${starTracked}");
                                                                    }
                                                                    else{
                                                                      var theUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                                                      var docNameForUsers;
                                                                      theUser.docs.forEach((result){
                                                                        docNameForUsers = result.id;
                                                                      });

                                                                      DocumentSnapshot<Map<dynamic, dynamic>> snapshotUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForUsers).get();
                                                                      Map<dynamic, dynamic>? individual = snapshotUsers.data();

                                                                      starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(theStar.starName!);
                                                                      print("starTracked: ${starTracked}");
                                                                    }
                                                                  }
                                                                  myAccessCheckNotifier.value = DateTime.now();

                                                                  if(!context.mounted){
                                                                    return;
                                                                  }

                                                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => articlePage(starInfo), settings: RouteSettings(arguments: theStar)));
                                                                }
                                                              }
                                                          ),
                                                          TextButton(
                                                            child: Text("Cancel"),
                                                            onPressed: (){
                                                              if(!context.mounted){
                                                                return;
                                                              }

                                                              Navigator.pop(context);
                                                            }
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                              );
                                            }
                                            else{
                                              myAccessCheckNotifier.value = DateTime.now();

                                              await showDialog(
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
                                                              if(!context.mounted){
                                                                return;
                                                              }

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
                                            trackStarButton.value = false;
                                          }
                                        ),
                                      ),
                                    );
                                  }
                                ),
                            ),
                          if(((myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != "") && starTracked == true))
                            Padding(
                              padding: EdgeInsets.all(MediaQuery.of(bc).size.height * 0.015625),
                              child: ValueListenableBuilder<bool>(
                                valueListenable: untrackStarButton,
                                builder: (bc, untrackingStar, child){
                                  return AbsorbPointer(
                                    absorbing: untrackingStar,
                                    child: Center(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                        ),
                                        child: Ink(
                                          color: Colors.black,
                                          child: Text("Untrack this Star", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                                        ),
                                        onPressed: () async{
                                          if(untrackStarButton.value){
                                            return;
                                          }

                                          untrackStarButton.value = true;

                                          myAccessCheckNotifier.value = DateTime.now();
                                          await showDialog(
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
                                                          if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                                            if(firebaseDesktopHelper.onDesktop){
                                                              List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                                              var theUser = allUsers.firstWhere((user) => user["usernameLowercased"] == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                                              var docForTheUser = theUser["docId"];

                                                              Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theUser["usernameProfileInformation"] ?? {});

                                                              //Getting and modifying starsTracked:
                                                              Map<String, dynamic> starsTracked = Map<String, dynamic>.from(currentInfoOfUser["starsTracked"] ?? {});
                                                              starsTracked.remove(theStar.starName!);

                                                              //Gets an updated list of the stars a user has tracked:
                                                              currentInfoOfUser["starsTracked"] = starsTracked;

                                                              await firebaseDesktopHelper.updateFirestoreDocument("User/$docForTheUser", {
                                                                "usernameProfileInformation": currentInfoOfUser,
                                                              });

                                                              print("starsTracked: ${starsTracked}");
                                                              starsUserTracked.remove(theStar.starName!);
                                                            }
                                                            else{
                                                              var theUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                                              var docForTheUser;

                                                              theUser.docs.forEach((result){
                                                                docForTheUser = result.id;
                                                              });

                                                              DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotUsers = await FirebaseFirestore.instance.collection("User").doc(docForTheUser).get();
                                                              Map<dynamic, dynamic>? individual = theSnapshotUsers.data();

                                                              var starsTracked = individual?["usernameProfileInformation"]["starsTracked"];

                                                              starsTracked.remove(theStar.starName!);
                                                              FirebaseFirestore.instance.collection("User").doc(docForTheUser).update({
                                                                "usernameProfileInformation.starsTracked": starsTracked,
                                                              }).then((outcome) {
                                                                print("Untracked the star!");
                                                              });

                                                              print("starsTracked: ${starsTracked}");
                                                              starsUserTracked.remove(theStar.starName!);
                                                            }

                                                            if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                                              if(firebaseDesktopHelper.onDesktop){
                                                                var userNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                                var usersDoc = userNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                                                //Getting the current profile info of the user:
                                                                Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(usersDoc["usernameProfileInformation"] ?? {});
                                                                starTracked = currentInfoOfUser["starsTracked"].containsKey(theStar.starName!);
                                                                print("starTracked: ${starTracked}");
                                                                starsUsersTracked.remove(theStar.starName!);
                                                              }
                                                              else{
                                                                var theUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                                                var docNameForUsers;
                                                                theUser.docs.forEach((result){
                                                                  docNameForUsers = result.id;
                                                                });

                                                                DocumentSnapshot<Map<dynamic, dynamic>> snapshotUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForUsers).get();
                                                                Map<dynamic, dynamic>? individual = snapshotUsers.data();

                                                                starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(theStar.starName!);
                                                                print("starTracked: ${starTracked}");
                                                                starsUserTracked.remove(theStar.starName!);
                                                              }
                                                            }
                                                            myAccessCheckNotifier.value = DateTime.now();

                                                            if(!context.mounted){
                                                              return;
                                                            }

                                                            await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => articlePage(starInfo), settings: RouteSettings(arguments: theStar)));
                                                          }
                                                        }
                                                    ),
                                                    TextButton(
                                                      child: Text("No"),
                                                      onPressed: (){
                                                        if(!context.mounted){
                                                          return;
                                                        }

                                                        Navigator.pop(context);
                                                        print("No");
                                                      }
                                                    )
                                                  ],
                                                );
                                              }
                                            );
                                            untrackStarButton.value = false;
                                          },
                                        ),
                                      ),
                                    );
                              }
                            )
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
              }
            }
          }
          else{ //This represents a scenario where the connection has not finished yet.
            return Center(child: CircularProgressIndicator());
          }
        },
        future: starFutureData,
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

  final ValueNotifier<bool> navigationBackToPreviousPage = ValueNotifier(false);
  final ValueNotifier<bool> trackPlanetButton = ValueNotifier(false);
  final ValueNotifier<bool> untrackPlanetButton = ValueNotifier(false);

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
    final myLoginStatus = theContext.watch<loginStatus>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(correctPlanet),
        leading: ValueListenableBuilder<bool>(
          valueListenable: navigationBackToPreviousPage,
          builder: (theContext, isNavigatingBack, child){
            return AbsorbPointer(
              absorbing: isNavigatingBack,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () async {
                  if(navigationBackToPreviousPage.value){
                    return;
                  }

                  navigationBackToPreviousPage.value = true;

                  if(fromSearchBarToPlanetArticle == true){
                    fromSearchBarToPlanetArticle = false;
                    myAccessCheckNotifier.value = DateTime.now();
                    showSearch(
                      context: theContext,
                      delegate: CustomSearchDelegateForPlanets(),
                    );
                  }
                  else if(fromMostTrackedStarsAndPlanetsPagePlanets == true){
                    fromMostTrackedStarsAndPlanetsPagePlanets = false;
                    if(!theContext.mounted){
                      return;
                    }
                    Navigator.push(theContext, MaterialPageRoute(builder: (BuildContext context) => mostTrackedStarsAndPlanetsPage()));
                  }
                  else if(fromUserProfileInUserPerspective == true && fromProfileAndStar == false){
                    fromUserProfileInUserPerspective = false;
                    if(!theContext.mounted){
                      return;
                    }
                    Navigator.pushReplacementNamed(theContext, routesToOtherPages.userProfileInUserPerspectivePage);
                  }
                  else if(fromUserProfileInOtherUsersPerspective == true && fromProfileAndStar == false){
                    fromUserProfileInOtherUsersPerspective = false;
                    if(firebaseDesktopHelper.onDesktop){
                      nameClickedData = await firebaseDesktopHelper.getFirestoreCollection("User");
                      theUsersData = nameClickedData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == theUsernameResult.toLowerCase(), orElse: () => {} as Map<String, dynamic>);

                      if(!theContext.mounted){
                        return;
                      }

                      Navigator.push(theContext, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective()));
                    }
                    else{
                      nameClickedData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theUsernameResult.toLowerCase()).get();
                      nameClickedData.docs.forEach((person){
                        theUsersData = person.data();
                      });

                      if(!theContext.mounted){
                        return;
                      }

                      Navigator.push(theContext, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective()));
                    }
                  }
                  else{
                    hostStarInformation = await getStarInformation();
                    print("The host star information: $hostStarInformation");

                    starFileContent = await readStarFile();

                    listOfStarUrls = [];

                    final myLines = starFileContent.replaceAll("\r\n", "\n").replaceAll("\r", "\n").split("\n").where((s) => s.isNotEmpty && s != " ").toList();

                    Map<int, String> myTitles = {};

                    for(int i = 0; i < myLines.length; i++){
                      if(myLines[i].contains("||")){
                        final parts = myLines[i].split("||");
                        listOfStarUrls.add(parts[0].trim());
                        myTitles[i] = parts[1].trim();
                      }
                      else{
                        listOfStarUrls.add(myLines[i]);
                      }
                    }

                    urlTitlesForStars = await Future.wait(List.generate(listOfStarUrls.length, (i){
                        if(myTitles.containsKey(i)){
                          return Future.value(myTitles[i]);
                        }
                        return getTitleOfPage(listOfStarUrls[i]);
                      })
                    );

                    if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                      if(firebaseDesktopHelper.onDesktop){
                        var userNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                        var usersDoc = userNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                        //Getting the current profile info of the user:
                        Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(usersDoc["usernameProfileInformation"] ?? {});
                        starTracked = currentInfoOfUser["starsTracked"].containsKey(correctStar);
                        print("starTracked: ${starTracked}");
                      }
                      else{
                        var theUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                        var docNameForUsers;
                        theUser.docs.forEach((result){
                          docNameForUsers = result.id;
                        });

                        DocumentSnapshot<Map<dynamic, dynamic>> snapshotUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForUsers).get();
                        Map<dynamic, dynamic>? individual = snapshotUsers.data();

                        starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(correctStar);
                        print("starTracked: ${starTracked}");
                      }
                    }

                    myAccessCheckNotifier.value = DateTime.now();

                    if(!theContext.mounted){
                      return;
                    }

                    Navigator.of(theContext).push(MaterialPageRoute(builder: (theContext) => articlePage(hostStarInformation), settings: RouteSettings(arguments: myStars(starName: correctStar, imagePath: "assets/images"))));
                  }
                  navigationBackToPreviousPage.value = false;
                },
              ),
            );
          }
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Padding(
                        padding: EdgeInsets.fromLTRB(MediaQuery.of(theContext).size.width * 0.031250, 0.0, MediaQuery.of(theContext).size.width * 0.031250, 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Discovery date of planet: ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: informationAboutPlanet[0].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Distance from star: ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: informationAboutPlanet[1].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Earth masses: ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: informationAboutPlanet[2].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Known gases: ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: informationAboutPlanet[3].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Orbital period: ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: informationAboutPlanet[4].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: "Temperature (in Kelvin): ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: informationAboutPlanet[5].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
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
                          Padding(
                            padding: EdgeInsets.fromLTRB(MediaQuery.of(theContext).size.width * 0.031250, 0.0, MediaQuery.of(theContext).size.width * 0.031250, 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(listOfPlanetUrls.length, (int indexPlace) =>
                                GestureDetector(
                                  child: RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(text: "${urlTitlesForPlanets[indexPlace]}\n", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)),
                                  ),
                                  onTap: () async{
                                    planetListUrlIndex = indexPlace;
                                    if(!(listOfPlanetUrls[indexPlace].contains("pdf"))){
                                      launchUrl(Uri.parse("${listOfPlanetUrls[indexPlace]}"), mode: LaunchMode.externalApplication);
                                      print("Not a pdf file");
                                    }
                                    else{
                                      planetPdfBool = true;

                                      var myResponse = await http.get(Uri.parse(listOfPlanetUrls[indexPlace]));

                                      if(myResponse.statusCode == 200 && myResponse.headers["content-type"]?.contains("application/pdf") == true){
                                        if(firebaseDesktopHelper.onDesktop){
                                          var temporaryDirectory = await getTemporaryDirectory();
                                          var temporaryFile = File("${temporaryDirectory.path}/temporaryPdf.pdf");
                                          await temporaryFile.writeAsBytes(myResponse.bodyBytes);
                                          myPlanetPdfFile = PdfDocument.openFile(temporaryFile.path);
                                        }
                                        else if(kIsWeb){
                                          myPlanetPdfFile = PdfDocument.openData(myResponse.bodyBytes);
                                        }
                                        else{
                                          var temporaryDirectory = await getTemporaryDirectory();
                                          var temporaryFile = File("${temporaryDirectory.path}/temporaryPdf.pdf");
                                          await temporaryFile.writeAsBytes(myResponse.bodyBytes);
                                          myPlanetPdfFile = PdfDocument.openFile(temporaryFile.path);
                                        }

                                        //Going to the page that has the PDF
                                        Navigator.push(theContext, MaterialPageRoute(builder: (theContext) => pdfViewer()));
                                        print("A pdf file. planetListUrlIndex is: ${planetListUrlIndex.toString()}");
                                      }
                                      else{
                                        print("Unfortunately, the PDF file failed to load. This is the status code: ${myResponse.statusCode}");
                                        print("myResponse.headers[content-type]?: ${myResponse.headers["content-type"]}");

                                        planetPdfMessageForUser = planetPdfDialogMessage(myResponse);

                                        myAccessCheckNotifier.value = DateTime.now();

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
                          if((myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != "") && planetTracked == false)
                            Padding(
                              padding: EdgeInsets.all(MediaQuery.of(theContext).size.height * 0.015625),
                              child: ValueListenableBuilder<bool>(
                                valueListenable: trackPlanetButton,
                                builder: (bc, trackingPlanet, child){
                                  return AbsorbPointer(
                                    absorbing: trackingPlanet,
                                    child: Center(
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                          ),
                                          child: Ink(
                                            color: Colors.black,
                                            child: Text("Track this Planet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                                          ),
                                          onPressed: () async{
                                            if(trackPlanetButton.value){
                                              return;
                                            }

                                            trackPlanetButton.value = true;

                                            if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                              TextEditingController reasonForPlanetTrackUsers = TextEditingController();
                                              var planetsTracked;

                                              if(firebaseDesktopHelper.onDesktop){
                                                List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                                var user = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                                docNameForPlanetsTrackedUser = user["docId"];
                                                print("docNameForPlanetsTrackedUser: ${docNameForPlanetsTrackedUser}");

                                                Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(user["usernameProfileInformation"] ?? {});

                                                planetsTracked = currentInfoOfUser?["planetsTracked"];
                                              }
                                              else{
                                                var user = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                                user.docs.forEach((result){
                                                  docNameForPlanetsTrackedUser = result.id;
                                                });
                                                print(docNameForPlanetsTrackedUser);

                                                DocumentSnapshot<Map<dynamic, dynamic>> mySnapshotUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForPlanetsTrackedUser).get();
                                                Map<dynamic, dynamic>? individual = mySnapshotUsers.data();

                                                print(individual?["usernameProfileInformation"]);
                                                print(individual?["usernameProfileInformation"]["planetsTracked"]);

                                                planetsTracked = individual?["usernameProfileInformation"]["planetsTracked"];
                                              }

                                              if(planetsTracked.length < 3){
                                                myAccessCheckNotifier.value = DateTime.now();
                                                await showDialog(
                                                    context: theContext,
                                                    builder: (BuildContext context){
                                                      return Listener(
                                                        behavior: HitTestBehavior.translucent,
                                                        onPointerDown: (_){
                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                        },
                                                        child: AlertDialog(
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
                                                                controller: reasonForPlanetTrackUsers,
                                                              ),
                                                            ],
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                                child: Text("Ok"),
                                                                onPressed: () async{
                                                                  if(whitespaceChecker(reasonForPlanetTrackUsers.text) == false){
                                                                    planetsTracked.addEntries({correctPlanet: reasonForPlanetTrackUsers.text}.entries);

                                                                    if(firebaseDesktopHelper.onDesktop){
                                                                      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                                                      var currentUser = allUsers.firstWhere((user) => user["docId"] == docNameForPlanetsTrackedUser, orElse: () => <String, dynamic>{});

                                                                      Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(currentUser["usernameProfileInformation"] ?? {});

                                                                      //Updating planetsTracked:
                                                                      currentInfoOfUser["planetsTracked"] = planetsTracked;

                                                                      await firebaseDesktopHelper.updateFirestoreDocument("User/$docNameForPlanetsTrackedUser", {
                                                                        "usernameProfileInformation": currentInfoOfUser,
                                                                      });
                                                                    }
                                                                    else{
                                                                      FirebaseFirestore.instance.collection("User").doc(docNameForPlanetsTrackedUser).update({
                                                                        "usernameProfileInformation.planetsTracked": planetsTracked,
                                                                      }).then((outcome) {
                                                                        print("planetsTracked updated!");
                                                                      });
                                                                    }

                                                                    //Is the planet tracked by the user?
                                                                    if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                                                      if(firebaseDesktopHelper.onDesktop){
                                                                        var userNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                                        var usersDoc = userNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                                                        //Getting the current profile info of the user:
                                                                        Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(usersDoc["usernameProfileInformation"] ?? {});
                                                                        planetTracked = currentInfoOfUser["planetsTracked"].containsKey(correctPlanet);
                                                                        print("planetTracked: ${planetTracked}");
                                                                      }
                                                                      else{
                                                                        var theUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                                                        var theDocNameForUsers;
                                                                        theUser.docs.forEach((result){
                                                                          theDocNameForUsers = result.id;
                                                                        });

                                                                        DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForUsers).get();
                                                                        Map<dynamic, dynamic>? individual = theSnapshotUsers.data();

                                                                        planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                                                                        print("planetTracked: ${planetTracked}");
                                                                      }
                                                                    }

                                                                    myAccessCheckNotifier.value = DateTime.now();

                                                                    if(!context.mounted){
                                                                      return;
                                                                    }

                                                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => planetArticle(informationAboutPlanet)));
                                                                  }
                                                                }
                                                            ),
                                                            TextButton(
                                                              child: Text("Cancel"),
                                                              onPressed: () {
                                                                if(!context.mounted){
                                                                  return;
                                                                }

                                                                Navigator.pop(context);
                                                              }
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                );
                                              }
                                              else{
                                                myAccessCheckNotifier.value = DateTime.now();
                                                await showDialog(
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
                                                                if(!context.mounted){
                                                                  return;
                                                                }

                                                                Navigator.pop(context);
                                                              }
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                );
                                              }
                                            }
                                            trackPlanetButton.value = false;
                                          }
                                          ),
                                        )
                                );
                              }
                            )
                          ),
                          if((myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != "") && planetTracked == true)
                            Padding(
                              padding: EdgeInsets.all(MediaQuery.of(theContext).size.height * 0.015625),
                              child: ValueListenableBuilder<bool>(
                                valueListenable: untrackPlanetButton,
                                builder: (bc, untrackingPlanet, child){
                                  return AbsorbPointer(
                                    absorbing: untrackingPlanet,
                                     child: Center(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                        ),
                                        child: Ink(
                                          color: Colors.black,
                                          child: Text("Untrack this Planet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                                        ),
                                        onPressed: () async{
                                          if(untrackPlanetButton.value){
                                            return;
                                          }

                                          untrackPlanetButton.value = true;

                                          myAccessCheckNotifier.value = DateTime.now();
                                          await showDialog(
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
                                                        if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                                          if(firebaseDesktopHelper.onDesktop){
                                                            List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                                            var theUser = allUsers.firstWhere((user) => user["usernameLowercased"] == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                                            var docForTheUser = theUser["docId"];

                                                            Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theUser["usernameProfileInformation"] ?? {});

                                                            //Getting and modifying starsTracked:
                                                            Map<String, dynamic> planetsTracked = Map<String, dynamic>.from(currentInfoOfUser["planetsTracked"] ?? {});
                                                            planetsTracked.remove(correctPlanet);

                                                            //Gets an updated list of the stars a user has tracked:
                                                            currentInfoOfUser["planetsTracked"] = planetsTracked;

                                                            await firebaseDesktopHelper.updateFirestoreDocument("User/$docForTheUser", {
                                                              "usernameProfileInformation": currentInfoOfUser,
                                                            });

                                                            print("planetTracked: ${planetTracked}");

                                                            planetsUserTracked.remove(correctPlanet);
                                                          }
                                                          else{
                                                            var theUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                                            var docForTheUser;

                                                            theUser.docs.forEach((result){
                                                              docForTheUser = result.id;
                                                            });

                                                            DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotUsers = await FirebaseFirestore.instance.collection("User").doc(docForTheUser).get();
                                                            Map<dynamic, dynamic>? individual = theSnapshotUsers.data();

                                                            var planetsTracked = individual?["usernameProfileInformation"]["planetsTracked"];

                                                            planetsTracked.remove(correctPlanet);
                                                            FirebaseFirestore.instance.collection("User").doc(docForTheUser).update({
                                                              "usernameProfileInformation.planetsTracked": planetsTracked,
                                                            }).then((outcome) {
                                                              print("Untracked the planet!");
                                                            });

                                                            print("planetTracked: ${planetTracked}");
                                                            planetsUserTracked.remove(correctPlanet);
                                                          }

                                                          //Is the planet tracked by the user?
                                                          if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                                            if(firebaseDesktopHelper.onDesktop){
                                                              var userNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                              var usersDoc = userNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                                              //Getting the current profile info of the user:
                                                              Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(usersDoc["usernameProfileInformation"] ?? {});
                                                              planetTracked = currentInfoOfUser["planetsTracked"].containsKey(correctPlanet);
                                                              print("planetTracked: ${planetTracked}");

                                                              planetsUserTracked.remove(correctPlanet);
                                                            }
                                                            else{
                                                              var theUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                                              var theDocNameForUsers;
                                                              theUser.docs.forEach((result){
                                                                theDocNameForUsers = result.id;
                                                              });

                                                              DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForUsers).get();
                                                              Map<dynamic, dynamic>? individual = theSnapshotUsers.data();

                                                              planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(correctPlanet);
                                                              print("planetTracked: ${planetTracked}");
                                                              planetsUserTracked.remove(correctPlanet);
                                                            }
                                                          }

                                                          myAccessCheckNotifier.value = DateTime.now();

                                                          if(!context.mounted){
                                                            return;
                                                          }

                                                          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => planetArticle(informationAboutPlanet)));
                                                        }
                                                      }
                                                    ),
                                                    TextButton(
                                                      child: Text("No"),
                                                      onPressed: (){
                                                        if(!context.mounted){
                                                          return;
                                                        }

                                                        Navigator.pop(context);
                                                        print("No");
                                                      }
                                                    ),
                                                  ],
                                                );
                                              }
                                            );
                                            untrackPlanetButton.value = false;
                                          }
                                        ),
                                      ),
                                    );
                                  }
                                ),
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