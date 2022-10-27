import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'main.dart' as myMain;

String mySpectralClass = "";

class spectralClassPage extends StatefulWidget{
  const spectralClassPage({Key? key}) : super(key: key);

  @override
  spectralClassPageState createState() => spectralClassPageState();
}

class spectralClassPageState extends State<spectralClassPage>{
  static String nameOfRoute = '/spectralClassPage';
  //final spectralClassSnapshot = await spectralClassRef.get();
  List<String> spectralClassOfStars = [];
  //String spectralClass = "";
  var scpNumberOfStars = myMain.starsForSearchBar.length;
  List<String> spectralClassCount = [];
  bool b = false;

  @override
  Future <List<String>> getSpectralClassData() async{
    List<String> spectralClasses = [];
    for(int i = 0; i < scpNumberOfStars; i++) {
      final spectralClassRef = FirebaseDatabase.instance.ref(myMain.starsForSearchBar[i].starName!);
      var spectralClassSnapshot = await spectralClassRef.child("spectral_class").get();
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
        title: Text("Star Expedition"),
      ),
      body: Wrap(
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
                      mySpectralClass = "K";
                      },
                    child: Text(spectralClassCount[1].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))
                ),
                ),
            ]),
              DataRow(cells: [
                DataCell(Text('G')),
                DataCell(Text('5300-6000 K')),
                DataCell(Text(spectralClassCount[2].toString())),
              ]),
              DataRow(cells: [
                DataCell(Text('F')),
                DataCell(Text('6000-7300 K')),
                DataCell(Text(spectralClassCount[3].toString())),
              ]),
              DataRow(cells: [
                DataCell(Text('A')),
                DataCell(Text('7300-10000 K')),
                DataCell(Text(spectralClassCount[4].toString())),
              ]),
              DataRow(cells: [
                DataCell(Text('B')),
                DataCell(Text('10000-30000 K')),
                DataCell(Text(spectralClassCount[5].toString())),
              ]),
              DataRow(cells: [
                DataCell(Text('O')),
                DataCell(Text('30000+ K')),
                DataCell(Text(spectralClassCount[6].toString())),
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

class listForSpectralClassesPage extends StatelessWidget{

  List<String> mStars = [];
  List<String> kStars = [];
  List<String> gStars = [];
  List<String> fStars = [];
  List<String> aStars = [];
  List<String> bStars = [];
  List<String> oStars = [];

  @override
  void getStars() async{
    for(int i = 0; i < myMain.starsForSearchBar.length; i++) {
      var starsWithSpectralClassRef = FirebaseDatabase.instance.ref(myMain.starsForSearchBar[i].starName!);
      String starSnapshot = await starsWithSpectralClassRef.child("spectral_class").toString();
      String starSnapshotSpectralClass = starSnapshot[0];
      switch(starSnapshotSpectralClass){
        case "M":
          mStars.add(myMain.starsForSearchBar[i].starName!);
          break;
        case "K":
          kStars.add(myMain.starsForSearchBar[i].starName!);
          break;
        case "G":
          gStars.add(myMain.starsForSearchBar[i].starName!);
          break;
        case "F":
          fStars.add(myMain.starsForSearchBar[i].starName!);
          break;
        case "A":
          aStars.add(myMain.starsForSearchBar[i].starName!);
          break;
        case "B":
          bStars.add(myMain.starsForSearchBar[i].starName!);
          break;
        case "O":
          oStars.add(myMain.starsForSearchBar[i].starName!);
          break;
      }
    }
    print(mStars.toString());
  }

  void initState(){
    getStars();
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Wrap(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: Text("List of stars with articles that belong to the " + mySpectralClass + " spectral class"),
          )
        ]
      )
    );
  }
}