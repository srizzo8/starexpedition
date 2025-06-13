import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:starexpedition4/registerPage.dart';

import 'loginPage.dart';
import 'main.dart' as myMain;

String mySpectralClass = "";
bool fromSpectralClassPage = false;

class spectralClassPage extends StatefulWidget{
  const spectralClassPage({Key? key}) : super(key: key);

  @override
  spectralClassPageState createState() => spectralClassPageState();
}

class spectralClassPageState extends State<spectralClassPage>{
  static String nameOfRoute = '/spectralClassPage';
  //final spectralClassSnapshot = await spectralClassRef.get();
  List<String> spectralClassOfStars = [];
  //String spectralClass = " ";
  var scpNumberOfStars = myMain.starsForSearchBar.length;
  List<String> spectralClassCount = [];
  bool b = false;

  @override
  Future <List<String>> getSpectralClassData() async{
    List<String> spectralClasses = [];
    for(int i = 0; i < scpNumberOfStars; i++) {
      final spectralClassRef = FirebaseDatabase.instance.ref(myMain.starsForSearchBar[i].starName!);
      //print('This is spectralClassRef: ' + spectralClassRef.toString());
      var spectralClassSnapshot = await spectralClassRef.child("spectral_class").get();
      //print('This is spectralClassSnapshot: ' + spectralClassSnapshot.toString());
      //print(spectralClassSnapshot.value.toString());
      spectralClasses.add(spectralClassSnapshot.value.toString());
    }
    //print(spectralClasses);

    return spectralClasses;
  }

  //spectralClassOfStars = await getSpectralClassData();

  @override
  Future<List<String>> generateSpectralClasses() async{
    int countMStars = 0;
    int countKStars = 0;
    int countGStars = 0;
    int countFStars = 0;
    int countAStars = 0;
    int countBStars = 0;
    int countOStars = 0;

    List<String> gscSpectralClassesOfStars = [];
    gscSpectralClassesOfStars = await getSpectralClassData();

    print(gscSpectralClassesOfStars);
    for(int i = 0; i < gscSpectralClassesOfStars.length; i++)
    {
      String mySpectralClass = gscSpectralClassesOfStars[i];
      print(mySpectralClass[0]);
      switch(mySpectralClass[0])
      {
        case 'M':
          countMStars++;
          break;
        case 'K':
          countKStars++;
          break;
        case 'G':
          countGStars++;
          break;
        case 'F':
          countFStars++;
          break;
        case 'A':
          countAStars++;
          break;
        case 'B':
          countBStars++;
          break;
        case 'O':
          countOStars++;
          break;
      }
      //print([countMStars.toString(), countKStars.toString(), countGStars.toString(), countFStars.toString(), countAStars.toString(), countBStars.toString(), countOStars.toString()]);

    }
    return [countMStars.toString(), countKStars.toString(), countGStars.toString(), countFStars.toString(), countAStars.toString(), countBStars.toString(), countOStars.toString()];
  }

  void getDataForMyLists() async{
    spectralClassOfStars = await getSpectralClassData();
    spectralClassCount = await generateSpectralClasses();
    setState(() {
      b = true;
    });
  }

  @override
  void initState() {
    /*Future.delayed(Duration.zero,() async {
      spectralClassOfStars = await getSpectralClassData();
      print('The spectral classes of stars: ' + spectralClassOfStars.toString());
      spectralClassCount = await generateSpectralClasses();
      print('This is spectralClassCount: ' + spectralClassCount.toString());
    });*/
    getDataForMyLists();
    super.initState();

    //print('This is spectralClassCount: ' + spectralClassCount.toString());
  }
  /*void futureListToListConverterGSCD(Future<List<String>> fls) async{
    Future<List<String>> flcSpectralClassOfStars = getSpectralClassData();
    List<String> listOfStrings = await flcSpectralClassOfStars;
    print("New list: " + listOfStrings.toString());
  }*/

  /*void main() async{
    List<String> list1 = await getSpectralClassData();
    List<String> list2 = await generateSpectralClasses();
    spectralClassOfStars.add(list1.toString());
    spectralClassCount.add(list2.toString());
    print('spectralClassOfStars in main method: ' + spectralClassOfStars.toString());
    print('spectralClassCount in main method: ' + spectralClassCount.toString());
  }*/

  @override
  Widget build(BuildContext bc) {
    /*Future.delayed(Duration.zero, () async {
      spectralClassOfStars = await getSpectralClassData();
      print('The spectral classes of stars: ' + spectralClassOfStars.toString());
      spectralClassCount = await generateSpectralClasses();
      print('This is spectralClassCount: ' + spectralClassCount.toString());
    });*/

    //futureListToListConverterGSCD(getSpectralClassData());
    //Future.delayed(const Duration(milliseconds: 200), (){
    if(b == true) {
      print('spectralClassOfStars in build method: ' + spectralClassOfStars.toString());
      print('spectralClassCount in build method: ' + spectralClassCount.toString());
      //print('This is spectralClassCount in the build method: ' + spectralClassCount.toString());
    }//});
    /*() async{
      spectralClassCount = await generateSpectralClasses();
      print('async spectralClassCount: ' + spectralClassCount.toString());
    };
    print('spectralClassCount outside async: ' + spectralClassCount.toString());*/

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        /*leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            print("Going to home page"),
            Navigator.push(bc, MaterialPageRoute(builder: (bc) => const myMain.StarExpedition())),
          },
        ),*/
      ),
      body: spectralClassOfStars.isEmpty || spectralClassCount.isEmpty? Center(child: CircularProgressIndicator()):
      Wrap(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Center(
            child: Container(
              //alignment: Alignment.topCenter,
              child: Text("Spectral Classes of Stars", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Text("This page has information regarding each star spectral class. "
                "To see a list of stars that have articles on Star Expedition that belong to a certain spectral class, click the number in the \"Stars with Articles\" column.", textAlign: TextAlign.center),
          ),
          Center(
            child: DataTable(
              columnSpacing: 30.0,
              columns: [
                DataColumn(label: Expanded(
                  child: Center(
                      child: Text('Spectral Class', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5))),
                ),
                ),
                DataColumn(label: Expanded(
                  child: Center(
                      child: Text('Temperature', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5))),
                ),
                ),
                DataColumn(label: Expanded(
                  child: Center(
                      child: Text('Stars with Articles', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5))),
                ),
                ),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('M'),
                  ),
                  ),
                  DataCell(Align(
                    //alignment: Alignment.center,
                    child: Text('2500-3800 K'),
                  ),
                  ),
                  //DataCell(Text('Proxima Centauri')),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      child: Text(spectralClassCount[0].toString(), style: TextStyle(color: Colors.black)),
                      onTap: (){
                        print("You clicked me!");
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                        mySpectralClass = "M";
                      },
                    ),
                  ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('K'),
                  ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('3800-5300 K'),
                  ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      child: Text(spectralClassCount[1].toString(), style: TextStyle(color: Colors.black)),
                      onTap: (){
                        print('You clicked me!');
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                        mySpectralClass = "K";
                      },
                    ),
                  ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('G'),
                  ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('5300-6000 K'),
                  ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      child: Text(spectralClassCount[2].toString(), style: TextStyle(color: Colors.black)),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                        mySpectralClass = "G";
                      },
                    ),
                  ),
                  ),      //Text(spectralClassCount[2].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))),
                ]),
                DataRow(cells: [
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('F'),
                  ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('6000-7300 K'),
                  ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      child: Text(spectralClassCount[3].toString(), style: TextStyle(color: Colors.black)),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                        mySpectralClass = "F";
                      },
                    ),
                  )
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('A'),
                  ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('7300-10000 K'),
                  ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      child: Text(spectralClassCount[4].toString(), style: TextStyle(color: Colors.black)),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                        mySpectralClass = "A";
                      },
                    ),
                  )
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('B'),
                  ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('10000-30000 K'),
                  ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      child: Text(spectralClassCount[5].toString(), style: TextStyle(color: Colors.black)),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                        mySpectralClass = "B";
                      },
                    ),
                  )
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('O'),
                  ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: Text('30000+ K'),
                  ),
                  ),
                  DataCell(Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      child: Text(spectralClassCount[6].toString(), style: TextStyle(color: Colors.black)),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                        mySpectralClass = "O";
                      },
                    ),
                  )
                  ),
                ]),
              ],
            ),
          ),
          Center(
            child: Container(
              child: Text("Sources", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
              height: 20,
              width: 360,
            ),
          ),
          Center(
            child: Container(
              child: Text("https://www.handprint.com/ASTRO/specclass.html", textAlign: TextAlign.center),
              height: 20,
              width: 360,
            ),
          ),
        ],
      ),
      drawer: myMain.starExpeditionNavigationDrawer(),
    );
    //});
    /*return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Wrap(
      children: <Widget>[
        Container(
          alignment: Alignment.topCenter,
          child: Text("Hello World"),
        ),
      ]
    ),
    );*/
  }
}

class listForSpectralClassesPage extends StatefulWidget{
  const listForSpectralClassesPage({Key? key}) : super(key: key);

  @override
  listForSpectralClassesPageState createState() => listForSpectralClassesPageState();
}

class listForSpectralClassesPageState extends State<listForSpectralClassesPage>{

  List<String> mStars = [];
  List<String> kStars = [];
  List<String> gStars = [];
  List<String> fStars = [];
  List<String> aStars = [];
  List<String> bStars = [];
  List<String> oStars = [];
  List<List> fullListOfStars = [];
  bool switchOn = false;
  myMain.myStars clickedStar = myMain.myStars(starName: "not available");

  @override
  Future<List<List>> getStars() async{
    List<String> getMStars = [];
    List<String> getKStars = [];
    List<String> getGStars = [];
    List<String> getFStars = [];
    List<String> getAStars = [];
    List<String> getBStars = [];
    List<String> getOStars = [];

    for(int i = 0; i < myMain.starsForSearchBar.length; i++) {
      print('Current star: ' + myMain.starsForSearchBar[i].starName!.toString());
      final starsWithSpectralClassRef = FirebaseDatabase.instance.ref(myMain.starsForSearchBar[i].starName!);
      //print(starsWithSpectralClassRef.toString());
      var starSnapshot = await starsWithSpectralClassRef.child("spectral_class").get();
      //print('This is starSnapshot: ' + starSnapshot.toString());
      String starSnapshotString = starSnapshot.value.toString();
      String starSnapshotSpectralClass = starSnapshotString[0];
      //print('This is starSnapshotSpectralClass: ' + starSnapshotSpectralClass);
      switch(starSnapshotSpectralClass){
        case "M":
          getMStars.add(myMain.starsForSearchBar[i].starName!);
          break;
        case "K":
          getKStars.add(myMain.starsForSearchBar[i].starName!);
          break;
        case "G":
          getGStars.add(myMain.starsForSearchBar[i].starName!);
          break;
        case "F":
          getFStars.add(myMain.starsForSearchBar[i].starName!);
          break;
        case "A":
          getAStars.add(myMain.starsForSearchBar[i].starName!);
          break;
        case "B":
          getBStars.add(myMain.starsForSearchBar[i].starName!);
          break;
        case "O":
          getOStars.add(myMain.starsForSearchBar[i].starName!);
          break;
      }
    }

    //Sorting stars of each spectral class alphabetically
    getMStars.sort((s1, s2) => s1.toLowerCase().compareTo(s2.toLowerCase()));
    getKStars.sort((s1, s2) => s1.toLowerCase().compareTo(s2.toLowerCase()));
    getGStars.sort((s1, s2) => s1.toLowerCase().compareTo(s2.toLowerCase()));
    getFStars.sort((s1, s2) => s1.toLowerCase().compareTo(s2.toLowerCase()));
    getAStars.sort((s1, s2) => s1.toLowerCase().compareTo(s2.toLowerCase()));
    getBStars.sort((s1, s2) => s1.toLowerCase().compareTo(s2.toLowerCase()));
    getOStars.sort((s1, s2) => s1.toLowerCase().compareTo(s2.toLowerCase()));

    print("List of M-type stars: " + mStars.toString());
    print("List of K-type stars: " + kStars.toString());
    print("List of G-type stars: " + gStars.toString());
    print("List of F-type stars: " + fStars.toString());
    print("List of A-type stars: " + aStars.toString());
    print("List of B-type stars: " + bStars.toString());
    print("List of O-type stars: " + oStars.toString());
    //return "myFutureString";
    return [getMStars, getKStars, getGStars, getFStars, getAStars, getBStars, getOStars];
  }

  void getListOfStars() async{
    fullListOfStars = await getStars();
    setState((){
      switchOn = true;
    });
  }

  @override
  void initState(){
    getListOfStars();
    super.initState();
  }


  @override
  Widget build(BuildContext context){
    //List<String> buildMethodStarList = [];

    if(switchOn == true) {
      //print('Here are some M stars: ' + mStars.toString());
      print('This is fullListOfStars: ' + fullListOfStars.toString());
      //print('List of M stars: ' + fullListOfStars[0].toString());
      //print('An M star: ' + fullListOfStars[0][1].toString());
      //buildMethodStarList = spectralClassListInformation() as List<String>;
      //print(buildMethodStarList);
    }
    List<String> informationAboutClickedStar = [];
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text("Star Expedition"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () =>{
                Navigator.push(context, MaterialPageRoute(builder: (context) => spectralClassPage())),
              }
          )
      ),
      body: fullListOfStars.isEmpty? Center(child: CircularProgressIndicator()):
      Column(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(10.0),
            child: Text("List of stars with articles that belong to the " + mySpectralClass + " spectral class", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: 5,
          ),
          /*Container(
            height: 300,
            width: 360,*/
          /*child: InkWell(
              onTap: (){
                print('You clicked on a star!');
              },
              child: spectralClassListInformation(),
            )*/
          switchOn? Expanded(
            child: ListView.builder(
              itemCount: fullListOfStars[indexPlaceSpectralClass()].length,
              itemBuilder: (context, index){
                return ListTile(
                    title: Text(fullListOfStars[indexPlaceSpectralClass()][index], textAlign: TextAlign.center),
                    onTap: () async{
                      myMain.correctStar = fullListOfStars[indexPlaceSpectralClass()][index];
                      print(myMain.correctStar);
                      clickedStar.starName = myMain.correctStar;
                      print(clickedStar.starName);

                      informationAboutClickedStar = await myMain.getStarInformation();
                      print(informationAboutClickedStar);
                      fromSpectralClassPage = true;

                      myMain.starFileContent = await myMain.readStarFile();
                      myMain.listOfStarUrls = myMain.starFileContent.replaceAll("\n", "").replaceAll("\r", "|").split("|");

                      myMain.listOfStarUrls.removeWhere((myUrl) => myUrl == "" || myUrl == " ");

                      //Is a user tracking this star?
                      if(myNewUsername != "" && myUsername == ""){
                        var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                        var docNameForNewUsers;
                        theNewUser.docs.forEach((result){
                          docNameForNewUsers = result.id;
                        });

                        DocumentSnapshot<Map<dynamic, dynamic>> snapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForNewUsers).get();
                        Map<dynamic, dynamic>? individual = snapshotNewUsers.data();

                        myMain.starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(myMain.correctStar);
                        print("starTracked: ${myMain.starTracked}");
                      }
                      else if(myNewUsername == "" && myUsername != ""){
                        var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                        var docNameForExistingUsers;
                        theExistingUser.docs.forEach((result){
                          docNameForExistingUsers = result.id;
                        });

                        DocumentSnapshot<Map<dynamic, dynamic>> snapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForExistingUsers).get();
                        Map<dynamic, dynamic>? individual = snapshotExistingUsers.data();

                        myMain.starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(myMain.correctStar);
                        print("starTracked: ${myMain.starTracked}");
                      }

                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => myMain.articlePage(informationAboutClickedStar), settings: RouteSettings(arguments: clickedStar)));
                    },
                    leading: Image.asset(myMain.starsForSearchBar[myMain.starsForSearchBar.indexWhere((star) => star.starName! == fullListOfStars[indexPlaceSpectralClass()][index])].imagePath!, fit: BoxFit.cover, height: 50, width: 50));
              },
            ),
          ): Container(),
        ],
      ),
      drawer: myMain.starExpeditionNavigationDrawer(),
    );
  }

  int indexPlaceSpectralClass(){
    int myIndexPlace = 0;
    switch(mySpectralClass) {
      case "M":
        myIndexPlace = 0;
        break;
      case "K":
        myIndexPlace = 1;
        break;
      case "G":
        myIndexPlace = 2;
        break;
      case "F":
        myIndexPlace = 3;
        break;
      case "A":
        myIndexPlace = 4;
        break;
      case "B":
        myIndexPlace = 5;
        break;
      case "O":
        myIndexPlace = 6;
        break;
    }

    return myIndexPlace;
  }
}