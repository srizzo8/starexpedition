import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'createThread.dart';
import 'main.dart' as myMain;

bool newDiscoveriesBool = false;
List<List> newDiscoveriesThreads = [];
Iterable<List> reversedNewDiscoveriesThreadsIterable = newDiscoveriesThreads.reversed;
String threadAuthorNewDiscoveries = "";
String threadTitleNewDiscoveries = "";
String threadContentNewDiscoveries = "";

class newDiscoveriesPage extends StatefulWidget{
  const newDiscoveriesPage ({Key? key}) : super(key: key);

  @override
  newDiscoveriesPageState createState() => newDiscoveriesPageState();
}

class MyNewDiscoveriesPage extends StatelessWidget{
  const MyNewDiscoveriesPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext bc){
    return MaterialApp(
      title: "New Discoveries Page",
      routes: {
        routeToCreateThreadNewDiscoveriesPage.createThreadPage: (context) => createThread(),
      }
    );
  }
}

class routeToCreateThreadNewDiscoveriesPage{
  static String createThreadPage = createThreadState.threadCreator;
}

class newDiscoveriesPageState extends State<newDiscoveriesPage>{
  static String newDiscoveriesRoute = '/newDiscoveriesPage';

  Widget build(BuildContext buildContext){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Text("New Discoveries Subforum", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          GestureDetector(
            child: Container(
              child: Text("Post new thread", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              color: Colors.black,
              height: 20,
              width: 120,
              margin: EdgeInsets.only(left: 250.0),
              alignment: Alignment.center,
            ),
            onTap: (){
              newDiscoveriesBool = true;
              Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
            }
          ),
          Expanded(
            child: ListView.builder(
                itemCount: reversedNewDiscoveriesThreadsIterable.toList().length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      Container(
                        height: 10,
                      ),
                      GestureDetector(
                          child: Container(
                            child: Text(reversedNewDiscoveriesThreadsIterable.toList()[index][1] + "\n" + "By: " + reversedNewDiscoveriesThreadsIterable.toList()[index][0]),
                            height: 30,
                            width: 360,
                            color: Colors.tealAccent,
                          ),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => newDiscoveriesThreadContent()));
                            threadAuthorNewDiscoveries = reversedNewDiscoveriesThreadsIterable.toList()[index][0];
                            threadTitleNewDiscoveries = reversedNewDiscoveriesThreadsIterable.toList()[index][1];
                            threadContentNewDiscoveries = reversedNewDiscoveriesThreadsIterable.toList()[index][2];
                          }
                      ),
                    ],
                  );
                }
            ),
          ),
        ],
      ),
    );
  }
}

class newDiscoveriesThreadContent extends StatelessWidget{
  @override
  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
      ),
      body: Wrap(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              child: Text("Thread title: " + threadTitleNewDiscoveries + "\n" + "Posted by: " + threadAuthorNewDiscoveries + "\n" + threadContentNewDiscoveries),
              color: Colors.tealAccent,
              alignment: Alignment.topLeft,
            ),
          ),
        ],
      ),
    );
  }
}