import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:starexpedition4/userProfile.dart';
import 'package:starexpedition4/userSearchBar.dart';

import 'createThread.dart';
import 'replyThreadPage.dart';
import 'main.dart' as myMain;
import 'discussionBoardPage.dart' as discussionBoardPage;
import 'package:starexpedition4/firebaseDesktopHelper.dart';

bool newDiscoveriesBool = false;
bool newDiscoveriesReplyBool = false;
bool newDiscoveriesReplyingToReplyBool = false;
var newDiscoveriesThreads = [];
var newDiscoveriesReplies = [];
int myIndex = -1;
var reversedNewDiscoveriesThreadsIterable = newDiscoveriesThreads.reversed;
var reversedNewDiscoveriesRepliesIterable = newDiscoveriesReplies.reversed;
String threadAuthorNd = "";
String threadTitleNd = "";
String threadContentNd = "";
String threadID = "";
var theNdThreadReplies;
var myDocNd;
var replyToReplyDocNd;
var replyToReplyTimeNd;
var replyToReplyContentNd;
var replyToReplyPosterNd;
var myReplyToReplyNd;
var replyToReplyOriginalInfoNd;
List<List> ndRepliesToReplies = [];
Map<String, dynamic> myReplyToReplyNdMap = {};

var ndNameData;
bool ndClickedOnUser = false;

var mySublistsNewDiscoveriesInformation;
var myIndexPlaceNewDiscoveries;
var myLocation;

class newDiscoveriesPage extends StatefulWidget{
  const newDiscoveriesPage ({Key? key}) : super(key: key);

  @override
  newDiscoveriesPageState createState() => newDiscoveriesPageState();
}

class newDiscoveriesThreadsPage extends StatefulWidget{
  const newDiscoveriesThreadsPage ({Key? key}) : super(key: key);

  @override
  newDiscoveriesThreadContent createState() => newDiscoveriesThreadContent();
}

class MyNewDiscoveriesPage extends StatelessWidget{
  const MyNewDiscoveriesPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext bc){
    return MaterialApp(
      title: "New Discoveries Page",
      routes: {
        routeToCreateThreadNewDiscoveriesPage.createThreadPage: (context) => createThread(),
        routeToReplyToThreadNewDiscoveriesPage.replyThreadPage: (context) => replyThreadPage(),
      }
    );
  }
}

class routeToCreateThreadNewDiscoveriesPage{
  static String createThreadPage = createThreadState.threadCreator;
}

class routeToReplyToThreadNewDiscoveriesPage{
  static String replyThreadPage = replyThreadPageState.replyThread;
}

class newDiscoveriesPageState extends State<newDiscoveriesPage>{
  static String newDiscoveriesRoute = '/newDiscoveriesPage';
  int numberOfPagesNd = (((discussionBoardPage.newDiscoveriesThreads.length)/10)).ceil();
  int theCurrentPageNd = 0;

  var listOfNdThreads = discussionBoardPage.newDiscoveriesThreads;
  var mySublistsNd = [];
  var portionSizeNd = 10;

  Widget build(BuildContext buildContext){
    for(int i = 0; i < listOfNdThreads.length; i += portionSizeNd){
      mySublistsNd.add(listOfNdThreads.sublist(i, i + portionSizeNd > listOfNdThreads.length ? listOfNdThreads.length : i + portionSizeNd));
    }

    mySublistsNewDiscoveriesInformation = mySublistsNd;

    var myPagesNd = List.generate(
      numberOfPagesNd,
        (index) => Center(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: mySublistsNd[theCurrentPageNd].length,
              itemBuilder: (context, index){
                return Column(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.015625,
                    ),
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        height: MediaQuery.of(context).size.height * 0.08,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.050000),
                                    child: Text.rich(
                                      TextSpan(
                                        text: "${mySublistsNd[theCurrentPageNd][index]["threadTitle"].toString()}\nBy: ",
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, height: 1.1),
                                        children: [
                                          TextSpan(
                                              text: "${mySublistsNd[theCurrentPageNd][index]["poster"].toString()}",
                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, height: 1.1),
                                              recognizer: TapGestureRecognizer()..onTap = () async =>{
                                                ndClickedOnUser = true,

                                                if(firebaseDesktopHelper.onDesktop){
                                                  ndNameData = await firebaseDesktopHelper.getFirestoreCollection("User"),
                                                  theUsersData = ndNameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsNd[theCurrentPageNd][index]["poster"].toString().toLowerCase(), orElse: () => {} as Map<String, dynamic>),
                                                }
                                                else{
                                                  ndNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsNd[theCurrentPageNd][index]["poster"].toString().toLowerCase()).get(),
                                                  ndNameData.docs.forEach((person){
                                                    theUsersData = person.data();
                                                  }),
                                                },
                                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                              }
                                          ),
                                          TextSpan(
                                            text: " ",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                            ),
                            onPressed: () async{
                              print("This is index: $index");
                              print("listOfNdThreads is null? ${listOfNdThreads == null}");
                              print("I clicked on a thread");

                              myIndexPlaceNewDiscoveries = index;
                              myLocation = theCurrentPageNd;

                              threadAuthorNd = mySublistsNd[theCurrentPageNd][index]["poster"].toString();
                              threadTitleNd = mySublistsNd[theCurrentPageNd][index]["threadTitle"].toString();
                              threadContentNd = mySublistsNd[theCurrentPageNd][index]["threadContent"].toString();
                              threadID = mySublistsNd[theCurrentPageNd][index]["threadId"].toString();

                              print(discussionBoardPage.newDiscoveriesThreads![index]);
                              print("${threadAuthorNd} + ${threadTitleNd} + ${threadContentNd} + ${threadID}");
                              print("context: ${context}");

                              if(firebaseDesktopHelper.onDesktop){
                                var theNdThreads = await firebaseDesktopHelper.getFirestoreCollection("New_Discoveries");
                                var matchingThread = theNdThreads.firstWhere((myDoc) => myDoc["threadId"] == int.parse(threadID), orElse: () => {} as Map<String, dynamic>);

                                if(matchingThread.isNotEmpty){
                                  //Getting the document ID:
                                  myDocNd = matchingThread["docId"];
                                  print("This is myDocNd: ${myDocNd}");
                                }
                                else{
                                  print("Sorry; the thread was not found");
                                }
                              }
                              else{
                                await FirebaseFirestore.instance.collection("New_Discoveries").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                  myDocNd = d.docs.first.id;
                                  print(myDocNd);
                                });
                              }

                              if(firebaseDesktopHelper.onDesktop){
                                theNdThreadReplies = await firebaseDesktopHelper.getFirestoreSubcollection("New_Discoveries", myDocNd, "Replies");

                                print(theNdThreadReplies.runtimeType);

                                print(DateTime.now().runtimeType);

                                theNdThreadReplies.sort((b, a){
                                  DateTime dta = firebaseDesktopHelper.convertStringToDateTime(a["time"]);
                                  DateTime dtb = firebaseDesktopHelper.convertStringToDateTime(b["time"]);
                                  return dta.compareTo(dtb);
                                });
                              }
                              else{
                                await FirebaseFirestore.instance.collection("New_Discoveries").doc(myDocNd).collection("Replies");

                                QuerySnapshot ndRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("New_Discoveries").doc(myDocNd).collection("Replies").get();
                                theNdThreadReplies = ndRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                                print(theNdThreadReplies.runtimeType);

                                print(DateTime.now().runtimeType);

                                (theNdThreadReplies as List<dynamic>).sort((b2, a2) => (DateTime.parse(a2["time"])).compareTo(DateTime.parse(b2["time"])));
                              }

                              print("Number of theNdThreadReplies: ${theNdThreadReplies.length}");

                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => newDiscoveriesThreadsPage()));
                            }
                        ),
                      ),
                    ),
                  ],
                );
              }
          ),
        ),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            Navigator.pushNamed(context, '/discussionBoardPage'),
          }
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            child: Text("New Discoveries Subforum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Center(
            //margin: EdgeInsets.only(left: 250.0),
            //alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
              child: InkWell(
                child: Ink(
                  color: Colors.black,
                  //padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.031250),
                  //height: 40,
                  //width: 150,
                  //child: Center(
                  child: Text("Post New Thread", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white), textAlign: TextAlign.center),
                  //),
                ),
              ),
              onPressed: (){
                print(newDiscoveriesBool);
                newDiscoveriesBool = true;
                print(newDiscoveriesBool);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                print("I am going to write a new thread.");
              }
            ),
          ),
          Expanded(
            child: listOfNdThreads.length != 0? myPagesNd[theCurrentPageNd] : Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.031250, 0.0, MediaQuery.of(context).size.width * 0.031250, 0.0), child: Text("There are no threads in this subforum yet. Be the first to post a thread!", textAlign: TextAlign.center),),
          ),
          NumberPaginator(
            height: MediaQuery.of(context).size.height * 0.0782125,
            numberPages: listOfNdThreads.length != 0? numberOfPagesNd : 1,
            onPageChange: (myIndexNd){
              setState((){
                theCurrentPageNd = myIndexNd;
              });
            }
          ),
        ],
      ),
    );
  }
}

class newDiscoveriesThreadContent extends State<newDiscoveriesThreadsPage>{
  int numberOfPagesNdThreadReplies = 0;
  int theCurrentPageNdThreadReplies = 0;

  var listOfNdThreadReplies = theNdThreadReplies;
  var mySublistsNdThreadReplies = [];
  int portionSizeNdThreadReplies = 10;

  @override
  Widget build(BuildContext context){
    if(listOfNdThreadReplies == []){
      numberOfPagesNdThreadReplies = 1;
    }
    else{
      numberOfPagesNdThreadReplies = (((theNdThreadReplies.length)/10)).ceil();

      for(int i = 0; i < listOfNdThreadReplies.length; i += portionSizeNdThreadReplies){
        mySublistsNdThreadReplies.add(listOfNdThreadReplies.sublist(i, i + portionSizeNdThreadReplies > listOfNdThreadReplies.length ? listOfNdThreadReplies.length : i + portionSizeNdThreadReplies));
      }
    }

    var myPagesNdThreadReplies = List.generate(
      numberOfPagesNdThreadReplies,
        (myIndex) => Column(
          children: <Widget>[
            ListView.builder(
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: mySublistsNdThreadReplies[theCurrentPageNdThreadReplies].length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["theOriginalReplyInfo"]["replyContent"] != null && mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["theOriginalReplyInfo"]["replier"] != null?
                      Column(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * 0.015625,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blueGrey[300],
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Container(
                                //child: Text("Reply to: " + theNdThreadReplies[index]["theOriginalReplyInfo"]["replyContent"].toString() + "\n" + "Posted by: " + theNdThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                    text: "Reply to: ${mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["theOriginalReplyInfo"]["replyContent"].toString()}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        text: "${mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          ndClickedOnUser = true,

                                          if(firebaseDesktopHelper.onDesktop){
                                            ndNameData = await firebaseDesktopHelper.getFirestoreCollection("User"),
                                            theUsersData = ndNameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString().toLowerCase(), orElse: () => {} as Map<String, dynamic>),
                                          }
                                          else{
                                            ndNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString().toLowerCase()).get(),
                                            ndNameData.docs.forEach((person){
                                              theUsersData = person.data();
                                            }),
                                          },
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                      ),
                                      TextSpan(
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        text: " ",
                                      ),
                                    ],
                                  ),
                                ),
                                color: Colors.blueGrey[300],
                                width: MediaQuery.of(context).size.width * 0.5,
                              ),
                              onPressed: (){
                                //Does nothing
                              }
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey[300],
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Container(
                                //child: Text("Posted on: " + theNdThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + theNdThreadReplies[index]["replier"].toString() + "\n" + theNdThreadReplies[index]["replyContent"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                    text: "Posted on: ${firebaseDesktopHelper.formatMyTimestamp(mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["time"].toString())}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        text: "${mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          ndClickedOnUser = true,

                                          if(firebaseDesktopHelper.onDesktop){
                                            ndNameData = await firebaseDesktopHelper.getFirestoreCollection("User"),
                                            theUsersData = ndNameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["replier"].toString().toLowerCase(), orElse: () => {} as Map<String, dynamic>),
                                          }
                                          else{
                                            ndNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["replier"].toString().toLowerCase()).get(),
                                            ndNameData.docs.forEach((person){
                                              theUsersData = person.data();
                                            }),
                                          },
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                      ),
                                      TextSpan(
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        text: " ",
                                      ),
                                      TextSpan(
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        text: "\n${mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["replyContent"].toString()}",
                                      ),
                                    ],
                                  ),
                                ),
                                color: Colors.grey[300],
                                width: MediaQuery.of(context).size.width * 0.5,
                              ),
                              onPressed: (){
                                //Does nothing
                              }
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey[500],
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: InkWell(
                                child: Ink(
                                  child: Text("Reply", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal), textAlign: TextAlign.center),
                                  color: Colors.grey[500],
                                  width: MediaQuery.of(context).size.width * 0.5,
                                ),
                                onTap: () async{
                                  replyToReplyTimeNd = mySublistsNdThreadReplies[theCurrentPageNdThreadReplies]![index]["time"];
                                  replyToReplyContentNd = mySublistsNdThreadReplies[theCurrentPageNdThreadReplies]![index]["replyContent"].toString();
                                  replyToReplyPosterNd = mySublistsNdThreadReplies[theCurrentPageNdThreadReplies]![index]["replier"].toString();

                                  print("This is replyToReplyTime: $replyToReplyTimeNd");

                                  if(firebaseDesktopHelper.onDesktop){
                                    var theDocNd = await firebaseDesktopHelper.getFirestoreCollection("New_Discoveries");
                                    print("Hello. This is theDocNd: $theDocNd");
                                    myDocNd = theDocNd.firstWhere((myThreadId) => myThreadId["threadId"] == int.parse(threadID), orElse: () => <String, dynamic>{})["docId"];
                                    print("Hello. This is myDocNd: $myDocNd");
                                    print("Hello. This is the runtime type of myDocNd: ${myDocNd.runtimeType}");

                                    var tempReplyToReplyVar = await firebaseDesktopHelper.getFirestoreSubcollection("New_Discoveries", myDocNd, "Replies");
                                    print("Hello. This is tempReplyToReplyVar: ${tempReplyToReplyVar}");
                                    print("Hello. This is the replyToReplyTimeNd variable: ${replyToReplyTimeNd}");
                                    replyToReplyDocNd = tempReplyToReplyVar.firstWhere((myTime) => firebaseDesktopHelper.formatMyTimestamp(myTime["time"]) == replyToReplyTimeNd.toString(), orElse: () => <String, dynamic>{});
                                    print("Hello. This is replyToReplyDocNd: ${replyToReplyDocNd}");
                                  }
                                  else{
                                    await FirebaseFirestore.instance.collection("New_Discoveries").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                      myDocNd = d.docs.first.id;
                                      print(myDocNd);
                                    });

                                    await FirebaseFirestore.instance.collection("New_Discoveries").doc(myDocNd).collection("Replies").where("time", isEqualTo: replyToReplyTimeNd).get().then((rd) {
                                      replyToReplyDocNd = rd.docs.first.id;
                                      print(replyToReplyDocNd);
                                    });
                                  }

                                  print(theNdThreadReplies);
                                  print(replyToReplyDocNd);

                                  if(firebaseDesktopHelper.onDesktop){
                                    print("The doc: $myDocNd");
                                    print("The subdoc: $replyToReplyDocNd");

                                    try{
                                      Map<String, dynamic>? dsData = await firebaseDesktopHelper.getFirestoreSubcollectionDocument("New_Discoveries", myDocNd, "Replies", replyToReplyDocNd);

                                      print("This is dsData: ${dsData}");
                                      print("This is dsData's runtime type: ${dsData.runtimeType}");

                                      if(dsData != null){
                                        print("This is dsData: ${dsData}");
                                        print("This is dsData's runtime type: ${dsData.runtimeType}");
                                      }
                                      else{
                                        print("The document is not found on Desktop");
                                      }
                                    }
                                    catch (error){
                                      print("There is an error on Desktop: ${error}");
                                    }
                                  }
                                  else{
                                    DocumentSnapshot ds = await FirebaseFirestore.instance.collection("New_Discoveries").doc(myDocNd).collection("Replies").doc(replyToReplyDocNd).get();
                                    print(ds.data());
                                    print(ds.data().runtimeType);
                                  }

                                  print(mySublistsNdThreadReplies[theCurrentPageNdThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeNd));

                                  myIndex = mySublistsNdThreadReplies[theCurrentPageNdThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeNd);
                                  myReplyToReplyNd = mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][myIndex];
                                  myReplyToReplyNdMap = Map.from(myReplyToReplyNd);

                                  List<dynamic> tempReplyToReplyList = [replyToReplyContentNd, replyToReplyPosterNd, myReplyToReplyNdMap];
                                  ndRepliesToReplies.add(tempReplyToReplyList);

                                  print("myReplyToReplyNdMap: ${myReplyToReplyNdMap}");
                                  print("myReplyToReplyNd: ${myReplyToReplyNd["replyContent"]}");
                                  print("This is myIndex: $myIndex");

                                  newDiscoveriesReplyBool = true;
                                  newDiscoveriesReplyingToReplyBool = true;
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                }
                              ),
                              onPressed: (){
                                //Does nothibg
                              }
                            ),
                          ]
                      ): Column(
                          children: <Widget>[
                            Container(
                              height: 10,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey[300],
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Container(
                                //child: Text("Posted on: " + theNdThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + theNdThreadReplies[index]["replier"].toString() + "\n" + theNdThreadReplies[index]["replyContent"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                    text: "Posted on: ${firebaseDesktopHelper.formatMyTimestamp(mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["time"].toString())}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        text: "${mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          ndClickedOnUser = true,

                                          if(firebaseDesktopHelper.onDesktop){
                                            ndNameData = await firebaseDesktopHelper.getFirestoreCollection("User"),
                                            theUsersData = ndNameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["replier"].toString().toLowerCase(), orElse: () => {} as Map<String, dynamic>),
                                            print("theUsersData is this on Desktop: ${theUsersData}"),
                                          }
                                          else{
                                            ndNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["replier"].toString().toLowerCase()).get(),
                                            ndNameData.docs.forEach((person){
                                              theUsersData = person.data();
                                            }),
                                          },
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                      ),
                                      TextSpan(
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        text: " ",
                                      ),
                                      TextSpan(
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        text: "\n${mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][index]["replyContent"].toString()}",
                                      ),
                                    ],
                                  ),
                                ),
                                color: Colors.grey[300],
                                width: MediaQuery.of(context).size.width * 0.5,
                              ),
                              onPressed: (){
                                //Does nothing
                              }
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey[500],
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: InkWell(
                                child: Ink(
                                  child: Text("Reply", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal), textAlign: TextAlign.center),
                                  color: Colors.grey[500],
                                  width: MediaQuery.of(context).size.width * 0.5,
                                ),
                                onTap: () async{
                                  replyToReplyTimeNd = mySublistsNdThreadReplies[theCurrentPageNdThreadReplies]![index]["time"];
                                  replyToReplyContentNd = mySublistsNdThreadReplies[theCurrentPageNdThreadReplies]![index]["replyContent"].toString();
                                  replyToReplyPosterNd = mySublistsNdThreadReplies[theCurrentPageNdThreadReplies]![index]["replier"].toString();

                                  print("This is replyToReplyTime: $replyToReplyTimeNd");

                                  if(firebaseDesktopHelper.onDesktop){
                                    var theNdThreads = await firebaseDesktopHelper.getFirestoreCollection("New_Discoveries");
                                    var matchingThread = theNdThreads.firstWhere((myDoc) => myDoc["threadId"] == int.parse(threadID), orElse: () => {} as Map<String, dynamic>);

                                    if(matchingThread.isNotEmpty){
                                      //Getting the document ID:
                                      myDocNd = matchingThread["docId"];
                                      print("This is myDocNd: ${myDocNd}");
                                    }
                                    else{
                                      print("Sorry; the thread was not found");
                                    }

                                    var theNdThreadsReplies = await firebaseDesktopHelper.getFirestoreSubcollection("New_Discoveries", myDocNd, "Replies");
                                    var matchingReply = theNdThreadsReplies.firstWhere((myDoc) => myDoc["time"] == replyToReplyTimeNd, orElse: () => {} as Map<String, dynamic>);

                                    if(matchingReply.isNotEmpty){
                                      //Getting the document ID:
                                      replyToReplyDocNd = matchingReply["docId"];
                                      print("This is replyToReplyDocNd: ${replyToReplyDocNd}");
                                    }
                                    else{
                                      print("Sorry; the thread was not found");
                                    }
                                  }
                                  else{
                                    await FirebaseFirestore.instance.collection("New_Discoveries").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                      myDocNd = d.docs.first.id;
                                      print(myDocNd);
                                    });

                                    await FirebaseFirestore.instance.collection("New_Discoveries").doc(myDocNd).collection("Replies").where("time", isEqualTo: replyToReplyTimeNd).get().then((rd) {
                                      replyToReplyDocNd = rd.docs.first.id;
                                      print(replyToReplyDocNd);
                                    });
                                  }

                                  print(theNdThreadReplies);
                                  print(replyToReplyDocNd);

                                  if(firebaseDesktopHelper.onDesktop){
                                    print("The doc: $myDocNd");
                                    print("The subdoc: $replyToReplyDocNd");

                                    try{
                                      Map<String, dynamic>? dsData = await firebaseDesktopHelper.getFirestoreSubcollectionDocument("New_Discoveries", myDocNd, "Replies", replyToReplyDocNd);

                                      print("This is dsData: ${dsData}");
                                      print("This is dsData's runtime type: ${dsData.runtimeType}");

                                      if(dsData != null){
                                        print("This is dsData: ${dsData}");
                                        print("This is dsData's runtime type: ${dsData.runtimeType}");
                                      }
                                      else{
                                        print("The document is not found on Desktop");
                                      }
                                    }
                                    catch (error){
                                      print("There is an error on Desktop: ${error}");
                                    }
                                  }
                                  else{
                                    DocumentSnapshot ds = await FirebaseFirestore.instance.collection("New_Discoveries").doc(myDocNd).collection("Replies").doc(replyToReplyDocNd).get();
                                    print(ds.data());
                                    print(ds.data().runtimeType);
                                  }

                                  myIndex = mySublistsNdThreadReplies[theCurrentPageNdThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeNd);

                                  print(mySublistsNdThreadReplies[theCurrentPageNdThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeNd));
                                  myReplyToReplyNd = mySublistsNdThreadReplies[theCurrentPageNdThreadReplies][myIndex];

                                  myReplyToReplyNdMap = Map.from(myReplyToReplyNd);

                                  List<dynamic> tempReplyToReplyList = [replyToReplyContentNd, replyToReplyPosterNd, myReplyToReplyNdMap];
                                  ndRepliesToReplies.add(tempReplyToReplyList);

                                  print("myReplyToReplyNdMap: ${myReplyToReplyNdMap}");

                                  print("myReplyToReplyNd: ${myReplyToReplyNd["replyContent"]}");
                                  print("This is myIndex: $myIndex");

                                  newDiscoveriesReplyBool = true;
                                  newDiscoveriesReplyingToReplyBool = true;
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                }
                              ),
                              onPressed: (){
                                //Does nothing
                              }
                            ),
                          ]
                      ),
                    ],
                  );
                }
            ),
          ],
        ),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            Navigator.push(context, MaterialPageRoute(builder: (context) => const newDiscoveriesPage())),
          }
        ),
      ),
      body: SingleChildScrollView(
        child: Wrap(
        children: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.grey[300],
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.031250),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                      text: "Thread title: ${threadTitleNd}\nPosted by: ",
                      children: <TextSpan>[
                        TextSpan(
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                          text: "${threadAuthorNd}",
                          recognizer: TapGestureRecognizer()..onTap = () async =>{
                            ndClickedOnUser = true,

                            if(firebaseDesktopHelper.onDesktop){
                              ndNameData = await firebaseDesktopHelper.getFirestoreCollection("User"),
                              theUsersData = ndNameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == threadAuthorNd.toLowerCase(), orElse: () => {} as Map<String, dynamic>),
                            }
                            else{
                              ndNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: threadAuthorNd.toLowerCase()).get(),
                              ndNameData.docs.forEach((person){
                                theUsersData = person.data();
                              }),
                            },
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                          }
                        ),
                        TextSpan(
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                          text: " ",
                        ),
                        TextSpan(
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                          text: "\n${threadContentNd}",
                        )
                      ],
                    ),
                  ),
                ),
                color: Colors.grey[300],
                alignment: Alignment.topLeft,
              ),
            ),
            onPressed: (){
              //Does nothing
            }
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.grey[500],
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: InkWell(
              child: Ink(
                color: Colors.grey[500],
                height: MediaQuery.of(context).size.height * 0.02734375,
                child: Container(
                  alignment: Alignment.topCenter,
                  child: Text("Reply to thread", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                ),
              ),
              onTap: (){
                newDiscoveriesReplyingToReplyBool = false;
                newDiscoveriesReplyBool = true;
                print(reversedNewDiscoveriesThreadsIterable.toList());
                print(threadID);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                print('Replying to the thread');
              }
            ),
            onPressed: (){
              //Does nothing
            }
          ),
          Center(
            child: listOfNdThreadReplies.length != 0? myPagesNdThreadReplies[theCurrentPageNdThreadReplies] : Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.031250, MediaQuery.of(context).size.height * 0.062500, MediaQuery.of(context).size.width * 0.031250, 0.0), child: Text("There are no replies to this thread yet. Be the first to reply!", textAlign: TextAlign.center),),
          ),
          NumberPaginator(
            height: MediaQuery.of(context).size.height * 0.0782125,
            numberPages: listOfNdThreadReplies.length != 0? numberOfPagesNdThreadReplies : 1,
            onPageChange: (myIndexNdThreadReplies){
              setState((){
                theCurrentPageNdThreadReplies = myIndexNdThreadReplies;
              });
            }
          ),
        ],
      ),
      ),
    );
  }
}