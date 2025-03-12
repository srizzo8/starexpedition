import 'dart:async';
import 'dart:math';
import 'dart:collection';

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

bool projectsBool = false;
bool projectsReplyBool = false;
bool projectsReplyingToReplyBool = false;
var projectsThreads = [];
var projectsReplies = [];
int myIndex = -1;
var reversedProjectsThreadsIterable = projectsThreads.reversed;
var reversedProjectsRepliesIterable = projectsReplies.reversed;
String threadAuthorP = "";
String threadTitleP = "";
String threadContentP = "";
String threadID = "";
var thePThreadReplies;
var myDocP;
var replyToReplyDocP;
var replyToReplyTimeP;
var replyToReplyContentP;
var replyToReplyPosterP;
var myReplyToReplyP;
var replyToReplyOriginalInfoP;
List<List> pRepliesToReplies = [];
Map<String, dynamic> myReplyToReplyPMap = {};

var projectsNameData;
bool projectsClickedOnUser = false;

var mySublistsProjectsInformation;
var myIndexPlaceProjects;
var myLocation;

class projectsPage extends StatefulWidget{
  const projectsPage ({Key? key}) : super(key: key);

  @override
  projectsPageState createState() => projectsPageState();
}

class projectsThreadsPage extends StatefulWidget{
  const projectsThreadsPage ({Key? key}) : super(key: key);

  @override
  projectsThreadContent createState() => projectsThreadContent();
}

class MyProjectsPage extends StatelessWidget{
  const MyProjectsPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext bc){
    return MaterialApp(
        title: "Projects Page",
        routes: {
          routeToCreateThreadProjectsPage.createThreadPage: (context) => createThread(),
          routeToReplyToThreadProjectsPage.replyThreadPage: (context) => replyThreadPage(),
        }
    );
  }
}

class routeToCreateThreadProjectsPage{
  static String createThreadPage = createThreadState.threadCreator;
}

class routeToReplyToThreadProjectsPage{
  static String replyThreadPage = replyThreadPageState.replyThread;
}

class projectsPageState extends State<projectsPage>{
  static String projectsRoute = '/projectsPage';
  int numberOfPages = (((discussionBoardPage.projectsThreads.length)/10)).ceil();
  int theCurrentPage = 0;

  //Getting the threads that will appear in a page
  var listOfProjectsThreads = discussionBoardPage.projectsThreads;
  var mySublistsProjects = [];
  var portionSize = 10;

  //build method
  Widget build(BuildContext buildContext){
    for(int i = 0; i < listOfProjectsThreads.length; i += portionSize){
      mySublistsProjects.add(listOfProjectsThreads.sublist(i, i + portionSize > listOfProjectsThreads.length ? listOfProjectsThreads.length : i + portionSize));
    }

    mySublistsProjectsInformation = mySublistsProjects;

    //for(int i = 0; i < ((listOfProjectsThreads.length / 10).ceil()); i++){
      /*var myListLength = listOfProjectsThreads.length;
      if(myListLength >= 10){
        for(int j = 0; j < 10; j++){
          portions.add(listOfProjectsThreads[j]["threadId"]);
        }
        myListLength = myListLength - 10;
        i++;
      }
      else{
        for(int k = 0; k < myListLength; k++){
          portions.add(listOfProjectsThreads[k]["threadId"]);
        }
        myListLength = myListLength - myListLength;
        i++;
      }*/

    //}

    var myPages = List.generate(
      numberOfPages,
        (index) => Center(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: mySublistsProjects[theCurrentPage].length,
              itemBuilder: (context, index){
                return Column(
                  children: <Widget>[
                    Container(
                      height: 10,
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey[300],
                        ),
                        child: InkWell(
                          child: Ink(
                            //child: Text(discussionBoardPage.projectsThreads[index]["threadTitle"].toString() + "\n" + "By: " + discussionBoardPage.projectsThreads[index]["poster"].toString()),
                            child: Text.rich(
                              TextSpan(
                                text: "${mySublistsProjects[theCurrentPage][index]["threadTitle"].toString()}\nBy: ",//"${discussionBoardPage.projectsThreads[index]["threadTitle"].toString()}\nBy: ",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: "${mySublistsProjects[theCurrentPage][index]["poster"].toString()}",//"${discussionBoardPage.projectsThreads[index]["poster"].toString()}",
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                      recognizer: TapGestureRecognizer()..onTap = () async =>{
                                        projectsClickedOnUser = true,
                                        projectsNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsProjects[theCurrentPage][index]["poster"].toString().toLowerCase()).get(),
                                        projectsNameData.docs.forEach((person){
                                          theUsersData = person.data();
                                        }),
                                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                      }
                                  ),
                                  TextSpan(
                                    text: " ",
                                  ),
                                ],
                              ),
                            ),
                            height: 30,
                            width: 360,
                            color: Colors.grey[300],
                          ),
                        ),
                        onPressed: () async{
                          print("This is index: $index");
                          print("listOfProjectsThreads is null? ${listOfProjectsThreads == null}");
                          print("I clicked on a thread");

                          myIndexPlaceProjects = index;
                          myLocation = theCurrentPage;

                          threadAuthorP = mySublistsProjects[theCurrentPage][index]["poster"].toString();//discussionBoardPage.projectsThreads![index]["poster"].toString();
                          threadTitleP = mySublistsProjects[theCurrentPage][index]["threadTitle"].toString();//discussionBoardPage.projectsThreads![index]["threadTitle"].toString();
                          threadContentP = mySublistsProjects[theCurrentPage][index]["threadContent"].toString();//discussionBoardPage.projectsThreads![index]["threadContent"].toString();
                          threadID = mySublistsProjects[theCurrentPage][index]["threadId"].toString();//discussionBoardPage.projectsThreads![index]["threadId"].toString();

                          print(mySublistsProjects[theCurrentPage][index]);
                          print("${threadAuthorP} + ${threadTitleP} + ${threadContentP} + ${threadID}");
                          print("context: ${context}");
                          await FirebaseFirestore.instance.collection("Projects").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                            myDocP = d.docs.first.id;
                            print(myDocP);
                          });

                          await FirebaseFirestore.instance.collection("Projects").doc(myDocP).collection("Replies");

                          QuerySnapshot pRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Projects").doc(myDocP).collection("Replies").get();
                          thePThreadReplies = pRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                          print(thePThreadReplies.runtimeType);

                          print(DateTime.now().runtimeType);

                          (thePThreadReplies as List<dynamic>).sort((b2, a2) => (a2["time"].toDate()).compareTo(b2["time"].toDate()));

                          print("Number of thePThreadReplies: ${thePThreadReplies.length}");

                          //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => projectsThreadContent()));
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => projectsThreadsPage()));
                        }
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
            print("portions: ${mySublistsProjects}"),
            Navigator.pushNamed(context, '/discussionBoardPage'),
          }
        )
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            child: Text("Projects Subforum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            margin: EdgeInsets.only(left: 250.0),
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
              child: InkWell(
                child: Ink(
                  child: Text("Post new thread", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white), textAlign: TextAlign.center),
                  padding: EdgeInsets.all(5.0),
                  color: Colors.black,
                  height: 30,
                  width: 120,
                ),
              ),
              onPressed: (){
                print(projectsBool);
                projectsBool = true;
                print(projectsBool);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                print("I am going to write a new thread.");
              }
            ),
          ),
          Expanded(
            child: listOfProjectsThreads.length != 0? myPages[theCurrentPage] : Text("There are no threads in this subforum yet. Be the first to post a thread!", textAlign: TextAlign.center),//myPages[theCurrentPage],
          ),
          //IMPORTANT CONTENT STARTS
          /*Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: discussionBoardPage.projectsThreads.length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      Container(
                        height: 10,
                      ),
                      InkWell(
                          child: Ink(
                            //child: Text(discussionBoardPage.projectsThreads[index]["threadTitle"].toString() + "\n" + "By: " + discussionBoardPage.projectsThreads[index]["poster"].toString()),
                            child: Text.rich(
                              TextSpan(
                                text: "${discussionBoardPage.projectsThreads[index]["threadTitle"].toString()}\nBy: ",
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "${discussionBoardPage.projectsThreads[index]["poster"].toString()}",
                                    recognizer: TapGestureRecognizer()..onTap = () async =>{
                                      projectsClickedOnUser = true,
                                      projectsNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: discussionBoardPage.projectsThreads[index]["poster"].toString().toLowerCase()).get(),
                                      projectsNameData.docs.forEach((person){
                                        theUsersData = person.data();
                                      }),
                                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                    }
                                  ),
                                  TextSpan(
                                    text: " ",
                                  ),
                                ],
                              ),
                            ),
                            height: 30,
                            width: 360,
                            color: Colors.grey[300],
                          ),
                          onTap: () async{
                            print("This is index: $index");
                            print("discussionBoardPage.projectsThreads is null? ${discussionBoardPage.projectsThreads == null}");
                            print("I clicked on a thread");
                            threadAuthorP = discussionBoardPage.projectsThreads![index]["poster"].toString();
                            threadTitleP = discussionBoardPage.projectsThreads![index]["threadTitle"].toString();
                            threadContentP = discussionBoardPage.projectsThreads![index]["threadContent"].toString();
                            threadID = discussionBoardPage.projectsThreads![index]["threadId"].toString();

                            print(discussionBoardPage.projectsThreads![index]);
                            print("${threadAuthorP} + ${threadTitleP} + ${threadContentP} + ${threadID}");
                            print("context: ${context}");
                            await FirebaseFirestore.instance.collection("Projects").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                              myDocP = d.docs.first.id;
                              print(myDocP);
                            });

                            await FirebaseFirestore.instance.collection("Projects").doc(myDocP).collection("Replies");

                            QuerySnapshot pRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Projects").doc(myDocP).collection("Replies").get();
                            thePThreadReplies = pRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                            print(thePThreadReplies.runtimeType);

                            print(DateTime.now().runtimeType);

                            (thePThreadReplies as List<dynamic>).sort((b2, a2) => (a2["time"].toDate()).compareTo(b2["time"].toDate()));

                            print("Number of thePThreadReplies: ${thePThreadReplies.length}");

                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => projectsThreadContent()));
                          }
                      ),
                      /*Expanded(
                        child: Text("${myPages[theCurrentPage]}"),
                      ),*/
                    ],
                  );
                }
            ),
          ),*/ //IMPORTANT CONTENT ENDS

          /*Expanded(
            child: Container(
              child: myPages[theCurrentPage],
            ),
          ),*/
          NumberPaginator(
              height: 50,
              numberPages: listOfProjectsThreads.length != 0? numberOfPages : 1,
              //buttonSelectedBackgroundColor: Colors.green,
              //buttonUnselectedBackgroundColor: Colors.red,
              //buttonSelectedForegroundColor: Colors.grey,
              //buttonUnselectedForegroundColor: Colors.grey,
              onPageChange: (myIndex){
                setState((){
                  theCurrentPage = myIndex;
                  print(theCurrentPage);
                });
              }
          ),
        ],
      ),
    );
  }
}

class projectsThreadContent extends State<projectsThreadsPage>{
  int numberOfPagesProjectsThreadReplies = 0;
  int theCurrentPageProjectsThreadReplies = 0;

  var listOfProjectsThreadReplies = thePThreadReplies;
  var mySublistsProjectsThreadReplies = [];
  int portionSizeProjectsThreadReplies = 10;

  @override
  Widget build(BuildContext context){
    if(listOfProjectsThreadReplies == []){
      numberOfPagesProjectsThreadReplies = 1;
    }
    else{
      numberOfPagesProjectsThreadReplies = (((thePThreadReplies.length)/10)).ceil();

      for(int i = 0; i < listOfProjectsThreadReplies.length; i += portionSizeProjectsThreadReplies){
        mySublistsProjectsThreadReplies.add(listOfProjectsThreadReplies.sublist(i, i + portionSizeProjectsThreadReplies > listOfProjectsThreadReplies.length ? listOfProjectsThreadReplies.length : i + portionSizeProjectsThreadReplies));
      }
    }

    //print("Some replies length: ${mySublistsProjectsThreadReplies[0].length}");
    //print("Some more replies length: ${mySublistsProjectsThreadReplies[1].length}");

    var myPagesProjectsThreadReplies = List.generate(
      numberOfPagesProjectsThreadReplies,
        (myIndex) => Column(
          children: <Widget>[
            ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies].length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies][index]["theOriginalReplyInfo"]["replyContent"] != null && mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies][index]["theOriginalReplyInfo"]["replier"] != null?
                      Column(
                          children: <Widget>[
                            Container(
                              height: 5,
                            ),
                            Container(
                              //child: Text("Reply to: " + thePThreadReplies[index]["theOriginalReplyInfo"]["replyContent"].toString() + "\n" + "Posted by: " + thePThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString()),
                              child: Text.rich(
                                TextSpan(
                                  text: "Reply to: ${mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies][index]["theOriginalReplyInfo"]["replyContent"].toString()}\nPosted by: ",
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "${mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          projectsClickedOnUser = true,
                                          projectsNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString().toLowerCase()).get(),
                                          projectsNameData.docs.forEach((person){
                                            theUsersData = person.data();
                                          }),
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                    ),
                                    TextSpan(
                                      text: " ",
                                    ),
                                  ],
                                ),
                              ),
                              color: Colors.blueGrey[300],
                              width: 360,
                            ),
                            Container(
                              //child: Text("Posted on: " + thePThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + thePThreadReplies[index]["replier"].toString() + "\n" + thePThreadReplies[index]["replyContent"].toString()),
                              child: Text.rich(
                                TextSpan(
                                  text: "Posted on: ${mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies][index]["time"].toDate().toString()}\nPosted by: ",
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "${mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies][index]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          projectsClickedOnUser = true,
                                          projectsNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies][index]["replier"].toString().toLowerCase()).get(),
                                          projectsNameData.docs.forEach((person){
                                            theUsersData = person.data();
                                          }),
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                    ),
                                    TextSpan(
                                      text: " ",
                                    ),
                                    TextSpan(
                                      text: "\n${mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies][index]["replyContent"].toString()}",
                                    ),
                                  ],
                                ),
                              ),
                              color: Colors.grey[300],
                              width: 360,
                            ),
                            InkWell(
                                child: Ink(
                                  child: Text("Reply"),
                                  color: Colors.grey[500],
                                  width: 360,
                                ),
                                onTap: () async{
                                  replyToReplyTimeP = mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies]![index]["time"];
                                  replyToReplyContentP = mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies]![index]["replyContent"].toString();
                                  replyToReplyPosterP = mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies]![index]["replier"].toString();

                                  print("This is replyToReplyTime: $replyToReplyTimeP");

                                  await FirebaseFirestore.instance.collection("Projects").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                    myDocP = d.docs.first.id;
                                    print(myDocP);
                                  });

                                  await FirebaseFirestore.instance.collection("Projects").doc(myDocP).collection("Replies").where("time", isEqualTo: replyToReplyTimeP).get().then((rd) {
                                    replyToReplyDocP = rd.docs.first.id;
                                    print(replyToReplyDocP);
                                  });

                                  print(thePThreadReplies);
                                  print(replyToReplyDocP);

                                  DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Projects").doc(myDocP).collection("Replies").doc(replyToReplyDocP).get();
                                  print(ds.data());
                                  print(ds.data().runtimeType);
                                  print(thePThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeP));

                                  myIndex = mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeP);
                                  myReplyToReplyP = mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies][myIndex];
                                  myReplyToReplyPMap = Map.from(myReplyToReplyP);

                                  List<dynamic> tempReplyToReplyList = [replyToReplyContentP, replyToReplyPosterP, myReplyToReplyPMap];
                                  pRepliesToReplies.add(tempReplyToReplyList);

                                  print("myReplyToReplyTMap: ${myReplyToReplyPMap}");
                                  print("myReplyToReplyT: ${myReplyToReplyP["replyContent"]}");
                                  print("This is myIndex: $myIndex");

                                  projectsReplyBool = true;
                                  projectsReplyingToReplyBool = true;
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                }
                            ),
                          ]
                      ): Column(
                          children: <Widget>[
                            Container(
                              height: 5,
                            ),
                            Container(
                              //child: Text("Posted on: " + thePThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + thePThreadReplies[index]["replier"].toString() + "\n" + thePThreadReplies[index]["replyContent"].toString()),
                              child: Text.rich(
                                TextSpan(
                                  text: "Posted on: ${mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies][index]["time"].toDate().toString()}\nPosted by: ",
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "${mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies][index]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          projectsClickedOnUser = true,
                                          projectsNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies][index]["replier"].toString().toLowerCase()).get(),
                                          projectsNameData.docs.forEach((person){
                                            theUsersData = person.data();
                                          }),
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                    ),
                                    TextSpan(
                                      text: " ",
                                    ),
                                    TextSpan(
                                      text: "\n${mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies][index]["replyContent"].toString()}",
                                    ),
                                  ],
                                ),
                              ),
                              color: Colors.grey[300],
                              width: 360,
                            ),
                            InkWell(
                                child: Ink(
                                  child: Text("Reply"),
                                  color: Colors.grey[500],
                                  width: 360,
                                ),
                                onTap: () async{
                                  replyToReplyTimeP = mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies]![index]["time"];
                                  replyToReplyContentP = mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies]![index]["replyContent"].toString();
                                  replyToReplyPosterP = mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies]![index]["replier"].toString();

                                  print("This is replyToReplyTime: $replyToReplyTimeP");

                                  await FirebaseFirestore.instance.collection("Projects").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                    myDocP = d.docs.first.id;
                                    print(myDocP);
                                  });

                                  await FirebaseFirestore.instance.collection("Projects").doc(myDocP).collection("Replies").where("time", isEqualTo: replyToReplyTimeP).get().then((rd) {
                                    replyToReplyDocP = rd.docs.first.id;
                                    print(replyToReplyDocP);
                                  });

                                  print(thePThreadReplies);
                                  print(replyToReplyDocP);

                                  DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Projects").doc(myDocP).collection("Replies").doc(replyToReplyDocP).get();
                                  print(ds.data());
                                  print(ds.data().runtimeType);

                                  myIndex = mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeP);

                                  print(mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeP));
                                  myReplyToReplyP = mySublistsProjectsThreadReplies[theCurrentPageProjectsThreadReplies][myIndex];

                                  myReplyToReplyPMap = Map.from(myReplyToReplyP);

                                  List<dynamic> tempReplyToReplyList = [replyToReplyContentP, replyToReplyPosterP, myReplyToReplyPMap];
                                  pRepliesToReplies.add(tempReplyToReplyList);

                                  print("myReplyToReplyPMap: ${myReplyToReplyPMap}");

                                  print("myReplyToReplyP: ${myReplyToReplyP["replyContent"]}");
                                  print("This is myIndex: $myIndex");

                                  projectsReplyBool = true;
                                  projectsReplyingToReplyBool = true;
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => const projectsPage())),
          }
        ),
      ),
      body: SingleChildScrollView(
        child: Wrap(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              //child: Text("Thread title: " + threadTitleP + "\n" + "Posted by: " + threadAuthorP + "\n" + threadContentP),
              child: Text.rich(
                TextSpan(
                  text: "Thread title: ${threadTitleP}\nPosted by: ",
                  children: <TextSpan>[
                    TextSpan(
                      text: "${threadAuthorP}",
                      recognizer: TapGestureRecognizer()..onTap = () async =>{
                        projectsClickedOnUser = true,
                        projectsNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: threadAuthorP.toLowerCase()).get(),
                        projectsNameData.docs.forEach((person){
                          theUsersData = person.data();
                        }),
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                      }
                    ),
                    TextSpan(
                      text: " ",
                    ),
                    TextSpan(
                      text: "\n${threadContentP}",
                    ),
                  ],
                )
              ),
              color: Colors.grey[300],
              alignment: Alignment.topLeft,
            ),
          ),
          InkWell(
              child: Ink(
                color: Colors.grey[500],
                height: 20,
                child: Container(
                  alignment: Alignment.topCenter,
                  child: Text("Reply to thread", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              onTap: (){
                projectsReplyingToReplyBool = false;
                projectsReplyBool = true;
                print(reversedProjectsThreadsIterable.toList());
                print(threadID);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                print('Replying to the thread');
              }
          ),
          Center(
            child: listOfProjectsThreadReplies.length != 0? myPagesProjectsThreadReplies[theCurrentPageProjectsThreadReplies] : Text("There are no replies to this thread yet. Be the first to reply!"),
          ),//Column(
            /*children: <Widget>[
              ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: thePThreadReplies.length,
                  itemBuilder: (context, index){
                    return Column(
                      children: <Widget>[
                        thePThreadReplies[index]["theOriginalReplyInfo"]["replyContent"] != null && thePThreadReplies[index]["theOriginalReplyInfo"]["replier"] != null?
                        Column(
                            children: <Widget>[
                              Container(
                                height: 5,
                              ),
                              Container(
                                //child: Text("Reply to: " + thePThreadReplies[index]["theOriginalReplyInfo"]["replyContent"].toString() + "\n" + "Posted by: " + thePThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    text: "Reply to: ${thePThreadReplies[index]["theOriginalReplyInfo"]["replyContent"].toString()}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "${thePThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          projectsClickedOnUser = true,
                                          projectsNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: thePThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString().toLowerCase()).get(),
                                          projectsNameData.docs.forEach((person){
                                            theUsersData = person.data();
                                          }),
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                      ),
                                      TextSpan(
                                        text: " ",
                                      ),
                                    ],
                                  ),
                                ),
                                color: Colors.blueGrey[300],
                                width: 360,
                              ),
                              Container(
                                //child: Text("Posted on: " + thePThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + thePThreadReplies[index]["replier"].toString() + "\n" + thePThreadReplies[index]["replyContent"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    text: "Posted on: ${thePThreadReplies[index]["time"].toDate().toString()}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "${thePThreadReplies[index]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          projectsClickedOnUser = true,
                                          projectsNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: thePThreadReplies[index]["replier"].toString().toLowerCase()).get(),
                                          projectsNameData.docs.forEach((person){
                                            theUsersData = person.data();
                                          }),
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                      ),
                                      TextSpan(
                                        text: " ",
                                      ),
                                      TextSpan(
                                        text: "\n${thePThreadReplies[index]["replyContent"].toString()}",
                                      ),
                                    ],
                                  ),
                                ),
                                color: Colors.grey[300],
                                width: 360,
                              ),
                              InkWell(
                                  child: Ink(
                                    child: Text("Reply"),
                                    color: Colors.grey[500],
                                    width: 360,
                                  ),
                                  onTap: () async{
                                    replyToReplyTimeP = thePThreadReplies![index]["time"];
                                    replyToReplyContentP = thePThreadReplies![index]["replyContent"].toString();
                                    replyToReplyPosterP = thePThreadReplies![index]["replier"].toString();

                                    print("This is replyToReplyTime: $replyToReplyTimeP");

                                    await FirebaseFirestore.instance.collection("Projects").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                      myDocP = d.docs.first.id;
                                      print(myDocP);
                                    });

                                    await FirebaseFirestore.instance.collection("Projects").doc(myDocP).collection("Replies").where("time", isEqualTo: replyToReplyTimeP).get().then((rd) {
                                      replyToReplyDocP = rd.docs.first.id;
                                      print(replyToReplyDocP);
                                    });

                                    print(thePThreadReplies);
                                    print(replyToReplyDocP);

                                    DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Projects").doc(myDocP).collection("Replies").doc(replyToReplyDocP).get();
                                    print(ds.data());
                                    print(ds.data().runtimeType);
                                    print(thePThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeP));

                                    myIndex = thePThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeP);
                                    myReplyToReplyP = thePThreadReplies[myIndex];
                                    myReplyToReplyPMap = Map.from(myReplyToReplyP);

                                    List<dynamic> tempReplyToReplyList = [replyToReplyContentP, replyToReplyPosterP, myReplyToReplyPMap];
                                    pRepliesToReplies.add(tempReplyToReplyList);

                                    print("myReplyToReplyTMap: ${myReplyToReplyPMap}");
                                    print("myReplyToReplyT: ${myReplyToReplyP["replyContent"]}");
                                    print("This is myIndex: $myIndex");

                                    projectsReplyBool = true;
                                    projectsReplyingToReplyBool = true;
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                  }
                              ),
                            ]
                        ): Column(
                            children: <Widget>[
                              Container(
                                height: 5,
                              ),
                              Container(
                                //child: Text("Posted on: " + thePThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + thePThreadReplies[index]["replier"].toString() + "\n" + thePThreadReplies[index]["replyContent"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    text: "Posted on: ${thePThreadReplies[index]["time"].toDate().toString()}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "${thePThreadReplies[index]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          projectsClickedOnUser = true,
                                          projectsNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: thePThreadReplies[index]["replier"].toString().toLowerCase()).get(),
                                          projectsNameData.docs.forEach((person){
                                            theUsersData = person.data();
                                          }),
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                      ),
                                      TextSpan(
                                        text: " ",
                                      ),
                                      TextSpan(
                                        text: "\n${thePThreadReplies[index]["replyContent"].toString()}",
                                      ),
                                    ],
                                  ),
                                ),
                                color: Colors.grey[300],
                                width: 360,
                              ),
                              InkWell(
                                  child: Ink(
                                    child: Text("Reply"),
                                    color: Colors.grey[500],
                                    width: 360,
                                  ),
                                  onTap: () async{
                                    replyToReplyTimeP = thePThreadReplies![index]["time"];
                                    replyToReplyContentP = thePThreadReplies![index]["replyContent"].toString();
                                    replyToReplyPosterP = thePThreadReplies![index]["replier"].toString();

                                    print("This is replyToReplyTime: $replyToReplyTimeP");

                                    await FirebaseFirestore.instance.collection("Projects").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                      myDocP = d.docs.first.id;
                                      print(myDocP);
                                    });

                                    await FirebaseFirestore.instance.collection("Projects").doc(myDocP).collection("Replies").where("time", isEqualTo: replyToReplyTimeP).get().then((rd) {
                                      replyToReplyDocP = rd.docs.first.id;
                                      print(replyToReplyDocP);
                                    });

                                    print(thePThreadReplies);
                                    print(replyToReplyDocP);

                                    DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Projects").doc(myDocP).collection("Replies").doc(replyToReplyDocP).get();
                                    print(ds.data());
                                    print(ds.data().runtimeType);

                                    myIndex = thePThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeP);

                                    print(thePThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeP));
                                    myReplyToReplyP = thePThreadReplies[myIndex];

                                    myReplyToReplyPMap = Map.from(myReplyToReplyP);

                                    List<dynamic> tempReplyToReplyList = [replyToReplyContentP, replyToReplyPosterP, myReplyToReplyPMap];
                                    pRepliesToReplies.add(tempReplyToReplyList);

                                    print("myReplyToReplyPMap: ${myReplyToReplyPMap}");

                                    print("myReplyToReplyP: ${myReplyToReplyP["replyContent"]}");
                                    print("This is myIndex: $myIndex");

                                    projectsReplyBool = true;
                                    projectsReplyingToReplyBool = true;
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                  }
                              ),
                            ]
                        ),
                      ],
                    );
                  }
              ),
            ],*/
            NumberPaginator(
              height: 50,
              numberPages: listOfProjectsThreadReplies.length != 0? numberOfPagesProjectsThreadReplies : 1,
              onPageChange: (myIndexProjectsThreadReplies){
                setState((){
                  theCurrentPageProjectsThreadReplies = myIndexProjectsThreadReplies;
                });
              }
            ),
          ],
        ),
      ),
    );
  }
}