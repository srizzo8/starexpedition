import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'main.dart' as myMain;

class spectralClassPage extends StatelessWidget {
  static String nameOfRoute = '/spectralClassPage';
  //final spectralClassSnapshot = await spectralClassRef.get();
  List<String> spectralClassOfStars = [];
  //String spectralClass = "";
  var scpNumberOfStars = myMain.starsForSearchBar.length;

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
  void generateSpectralClasses() async{
    spectralClassOfStars = await getSpectralClassData();
    print(spectralClassOfStars);
  }

  @override
  Widget build(BuildContext bc){
    generateSpectralClasses();
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
                DataCell(Text(spectralClassOfStars.toString())),
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