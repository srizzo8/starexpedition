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

class projectsPage extends StatefulWidget{
  const projectsPage ({Key? key}) : super(key: key);

  @override
  projectsPageState createState() => projectsPageState();
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
        )
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Text("Projects Subforum", style: TextStyle(fontWeight: FontWeight.bold)),
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
                   print(projectsBool);
                   projectsBool = true;
                   print(projectsBool);
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                   print("I am going to write a new thread.");
                }
              ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: discussionBoardPage.projectsThreads.length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      Container(
                        height: 10,
                      ),
                      InkWell(
                          child: Ink(
                            child: Text(discussionBoardPage.projectsThreads[index]["threadTitle"].toString() + "\n" + "By: " + discussionBoardPage.projectsThreads[index]["poster"].toString()),
                            height: 30,
                            width: 360,
                            color: Colors.tealAccent,
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

class projectsThreadContent extends StatelessWidget{
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
            Navigator.pushNamed(context, '/discussionBoardPage'),
          }
        ),
      ),
      body: Wrap(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              child: Text("Thread title: " + threadTitleP + "\n" + "Posted by: " + threadAuthorP + "\n" + threadContentP),
              color: Colors.tealAccent,
              alignment: Alignment.topLeft,
            ),
          ),
          InkWell(
              child: Ink(
                color: Colors.deepPurpleAccent,
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
          Column(
            children: <Widget>[
              ListView.builder(
                  scrollDirection: Axis.vertical,
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
                                child: Text("Reply to: " + thePThreadReplies[index]["theOriginalReplyInfo"]["replyContent"].toString() + "\n" + "Posted by: " + thePThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString()),
                                color: Colors.teal,
                                width: 360,
                              ),
                              Container(
                                child: Text("Posted on: " + thePThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + thePThreadReplies[index]["replier"].toString() + "\n" + thePThreadReplies[index]["replyContent"].toString()),
                                color: Colors.tealAccent,
                                width: 360,
                              ),
                              InkWell(
                                  child: Ink(
                                    child: Text("Reply"),
                                    color: Colors.purple.shade200,
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
                                child: Text("Posted on: " + thePThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + thePThreadReplies[index]["replier"].toString() + "\n" + thePThreadReplies[index]["replyContent"].toString()),
                                color: Colors.tealAccent,
                                width: 360,
                              ),
                              InkWell(
                                  child: Ink(
                                    child: Text("Reply"),
                                    color: Colors.purple.shade200,
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
            ],
          ),
        ],
      ),
    );
  }
}