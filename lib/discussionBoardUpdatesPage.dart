import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'createThread.dart';
import 'discussionBoardPage.dart' as discussionBoardPage;
import 'replyThreadPage.dart';
import 'main.dart' as myMain;

bool discussionBoardUpdatesBool = false;
bool discussionBoardUpdatesReplyBool = false;
bool discussionBoardUpdatesReplyingToReplyBool = false;
var discussionBoardUpdatesThreads = [];
var discussionBoardUpdatesReplies = [];
int myIndex = -1;// = -1;
//List<List> reversedDiscussionBoardUpdatesThreadsList = discussionBoardUpdatesThreads.reversed.toList();
var reversedDiscussionBoardUpdatesThreadsIterable = discussionBoardUpdatesThreads.reversed;
var reversedDiscussionBoardUpdatesRepliesIterable = discussionBoardUpdatesReplies.reversed;
String threadAuthorDbu = "";
String threadTitleDbu = "";
String threadContentDbu = "";
//int threadsIndex = reversedDiscussionBoardUpdatesThreadsIterable.
String threadID = "";
int discussionBoardUpdatesThreadId = -1;
var theDbuThreadReplies;
var myDoc;
var replyToReplyDoc;
var replyToReplyTime;
var replyToReplyContent;
var replyToReplyPoster;

class discussionBoardUpdatesPage extends StatefulWidget{
  const discussionBoardUpdatesPage ({Key? key}) : super(key: key);

  @override
  discussionBoardUpdatesPageState createState() => discussionBoardUpdatesPageState();
}

class MyDiscussionBoardUpdatesPage extends StatelessWidget{
  const MyDiscussionBoardUpdatesPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext updatesSubforumBuildContext){
    return MaterialApp(
      title: 'Discussion Board Updates Page',
      routes: {
        routeToCreateThread.createThreadPage: (context) => createThread(),
        routeToReplyToThreadDiscussionBoardUpdates.replyThreadPage: (context) => replyThreadPage(),
      }
    );
  }
}

class routeToCreateThread{
  static String createThreadPage = createThreadState.threadCreator;
}

class routeToReplyToThreadDiscussionBoardUpdates{
  static String replyThreadPage = replyThreadPageState.replyThread;
}

class discussionBoardUpdatesPageState extends State<discussionBoardUpdatesPage>{
  static String dBoardRoute = '/discussionBoardUpdatesPage';

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
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
            child: Text("Discussion Board Updates Subforum", style: TextStyle(fontWeight: FontWeight.bold)),
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
              print(discussionBoardUpdatesBool);
              discussionBoardUpdatesBool = true;
              print(discussionBoardUpdatesBool);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
              print("I am going to write a new thread.");
            }
          ),
          Expanded(
            child: ListView.builder(
              itemCount: discussionBoardPage.discussionBoardUpdatesThreads.length,//discussionBoardUpdatesThreads.reversed.toList().length,
              itemBuilder: (context, index){
              return Column(
                children: <Widget>[
                  Container(
                    height: 10,
                  ),
                  GestureDetector(
                    child: Container(
                      child: Text(discussionBoardPage.discussionBoardUpdatesThreads[index]["threadTitle"].toString() + "\n" + "By: " + discussionBoardPage.discussionBoardUpdatesThreads[index]["poster"].toString()),//Text(reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][1] + "\n" + "By: " + reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][0]),
                      height: 30,
                      width: 360,
                      color: Colors.tealAccent,
                    ),
                    onTap: () async {
                      print("This is index: $index");
                      print("discussionBoardPage.discussionBoardUpdatesThreads is null? ${discussionBoardPage.discussionBoardUpdatesThreads == null}");
                      print("I clicked on a thread");
                      //print('You clicked on: ' + reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][1]);
                      //if(discussionBoardPage.discussionBoardUpdatesThreads[index].isNotEmpty){
                      threadAuthorDbu = discussionBoardPage.discussionBoardUpdatesThreads![index]["poster"].toString();//reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][0];
                      threadTitleDbu = discussionBoardPage.discussionBoardUpdatesThreads![index]["threadTitle"].toString();//reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][1];
                      threadContentDbu = discussionBoardPage.discussionBoardUpdatesThreads![index]["threadContent"].toString();//reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][2];
                      threadID = discussionBoardPage.discussionBoardUpdatesThreads![index]["threadId"].toString();//reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][3];
                      print("${threadAuthorDbu} + ${threadTitleDbu} + ${threadContentDbu} + ${threadID}");
                      print("context: ${context}");
                      await FirebaseFirestore.instance.collection("Discussion_Board_Updates").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                        myDoc = d.docs.first.id;
                        print(myDoc);
                      });
                      //var oneReply = {"animal": "dog", "breed": "belgian tervuren"};

                      //Getting the replies of a thread
                      await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies");//.add(oneReply);

                      QuerySnapshot dbuRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").get();//.do//.docs.map((myDoc) => myDoc.data()).toList();;
                      theDbuThreadReplies = dbuRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                      //print(theDbuThreadReplies[0]["threadNumber"]);
                      //print(theDbuThreadReplies.where((sr) => sr.replyContent == "Four!"));
                      print("Number of theDbuThreadReplies: ${theDbuThreadReplies.length}");
                      //}
                      /*await FirebaseFirestore.instance.collection("Discussion_Board_Updates").where("threadId", isEqualTo: int.parse(reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][3])).get().then((num){
                        discussionBoardUpdatesThreadId = num.docs.first.data()["threadId"];
                      });*/
                      //print("This is discussionBoardUpdatesThreadId: ${discussionBoardUpdatesThreadId}");
                      Navigator.push(context, MaterialPageRoute(builder: (context) => discussionBoardUpdatesThreadContent()));//myIndexPlace = index;
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

class discussionBoardUpdatesThreadContent extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => {
            Navigator.pop(context),
          }
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                child: Text("Thread title: " + threadTitleDbu + "\n" + "Posted by: " + threadAuthorDbu + "\n" + threadContentDbu),
                color: Colors.tealAccent,
                alignment: Alignment.topLeft,
              ),
            ),
            GestureDetector(
              child: Container(
                alignment: Alignment.topCenter,
                child: Text("Reply to thread", style: TextStyle(fontWeight: FontWeight.bold)),
                color: Colors.deepPurpleAccent,
                height: 20,
              ),
              onTap: (){
                discussionBoardUpdatesReplyingToReplyBool = false;
                discussionBoardUpdatesReplyBool = true;
                print(reversedDiscussionBoardUpdatesThreadsIterable.toList());
                //myIndexPlace = discussionBoardUpdatesPageState.index;
                //myIndexPlace = reversedDiscussionBoardUpdatesThreadsIterable.toList().indexWhere((reversedDiscussionBoardUpdatesThreadsIterable) => reversedDiscussionBoardUpdatesThreadsIterable.contains("[" + threadAuthorDbu + ", " + threadTitleDbu + ", " + threadContentDbu + "]"));
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
                    itemCount: theDbuThreadReplies.length,//FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").length//5,//discussionBoardUpdatesThreads[int.parse(threadID)][4].length,
                    itemBuilder: (context, index){
                      return Column(
                        children: <Widget>[
                          replyToReplyContent != null && replyToReplyPoster != null?//theDbuThreadReplies.length > 0?//discussionBoardUpdatesThreads[int.parse(threadID)][4][index][3] != "" && discussionBoardUpdatesThreads[int.parse(threadID)][4][index][4] != ""?
                          Column(
                          children: <Widget>[
                            Container(
                              height: 5,
                            ),
                            Container(
                              //Reply to: Reply content, reply poster
                              child: Text("Reply to: " + theDbuThreadReplies[myIndex]["replyContent"] + "\n" + "Posted by: " + theDbuThreadReplies[myIndex]["replier"]),//Text("Reply to: \n" + "Posted by: " + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][3].toString() + "\n" + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][4].toString()),
                              color: Colors.teal,
                              width: 360,
                            ),
                            //if(discussionBoardUpdatesThreads[int.parse(threadID)][4] != null)
                            Container(
                              //child: Text("Posted on: " + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][2] + "\n" + "Posted by: " + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][0] + "\n" + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][1]),
                              child: Text("Posted on: " + theDbuThreadReplies[index]["time"].toString() + "\n" + "Posted by: " + theDbuThreadReplies[index]["replier"].toString() + "\n" + theDbuThreadReplies[index]["replyContent"].toString()),//Text("Posted on: " + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][0].toString() + "\n" + "Posted by: " + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][1].toString() + "\n" + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][2].toString()),
                              color: Colors.tealAccent,
                              width: 360,
                            ),
                            GestureDetector(
                              child: Container(
                                child: Text("Reply"),
                                color: Colors.purple.shade200,
                                width: 360,
                              ),
                              onTap: () async{
                                replyToReplyTime = theDbuThreadReplies![index]["time"].toString();
                                replyToReplyContent = theDbuThreadReplies![index]["replyContent"].toString();
                                replyToReplyPoster = theDbuThreadReplies![index]["replier"].toString();
                                print("This is replyToReplyTime: $replyToReplyTime");

                                await FirebaseFirestore.instance.collection("Discussion_Board_Updates").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                  myDoc = d.docs.first.id;
                                  print(myDoc);
                                });
                                await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").where("time", isEqualTo: replyToReplyTime).get().then((rd) {
                                  replyToReplyDoc = rd.docs.first.id;
                                  //replyToReplyTime = rd.docs.first["time"];
                                  //print("This is t: $replyToReplyTime");
                                  //replyContent = dbuRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                                  print(replyToReplyDoc);
                                });

                                //var theReply = FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").where();

                                //.add(oneReply);

                                //QuerySnapshot dbuRepliesQuerySnapshot = (await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").doc(replyToReplyDoc).get()) as QuerySnapshot<Object?>;//.do//.docs.map((myDoc) => myDoc.data()).toList();;
                                //theDbuThreadReplies = dbuRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                                print(theDbuThreadReplies);
                                print(replyToReplyDoc);
                                //print(replyToReplyDoc.snapshot);
                                //print(replyContent);
                                DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").doc(replyToReplyDoc).get();
                                print(ds.data());
                                print(ds.data().runtimeType);
                                print(theDbuThreadReplies.indexWhere((i) => i["time"] == replyToReplyTime));
                                myIndex = theDbuThreadReplies.indexWhere((i) => i["time"] == replyToReplyTime); //where replyToReplyDoc is in theDbuThreadReplies.
                                print("This is myIndex: $myIndex");
                                discussionBoardUpdatesReplyBool = true;
                                discussionBoardUpdatesReplyingToReplyBool = true;
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                //print('Reply no. ' + index.toString());
                                //print('Replying to this reply: ' + discussionBoardUpdatesThreads[int.parse(threadID)][4][myIndex][2].toString());
                              }
                            ),
                          ]
                          ): Column(
                              children: <Widget>[
                                Container(
                                  height: 5,
                                ),
                                //if(discussionBoardUpdatesThreads[int.parse(threadID)][4] != null)
                                Container(
                                  //child: Text("Posted on: " + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][2] + "\n" + "Posted by: " + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][0] + "\n" + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][1]),
                                  child: Text("Posted on: " + theDbuThreadReplies[index]["time"].toString() + "\n" + "Posted by: " + theDbuThreadReplies[index]["replier"].toString() + "\n" + theDbuThreadReplies[index]["replyContent"].toString()),//Text("Posted on: " + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][0].toString() + "\n" + "Posted by: " + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][1].toString() + "\n" + discussionBoardUpdatesThreads[int.parse(threadID)][4][index][2].toString()),
                                  color: Colors.tealAccent,
                                  width: 360,
                                ),
                                GestureDetector(
                                    child: Container(
                                      child: Text("Reply"),
                                      color: Colors.purple.shade200,
                                      width: 360,
                                    ),
                                    onTap: () async{
                                      replyToReplyTime = theDbuThreadReplies![index]["time"].toString();
                                      replyToReplyContent = theDbuThreadReplies![index]["replyContent"].toString();
                                      replyToReplyPoster = theDbuThreadReplies![index]["replier"].toString();
                                      print("This is replyToReplyTime: $replyToReplyTime");

                                      await FirebaseFirestore.instance.collection("Discussion_Board_Updates").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                        myDoc = d.docs.first.id;
                                        print(myDoc);
                                      });
                                      await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").where("time", isEqualTo: replyToReplyTime).get().then((rd) {
                                        replyToReplyDoc = rd.docs.first.id;
                                        //replyToReplyTime = rd.docs.first["time"];
                                        //print("This is t: $replyToReplyTime");
                                        //replyContent = dbuRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                                        print(replyToReplyDoc);
                                      });

                                      //var theReply = FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").where();

                                      //.add(oneReply);

                                      //QuerySnapshot dbuRepliesQuerySnapshot = (await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").doc(replyToReplyDoc).get()) as QuerySnapshot<Object?>;//.do//.docs.map((myDoc) => myDoc.data()).toList();;
                                      //theDbuThreadReplies = dbuRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                                      print(theDbuThreadReplies);
                                      print(replyToReplyDoc);
                                      //print(replyToReplyDoc.snapshot);
                                      //print(replyContent);
                                      DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").doc(replyToReplyDoc).get();
                                      print(ds.data());
                                      print(ds.data().runtimeType);
                                      print(theDbuThreadReplies[1].runtimeType);
                                      myIndex = theDbuThreadReplies.indexWhere((i) => i["time"] == replyToReplyTime);
                                      //where replyToReplyDoc is in theDbuThreadReplies.
                                      print(theDbuThreadReplies.indexWhere((i) => i["time"] == replyToReplyTime));
                                      print("This is myIndex: $myIndex");
                                      discussionBoardUpdatesReplyBool = true;
                                      discussionBoardUpdatesReplyingToReplyBool = true;
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                      //print('Reply no. ' + index.toString());
                                      //print('Replying to this reply: ' + discussionBoardUpdatesThreads[int.parse(threadID)][4][myIndex][2].toString());
                                      //print('Reply no. ' + index.toString());
                                      //print('Replying to this reply: ' + discussionBoardUpdatesThreads[int.parse(threadID)][4][myIndex][2].toString());
                                      /*var replyContent;
                                      await FirebaseFirestore.instance.collection("Discussion_Board_Updates").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                        myDoc = d.docs.first.id;
                                        print(myDoc);
                                      });
                                      await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").get().then((secondRd) {
                                        replyContent = secondRd.docs.first;
                                        replyToReplyDoc = secondRd.docs.first.id;

                                        replyToReplyTime = secondRd.docs.first["time"];
                                        print("This is t: $replyToReplyTime");

                                        print(replyToReplyDoc);
                                      });
                                      print(theDbuThreadReplies);
                                      print(replyToReplyDoc);
                                      print(replyContent);
                                      myIndex = theDbuThreadReplies.indexOf(replyToReplyDoc); //where replyToReplyDoc is in theDbuThreadReplies.
                                      print("This is myIndex: $myIndex");
                                      discussionBoardUpdatesReplyBool = true;
                                      discussionBoardUpdatesReplyingToReplyBool = true;
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                      //print('Reply no. ' + index.toString());
                                      //print('Replying to this reply: ' + discussionBoardUpdatesThreads[int.parse(threadID)][4][myIndex][2].toString());
                                      /*myIndex = index;
                                      discussionBoardUpdatesReplyBool = true;
                                      discussionBoardUpdatesReplyingToReplyBool = true;
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                      print('Reply no. ' + index.toString());
                                      print('Replying to this reply: ' + discussionBoardUpdatesThreads[int.parse(threadID)][4][myIndex][2].toString());*/
                                      print(theDbuThreadReplies.length);*/
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