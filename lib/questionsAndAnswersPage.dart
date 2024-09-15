import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
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

class questionsAndAnswersPage extends StatefulWidget{
  const questionsAndAnswersPage ({Key? key}) : super(key: key);

  @override
  questionsAndAnswersPageState createState() => questionsAndAnswersPageState();
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
            child: Text("Questions and Answers Subforum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
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
                  print(questionsAndAnswersBool);
                  questionsAndAnswersBool = true;
                  print(questionsAndAnswersBool);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                  print("I am going to write a new thread.");
                }
              ),
          ),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: discussionBoardPage.questionsAndAnswersThreads.length,//questionsAndAnswersThreads.reversed.toList().length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      Container(
                        height: 10,
                      ),
                      InkWell(
                          child: Ink(
                            //child: Text(discussionBoardPage.questionsAndAnswersThreads[index]["threadTitle"].toString() + "\n" + "By: " + discussionBoardPage.questionsAndAnswersThreads[index]["poster"].toString()),//Text(reversedQuestionsAndAnswersThreadsIterable.toList()[index][1] + "\n" + "By: " + reversedQuestionsAndAnswersThreadsIterable.toList()[index][0]),
                            child: Text.rich(
                              TextSpan(
                                text: "${discussionBoardPage.questionsAndAnswersThreads[index]["threadTitle"].toString()}\nBy: ",
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "${discussionBoardPage.questionsAndAnswersThreads[index]["poster"].toString()}",
                                    recognizer: TapGestureRecognizer()..onTap = () async =>{
                                      qaaClickedOnUser = true,
                                      qaaNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: discussionBoardPage.questionsAndAnswersThreads[index]["poster"].toString().toLowerCase()).get(),
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
                          onTap: () async {
                            print("This is index: $index");
                            print("discussionBoardPage.questionsAndAnswersThreads is null? ${discussionBoardPage.questionsAndAnswersThreads == null}");
                            print("I clicked on a thread");
                            threadAuthorQaa = discussionBoardPage.questionsAndAnswersThreads![index]["poster"].toString();
                            threadTitleQaa = discussionBoardPage.questionsAndAnswersThreads![index]["threadTitle"].toString();
                            threadContentQaa = discussionBoardPage.questionsAndAnswersThreads![index]["threadContent"].toString();
                            threadID = discussionBoardPage.questionsAndAnswersThreads![index]["threadId"].toString();

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

                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => questionsAndAnswersThreadContent()));
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

class questionsAndAnswersThreadContent extends StatelessWidget{
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
            Navigator.pop(context),
          }
        ),
      ),
      body: SingleChildScrollView(
        child: Wrap(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              //child: Text("Thread title: " + threadTitleQaa + "\n" + "Posted by: " + threadAuthorQaa + "\n" + threadContentQaa),
              child: Text.rich(
                TextSpan(
                  text: "Thread title: ${threadTitleQaa}\nPosted by: ",
                  children: <TextSpan>[
                    TextSpan(
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
                      text: " ",
                    ),
                    TextSpan(
                      text: "\n${threadContentQaa}",
                    ),
                  ],
                ),
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
                questionsAndAnswersReplyingToReplyBool = false;
                questionsAndAnswersReplyBool = true;
                print(reversedQuestionsAndAnswersThreadsIterable.toList());
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
                  itemCount: theQaaThreadReplies.length,
                  itemBuilder: (context, index){
                    return Column(
                      children: <Widget>[
                        theQaaThreadReplies[index]["theOriginalReplyInfo"]["replyContent"] != null && theQaaThreadReplies[index]["theOriginalReplyInfo"]["replier"] != null?
                        Column(
                            children: <Widget>[
                              Container(
                                height: 5,
                              ),
                              Container(
                                //child: Text("Reply to: " + theQaaThreadReplies[index]["theOriginalReplyInfo"]["replyContent"].toString() + "\n" + "Posted by: " + theQaaThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    text: "Reply to: ${theQaaThreadReplies[index]["theOriginalReplyInfo"]["replyContent"].toString()}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "${theQaaThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          qaaClickedOnUser = true,
                                          qaaNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theQaaThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString().toLowerCase()).get(),
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
                                color: Colors.blueGrey[300],
                                width: 360,
                              ),
                              Container(
                                //child: Text("Posted on: " + theQaaThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + theQaaThreadReplies[index]["replier"].toString() + "\n" + theQaaThreadReplies[index]["replyContent"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    text: "Posted on: ${theQaaThreadReplies[index]["time"].toDate().toString()}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "${theQaaThreadReplies[index]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          qaaClickedOnUser = true,
                                          qaaNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theQaaThreadReplies[index]["replier"].toString().toLowerCase()).get(),
                                          qaaNameData.docs.forEach((person){
                                            theUsersData = person.data();
                                          }),
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                      ),
                                      TextSpan(
                                        text: " ",
                                      ),
                                      TextSpan(
                                        text: "\n${theQaaThreadReplies[index]["replyContent"].toString()}",
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
                                    replyToReplyTimeQaa = theQaaThreadReplies![index]["time"];
                                    replyToReplyContentQaa = theQaaThreadReplies![index]["replyContent"].toString();
                                    replyToReplyPosterQaa = theQaaThreadReplies![index]["replier"].toString();

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
                                    print(theQaaThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeQaa));

                                    myIndex = theQaaThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeQaa);
                                    myReplyToReplyQaa = theQaaThreadReplies[myIndex];
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
                            ]
                        ): Column(
                            children: <Widget>[
                              Container(
                                height: 5,
                              ),
                              Container(
                                //child: Text("Posted on: " + theQaaThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + theQaaThreadReplies[index]["replier"].toString() + "\n" + theQaaThreadReplies[index]["replyContent"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    text: "Posted on: ${theQaaThreadReplies[index]["time"].toDate().toString()}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "${theQaaThreadReplies[index]["replier"].toString()}",
                                        recognizer: TapGestureRecognizer()..onTap = () async =>{
                                          qaaClickedOnUser = true,
                                          qaaNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theQaaThreadReplies[index]["replier"].toString().toLowerCase()).get(),
                                          qaaNameData.docs.forEach((person){
                                            theUsersData = person.data();
                                          }),
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                        }
                                      ),
                                      TextSpan(
                                        text: " ",
                                      ),
                                      TextSpan(
                                        text: "\n${theQaaThreadReplies[index]["replyContent"].toString()}",
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
                                    replyToReplyTimeQaa = theQaaThreadReplies![index]["time"];
                                    replyToReplyContentQaa = theQaaThreadReplies![index]["replyContent"].toString();
                                    replyToReplyPosterQaa = theQaaThreadReplies![index]["replier"].toString();

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

                                    myIndex = theQaaThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeQaa);

                                    print(theQaaThreadReplies.indexWhere((i) => i["time"] == replyToReplyTimeQaa));
                                    myReplyToReplyQaa = theQaaThreadReplies[myIndex];

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