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
import 'package:flutter/services.dart' show SystemChannels, rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';
import 'package:starexpedition4/userProfile.dart';
import 'package:starexpedition4/firebaseDesktopHelper.dart';

var nameClickedData;
var theUsersData;
var theUsernameResult = "";

class userSearchBarPage extends StatefulWidget{
  const userSearchBarPage ({Key? key}) : super(key: key);

  @override
  userSearchBarPageState createState() => userSearchBarPageState();
}

class mySearch extends SearchDelegate{
  List<dynamic> usernameList = myMain.theListOfUsers;

  final ScrollController myScrollController = ScrollController();

  @override
  TextInputAction get textInputAction => TextInputAction.search;

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
        //close(bc2, null);
        Navigator.push(bc2, MaterialPageRoute(builder: (BuildContext context) => userSearchBarPage()));
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext bc3){
    List<String> myMatchQuery = [];

    if(!myScrollController.hasListeners){
      myScrollController.addListener((){
        SystemChannels.textInput.invokeMethod("TextInput.hide");
      });
    }

    SystemChannels.textInput.invokeMethod("TextInput.hide");

    WidgetsBinding.instance.addPostFrameCallback((_){
      SystemChannels.textInput.invokeMethod("TextInput.hide");
      FocusScope.of(bc3).requestFocus(FocusNode());}
    );

    Future.delayed(Duration(milliseconds: 50), (){
      SystemChannels.textInput.invokeMethod("TextInput.hide");
    });

    Future.delayed(Duration(milliseconds: 100), (){
      SystemChannels.textInput.invokeMethod("TextInput.hide");
    });

    Future.delayed(Duration(milliseconds: 250), (){
      SystemChannels.textInput.invokeMethod("TextInput.hide");
    });

    Future.delayed(Duration(milliseconds: 500), (){
      SystemChannels.textInput.invokeMethod("TextInput.hide");
    });

    for(var user in usernameList){
      if(user.toLowerCase().contains(query.toLowerCase())){
        myMatchQuery.add(user);
      }
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: (){
        SystemChannels.textInput.invokeMethod("TextInput.hide");
      },
      onPanDown: (_){
        SystemChannels.textInput.invokeMethod("TextInput.hide");
      },
      child: ListView.builder(
        controller: myScrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: myMatchQuery.length,
        itemBuilder: (bc3, index){
          var myResult = myMatchQuery[index];
          return ListTile(
            title: Text(myResult),
          );
        }
      ),
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

    return GestureDetector(
      onTap: () => FocusScope.of(bc4).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: myMatchQuery.length,
        itemBuilder: (bc4, index){
          var myResult = myMatchQuery[index];
          return ListTile(
            title: Text(myResult),
            onTap: () async{
              SystemChannels.textInput.invokeMethod("TextInput.hide");

              theUsernameResult = myResult;

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
      ),
    );
  }
}

class userSearchBarPageState extends State<userSearchBarPage> with RouteAware{
  static String nameOfRoute = '/userSearchBarPage';
  TextEditingController query = TextEditingController();
  mySearch ms = new mySearch();

  //Lifecycle methods (didChangeDependencies() and dispose()):
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    myMain.routesToOtherPages.myRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose(){
    myMain.routesToOtherPages.myRouteObserver.unsubscribe(this);
    super.dispose();
  }

  //RouteAware methods (didPopNext() and didPush()):
  @override
  void didPopNext(){
    //Called when returning to this page:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  @override
  void didPush(){
    //Called when the page is pushed:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  Widget build(BuildContext context){
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
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
                  readOnly: true,
                  focusNode: FocusNode(canRequestFocus: false),
                  onTap: (){
                    myMain.myAccessCheckNotifier.value = DateTime.now();
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
        ),
    );
  }
}