import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'main.dart' as myMain;

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

    spectralClassOfStars = await getSpectralClassData();

    print(spectralClassOfStars);
    for(int i = 0; i < spectralClassOfStars.length; i++)
    {
      String mySpectralClass = spectralClassOfStars[i];
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

  /*@override
  void initState() {
    Future.delayed(const Duration(milliseconds: 250),() async {
      print("Testing initState method");
      spectralClassCount = await generateSpectralClasses();
    });
    super.initState();

    print('This is spectralClassCount: ' + spectralClassCount.toString());
  }*/

  @override
  Widget build(BuildContext bc){
    //spectralClassCount = await generateSpectralClasses();

    setState(() async {
      spectralClassCount = await generateSpectralClasses();
      print(spectralClassCount);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Wrap(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: Text("Spectral Classes of Stars", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
            height: 30,
          ),
          DataTable(
            columns: [
              DataColumn(label: Text('Spectral Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9.0))),
              DataColumn(label: Text('Temperature', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9.0))),
              //DataColumn(label: Text('Example', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Stars with Articles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9.0))),
            ],
            rows: [
              DataRow(cells: [
                DataCell(Text('M')),
                DataCell(Text('2500-3800 K')),
                //DataCell(Text('Proxima Centauri')),
                DataCell(Text("TBA")),
              ]),
              DataRow(cells: [
                DataCell(Text('K')),
                DataCell(Text('3800-5300 K')),
                DataCell(Text(spectralClassOfStars.toString())),
              ]),
              DataRow(cells: [
                DataCell(Text('G')),
                DataCell(Text('5300-6000 K')),
                DataCell(Text(spectralClassOfStars.toString())),
              ]),
              DataRow(cells: [
                DataCell(Text('F')),
                DataCell(Text('6000-7300 K')),
                DataCell(Text(spectralClassOfStars.toString())),
              ]),
              DataRow(cells: [
                DataCell(Text('A')),
                DataCell(Text('7300-10000 K')),
                DataCell(Text(spectralClassOfStars.toString())),
              ]),
              DataRow(cells: [
                DataCell(Text('B')),
                DataCell(Text('10000-30000 K')),
                DataCell(Text(spectralClassOfStars.toString())),
              ]),
              DataRow(cells: [
                DataCell(Text('O')),
                DataCell(Text('30000+ K')),
                DataCell(Text(spectralClassOfStars.toString())),
              ]),
            ],
            ),
          Container(
            child: Text("Sources", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            height: 20,
            width: 360,
          ),
          Container(
            child: Text("https://www.handprint.com/ASTRO/specclass.html", textAlign: TextAlign.center),
            height: 20,
            width: 360,
          ),
        ],
      ),
      drawer: myMain.starExpeditionNavigationDrawer(),
    );
  }
}