import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'createThread.dart';
import 'replyThreadPage.dart';
import 'main.dart' as myMain;
import 'discussionBoardPage.dart' as discussionBoardPage;

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

  Widget build(BuildContext buildContext){
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
            child: Text("New Discoveries Subforum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          //InkWell(
            Container(
              //color: Colors.black,
              height: 20,
              width: 130,
              margin: EdgeInsets.only(left: 250.0),
              alignment: Alignment.center,
              child: InkWell(
                child: Ink(
                  color: Colors.black,
                  child: Text("Post new thread", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                ),
                onTap: (){
                    print(newDiscoveriesBool);
                    newDiscoveriesBool = true;
                    print(newDiscoveriesBool);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                    print("I am going to write a new thread.");
                  }
              ),
            ),
          //),
          Expanded(
            child: ListView.builder(
                itemCount: discussionBoardPage.newDiscoveriesThreads.length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      Container(
                        height: 10,
                      ),
                      InkWell(
                          child: Ink(
                            child: Text(discussionBoardPage.newDiscoveriesThreads[index]["threadTitle"].toString() + "\n" + "By: " + discussionBoardPage.newDiscoveriesThreads[index]["poster"].toString()),
                            height: 30,
                            width: 360,
                            color: Colors.grey[300],
                          ),
                          onTap: () async{
                            print("This is index: $index");
                            print("discussionBoardPage.newDiscoveriesThreads is null? ${discussionBoardPage.newDiscoveriesThreads == null}");
                            print("I clicked on a thread");
                            threadAuthorNd = discussionBoardPage.newDiscoveriesThreads![index]["poster"].toString();
                            threadTitleNd = discussionBoardPage.newDiscoveriesThreads![index]["threadTitle"].toString();
                            threadContentNd = discussionBoardPage.newDiscoveriesThreads![index]["threadContent"].toString();
                            threadID = discussionBoardPage.newDiscoveriesThreads![index]["threadId"].toString();

                            print(discussionBoardPage.newDiscoveriesThreads![index]);
                            print("${threadAuthorNd} + ${threadTitleNd} + ${threadContentNd} + ${threadID}");
                            print("context: ${context}");
                            await FirebaseFirestore.instance.collection("New_Discoveries").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                              myDocNd = d.docs.first.id;
                              print(myDocNd);
                            });

                            await FirebaseFirestore.instance.collection("New_Discoveries").doc(myDocNd).collection("Replies");

                            QuerySnapshot ndRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("New_Discoveries").doc(myDocNd).collection("Replies").get();
                            theNdThreadReplies = ndRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                            print(theNdThreadReplies.runtimeType);

                            print(DateTime.now().runtimeType);

                            (theNdThreadReplies as List<dynamic>).sort((b2, a2) => (a2["time"].toDate()).compareTo(b2["time"].toDate()));

                            print("Number of theNdThreadReplies: ${theNdThreadReplies.length}");

                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => newDiscoveriesThreadContent()));
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
      body: Wrap(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              child: Text("Thread title: " + threadTitleNd + "\n" + "Posted by: " + threadAuthorNd + "\n" + threadContentNd),
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
              newDiscoveriesReplyingToReplyBool = false;
              newDiscoveriesReplyBool = true;
              print(reversedNewDiscoveriesThreadsIterable.toList());
              print(threadID);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
              print('Replying to the thread');
            }
          ),
          Column(
            children: <Widget>[
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: theNdThreadReplies.length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      theNdThreadReplies[index]["theOriginalReplyInfo"]["replyContent"] != null && theNdThreadReplies[index]["theOriginalReplyInfo"]["replier"] != null?
                        Column(
                          children: <Widget>[
                            Container(
                              height: 5,
                            ),
                            Container(
                              child: Text("Reply to: " + theNdThreadReplies[index]["theOriginalReplyInfo"]["replyContent"].toString() + "\n" + "Posted by: " + theNdThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString()),
                              color: Colors.blueGrey[300],
                              width: 360,
                            ),
                            Container(
                              child: Text("Posted on: " + theNdThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + theNdThreadReplies[index]["replier"].toString() + "\n" + theNdThreadReplies[index]["replyContent"].toString()),
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
                                replyToReplyTimeNd = theNdThreadReplies![index]["time"];
                                replyToReplyContentNd = theNdThreadReplies![index]["replyContent"].toString();
                                replyToReplyPosterNd = theNdThreadReplies![index]["replier"].toString();

                                print("This is replyToReplyTime: $replyToReplyTimeNd");

                                await FirebaseFirestore.instance.collection("New_Discoveries").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                  myDocNd = d.docs.first.id;
                                  print(myDocNd);
                                });

                                await FirebaseFirestore.instance.collection("New_Discoveries").doc(myDocNd).collection("Replies").where("time", isEqualTo: replyToReplyTimeNd).get().then((rd) {
                                  replyToReplyDocNd = rd.docs.first.id;
                                  print(replyToReplyDocNd);
                                });

                                print(theNdThreadReplies);
                                print(replyToReplyDocNd);

                                DocumentSnapshot ds = await FirebaseFirestore.instance.collection("New_Discoveries").doc(myDocNd).collection("Replies").doc(replyToReplyDocNd).get();
                                print(ds.data());
                                print(ds.data().runtimeType);
                                print(theNdThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeNd));

                                myIndex = theNdThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeNd);
                                myReplyToReplyNd = theNdThreadReplies[myIndex];
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
                          ]
                        ): Column(
                            children: <Widget>[
                              Container(
                                height: 5,
                              ),
                              Container(
                                child: Text("Posted on: " + theNdThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + theNdThreadReplies[index]["replier"].toString() + "\n" + theNdThreadReplies[index]["replyContent"].toString()),
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
                                  replyToReplyTimeNd = theNdThreadReplies![index]["time"];
                                  replyToReplyContentNd = theNdThreadReplies![index]["replyContent"].toString();
                                  replyToReplyPosterNd = theNdThreadReplies![index]["replier"].toString();

                                  print("This is replyToReplyTime: $replyToReplyTimeNd");

                                  await FirebaseFirestore.instance.collection("New_Discoveries").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                    myDocNd = d.docs.first.id;
                                    print(myDocNd);
                                  });

                                  await FirebaseFirestore.instance.collection("New_Discoveries").doc(myDocNd).collection("Replies").where("time", isEqualTo: replyToReplyTimeNd).get().then((rd) {
                                    replyToReplyDocNd = rd.docs.first.id;
                                    print(replyToReplyDocNd);
                                  });

                                  print(theNdThreadReplies);
                                  print(replyToReplyDocNd);

                                  DocumentSnapshot ds = await FirebaseFirestore.instance.collection("New_Discoveries").doc(myDocNd).collection("Replies").doc(replyToReplyDocNd).get();
                                  print(ds.data());
                                  print(ds.data().runtimeType);

                                  myIndex = theNdThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeNd);

                                  print(theNdThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeNd));
                                  myReplyToReplyNd = theNdThreadReplies[myIndex];

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
    );
  }
}