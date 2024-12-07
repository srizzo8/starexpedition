import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
//import 'dart:js';
import 'dart:math';
//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
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
import 'package:starexpedition4/starsAndPlanetsList.dart';

import 'loginPage.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //runApp(MyApp());
  List usersOnStarExpeditionDocs = [];
  await FirebaseFirestore.instance.collection("User").get().then((snapshot){
    snapshot.docs.forEach((item){
      usersOnStarExpeditionDocs.add(item.data());
    });
  });
  print("usersOnStarExpeditionDocs: ${usersOnStarExpeditionDocs}");

  for(int n = 0; n < usersOnStarExpeditionDocs.length; n++){
    Users u = new Users(username: usersOnStarExpeditionDocs[n]["username"], email: usersOnStarExpeditionDocs[n]["emailAddress"], password: usersOnStarExpeditionDocs[n]["password"]);
    theUsers!.add(u);
  }

  //List of stars in Star Expedition
  for(var s in starsForSearchBar){
    var star = s.starName!;
    allStars.add(star);
  }

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

  print("stars and their planets: ${starsAndTheirPlanets}");

  print("starsForSearchBar: ${starsForSearchBar}");
  print("The snapshot: ${allPlanets}");

  /*QuerySnapshot qs = await FirebaseFirestore.instance.collection("Users").get();
  var thePeople = qs.docs.map((info) => info.data());
  print("thePeople: ${thePeople}");*/

  //print("usersOnStarExpeditionDocs: ${usersOnStarExpeditionDocs}");

  //print("usersOnStarExpeditionDocs: ${usersOnStarExpeditionDocs}");

  /*Users u1 = new Users(username: "John", email: "john@testing.com", password: "123");
  theUsers!.add(u1);
  print(theUsers);
  print(theUsers![0].username);*/ //one's username


  //Directory d = await getTemporaryDirectory();
  //String dPath = "d/"

  //json information
  /*
  var accountsDataString = await rootBundle.loadString('json/accountsData.json');
  var data = jsonDecode(accountsDataString);
  print("Username: " + data[0]["username"].toString());
  data.length = data.length + 1;
  data[1]["username"] = "hans";
  data[1]["email"] = "hans@test.com";
  data[1]["password"] = "kenworth";
  print(data[1]["username"]);
  //data["username"] = "hans";
  //var data2 = jsonEncode(data);
  //print(data2);*/

  /*
  var myDirectory = await getApplicationDocumentsDirectory();
  var myPath = (myDirectory.path + "/accountsData.json");
  print(myPath);
  final accountsFile = File("assets/jsonfiles/accountsData.json");
  print(accountsFile.existsSync());
  final accountsData = await accountsFile.readAsString();
  final fileInstance = jsonDecode(accountsData);
  print(fileInstance);*/

  //readFilesFromAsset();
  //readFilesFromDevicePath();
  //writeFilesToCustomDevicePath();
  //await findLocalPath;
  //await findLocalFile;
  //print(findLocalPath);
  //print(findLocalFile);

  //final myDir = await getApplicationDocumentsDirectory();
  //File accountsDataJsonFile = await File("C:/Users/Owner/starexpedition_jsonfiles/accountsData.json");
  //var accountsData = jsonDecode(accountsDataJsonFile.readAsStringSync());
  //print(accountsData);

  //final String accountsDataString = await rootBundle.loadString('assets/jsonfiles/accountsData.json');
  //final myAccountsData = jsonDecode(accountsDataString);
  //await readUserData(accountsDataString);
  //print(myAccountsData);

  //var myData = await json.decode(accountsDataString);


  /*WidgetsBinding.instance.addPostFrameCallback((_) async{
    await loadAccountsData();
  });*/
  //Firebase
  //late final accountsApp = Firebase.app();
  //late final accountsAppRTDB = FirebaseDatabase.instanceFor(app: accountsApp, databaseURL:'https://star-expedition-accounts-default-rtdb.firebaseio.com/');
  //late FirebaseDatabase accountsDB = FirebaseDatabase(app: accountsApp, );
  /*
  await Firebase.initializeApp(
    name: 'AccountsApp',
    options: const FirebaseOptions(
      apiKey: "AIzaSyAExtFxpx52-yW4vnK7Q8xw1wLp1b05Jxk",
      appId: "1:1004486689657:android:9f606b8da60da237d725a8",
      messagingSenderId: "1004486689657",
      projectId: "star-expedition-accounts",
      databaseURL: "https://star-expedition-accounts-default-rtdb.firebaseio.com/",
    )
  );
  FirebaseApp accountApp = Firebase.app('AccountsApp');
  FirebaseDatabase accountsDatabase = FirebaseDatabase.instanceFor(app: accountApp);

  print(accountsDatabase.toString());

  final reff = FirebaseDatabase.instance.ref();
  final mySnapshot = await reff.child('users/username').get();
  if(mySnapshot.exists){
    print("It exists");
  }
  else{
    print("It doesn't exist");
  }

   */

  /*
  FirebaseDatabase dd = FirebaseDatabase.instanceFor(app: accountsInfo);
  DatabaseReference dr = FirebaseDatabase.instance.ref("users");
  DatabaseReference child = dr.child("username");
  print(child);
  DatabaseEvent e = await dr.once();
  print(e);
  */
  //FirebaseApp secondDB = Firebase.app('AccountsApp');
  //print(secondDB);
  /*
  List<FirebaseApp> myApps = Firebase.apps;
  myApps.forEach((i){
    print("Name of app: " + i.name);
  });
   */
  //theAccountsDatabase = FirebaseDatabase.instance.ref().child("Users");

  //Sentry:
  await dotenv.load(fileName: "dotenv.env");

  //if(kReleaseMode == true){ //This checks to see if you are in release mode (which means you are in production)
    await SentryFlutter.init(
        (options) {
        options.dsn = dotenv.env["OPTIONS_DSN"];

        options.tracesSampleRate = 1.0;

        options.profilesSampleRate = 1.0;
      },
      appRunner: () => runApp(const MyApp()),
    );
  /*else{
    //If you are in development mode, you can run your app without sentry.io:
    runApp(MyApp());
  }*/
}

class myStars {
  String? starName;
  String? imagePath;
  myStars({
    this.starName,
    this.imagePath,
  });
}

List<myStars> starsForSearchBar = [
  myStars(starName: "Proxima Centauri", imagePath: "assets/images/proxima_centauri.jpg"),
  myStars(starName: "Tau Ceti", imagePath: "assets/images/tau_ceti.jpg"),
  myStars(starName: "Ross 128", imagePath: "assets/images/ross_128.jpg"),
  myStars(starName: "Luyten's Star", imagePath: "assets/images/luytens_star.jpg"),
  myStars(starName: "Kapteyn's Star", imagePath: "assets/images/kapteyns_star.jpg"),
  myStars(starName: "Wolf 1061", imagePath: "assets/images/wolf_1061.jpg"),
  myStars(starName: "Gliese 876", imagePath: "assets/images/gliese_876.jpg"),
  myStars(starName: "Gliese 581", imagePath: "assets/images/gliese_581.jpg"),
  myStars(starName: "Lacaille 9352", imagePath: "assets/images/lacaille_9352.jpg"),
  myStars(starName: "Gliese 667 C", imagePath: "assets/images/gliese_667_c.jpg"),
  myStars(starName: "HD 85512", imagePath: "assets/images/hd_85512.jpg"),
  myStars(starName: "LHS 475", imagePath: "assets/images/lhs_475.JPG"),
  myStars(starName: "Wolf 359", imagePath: "assets/images/wolf_359.JPG"),
  myStars(starName: "Teegarden's Star", imagePath: "assets/images/teegardens_star.JPG"),
  myStars(starName: "TRAPPIST-1", imagePath: "assets/images/trappist_1.JPG",),
  myStars(starName: "Gliese 12", imagePath: "assets/images/gliese_12.JPG"),
  myStars(starName: "HD 48948", imagePath: "assets/images/hd_48948.JPG"),
  myStars(starName: "LHS 1140", imagePath: "assets/images/lhs_1140.JPG")
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
  final starReference = FirebaseDatabase.instance.ref(correctStar);
  final starConstellation = await starReference.child("constellation").get();
  final starDistance = await starReference.child("distance").get();
  final starOtherNames = await starReference.child("other_names").get();
  final starSpectralClass = await starReference.child("spectral_class").get();
  final starAbsoluteMagnitude = await starReference.child("star_absolute_magnitude").get();
  final starAge = await starReference.child("star_age").get();
  final starApparentMagnitude = await starReference.child("star_apparent_magnitude").get();
  final starDiscoverer = await starReference.child("star_discoverer").get();
  final starDiscoveryDate = await starReference.child("star_discovery_date").get();
  final starTemperature = await starReference.child("star_temperature").get();

  return [starConstellation.value.toString(), starDistance.value.toString(), starOtherNames.value.toString(), starSpectralClass.value.toString(), starAbsoluteMagnitude.value.toString(), starAge.value.toString(), starApparentMagnitude.value.toString(), starDiscoverer.value.toString(), starDiscoveryDate.value.toString(), starTemperature.value.toString()];
}

Future<Map<String, List>> getOtherNames() async{
  /*Finding if other star name leads user to star
      name on the search suggestions*/
  Map<String, List> otherNames = HashMap();
  for(var star in starsForSearchBar){
    var myStarReference = FirebaseDatabase.instance.ref(star.starName!);
    var otherNamesForStar = await myStarReference.child("other_names").get();
    var otherNamesSplit = otherNamesForStar.value.toString().split(",");
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

  //userItemsExistingUsers? myChosenItemExistingUsers;

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

              //showSearch
              showSearch(
                  context: context,
                  // delegate to customize the search bar
                  delegate: CustomSearchDelegate());
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
            height: 5,
          ),
          Container(
            alignment: Alignment.topCenter,
            child: const Text('Welcome to Star Expedition!', style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold)), //fontFamily: 'Raleway'
            height: 30,
          ),
          Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(10.0),
            child: Text('Star Expedition is an app that allows its users to view and research stars and planets that are potentially capable of supporting life outside our Solar System. Star Expedition will include stars whose spectral classes range from M8 to A5, are within 100 light-years from Earth, and have confirmed terrestrial planets in their habitable zones and planets that are terrestrial and in the habitable zones of their respective stars. Currently, Star Expedition features ${allStars.length} stars and ${allPlanets.length} planets.\n', style: TextStyle(color: Colors.black, fontFamily: 'Raleway'), textAlign: TextAlign.center),
            //height: 200,
          ),
          Container(
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
          ),
          Container(
            child: Text("\n"),
          ),
          Container(
            alignment: Alignment.topCenter,
            child: const Text('Featured Star of the Day', style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold)), //fontFamily: 'Railway'
            height: 25,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 2.0),
              child: InkWell(
                child: Ink.image(
                  image: AssetImage(starsForSearchBar[randomNumber].imagePath!),//, height: 150, width: 150),
                  fit: BoxFit.cover,
                  height: 150,
                  width: 150,
                ),
                onTap: () async{
                  correctStar = starsForSearchBar[randomNumber].starName!;
                  starInfo = await getStarInformation();
                  featuredStarOfTheDayBool = true;

                  //Is the star tracked by a user?
                  if(myNewUsername != "" && myUsername == ""){
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
                  else if(myNewUsername == "" && myUsername != ""){
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
            )
          ),

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

                  //Is the star tracked by a user?
                  if(myNewUsername != "" && myUsername == ""){
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
                  else if(myNewUsername == "" && myUsername != ""){
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
                      await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get().then((result){
                        usersBlurb = result.docs.first.data()["usernameProfileInformation"]["userInformation"];
                        numberOfPostsUserHasMade = result.docs.first.data()["usernameProfileInformation"]["numberOfPosts"];
                        starsUserTracked = result.docs.first.data()["usernameProfileInformation"]["starsTracked"];
                        planetsUserTracked = result.docs.first.data()["usernameProfileInformation"]["planetsTracked"];
                      });
                      print("usersBlurb: ${usersBlurb}");
                      print("numberOfPostsUserHasMade: ${numberOfPostsUserHasMade}");
                      print("starsUserTracked: ${starsUserTracked}");
                      print("planetsUserTracked: ${planetsUserTracked}");
                      Navigator.pushReplacementNamed(context, routesToOtherPages.userProfileInUserPerspectivePage);
                    }
                    else if(myUsername == "" && myNewUsername != ""){
                      await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get().then((result){
                        usersBlurb = result.docs.first.data()["usernameProfileInformation"]["userInformation"];
                        numberOfPostsUserHasMade = result.docs.first.data()["usernameProfileInformation"]["numberOfPosts"];
                        starsUserTracked = result.docs.first.data()["usernameProfileInformation"]["starsTracked"];
                        planetsUserTracked = result.docs.first.data()["usernameProfileInformation"]["planetsTracked"];
                      });
                      print("usersBlurb: ${usersBlurb}");
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
                    Navigator.pushReplacementNamed(context, routesToOtherPages.whyMade);
                  }
              ),
              ListTile(
                  title: Text("Information about the Spectral Classes of Stars"),
                  onTap: () {
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
                  Navigator.pushReplacementNamed(context, routesToOtherPages.conversionCalculator);
                }
              ),
              ListTile(
                title: Text("User Search"),
                onTap: () async{
                  //List<dynamic> myUserList = [];
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
    //HashMap<String?, String> otherNamesMatchQuery = new HashMap();
    //myStars starInMatchQuery = myStars(starName: "", imagePath: "");


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

              if(myNewUsername != "" && myUsername == ""){
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
              else if(myNewUsername == "" && myUsername != ""){
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

              Navigator.of(context).push(MaterialPageRoute(builder: (context) => articlePage(starInfo), settings: RouteSettings(arguments: myMatchQuery[index])));
            },
            leading: Image.asset(myMatchQuery[index].imagePath!, fit: BoxFit.cover, height: 50, width: 50)); //height: 50, width: 50, scale: 1.5));
            //trailing: Icon(Icons.whatshot_rounded));
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
    final ref = FirebaseDatabase.instance.ref(correctStar);
    print('This is the correct star: ' + correctStar);
    /*DatabaseEvent de = await ref.once();
    return Future.delayed(Duration(seconds: 1), () {
      return de.snapshot.value as String; // Data should be returned from the snapshot.
    });*/
    final snapshot = await ref.child('Planets').get();
    if (snapshot.exists) {
      getKeys(snapshot.value as Map); // Calling getKeys so that I can get the planets' names
      print(snapshot.value);
    } else {
      print('No data available.');
    }
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
    final getPlanetAttribute = FirebaseDatabase.instance.ref("${correctStar}/Planets/${correctPlanet}");
    final discoveryDate = await getPlanetAttribute.child("discovery_date").get();
    final distanceFromStar = await getPlanetAttribute.child("distance_from_star").get();
    final earthMasses = await getPlanetAttribute.child("earth_masses").get();
    final knownGases = await getPlanetAttribute.child("known_gases").get();
    final orbitalPeriod = await getPlanetAttribute.child("orbital_period").get();
    final planetTemperature = await getPlanetAttribute.child("planet_temperature").get();

    return Future.delayed(Duration(seconds: 1), () {
      return [discoveryDate.value.toString(), distanceFromStar.value.toString(), earthMasses.value.toString(), knownGases.value.toString(), orbitalPeriod.value.toString(), planetTemperature.value.toString()];
    });
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
            else if(fromStarList == true){
              fromStarList = false,
              Navigator.push(bc, MaterialPageRoute(builder: (BuildContext context) => starsList())),
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
                      height: 5,
                    ),
                    Center(
                      child: Text("Image of Star\n", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                    ),
                    Center(
                      child: Image(
                        image: AssetImage(starsForSearchBar[myStarIndex].imagePath!),
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: 5,
                    ),
                    Center(
                      child: Text("\nStar Information", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                    ),
                    Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "\nConstellation: ",
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
                    /*
                    Container(
                      child: Text("Constellation: " + starInfo[0].toString() + '\n' +
                      "Distance (in light-years): " + starInfo[1].toString() + '\n' +
                      "Other names: " + starInfo[2].toString() + '\n' +
                      "Spectral class: " + starInfo[3].toString() + '\n' +
                      "Absolute magnitude: " + starInfo[4].toString() + '\n' +
                      "Age of star: " + starInfo[5].toString() + '\n' +
                      "Apparent magnitude: " + starInfo[6].toString() + '\n' +
                      "Discoverer of star: " + starInfo[7].toString() + '\n' +
                      "Discovery date of star: " + starInfo[8].toString() + '\n' +
                      "Temperature (in Kelvin): " + starInfo[9].toString()),
                      height: 180,
                      width: 360,
                      alignment: Alignment.center,
                    ),*/
                    Center(
                      child: Text("\nConfirmed Terrestrial Planets",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                    ),
                    Column(
                      children: <Widget>[
                        ListView.builder(
                        itemCount: myData.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Column(
                            children: <Widget>[
                              Container(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.center,
                              //height: 40,
                              //width: 15,
                              //color: Colors.grey,
                              //margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                              //radius: 10, //const EdgeInsets.all(10),
                                child: InkWell(
                                  child: UnconstrainedBox(
                                    child: Container(
                                      //alignment: Alignment.center,
                                      child: Text(myData[index], textAlign: TextAlign.center),
                                    ),
                                  ),
                                  onTap: () async {
                                    correctPlanet = myData[index];
                                    informationAboutPlanet = await getPlanetData();
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => planetArticle(informationAboutPlanet)));
                                    //Navigator.push(context, new MaterialPageRoute(builder: (context) => articlePage(articlepage: ));
                                    //Navigator.push(context, new MaterialPageRoute(builder: (context) => new planetArticle(starAndPlanetInfo: new starAndPlanetInformation)));

                                    //Is the planet tracked by the user?
                                    if(myNewUsername != "" && myUsername == ""){
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
                                    else if(myNewUsername == "" && myUsername != ""){
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
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
                          if(((myNewUsername != "" && myUsername == "") || (myNewUsername == "" && myUsername != "")) && starTracked == false)
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: InkWell(
                                  child: Ink(
                                    color: Colors.black,
                                    padding: EdgeInsets.all(5.0),
                                    child: Text("Track this Star", style: TextStyle(color: Colors.white)),
                                  ),
                                  onTap: () async{
                                    if(myNewUsername != "" && myUsername == ""){
                                      TextEditingController reasonForStarTrackNewUsers = TextEditingController();

                                      var user = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                      user.docs.forEach((result){
                                        docNameForStarsTrackedNewUser = result.id;
                                      });
                                      print(docNameForStarsTrackedNewUser);

                                      DocumentSnapshot<Map<dynamic, dynamic>> mySnapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForStarsTrackedNewUser).get();
                                      Map<dynamic, dynamic>? individual = mySnapshotNewUsers.data();

                                      print(individual?["usernameProfileInformation"]);
                                      print(individual?["usernameProfileInformation"]["starsTracked"]);

                                      var starsTracked = individual?["usernameProfileInformation"]["starsTracked"];

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
                                                          FirebaseFirestore.instance.collection("User").doc(docNameForStarsTrackedNewUser).update({
                                                            "usernameProfileInformation.starsTracked": starsTracked,
                                                          }).then((outcome) {
                                                            print("starsTracked updated!");
                                                          });
                                                          Navigator.pop(bc);
                                                          showSearch(
                                                              context: context,
                                                              delegate: CustomSearchDelegate()
                                                          );
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

                                      var user = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                      user.docs.forEach((result){
                                        docNameForStarsTrackedExistingUser = result.id;
                                      });
                                      print(docNameForStarsTrackedExistingUser);

                                      DocumentSnapshot<Map<dynamic, dynamic>> mySnapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForStarsTrackedExistingUser).get();
                                      Map<dynamic, dynamic>? individual = mySnapshotExistingUsers.data();

                                      print(individual?["usernameProfileInformation"]);
                                      print(individual?["usernameProfileInformation"]["starsTracked"]);

                                      var starsTracked = individual?["usernameProfileInformation"]["starsTracked"];

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
                                                      starsTracked.addEntries({theStar.starName!: reasonForStarTrackExistingUsers.text}.entries);
                                                      FirebaseFirestore.instance.collection("User").doc(docNameForStarsTrackedExistingUser).update({
                                                        "usernameProfileInformation.starsTracked": starsTracked,
                                                      }).then((outcome) {
                                                      print("starsTracked updated!");
                                                    });
                                                    Navigator.pop(bc);
                                                    showSearch(
                                                        context: context,
                                                        delegate: CustomSearchDelegate()
                                                    );
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
                          if(((myNewUsername != "" && myUsername == "") || (myNewUsername == "" && myUsername != "")) && starTracked == true)
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: InkWell(
                                child: Ink(
                                  color: Colors.black,
                                  padding: EdgeInsets.all(5.0),
                                  child: Text("Untrack this Star", style: TextStyle(color: Colors.white)),
                                ),
                                onTap: () async{
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

                                                Navigator.pop(context);
                                                showSearch(
                                                    context: context,
                                                    delegate: CustomSearchDelegate()
                                                );
                                              }
                                              else if(myNewUsername == "" && myUsername != ""){
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

                                                Navigator.pop(context);
                                                showSearch(
                                                    context: context,
                                                    delegate: CustomSearchDelegate()
                                                );
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
            if(fromPlanetList == true){
              fromPlanetList = false;
              Navigator.push(theContext, MaterialPageRoute(builder: (BuildContext context) => planetsList()));
            }
            else{
              hostStarInformation = await getStarInformation();
              print("The host star information: $hostStarInformation");

              if(myNewUsername != "" && myUsername == ""){
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
              else if(myNewUsername == "" && myUsername != ""){
                var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                var docNameForExistingUsers;
                theExistingUser.docs.forEach((result){
                  docNameForExistingUsers = result.id;
                });

                DocumentSnapshot<Map<dynamic, dynamic>> snapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForExistingUsers).get();
                Map<dynamic, dynamic>? individual = snapshotExistingUsers.data();

                starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(correctStar);
                print("starTracked: ${starTracked}");
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
                      height: 5,
                    ),
                    Center(
                        child: Text("Planet Information",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0))
                    ),
                    Column(
                      //alignment: Alignment.center,
                      //height: 80,
                      //width: 360,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "\nDiscovery date of planet: ",
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
                        if(((myNewUsername != "" && myUsername == "") || (myNewUsername == "" && myUsername != "")) && planetTracked == false)
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: InkWell(
                                child: Ink(
                                  color: Colors.black,
                                  padding: EdgeInsets.all(5.0),
                                  child: Text("Track this Planet", style: TextStyle(color: Colors.white)),
                                ),
                                onTap: () async{
                                  if(myNewUsername != "" && myUsername == ""){
                                    TextEditingController reasonForPlanetTrackNewUsers = TextEditingController();

                                    var user = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                    user.docs.forEach((result){
                                      docNameForPlanetsTrackedNewUser = result.id;
                                    });
                                    print(docNameForPlanetsTrackedNewUser);

                                    DocumentSnapshot<Map<dynamic, dynamic>> mySnapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForPlanetsTrackedNewUser).get();
                                    Map<dynamic, dynamic>? individual = mySnapshotNewUsers.data();

                                    print(individual?["usernameProfileInformation"]);
                                    print(individual?["usernameProfileInformation"]["planetsTracked"]);

                                    var planetsTracked = individual?["usernameProfileInformation"]["planetsTracked"];

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
                                                        FirebaseFirestore.instance.collection("User").doc(docNameForPlanetsTrackedNewUser).update({
                                                          "usernameProfileInformation.planetsTracked": planetsTracked,
                                                        }).then((outcome) {
                                                          print("planetsTracked updated!");
                                                        });

                                                        hostStarInformation = await getStarInformation();
                                                        print("hoststarinformation: ${hostStarInformation}");
                                                        Navigator.pop(theContext);
                                                        Navigator.of(theContext).push(MaterialPageRoute(builder: (theContext) => articlePage(hostStarInformation), settings: RouteSettings(arguments: myStars(starName: correctStar, imagePath: "assets/images"))));
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
                                                )
                                              ],
                                            );
                                          }
                                      );
                                    }
                                  }
                                  else if(myNewUsername == "" && myUsername != ""){
                                    TextEditingController reasonForPlanetTrackExistingUsers = TextEditingController();

                                    var user = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                    user.docs.forEach((result){
                                      docNameForPlanetsTrackedExistingUser = result.id;
                                    });
                                    print(docNameForPlanetsTrackedExistingUser);

                                    DocumentSnapshot<Map<dynamic, dynamic>> mySnapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForPlanetsTrackedExistingUser).get();
                                    Map<dynamic, dynamic>? individual = mySnapshotExistingUsers.data();

                                    print(individual?["usernameProfileInformation"]);
                                    print(individual?["usernameProfileInformation"]["planetsTracked"]);

                                    var planetsTracked = individual?["usernameProfileInformation"]["planetsTracked"];

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
                                                        FirebaseFirestore.instance.collection("User").doc(docNameForPlanetsTrackedExistingUser).update({
                                                          "usernameProfileInformation.planetsTracked": planetsTracked,
                                                        }).then((outcome) {
                                                          print("planetsTracked updated!");
                                                        });

                                                        hostStarInformation = await getStarInformation();
                                                        print("hoststarinformation: ${hostStarInformation}");
                                                        Navigator.pop(context);
                                                        Navigator.of(theContext).push(MaterialPageRoute(builder: (theContext) => articlePage(hostStarInformation), settings: RouteSettings(arguments: myStars(starName: correctStar, imagePath: "assets/images"))));
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
                                                )
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
                            padding: EdgeInsets.all(10.0),
                            child: InkWell(
                                child: Ink(
                                  color: Colors.black,
                                  padding: EdgeInsets.all(5.0),
                                  child: Text("Untrack this Planet", style: TextStyle(color: Colors.white)),
                                ),
                                onTap: () async{
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

                                                    hostStarInformation = await getStarInformation();
                                                    print("hoststarinformation: ${hostStarInformation}");
                                                    Navigator.pop(context);
                                                    Navigator.of(theContext).push(MaterialPageRoute(builder: (theContext) => articlePage(hostStarInformation), settings: RouteSettings(arguments: myStars(starName: correctStar, imagePath: "assets/images"))));
                                                  }
                                                  else if(myNewUsername == "" && myUsername != ""){
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

                                                    hostStarInformation = await getStarInformation();
                                                    print("hoststarinformation: ${hostStarInformation}");
                                                    Navigator.pop(context);
                                                    Navigator.of(theContext).push(MaterialPageRoute(builder: (theContext) => articlePage(hostStarInformation), settings: RouteSettings(arguments: myStars(starName: correctStar, imagePath: "assets/images"))));
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
                                }
                            ),
                          ),
                      ],
                      /*Text("Discovery date: " + informationAboutPlanet[0].toString() + '\n' +
                  "Distance from star: " + informationAboutPlanet[1].toString() + '\n' +
                  "Earth masses: " + informationAboutPlanet[2].toString() + '\n' +
                  "Orbital period: " + informationAboutPlanet[3].toString() + '\n' +
                  "Temperature (in Kelvin): " + informationAboutPlanet[4].toString()),*/
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