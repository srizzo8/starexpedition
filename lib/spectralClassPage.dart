import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'main.dart';

class spectralClassPage extends StatelessWidget {
  static String nameOfRoute = '/spectralClassPage';
  //final spectralClassSnapshot = await spectralClassRef.get();
  List<String> spectralClassOfStars = [];
  //String spectralClass = "";

  Future <List<String>> getSpectralClassData() async{
    final spectralClassRef = FirebaseDatabase.instance.ref("/spectral_class");
    final spectralClassSnapshot = await spectralClassRef.get();

    return [spectralClassSnapshot.value.toString()];
  }

  //spectralClassOfStars = await getSpectralClassData();

  @override
  Widget build(BuildContext bc){
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
              DataColumn(label: Text('Spectral Class', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Temperature', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Example', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Number of Stars with Star Expedition Articles', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: [
              DataRow(cells: [
                DataCell(Text('M')),
                DataCell(Text('2545-3760 K')),
                DataCell(Text('Proxima Centauri')),
                DataCell(Text('Not available')),
              ]),
            ],
            ),
          Container(
            child: Text("Sources", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            child: Text("https://www.handprint.com/ASTRO/specclass.html", textAlign: TextAlign.center),
          ),
        ],
      ),
      drawer: starExpeditionNavigationDrawer(),
    );
  }
}