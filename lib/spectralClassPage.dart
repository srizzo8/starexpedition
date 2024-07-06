import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            print("Going to home page"),
            Navigator.push(bc, MaterialPageRoute(builder: (bc) => const myMain.StarExpedition())),
          },
        ),
      ),
      body: spectralClassOfStars.isEmpty || spectralClassCount.isEmpty? Center(child: CircularProgressIndicator()):
      Wrap(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: Text(
                "Spectral Classes of Stars", textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
            height: 30,
          ),
          DataTable(
            columns: [
              DataColumn(label: Text('Spectral Class', style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 9.0))),
              DataColumn(label: Text('Temperature', style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 9.0))),
              //DataColumn(label: Text('Example', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Stars with Articles', style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 9.0))),
            ],
            rows: [
              DataRow(cells: [
                DataCell(Text('M')),
                DataCell(Text('2500-3800 K')),
                //DataCell(Text('Proxima Centauri')),
                DataCell(GestureDetector(
                    onTap: (){
                      print("You clicked me!");
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                      mySpectralClass = "M";
                    },
                    child: Text(spectralClassCount[0].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))
                  ),
                ),
              ]),
              DataRow(cells: [
                DataCell(Text('K')),
                DataCell(Text('3800-5300 K')),
                DataCell(GestureDetector(
                    onTap: (){
                      print('You clicked me!');
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                      mySpectralClass = "K";
                      },
                    child: Text(spectralClassCount[1].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))
                ),
                ),
            ]),
              DataRow(cells: [
                DataCell(Text('G')),
                DataCell(Text('5300-6000 K')),
                DataCell(GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                    mySpectralClass = "G";
                  },
                  child: Text(spectralClassCount[2].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))
                ),
                ),      //Text(spectralClassCount[2].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))),
            ]),
              DataRow(cells: [
                DataCell(Text('F')),
                DataCell(Text('6000-7300 K')),
                DataCell(GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                    mySpectralClass = "F";
                },
                child: Text(spectralClassCount[3].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))
                )
                ),
              ]),
              DataRow(cells: [
                DataCell(Text('A')),
                DataCell(Text('7300-10000 K')),
                DataCell(GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                    mySpectralClass = "A";
                  },
                  child: Text(spectralClassCount[4].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))
                )
                ),
              ]),
              DataRow(cells: [
                DataCell(Text('B')),
                DataCell(Text('10000-30000 K')),
                DataCell(GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                    mySpectralClass = "B";
                  },
                  child: Text(spectralClassCount[5].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))
                )
                ),
              ]),
              DataRow(cells: [
                DataCell(Text('O')),
                DataCell(Text('30000+ K')),
                DataCell(GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => listForSpectralClassesPage()));
                    mySpectralClass = "O";
                  },
                  child: Text(spectralClassCount[6].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))
                )),
              ]),
            ],
          ),
          Container(
            child: Text("Sources", textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
            height: 20,
            width: 360,
          ),
          Container(
            child: Text("https://www.handprint.com/ASTRO/specclass.html",
                textAlign: TextAlign.center),
            height: 20,
            width: 360,
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
            Navigator.push(context, MaterialPageRoute(builder: (bc) => const myMain.StarExpedition())),
          }
        )
      ),
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: Text("List of stars with articles that belong to the " + mySpectralClass + " spectral class"),
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
            child: ListView.separated(
              itemCount: fullListOfStars[indexPlaceSpectralClass()].length,
              separatorBuilder: (context, index) => Container(height: 10),
              itemBuilder: (context, index){
                return Container(
                  color: Colors.white12,
                  child: InkWell(
                    onTap: () async{
                      //clickedStar.add(myMain.myStars(starName: fullListOfStars[indexPlaceSpectralClass()][index]));
                      myMain.correctStar = fullListOfStars[indexPlaceSpectralClass()][index];
                      print(myMain.correctStar);
                      clickedStar.starName = myMain.correctStar;
                      print(clickedStar.starName);
                      //clickedStar = ;
                      //print(clickedStar);
                      //print("This is the clicked star: " + clickedStar! as String);
                      informationAboutClickedStar = await myMain.getStarInformation();
                      print(informationAboutClickedStar);
                      fromSpectralClassPage = true;
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => myMain.articlePage(informationAboutClickedStar), settings: RouteSettings(arguments: clickedStar)));
                    },
                    child: Text(fullListOfStars[indexPlaceSpectralClass()][index], textAlign: TextAlign.center),
                  ),
                  //Text(fullListOfStars[indexPlaceSpectralClass()][index], textAlign: TextAlign.center),
                );
              }
            ),
          ): Container(),
            /*Column(
              children: [

              ],
            ),*/
            //),
            //child: spectralClassListInformation(),
        ]
      )
    );
  }

  /*myMain.myStars starDecider(){
    if(clickedStar != null){
      print("clickedStar is empty!");
    }
    else{
      myMain.myStars(imagePath:)
    }
  }*/

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

  /*Text spectralClassListInformation(){
    //Text myContainerText = RichText(text: TextSpan(text: "Not available at the moment"));
    Text myContainerText = Text("Not available at the moment");
    List starList = [];
    switch(mySpectralClass){
      case "M":
        for(int m = 0; m < fullListOfStars[0].length; m++) {
          starList.add(fullListOfStars[0][m]);
          //myContainerText = Text(fullListOfStars[0][m], textAlign: TextAlign.center);
        }
        myContainerText = Text(starList.join("\n").toString(), textAlign: TextAlign.center);
        //myContainerText = RichText(text: TextSpan(text: starList.join("\n").toString()), textAlign: TextAlign.center);
        break;
      case "K":
        for(int k = 0; k < fullListOfStars[1].length; k++){
          starList.add(fullListOfStars[1][k]);
        }
        myContainerText = Text(starList.join("\n").toString(), textAlign: TextAlign.center);
        //myContainerText = RichText(text: TextSpan(text: starList.join("\n").toString()), textAlign: TextAlign.center);
        break;
      case "G":
        for(int g = 0; g < fullListOfStars[2].length; g++){
          starList.add(fullListOfStars[2][g]);
        }
        myContainerText = Text(starList.join("\n").toString(), textAlign: TextAlign.center);
        //myContainerText = RichText(text: TextSpan(text: starList.join("\n").toString()), textAlign: TextAlign.center);
        break;
      case "F":
        for(int f = 0; f < fullListOfStars[3].length; f++){
          starList.add(fullListOfStars[3][f]);
        }
        myContainerText = Text(starList.join("\n").toString(), textAlign: TextAlign.center);
        //myContainerText = RichText(text: TextSpan(text: starList.join("\n").toString()), textAlign: TextAlign.center);
        break;
      case "A":
        for(int a = 0; a < fullListOfStars[4].length; a++){
          starList.add(fullListOfStars[4][a]);
        }
        myContainerText = Text(starList.join("\n").toString(), textAlign: TextAlign.center);
        //myContainerText = RichText(text: TextSpan(text: starList.join("\n").toString()), textAlign: TextAlign.center);
        break;
      case "B":
        for(int b = 0; b < fullListOfStars[5].length; b++){
          starList.add(fullListOfStars[5][b]);
        }
        myContainerText = Text(starList.join("\n").toString(), textAlign: TextAlign.center);
        //myContainerText = RichText(text: TextSpan(text: starList.join("\n").toString()), textAlign: TextAlign.center);
        break;
      case "O":
        for(int o = 0; o < fullListOfStars[6].length; o++){
          starList.add(fullListOfStars[6][o]);
        }
        myContainerText = Text(starList.join("\n").toString(), textAlign: TextAlign.center);
        //myContainerText = RichText(text: TextSpan(text: starList.join("\n").toString()), textAlign: TextAlign.center);
        break;
    }
    return myContainerText;
  }*/
//}