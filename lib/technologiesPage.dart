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

bool technologiesBool = false;
bool technologiesReplyBool = false;
bool technologiesReplyingToReplyBool = false;
var technologiesThreads = [];
var technologiesReplies = [];
int myIndex = -1;
var reversedTechnologiesThreadsIterable = technologiesThreads.reversed;
var reversedTechnologiesRepliesIterable = technologiesReplies.reversed;
String threadAuthorT = "";
String threadTitleT = "";
String threadContentT = "";
String threadID = "";
var theTThreadReplies;
var myDocT;
var replyToReplyDocT;
var replyToReplyTimeT;
var replyToReplyContentT;
var replyToReplyPosterT;
var myReplyToReplyT;
var replyToReplyOriginalInfoT;
List<List> tRepliesToReplies = [];
Map<String, dynamic> myReplyToReplyTMap = {};

var technologiesNameData;
bool technologiesClickedOnUser = false;

class technologiesPage extends StatefulWidget{
  const technologiesPage ({Key? key}) : super(key: key);

  @override
  technologiesPageState createState() => technologiesPageState();
}

class MyTechnologiesPage extends StatelessWidget{
  const MyTechnologiesPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext bc){
    return MaterialApp(
        title: "Technologies Page",
        routes: {
          routeToCreateThreadTechnologiesPage.createThreadPage: (context) => createThread(),
          routeToReplyToThreadTechnologiesPage.replyThreadPage: (context) => replyThreadPage(),
        }
    );
  }
}

class routeToCreateThreadTechnologiesPage{
  static String createThreadPage = createThreadState.threadCreator;
}

class routeToReplyToThreadTechnologiesPage{
  static String replyThreadPage = replyThreadPageState.replyThread;
}

class technologiesPageState extends State<technologiesPage>{
  static String technologiesRoute = '/technologiesPage';
  int numberOfPagesTechnologies = (((discussionBoardPage.technologiesThreads.length)/10)).ceil();
  int theCurrentPageTechnologies = 0;

  var listOfTechnologiesThreads = discussionBoardPage.technologiesThreads;
  var mySublistsTechnologies = [];
  var portionSizeTechnologies = 10;

  Widget build(BuildContext buildContext){
    for(int i = 0; i < listOfTechnologiesThreads.length; i += portionSizeTechnologies){
      mySublistsTechnologies.add(listOfTechnologiesThreads.sublist(i, i + portionSizeTechnologies > listOfTechnologiesThreads.length ? listOfTechnologiesThreads.length : i + portionSizeTechnologies));
    }

    var myPagesTechnologies = List.generate(
      numberOfPagesTechnologies,
        (index) => Center(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: mySublistsTechnologies[theCurrentPageTechnologies].length,
              itemBuilder: (context, index){
                return Column(
                  children: <Widget>[
                    Container(
                      height: 10,
                    ),
                    InkWell(
                        child: Ink(
                          //child: Text(discussionBoardPage.technologiesThreads[index]["threadTitle"].toString() + "\n" + "By: " + discussionBoardPage.technologiesThreads[index]["poster"].toString()),
                          child: Text.rich(
                            TextSpan(
                              text: "${mySublistsTechnologies[theCurrentPageTechnologies][index]["threadTitle"].toString()}\nBy: ",
                              children: <TextSpan>[
                                TextSpan(
                                    text: "${mySublistsTechnologies[theCurrentPageTechnologies][index]["poster"].toString()}",
                                    recognizer: TapGestureRecognizer()..onTap = () async =>{
                                      technologiesClickedOnUser = true,
                                      technologiesNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsTechnologies[theCurrentPageTechnologies][index]["poster"].toString().toLowerCase()).get(),
                                      technologiesNameData.docs.forEach((person){
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
                          print("listOfTechnologiesThreads is null? ${listOfTechnologiesThreads == null}");
                          print("I clicked on a thread");
                          threadAuthorT = mySublistsTechnologies[theCurrentPageTechnologies][index]["poster"].toString();
                          threadTitleT = mySublistsTechnologies[theCurrentPageTechnologies][index]["threadTitle"].toString();
                          threadContentT = mySublistsTechnologies[theCurrentPageTechnologies][index]["threadContent"].toString();
                          threadID = mySublistsTechnologies[theCurrentPageTechnologies][index]["threadId"].toString();

                          print(discussionBoardPage.technologiesThreads![index]);
                          print("${threadAuthorT} + ${threadTitleT} + ${threadContentT} + ${threadID}");
                          print("context: ${context}");
                          await FirebaseFirestore.instance.collection("Technologies").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                            myDocT = d.docs.first.id;
                            print(myDocT);
                          });

                          await FirebaseFirestore.instance.collection("Technologies").doc(myDocT).collection("Replies");

                          QuerySnapshot tRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Technologies").doc(myDocT).collection("Replies").get();
                          theTThreadReplies = tRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                          print(theTThreadReplies.runtimeType);

                          print(DateTime.now().runtimeType);

                          (theTThreadReplies as List<dynamic>).sort((b2, a2) => (a2["time"].toDate()).compareTo(b2["time"].toDate()));

                          print("Number of theTThreadReplies: ${theTThreadReplies.length}");

                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => technologiesThreadContent()));
                        }
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
            height: 5,
          ),
          Container(
            child: Text("Technologies Subforum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
              height: 30,
              width: 120,
              margin: EdgeInsets.only(left: 250.0),
              alignment: Alignment.center,
              child: InkWell(
                child: Ink(
                  child: Text("Post new thread", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                  padding: EdgeInsets.all(5.0),
                  color: Colors.black,
                ),
                onTap: (){
                  print(technologiesBool);
                  technologiesBool = true;
                  print(technologiesBool);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                  print("I am going to write a new thread.");
                }
              ),
          ),
          Expanded(
            child: myPagesTechnologies[theCurrentPageTechnologies],
          ),
          NumberPaginator(
            height: 50,
            numberPages: numberOfPagesTechnologies,
            onPageChange: (myIndexTechnologies){
              setState((){
                theCurrentPageTechnologies = myIndexTechnologies;
              });
            }
          ),
        ],
      ),
    );
  }
}

class technologiesThreadContent extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            Navigator.pop(context),//Navigator.pushNamed(context, '/discussionBoardPage'),
          }
        ),
      ),
      body: SingleChildScrollView(
        child: Wrap(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              //child: Text("Thread title: " + threadTitleT + "\n" + "Posted by: " + threadAuthorT + "\n" + threadContentT),
              child: Text.rich(
                TextSpan(
                  text: "Thread title: ${threadTitleT}\nPosted by: ",
                  children: <TextSpan>[
                    TextSpan(
                      text: "${threadAuthorT}",
                      recognizer: TapGestureRecognizer()..onTap = () async =>{
                        technologiesClickedOnUser = true,
                        technologiesNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: threadAuthorT.toLowerCase()).get(),
                        technologiesNameData.docs.forEach((person){
                          theUsersData = person.data();
                        }),
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                      }
                    ),
                    TextSpan(
                      text: " ",
                    ),
                    TextSpan(
                      text: "\n${threadContentT}",
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
                technologiesReplyingToReplyBool = false;
                technologiesReplyBool = true;
                print(reversedTechnologiesThreadsIterable.toList());
                print(threadID);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                //Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                print('Replying to the thread');
              }
          ),
          Column(
            children: <Widget>[
              ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: theTThreadReplies.length,
                  itemBuilder: (context, index){
                    return Column(
                      children: <Widget>[
                        theTThreadReplies[index]["theOriginalReplyInfo"]["replyContent"] != null && theTThreadReplies[index]["theOriginalReplyInfo"]["replier"] != null?
                        Column(
                            children: <Widget>[
                              Container(
                                height: 5,
                              ),
                              Container(
                                //child: Text("Reply to: " + theTThreadReplies[index]["theOriginalReplyInfo"]["replyContent"].toString() + "\n" + "Posted by: " + theTThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    text: "Reply to: ${theTThreadReplies[index]["theOriginalReplyInfo"]["replyContent"].toString()}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "${theTThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          technologiesClickedOnUser = true,
                                          technologiesNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theTThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString().toLowerCase()).get(),
                                          technologiesNameData.docs.forEach((person){
                                            theUsersData = person.data();
                                          }),
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                      ),
                                      TextSpan(
                                        text: " ",
                                      ),
                                    ],
                                  )
                                ),
                                color: Colors.blueGrey[300],
                                width: 360,
                              ),
                              Container(
                                //child: Text("Posted on: " + theTThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + theTThreadReplies[index]["replier"].toString() + "\n" + theTThreadReplies[index]["replyContent"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    text: "Posted on: ${theTThreadReplies[index]["time"].toDate().toString()}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "${theTThreadReplies[index]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          technologiesClickedOnUser = true,
                                          technologiesNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theTThreadReplies[index]["replier"].toString().toLowerCase()).get(),
                                          technologiesNameData.docs.forEach((person){
                                            theUsersData = person.data();
                                          }),
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                      ),
                                      TextSpan(
                                        text: " ",
                                      ),
                                      TextSpan(
                                        text: "\n${theTThreadReplies[index]["replyContent"].toString()}",
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
                                    replyToReplyTimeT = theTThreadReplies![index]["time"];
                                    replyToReplyContentT = theTThreadReplies![index]["replyContent"].toString();
                                    replyToReplyPosterT = theTThreadReplies![index]["replier"].toString();

                                    print("This is replyToReplyTime: $replyToReplyTimeT");

                                    await FirebaseFirestore.instance.collection("Technologies").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                      myDocT = d.docs.first.id;
                                      print(myDocT);
                                    });

                                    await FirebaseFirestore.instance.collection("Technologies").doc(myDocT).collection("Replies").where("time", isEqualTo: replyToReplyTimeT).get().then((rd) {
                                      replyToReplyDocT = rd.docs.first.id;
                                      print(replyToReplyDocT);
                                    });

                                    print(theTThreadReplies);
                                    print(replyToReplyDocT);

                                    DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Technologies").doc(myDocT).collection("Replies").doc(replyToReplyDocT).get();
                                    print(ds.data());
                                    print(ds.data().runtimeType);
                                    print(theTThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeT));

                                    myIndex = theTThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeT);
                                    myReplyToReplyT = theTThreadReplies[myIndex];
                                    myReplyToReplyTMap = Map.from(myReplyToReplyT);

                                    List<dynamic> tempReplyToReplyList = [replyToReplyContentT, replyToReplyPosterT, myReplyToReplyTMap];
                                    tRepliesToReplies.add(tempReplyToReplyList);

                                    print("myReplyToReplyTMap: ${myReplyToReplyTMap}");
                                    print("myReplyToReplyT: ${myReplyToReplyT["replyContent"]}");
                                    print("This is myIndex: $myIndex");

                                    technologiesReplyBool = true;
                                    technologiesReplyingToReplyBool = true;
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
                                //child: Text("Posted on: " + theTThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + theTThreadReplies[index]["replier"].toString() + "\n" + theTThreadReplies[index]["replyContent"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    text: "Posted on: ${theTThreadReplies[index]["time"].toDate().toString()}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "${theTThreadReplies[index]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          technologiesClickedOnUser = true,
                                          technologiesNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theTThreadReplies[index]["replier"].toString().toLowerCase()).get(),
                                          technologiesNameData.docs.forEach((person){
                                            theUsersData = person.data();
                                          }),
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                      ),
                                      TextSpan(
                                        text: " ",
                                      ),
                                      TextSpan(
                                        text: "\n${theTThreadReplies[index]["replyContent"].toString()}",
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
                                    replyToReplyTimeT = theTThreadReplies![index]["time"];
                                    replyToReplyContentT = theTThreadReplies![index]["replyContent"].toString();
                                    replyToReplyPosterT = theTThreadReplies![index]["replier"].toString();

                                    print("This is replyToReplyTime: $replyToReplyTimeT");

                                    await FirebaseFirestore.instance.collection("Technologies").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                      myDocT = d.docs.first.id;
                                      print(myDocT);
                                    });

                                    await FirebaseFirestore.instance.collection("Technologies").doc(myDocT).collection("Replies").where("time", isEqualTo: replyToReplyTimeT).get().then((rd) {
                                      replyToReplyDocT = rd.docs.first.id;
                                      print(replyToReplyDocT);
                                    });

                                    print(theTThreadReplies);
                                    print(replyToReplyDocT);

                                    DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Technologies").doc(myDocT).collection("Replies").doc(replyToReplyDocT).get();
                                    print(ds.data());
                                    print(ds.data().runtimeType);

                                    myIndex = theTThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeT);

                                    print(theTThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeT));
                                    myReplyToReplyT = theTThreadReplies[myIndex];

                                    myReplyToReplyTMap = Map.from(myReplyToReplyT);

                                    List<dynamic> tempReplyToReplyList = [replyToReplyContentT, replyToReplyPosterT, myReplyToReplyTMap];
                                    tRepliesToReplies.add(tempReplyToReplyList);

                                    print("myReplyToReplyTMap: ${myReplyToReplyTMap}");

                                    print("myReplyToReplyT: ${myReplyToReplyT["replyContent"]}");
                                    print("This is myIndex: $myIndex");

                                    technologiesReplyBool = true;
                                    technologiesReplyingToReplyBool = true;
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
        ],
      ),
      ),
    );
  }
}