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
            child: Text("Technologies Subforum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
              height: 20,
              width: 120,
              margin: EdgeInsets.only(left: 250.0),
              alignment: Alignment.center,
              child: InkWell(
                child: Ink(
                  child: Text("Post new thread", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
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
            child: ListView.builder(
                itemCount: discussionBoardPage.technologiesThreads.length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      Container(
                        height: 10,
                      ),
                      InkWell(
                          child: Ink(
                            child: Text(discussionBoardPage.technologiesThreads[index]["threadTitle"].toString() + "\n" + "By: " + discussionBoardPage.technologiesThreads[index]["poster"].toString()),
                            height: 30,
                            width: 360,
                            color: Colors.grey[300],
                          ),
                          onTap: () async{
                            print("This is index: $index");
                            print("discussionBoardPage.technologiesThreads is null? ${discussionBoardPage.technologiesThreads == null}");
                            print("I clicked on a thread");
                            threadAuthorT = discussionBoardPage.technologiesThreads![index]["poster"].toString();
                            threadTitleT = discussionBoardPage.technologiesThreads![index]["threadTitle"].toString();
                            threadContentT = discussionBoardPage.technologiesThreads![index]["threadContent"].toString();
                            threadID = discussionBoardPage.technologiesThreads![index]["threadId"].toString();

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
      body: Wrap(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              child: Text("Thread title: " + threadTitleT + "\n" + "Posted by: " + threadAuthorT + "\n" + threadContentT),
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
                                child: Text("Reply to: " + theTThreadReplies[index]["theOriginalReplyInfo"]["replyContent"].toString() + "\n" + "Posted by: " + theTThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString()),
                                color: Colors.blueGrey[300],
                                width: 360,
                              ),
                              Container(
                                child: Text("Posted on: " + theTThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + theTThreadReplies[index]["replier"].toString() + "\n" + theTThreadReplies[index]["replyContent"].toString()),
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
                                child: Text("Posted on: " + theTThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + theTThreadReplies[index]["replier"].toString() + "\n" + theTThreadReplies[index]["replyContent"].toString()),
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
    );
  }
}