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

import 'discussionBoardPage.dart' as discussionBoardPage;
import 'createThread.dart';
import 'replyThreadPage.dart';
import 'main.dart' as myMain;

bool questionsAndAnswersBool = false;
bool questionsAndAnswersReplyBool = false;
bool questionsAndAnswersReplyingToReplyBool = false;
var questionsAndAnswersThreads = [];
var questionsAndAnswersReplies = [];
int myIndex = -1;
var reversedQuestionsAndAnswersThreadsIterable = questionsAndAnswersThreads.reversed;
var reversedQuestionsAndAnswersRepliesIterable = questionsAndAnswersReplies.reversed;
String threadAuthorQaa = "";
String threadTitleQaa = "";
String threadContentQaa = "";
String threadID = "";
var theQaaThreadReplies;
var myDocQaa;
var replyToReplyDocQaa;
var replyToReplyTimeQaa;
var replyToReplyContentQaa;
var replyToReplyPosterQaa;
var myReplyToReplyQaa;
var replyToReplyOriginalInfoQaa;
List<List> qaaRepliesToReplies = [];
Map<String, dynamic> myReplyToReplyQaaMap = {};

var qaaNameData;
bool qaaClickedOnUser = false;

var mySublistsQaaInformation;
var myIndexPlaceQaa;
var myLocation;

class questionsAndAnswersPage extends StatefulWidget{
  const questionsAndAnswersPage ({Key? key}) : super(key: key);

  @override
  questionsAndAnswersPageState createState() => questionsAndAnswersPageState();
}

class questionsAndAnswersThreadsPage extends StatefulWidget{
  const questionsAndAnswersThreadsPage ({Key? key}) : super(key: key);

  @override
  questionsAndAnswersThreadContent createState() => questionsAndAnswersThreadContent();
}

class MyQuestionsAndAnswersPage extends StatelessWidget{
  const MyQuestionsAndAnswersPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext bc){
    return MaterialApp(
        title: "Questions and Answers Page",
        routes: {
          routeToCreateThreadQuestionsAndAnswersPage.createThreadPage: (context) => createThread(),
          routeToReplyToThreadQuestionsAndAnswersPage.replyThreadPage: (context) => replyThreadPage(),
        }
    );
  }
}

class routeToCreateThreadQuestionsAndAnswersPage{
  static String createThreadPage = createThreadState.threadCreator;
}

class routeToReplyToThreadQuestionsAndAnswersPage{
  static String replyThreadPage = replyThreadPageState.replyThread;
}

class questionsAndAnswersPageState extends State<questionsAndAnswersPage>{
  static String questionsAndAnswersRoute = '/questionsAndAnswersPage';
  int numberOfPagesQaa = (((discussionBoardPage.questionsAndAnswersThreads.length)/10)).ceil();
  int theCurrentPageQaa = 0;

  var listOfQaaThreads = discussionBoardPage.questionsAndAnswersThreads;
  var mySublistsQaa = [];
  var portionSizeQaa = 10;

  Widget build(BuildContext buildContext){
    for(int i = 0; i < listOfQaaThreads.length; i += portionSizeQaa){
      mySublistsQaa.add(listOfQaaThreads.sublist(i, i + portionSizeQaa > listOfQaaThreads.length ? listOfQaaThreads.length : i + portionSizeQaa));
    }

    mySublistsQaaInformation = mySublistsQaa;

    var myPagesQaa = List.generate(
      numberOfPagesQaa,
        (index) => Center(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: mySublistsQaa[theCurrentPageQaa].length,//questionsAndAnswersThreads.reversed.toList().length,
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
                              //child: Text(discussionBoardPage.questionsAndAnswersThreads[index]["threadTitle"].toString() + "\n" + "By: " + discussionBoardPage.questionsAndAnswersThreads[index]["poster"].toString()),//Text(reversedQuestionsAndAnswersThreadsIterable.toList()[index][1] + "\n" + "By: " + reversedQuestionsAndAnswersThreadsIterable.toList()[index][0]),
                              child: Text.rich(
                                TextSpan(
                                  text: "${mySublistsQaa[theCurrentPageQaa][index]["threadTitle"].toString()}\nBy: ",
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "${mySublistsQaa[theCurrentPageQaa][index]["poster"].toString()}",
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          qaaClickedOnUser = true,
                                          qaaNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsQaa[theCurrentPageQaa][index]["poster"].toString().toLowerCase()).get(),
                                          qaaNameData.docs.forEach((person){
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
                          onPressed: () async {
                            print("This is index: $index");
                            print("listOfQaaThreads is null? ${listOfQaaThreads == null}");
                            print("I clicked on a thread");

                            myIndexPlaceQaa = index;
                            myLocation = theCurrentPageQaa;

                            threadAuthorQaa = mySublistsQaa[theCurrentPageQaa][index]["poster"].toString();
                            threadTitleQaa = mySublistsQaa[theCurrentPageQaa][index]["threadTitle"].toString();
                            threadContentQaa = mySublistsQaa[theCurrentPageQaa][index]["threadContent"].toString();
                            threadID = mySublistsQaa[theCurrentPageQaa][index]["threadId"].toString();

                            print(discussionBoardPage.questionsAndAnswersThreads![index]);
                            print("${threadAuthorQaa} + ${threadTitleQaa} + ${threadContentQaa} + ${threadID}");
                            print("context: ${context}");
                            await FirebaseFirestore.instance.collection("Questions_And_Answers").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                              myDocQaa = d.docs.first.id;
                              print(myDocQaa);
                            });

                            await FirebaseFirestore.instance.collection("Questions_And_Answers").doc(myDocQaa).collection("Replies");

                            QuerySnapshot qaaRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Questions_And_Answers").doc(myDocQaa).collection("Replies").get();
                            theQaaThreadReplies = qaaRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                            print(theQaaThreadReplies.runtimeType);
                            //print(theQaaThreadReplies[0]["time"].toDate().runtimeType);

                            print(DateTime.now().runtimeType);

                            (theQaaThreadReplies as List<dynamic>).sort((b2, a2) => (a2["time"].toDate()).compareTo(b2["time"].toDate()));

                            print("Number of theQaaThreadReplies: ${theQaaThreadReplies.length}");
                            //}

                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => questionsAndAnswersThreadsPage()));
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
            Navigator.pushNamed(context, '/discussionBoardPage'),
          }
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 10,
          ),
          Container(
            child: Text("Questions and Answers Subforum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
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
                    color: Colors.black,
                    padding: EdgeInsets.all(5.0),
                    child: Text("Post new thread", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white), textAlign: TextAlign.center),
                    height: 30,
                    width: 120,
                  ),
                ),
                onPressed: (){
                  print(questionsAndAnswersBool);
                  questionsAndAnswersBool = true;
                  print(questionsAndAnswersBool);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                  print("I am going to write a new thread.");
                }
              ),
          ),
          Expanded(
            child: listOfQaaThreads.length != 0? myPagesQaa[theCurrentPageQaa] : Text("There are no threads in this subforum yet. Be the first to post a thread!", textAlign: TextAlign.center),//myPagesQaa[theCurrentPageQaa],
          ),
          NumberPaginator(
            height: 50,
            numberPages: listOfQaaThreads.length != 0? numberOfPagesQaa : 1,
            onPageChange: (myIndexQaa){
              setState((){
                theCurrentPageQaa = myIndexQaa;
              });
            }
          ),
        ],
      ),
    );
  }
}

class questionsAndAnswersThreadContent extends State<questionsAndAnswersThreadsPage>{
  int numberOfPagesQaaThreadReplies = 0;
  int theCurrentPageQaaThreadReplies = 0;

  var listOfQaaThreadReplies = theQaaThreadReplies;
  var mySublistsQaaThreadReplies = [];
  int portionSizeQaaThreadReplies = 10;

  @override
  Widget build(BuildContext context){
    if(listOfQaaThreadReplies == []){
      numberOfPagesQaaThreadReplies = 1;
    }
    else{
      numberOfPagesQaaThreadReplies = (((theQaaThreadReplies.length)/10)).ceil();

      for(int i = 0; i < listOfQaaThreadReplies.length; i += portionSizeQaaThreadReplies){
        mySublistsQaaThreadReplies.add(listOfQaaThreadReplies.sublist(i, i + portionSizeQaaThreadReplies > listOfQaaThreadReplies.length ? listOfQaaThreadReplies.length : i + portionSizeQaaThreadReplies));
      }
    }

    var myPagesQaaThreadReplies = List.generate(
      numberOfPagesQaaThreadReplies,
        (myIndex) => Column(
          children: <Widget>[
            ListView.builder(
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies].length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["theOriginalReplyInfo"]["replyContent"] != null && mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["theOriginalReplyInfo"]["replier"] != null?
                      Column(
                          children: <Widget>[
                            Container(
                              height: 10,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blueGrey[300],
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Container(
                                //child: Text("Reply to: " + theQaaThreadReplies[index]["theOriginalReplyInfo"]["replyContent"].toString() + "\n" + "Posted by: " + theQaaThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                    text: "Reply to: ${mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["theOriginalReplyInfo"]["replyContent"].toString()}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        text: "${mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          qaaClickedOnUser = true,
                                          qaaNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString().toLowerCase()).get(),
                                          qaaNameData.docs.forEach((person){
                                            theUsersData = person.data();
                                          }),
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
                                width: 320,
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
                                //child: Text("Posted on: " + theQaaThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + theQaaThreadReplies[index]["replier"].toString() + "\n" + theQaaThreadReplies[index]["replyContent"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                    text: "Posted on: ${mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["time"].toDate().toString()}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        text: "${mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          qaaClickedOnUser = true,
                                          qaaNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["replier"].toString().toLowerCase()).get(),
                                          qaaNameData.docs.forEach((person){
                                            theUsersData = person.data();
                                          }),
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                      ),
                                      TextSpan(
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        text: " ",
                                      ),
                                      TextSpan(
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        text: "\n${mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["replyContent"].toString()}",
                                      ),
                                    ],
                                  ),
                                ),
                                color: Colors.grey[300],
                                width: 320,
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
                                  width: 320,
                                ),
                                onTap: () async{
                                  replyToReplyTimeQaa = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies]![index]["time"];
                                  replyToReplyContentQaa = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies]![index]["replyContent"].toString();
                                  replyToReplyPosterQaa = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies]![index]["replier"].toString();

                                  print("This is replyToReplyTime: $replyToReplyTimeQaa");

                                  await FirebaseFirestore.instance.collection("Questions_And_Answers").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                    myDocQaa = d.docs.first.id;
                                    print(myDocQaa);
                                  });

                                  await FirebaseFirestore.instance.collection("Questions_And_Answers").doc(myDocQaa).collection("Replies").where("time", isEqualTo: replyToReplyTimeQaa).get().then((rd) {
                                    replyToReplyDocQaa = rd.docs.first.id;
                                    print(replyToReplyDocQaa);
                                  });

                                  print(theQaaThreadReplies);
                                  print(replyToReplyDocQaa);

                                  DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Questions_And_Answers").doc(myDocQaa).collection("Replies").doc(replyToReplyDocQaa).get();
                                  print(ds.data());
                                  print(ds.data().runtimeType);
                                  print(mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeQaa));

                                  myIndex = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeQaa);
                                  myReplyToReplyQaa = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][myIndex];
                                  myReplyToReplyQaaMap = Map.from(myReplyToReplyQaa);

                                  List<dynamic> tempReplyToReplyList = [replyToReplyContentQaa, replyToReplyPosterQaa, myReplyToReplyQaaMap];
                                  qaaRepliesToReplies.add(tempReplyToReplyList);

                                  print("myReplyToReplyQaaMap: ${myReplyToReplyQaaMap}");
                                  print("myReplyToReplyQaa: ${myReplyToReplyQaa["replyContent"]}");
                                  print("This is myIndex: $myIndex");

                                  questionsAndAnswersReplyBool = true;
                                  questionsAndAnswersReplyingToReplyBool = true;
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                  //print('Reply no. ' + index.toString());
                                  //print('Replying to this reply: ' + questionsAndAnswersThreads[int.parse(threadID)][4][myIndex][2].toString());
                                }
                              ),
                              onPressed: (){
                                //Does nothing
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
                                //child: Text("Posted on: " + theQaaThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + theQaaThreadReplies[index]["replier"].toString() + "\n" + theQaaThreadReplies[index]["replyContent"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                    text: "Posted on: ${mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["time"].toDate().toString()}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        text: "${mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          qaaClickedOnUser = true,
                                          qaaNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["replier"].toString().toLowerCase()).get(),
                                          qaaNameData.docs.forEach((person){
                                            theUsersData = person.data();
                                          }),
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                      ),
                                      TextSpan(
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        text: " ",
                                      ),
                                      TextSpan(
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                        text: "\n${mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["replyContent"].toString()}",
                                      ),
                                    ],
                                  ),
                                ),
                                color: Colors.grey[300],
                                width: 320,
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
                                  width: 320,
                                ),
                                onTap: () async{
                                  replyToReplyTimeQaa = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies]![index]["time"];
                                  replyToReplyContentQaa = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies]![index]["replyContent"].toString();
                                  replyToReplyPosterQaa = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies]![index]["replier"].toString();

                                  print("This is replyToReplyTime: $replyToReplyTimeQaa");

                                  await FirebaseFirestore.instance.collection("Questions_And_Answers").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                    myDocQaa = d.docs.first.id;
                                    print(myDocQaa);
                                  });

                                  await FirebaseFirestore.instance.collection("Questions_And_Answers").doc(myDocQaa).collection("Replies").where("time", isEqualTo: replyToReplyTimeQaa).get().then((rd) {
                                    replyToReplyDocQaa = rd.docs.first.id;
                                    print(replyToReplyDocQaa);
                                  });

                                  print(theQaaThreadReplies);
                                  print(replyToReplyDocQaa);

                                  DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Questions_And_Answers").doc(myDocQaa).collection("Replies").doc(replyToReplyDocQaa).get();
                                  print(ds.data());
                                  print(ds.data().runtimeType);

                                  myIndex = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeQaa);

                                  print(mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeQaa));
                                  myReplyToReplyQaa = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][myIndex];

                                  myReplyToReplyQaaMap = Map.from(myReplyToReplyQaa);

                                  List<dynamic> tempReplyToReplyList = [replyToReplyContentQaa, replyToReplyPosterQaa, myReplyToReplyQaaMap];
                                  qaaRepliesToReplies.add(tempReplyToReplyList);

                                  print("myReplyToReplyQaaMap: ${myReplyToReplyQaaMap}");

                                  print("myReplyToReplyQaa: ${myReplyToReplyQaa["replyContent"]}");
                                  print("This is myIndex: $myIndex");

                                  questionsAndAnswersReplyBool = true;
                                  questionsAndAnswersReplyingToReplyBool = true;
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => const questionsAndAnswersPage())),
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
                    padding: EdgeInsets.all(10.0),
                    //child: Text("Thread title: " + threadTitleQaa + "\n" + "Posted by: " + threadAuthorQaa + "\n" + threadContentQaa),
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                        text: "Thread title: ${threadTitleQaa}\nPosted by: ",
                        children: <TextSpan>[
                          TextSpan(
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                            text: "${threadAuthorQaa}",
                            recognizer: TapGestureRecognizer()..onTap = () async =>{
                              qaaClickedOnUser = true,
                              qaaNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: threadAuthorQaa.toLowerCase()).get(),
                              qaaNameData.docs.forEach((person){
                                theUsersData = person.data();
                              }),
                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                            }
                          ),
                          TextSpan(
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                            text: " ",
                          ),
                          TextSpan(
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                            text: "\n${threadContentQaa}",
                          ),
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
                  height: 20,
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: Text("Reply to thread", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                  ),
                ),
                onTap: (){
                  questionsAndAnswersReplyingToReplyBool = false;
                  questionsAndAnswersReplyBool = true;
                  print(reversedQuestionsAndAnswersThreadsIterable.toList());
                  print(threadID);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                  print('Replying to the thread');
                }
              ),
              onPressed: (){
                //Does nothing
              }
            ),
            Center(
              child: listOfQaaThreadReplies.length != 0? myPagesQaaThreadReplies[theCurrentPageQaaThreadReplies] : Text("There are no replies to this thread yet. Be the first to reply!"),
            ),
            NumberPaginator(
              height: 50,
              numberPages: listOfQaaThreadReplies.length != 0? numberOfPagesQaaThreadReplies : 1,
              onPageChange: (myIndexQaaThreadReplies){
                setState((){
                  theCurrentPageQaaThreadReplies = myIndexQaaThreadReplies;
                });
              }
            ),
          ],
        ),
      ),
    );
  }
}