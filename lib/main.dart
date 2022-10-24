import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:starexpedition4/spectralClassPage.dart';
//import 'package:starexpedition4/spectralClassPage.dart';

/* String correctString = "";
FirebaseDatabase database = FirebaseDatabase.instance;
DatabaseReference ref = FirebaseDatabase.instance.ref(myString);*/

String correctStar = "";
String correctPlanet = "";
List<String> informationAboutPlanet = [];
List<String> starInfo = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class myStars{
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
        primarySwatch: Colors.red,
      ),
      home: StarExpedition(),
      routes:{
        routesToOtherPages.spectralClass: (context) => spectralClassPage(),
      }
    );
  }
}

class routesToOtherPages{
  static String spectralClass = spectralClassPageState.nameOfRoute;
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

class theStarExpeditionState extends State<StarExpedition> {
  List<String> starInfo = [];
  theStarExpeditionState(this.starInfo);
  final CustomSearchDelegate csd = new CustomSearchDelegate();

  @override
  Widget build(BuildContext context) {
    DateTime? timeNow = DateTime.now();
    //var nextMidnight = DateTime(timeNow.year, timeNow.month, timeNow.day + 1);

    int numberOfDays = timeNow.day;
    numberOfDays = endOfMonthAdjustment(numberOfDays);
    print(numberOfDays.toString());
    int numberOfStars = starsForSearchBar.length;
    int randomNumber = numberOfDays % numberOfStars;
    //Maybe you can make an if statement that ensures that today's star name and image are not the same as yesterday's.
    // I am currently testing the if statement with testTime.
    print(timeNow);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Star Expedition",
        ),
        actions: [
          IconButton(
            onPressed: () {
              // method to show the search bar
              //_getStars(); // I am putting it here is just for testing; it is just to see if we are getting any data from firebase (the data we want, such as data relating to Alpha Centauri).
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
        //heightFactor: 15,
        /*child: (
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const <Widget>[
              Text('Welcome to Star Expedition!', style: TextStyle(color: Colors.black, fontFamily: 'Railway')),
              Text('Star Expedition is an app that allows its users to view and research stars with terrestrial planets and the terrestrial planets that orbit those stars. Star Expedition will include stars whose spectral classes range from M8 to A5 and are within 100 light-years from Earth.', style: TextStyle(color: Colors.black, fontFamily: 'Railway'))
            ]
          )
          /*SizedBox(
            width: 100,
            child: Center(
              child: Text('Welcome to Star Expedition!', style: TextStyle(color: Colors.black, fontFamily: 'Raleway'))
            ),
          )*/
        ),*/

          /*SizedBox(height: 20),
          Text('Star Expedition is an app that allows its users to view and research stars with terrestrial planets and the terrestrial planets that orbit those stars. Star Expedition will include stars whose spectral classes range from M8 to A5 and are within 100 light-years from Earth.'),
          */
          //heightFactor: 20,
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: const Text('Welcome to Star Expedition!', style: TextStyle(color: Colors.black, fontFamily: 'Raleway', fontSize: 20.0)),
            height: 30,
          ),
          Container(
            alignment: Alignment.topCenter,
            child: const Text('Star Expedition is an app that allows its users to view and research stars with terrestrial planets and the terrestrial planets that orbit those stars. Star Expedition will include stars whose spectral classes range from M8 to A5 and are within 100 light-years from Earth.', style: TextStyle(color: Colors.black, fontFamily: 'Raleway'), textAlign: TextAlign.center),
            height: 200,
          ),
          Container(
            alignment: Alignment.topCenter,
            child: const Text('Featured Star of the Day', style: TextStyle(color: Colors.black, fontFamily: 'Railway', fontSize: 20.0)),
            height: 25,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 2.0),
              child: Image.asset(starsForSearchBar[randomNumber].imagePath!, height: 150, width: 150),
            )
          ),
          /*Container(
            alignment: Alignment.topCenter,
            child: const Text('Featured Star of the Day', style: TextStyle(color: Colors.black, fontFamily: 'Raleway', fontSize: 20.0)),
            height: 25,
          ),
          Container( // This will eventually have a method that will have generate an image of a star and its name randomly.
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(starsForSearchBar[randomNumber].imagePath!),
                fit: BoxFit.fill,
                alignment: Alignment.topCenter,
              ),
            ),
          height: 150,
            width: 150,
          ),*/
          GestureDetector(
            child: Container(
              alignment: Alignment.topCenter,
              height: 30,
              child: Text(starsForSearchBar[randomNumber].starName!),
            ),
            onTap: () async{
              correctStar = starsForSearchBar[randomNumber].starName!;
              starInfo = await getStarInformation();
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
        ],
      ),
      drawer: starExpeditionNavigationDrawer(),
      );
  }

  int endOfMonthAdjustment(int numberOfDays) {
    if(numberOfDays == 31)
    {
      numberOfDays = 32;
    }
    return numberOfDays;
  }
}

class starExpeditionNavigationDrawer extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Drawer(
        child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.red,
                ),
                child: Text("Star Expedition Navigation Drawer", style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: "Railway")),
              ),
              ListTile(
                  title: Text("Why Star Expedition Was Made"),
                  onTap: () {
                    Navigator.pop(context);
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
                    Navigator.pop(context);
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
  //const CustomSearchDelegate({super.key, required this.starsForSearch});
  // final List<myStars> starsForSearch;
  // This is a demo list to show querying
  // late final myStars outcome;
  /*List<String> searchTerms = [
    "Proxima Centauri",
    "Alpha Centauri",
    "Tau Ceti",
    "Ross 128",
    "Luyten's Star",
    "Kapteyn's Star",
    "Wolf 1061",
    "Gliese 876",
    "Gliese 581",
    "Lacaille 9352",*/
  //];

  /*List<String> theImages = [
    'assets/images/proxima_centauri.jpg',
    'assets/images/alpha_centauri.jpg',
    'assets/images/tau_ceti.jpg',
    'assets/images/ross_128.jpg',
    'assets/images/luytens_star.jpg',
    'assets/images/kapteyns_star.jpg',
    'assets/images/wolf_1061.jpg',
    'assets/images/gliese_876.jpg',
    'assets/images/gliese_581.jpg',
    'assets/images/lacaille_9352.jpg'
  ];*/

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
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  // This is the third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<myStars> myMatchQuery = [];
    for (var star in starsForSearchBar) {
      if (star.starName!.toLowerCase().contains(query.toLowerCase())) {
        myMatchQuery.add(star!);
      }
    }
    return ListView.builder(
      itemCount: myMatchQuery.length,
      itemBuilder: (context, index) {
        var result = myMatchQuery[index];
        return ListTile(
          title: Text(result.starName!), // The ! is there so that it can prevent errors, especially for variables that are set to null
          /*onTap: () {
            print('Testing pop-up');
            showAlertDialog(context);
          }*/
        );
      },
    );
  }

  // This is the last overwrite (to show the querying process at the runtime)
  @override
  Widget buildSuggestions(BuildContext context) {
    List<myStars> myMatchQuery = [];
    //String correctStar = "";
    /*for (var stars in starsForSearchBar) {
      /*if (stars.toLowerCase().contains(query.toLowerCase())) {
        myMatchQuery.add(stars);
      }*/
    }*/
    for (var star in starsForSearchBar) {
      if (star.starName!.toLowerCase().contains(query.toLowerCase())) {
        myMatchQuery.add(star!);
      }
    }
    return ListView.builder(
      itemCount: myMatchQuery.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(myMatchQuery[index].starName!,
                style: TextStyle(
                    color: Colors.deepPurpleAccent, fontFamily: 'Raleway')),
            onTap: () async{
              correctStar = myMatchQuery[index].starName!;
              print(correctStar);
              //showAlertDialog(context);
             // Navigator.push(context, MaterialPageRoute(builder: (context) => articlePage(ms: ));
              //correctStar = myMatchQuery[index].starName!;
              //Navigator.push(context, new MaterialPageRoute(builder: (context) => articlePage(), arguments: )); // I am trying to use this to push the data from the star search suggestions to the dialog
              // Navigator.of(context).push(MaterialPageRoute(builder: (context) => articlePage(starInfo), settings: RouteSettings(arguments: myMatchQuery[index])));
              //print(Navigator.push(context, showAlertDialog(context)));
              starInfo = await getStarInformation();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => articlePage(starInfo), settings: RouteSettings(arguments: myMatchQuery[index])));
            },
            leading: Image.asset(myMatchQuery[index].imagePath!, height: 50, width: 50, scale: 1.5),
            trailing: Icon(Icons.whatshot_rounded));
      },
    );
  }
}

class articlePage extends StatelessWidget{
  //final myStars ms;
  //articlePage({Key? key, required this.ms}) : super(key:key);
  /*DatabaseReference dr = FirebaseDatabase.instance.ref("Ross 128");

  _getStarInfo() async{
    DatabaseEvent de = await dr.once();
  }*/
  List<String> informationAboutPlanet = [];
  var myPlanet = <String>[];

  final List<String> starInfo;
  articlePage(this.starInfo);


  void getKeys(Map myMap){ // This is for getting planet names, which are keys
    myMap.keys.forEach((key) {
      //print(key);
      myPlanet.add(key);
      print("The key is " + key);
    });
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
    final getPlanetAttribute = FirebaseDatabase.instance.ref("${correctStar}/Planets/${correctPlanet}");
    final discoveryDate = await getPlanetAttribute.child("discovery_date").get();
    final distanceFromStar = await getPlanetAttribute.child("distance_from_star").get();
    final earthMasses = await getPlanetAttribute.child("earth_masses").get();
    final orbitalPeriod = await getPlanetAttribute.child("orbital_period").get();
    final planetTemperature = await getPlanetAttribute.child("planet_temperature").get();

    return [discoveryDate.value.toString(), distanceFromStar.value.toString(), earthMasses.value.toString(), orbitalPeriod.value.toString(), planetTemperature.value.toString()];
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
        title: Text(theStar.starName!),
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
                /*return new <Widget>[
                  Container(
                    child: Text("Information about the star"),
                    height: 80,
                    width: 360,
                  ),*/
                /*children: <Widget>[
                  Container(
                    child: Text("This is an article about a star"),
                  );
                ];*/
                return Column(
                  children: [
                    Container(
                      child: Text("Star Information:", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
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
                    ),
                    Container(
                      child: Text("Confirmed terrestrial planets:", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                        child: ListView.builder(
                        itemCount: myData.length,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 40,
                            width: 15,
                            color: Colors.grey,
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                            child: InkWell(
                                radius: 10, //const EdgeInsets.all(10),
                                child: Text(myData[index], textAlign: TextAlign.center),
                                onTap: () async {
                                  correctPlanet = myData[index];
                                  //getPlanetData();
                                  informationAboutPlanet = await getPlanetData();
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => planetArticle(informationAboutPlanet)));
                                  //Navigator.push(context, new MaterialPageRoute(builder: (context) => articlePage(articlepage: ));
                                },
                            ),
                          );
                        }),
                      ),
                  ],
                );
                //];
          }
              else{ // This else statement indicates what happens if the Firebase database returns nothing.
                return Text("No data is available"); // If the snapshot does not have data, this will print.
              }
            }
          }
          else{
            return Text("Star data is still loading"); //This represents a scenario where the connection has not finished yet.
          }
        },
        future: getStarData(),
      ),
    );
  }
}

class planetArticle extends StatelessWidget{

  //final articlePage articlepage;
  final List<String> informationAboutPlanet;
  planetArticle(this.informationAboutPlanet);
  //planetArticle({required Key key, required this.articlepage}) : super(key: key);

  @override
  Widget build(BuildContext theContext) {
    return Scaffold(
      appBar: AppBar(
        title: Text(correctPlanet),
      ),
      body: Wrap(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            height: 80,
            width: 360,
            child:
              Text("Discovery date: " + informationAboutPlanet[0].toString() + '\n' +
                  "Distance from star: " + informationAboutPlanet[1].toString() + '\n' +
                  "Earth masses: " + informationAboutPlanet[2].toString() + '\n' +
                  "Orbital period: " + informationAboutPlanet[3].toString() + '\n' +
                  "Temperature (in Kelvin): " + informationAboutPlanet[4].toString()),

          ),
        ],
      ),
    );
  }
        /*children: <Widget>[
          Container(
            informationAboutPlanet = await ap.getPlanetData(),
            print('Testing information about the planet'),
            print(informationAboutPlanet.toString())
            ),
        ],*/
}