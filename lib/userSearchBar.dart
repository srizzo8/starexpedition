import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:starexpedition4/settingsPage.dart';
import 'package:starexpedition4/spectralClassPage.dart';

import 'package:starexpedition4/main.dart' as myMain;
import 'package:starexpedition4/discussionBoardPage.dart';
import 'package:starexpedition4/loginPage.dart';
import 'package:starexpedition4/registerPage.dart';
import 'package:starexpedition4/loginPage.dart' as theLoginPage;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';
import 'package:starexpedition4/userProfile.dart';
import 'package:starexpedition4/firebaseDesktopHelper.dart';

var nameClickedData;
var theUsersData;

class userSearchBarPage extends StatefulWidget{
  const userSearchBarPage ({Key? key}) : super(key: key);

  @override
  userSearchBarPageState createState() => userSearchBarPageState();
}

class mySearch extends SearchDelegate{
  List<dynamic> usernameList = myMain.theListOfUsers;

  @override
  List<Widget>? buildActions(BuildContext bc){
    return [
      IconButton(
        onPressed: (){
          query = "";
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext bc2){
    return IconButton(
      onPressed: (){
        close(bc2, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext bc3){
    List<String> myMatchQuery = [];
    for(var user in usernameList){
      if(user.toLowerCase().contains(query.toLowerCase())){
        myMatchQuery.add(user);
      }
    }
    return ListView.builder(
      itemCount: myMatchQuery.length,
      itemBuilder: (bc3, index){
        var myResult = myMatchQuery[index];
        return ListTile(
          title: Text(myResult),
        );
      }
    );
  }

  @override
  Widget buildSuggestions(BuildContext bc4){
    List<String> myMatchQuery = [];
    for(var guy in usernameList){
      if(guy.toLowerCase().contains(query.toLowerCase())){
        myMatchQuery.add(guy);
      }
    }

    myMatchQuery.sort((u1, u2) => u1.compareTo(u2));

    return ListView.builder(
      itemCount: myMatchQuery.length,
      itemBuilder: (bc4, index){
        var myResult = myMatchQuery[index];
        return ListTile(
          title: Text(myResult),
          onTap: () async{
            if(firebaseDesktopHelper.onDesktop){
              nameClickedData = await firebaseDesktopHelper.getFirestoreCollection("User");
              theUsersData = nameClickedData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myResult.toLowerCase(), orElse: () => {} as Map<String, dynamic>);
              print("nameclickeddata: ${nameClickedData}");
              print("theusersdata: ${theUsersData}");

              Navigator.push(bc4, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective()));
            }
            else{
              nameClickedData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myResult.toLowerCase()).get();
              nameClickedData.docs.forEach((person){
                theUsersData = person.data();
              });
              print("You clicked on someone's name: ${myResult}");
              print("The user's data: ${theUsersData}");
              print("Stars tracked: ${theUsersData["usernameProfileInformation"]["starsTracked"]}");
              Navigator.push(bc4, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective()));
            }
          }
        );
      }
    );
  }
}

class userSearchBarPageState extends State<userSearchBarPage>{
  static String nameOfRoute = '/userSearchBarPage';
  TextEditingController query = TextEditingController();
  mySearch ms = new mySearch();

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        /*leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () =>{
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => myMain.StarExpedition())),
            }
        ),*/
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            child: Text("User Search", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015625),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                icon: Icon(Icons.search),
              ),
              controller: query,
              onTap: (){
                showSearch(
                  context: context,
                  delegate: mySearch(),
                );
              }
            ),
          ),
        ],
      ),
      drawer: myMain.starExpeditionNavigationDrawer(),
    );
  }
}