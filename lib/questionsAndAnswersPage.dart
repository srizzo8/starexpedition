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
import 'package:starexpedition4/firebaseDesktopHelper.dart';

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

int theCurrentPageQaa = 0;

int qaaNavigationDepth = 0;

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
  //int theCurrentPageQaa = 0;

  var listOfQaaThreads = [];
  var mySublistsQaa = [];
  var portionSizeQaa = 10;

  int previousThreadsLength = -1;

  @override
  void initState(){
    super.initState();
    listOfQaaThreads = discussionBoardPage.questionsAndAnswersThreads;
    rebuildSublistsIfNecessary();
  }

  void rebuildSublistsIfNecessary(){
    int myCurrentLength = listOfQaaThreads?.length ?? 0;

    if(previousThreadsLength != myCurrentLength){
      previousThreadsLength = myCurrentLength;
      mySublistsQaa.clear();

      if(myCurrentLength == 0){
        numberOfPagesQaa = 1;
      }
      else{
        numberOfPagesQaa = (myCurrentLength / 10).ceil();

        for(int i = 0; i < myCurrentLength; i += portionSizeQaa){
          mySublistsQaa.add(listOfQaaThreads.sublist(i, i + portionSizeQaa > myCurrentLength ? myCurrentLength : i + portionSizeQaa));
        }
      }

      mySublistsQaaInformation = mySublistsQaa;
    }
  }

  Widget build(BuildContext buildContext){
    listOfQaaThreads = discussionBoardPage.questionsAndAnswersThreads;

    rebuildSublistsIfNecessary();

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
                                        text: "${mySublistsQaa[theCurrentPageQaa][index]["threadTitle"].toString()}\nBy: ",
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, height: 1.1),
                                        children: [
                                          TextSpan(
                                              text: "${mySublistsQaa[theCurrentPageQaa][index]["poster"].toString()}",
                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, height: 1.1),
                                              recognizer: TapGestureRecognizer()..onTap = () async =>{
                                                qaaClickedOnUser = true,

                                                if(firebaseDesktopHelper.onDesktop){
                                                  qaaNameData = await firebaseDesktopHelper.getFirestoreCollection("User"),
                                                  theUsersData = qaaNameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsQaa[theCurrentPageQaa][index]["poster"].toString().toLowerCase(), orElse: () => <String, dynamic>{}),
                                                }
                                                else{
                                                  qaaNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsQaa[theCurrentPageQaa][index]["poster"].toString().toLowerCase()).get(),
                                                  qaaNameData.docs.forEach((person){
                                                    theUsersData = person.data();
                                                  }),
                                                },

                                                //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                                if(theUsersData?.isEmpty ?? true){
                                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => nonexistentUser())),
                                                }
                                                else{
                                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                                }
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

                            if(firebaseDesktopHelper.onDesktop){
                              var theQaaThreads = await firebaseDesktopHelper.getFirestoreCollection("Questions_And_Answers");
                              var matchingThread = theQaaThreads.firstWhere((myDoc) => myDoc["threadId"] == int.parse(threadID), orElse: () => <String, dynamic>{});

                              if(matchingThread.isNotEmpty){
                                //Getting the document ID:
                                myDocQaa = matchingThread["docId"];
                                print("This is myDocQaa: ${myDocQaa}");
                              }
                              else{
                                print("Sorry; the thread was not found");
                              }
                            }
                            else{
                              await FirebaseFirestore.instance.collection("Questions_And_Answers").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                myDocQaa = d.docs.first.id;
                                print(myDocQaa);
                              });
                            }

                            if(firebaseDesktopHelper.onDesktop){
                              theQaaThreadReplies = await firebaseDesktopHelper.getFirestoreSubcollection("Questions_And_Answers", myDocQaa, "Replies");

                              print(theQaaThreadReplies.runtimeType);

                              print(DateTime.now().runtimeType);

                              theQaaThreadReplies.sort((b, a){
                                DateTime dta = firebaseDesktopHelper.convertStringToDateTime(a["time"]);
                                DateTime dtb = firebaseDesktopHelper.convertStringToDateTime(b["time"]);
                                return dta.compareTo(dtb);
                              });
                            }
                            else{
                              await FirebaseFirestore.instance.collection("Questions_And_Answers").doc(myDocQaa).collection("Replies");

                              QuerySnapshot qaaRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Questions_And_Answers").doc(myDocQaa).collection("Replies").get();
                              theQaaThreadReplies = qaaRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                              print(theQaaThreadReplies.runtimeType);

                              print(DateTime.now().runtimeType);

                              (theQaaThreadReplies as List<dynamic>).sort((b2, a2) => (DateTime.parse(a2["time"])).compareTo(DateTime.parse(b2["time"])));
                            }

                            print("Number of theQaaThreadReplies: ${theQaaThreadReplies.length}");

                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => questionsAndAnswersThreadsPage()));
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
              theCurrentPageQaa = 0,
            }
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            child: Text("Questions and Answers Subforum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
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
                  print(questionsAndAnswersBool);
                  questionsAndAnswersBool = true;
                  print(questionsAndAnswersBool);
                  qaaNavigationDepth++;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                  print("I am going to write a new thread.");
                }
            ),
          ),
          Expanded(
            child: listOfQaaThreads.length != 0? myPagesQaa[theCurrentPageQaa] : Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.031250, 0.0, MediaQuery.of(context).size.width * 0.031250, 0.0), child: Text("There are no threads in this subforum yet. Be the first to post a thread!", textAlign: TextAlign.center),),//myPagesQaa[theCurrentPageQaa],
          ),
          NumberPaginator(
              height: MediaQuery.of(context).size.height * 0.0782125,
              numberPages: listOfQaaThreads.length != 0? numberOfPagesQaa : 1,
              onPageChange: (myIndexQaa){
                setState((){
                  theCurrentPageQaa = myIndexQaa;
                  print("This is theCurrentPageQaa: ${theCurrentPageQaa}");
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

  var listOfQaaThreadReplies;
  var mySublistsQaaThreadReplies = [];
  int portionSizeQaaThreadReplies = 10;

  int myPaginatorResetValue = 0;
  int previousDataLength = -1;

  @override
  Widget build(BuildContext context){
    listOfQaaThreadReplies = theQaaThreadReplies;

    int currentDataLength = listOfQaaThreadReplies?.length ?? 0;

    if(previousDataLength != currentDataLength){
      previousDataLength = currentDataLength;
      //Clearing outdated sublists:
      mySublistsQaaThreadReplies.clear();

      if(currentDataLength == 0){
        numberOfPagesQaaThreadReplies = 1;
      }
      else{
        numberOfPagesQaaThreadReplies = (((theQaaThreadReplies.length)/10)).ceil();

        for(int i = 0; i < listOfQaaThreadReplies.length; i += portionSizeQaaThreadReplies){
          mySublistsQaaThreadReplies.add(listOfQaaThreadReplies.sublist(i, i + portionSizeQaaThreadReplies > listOfQaaThreadReplies.length ? listOfQaaThreadReplies.length : i + portionSizeQaaThreadReplies));
        }
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
              itemCount: (mySublistsQaaThreadReplies.isNotEmpty && theCurrentPageQaaThreadReplies < mySublistsQaaThreadReplies.length) ? mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies].length : 0,//mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies].length,
              itemBuilder: (context, index){
                return Column(
                  children: <Widget>[
                    mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["theOriginalReplyInfo"]["replyContent"] != null && mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["theOriginalReplyInfo"]["replier"] != null?
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

                                            if(firebaseDesktopHelper.onDesktop){
                                              qaaNameData = await firebaseDesktopHelper.getFirestoreCollection("User"),
                                              theUsersData = qaaNameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString().toLowerCase(), orElse: () => <String, dynamic>{}),
                                            }
                                            else{
                                              qaaNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString().toLowerCase()).get(),
                                              qaaNameData.docs.forEach((person){
                                                theUsersData = person.data();
                                              }),
                                            },
                                            //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                            if(theUsersData?.isEmpty ?? true){
                                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => nonexistentUser())),
                                            }
                                            else{
                                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                            }
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
                                //child: Text("Posted on: " + theQaaThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + theQaaThreadReplies[index]["replier"].toString() + "\n" + theQaaThreadReplies[index]["replyContent"].toString()),
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                    text: "Posted on: ${firebaseDesktopHelper.formatMyTimestamp(mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["time"].toString())}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                          text: "${mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["replier"].toString()}",
                                          recognizer: TapGestureRecognizer()..onTap = () async =>{
                                            qaaClickedOnUser = true,

                                            if(firebaseDesktopHelper.onDesktop){
                                              qaaNameData = await firebaseDesktopHelper.getFirestoreCollection("User"),
                                              theUsersData = qaaNameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["replier"].toString().toLowerCase(), orElse: () => <String, dynamic>{}),
                                            }
                                            else{
                                              qaaNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["replier"].toString().toLowerCase()).get(),
                                              qaaNameData.docs.forEach((person){
                                                theUsersData = person.data();
                                              }),
                                            },
                                            //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                            if(theUsersData?.isEmpty ?? true){
                                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => nonexistentUser())),
                                            }
                                            else{
                                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                            }
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
                                    replyToReplyTimeQaa = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies]![index]["time"];
                                    replyToReplyContentQaa = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies]![index]["replyContent"].toString();
                                    replyToReplyPosterQaa = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies]![index]["replier"].toString();

                                    print("This is replyToReplyTime: $replyToReplyTimeQaa");

                                    if(firebaseDesktopHelper.onDesktop){
                                      var theDocQaa = await firebaseDesktopHelper.getFirestoreCollection("Questions_And_Answers");
                                      print("Hello. This is theDocQaa: $theDocQaa");
                                      myDocQaa = theDocQaa.firstWhere((myThreadId) => myThreadId["threadId"] == int.parse(threadID), orElse: () => <String, dynamic>{})["docId"];
                                      print("Hello. This is myDocQaa: $myDocQaa");
                                      print("Hello. This is the runtime type of myDocQaa: ${myDocQaa.runtimeType}");

                                      var tempReplyToReplyVar = await firebaseDesktopHelper.getFirestoreSubcollection("Questions_And_Answers", myDocQaa, "Replies");
                                      print("Hello. This is tempReplyToReplyVar: ${tempReplyToReplyVar}");
                                      print("Hello. This is the replyToReplyTimeQaa variable: ${replyToReplyTimeQaa}");
                                      replyToReplyDocQaa = tempReplyToReplyVar.firstWhere((myTime) => firebaseDesktopHelper.formatMyTimestamp(myTime["time"]) == replyToReplyTimeQaa.toString(), orElse: () => <String, dynamic>{});
                                      print("Hello. This is replyToReplyDocQaa: ${replyToReplyDocQaa}");
                                    }
                                    else{
                                      await FirebaseFirestore.instance.collection("Questions_And_Answers").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                        myDocQaa = d.docs.first.id;
                                        print(myDocQaa);
                                      });

                                      await FirebaseFirestore.instance.collection("Questions_And_Answers").doc(myDocQaa).collection("Replies").where("time", isEqualTo: replyToReplyTimeQaa).get().then((rd) {
                                        replyToReplyDocQaa = rd.docs.first.id;
                                        print(replyToReplyDocQaa);
                                      });
                                    }

                                    print(theQaaThreadReplies);
                                    print(replyToReplyDocQaa);

                                    if(firebaseDesktopHelper.onDesktop){
                                      print("The doc: $myDocQaa");
                                      print("The subdoc: $replyToReplyDocQaa");

                                      try{
                                        Map<String, dynamic>? dsData = await firebaseDesktopHelper.getFirestoreSubcollectionDocument("Questions_And_Answers", myDocQaa, "Replies", replyToReplyDocQaa);

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
                                      DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Questions_And_Answers").doc(myDocQaa).collection("Replies").doc(replyToReplyDocQaa).get();
                                      print(ds.data());
                                      print(ds.data().runtimeType);
                                    }
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
                                    qaaNavigationDepth++;

                                    final myResult = await Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));

                                    //Refreshing the page after returning from a reply:
                                    if(myResult == true){
                                      setState((){
                                        theCurrentPageQaaThreadReplies = 0;
                                        myPaginatorResetValue++;
                                      });
                                    }
                                    //Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
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
                            height: MediaQuery.of(context).size.height * 0.015625,
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
                                    text: "Posted on: ${firebaseDesktopHelper.formatMyTimestamp(mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["time"].toString())}\nPosted by: ",
                                    children: <TextSpan>[
                                      TextSpan(
                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                          text: "${mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["replier"].toString()}",
                                          recognizer: TapGestureRecognizer()..onTap = () async =>{
                                            qaaClickedOnUser = true,

                                            if(firebaseDesktopHelper.onDesktop){
                                              qaaNameData = await firebaseDesktopHelper.getFirestoreCollection("User"),
                                              theUsersData = qaaNameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["replier"].toString().toLowerCase(), orElse: () => <String, dynamic>{}),
                                              print("theUsersData is this on Desktop: ${theUsersData}"),
                                            }
                                            else{
                                              qaaNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies][index]["replier"].toString().toLowerCase()).get(),
                                              qaaNameData.docs.forEach((person){
                                                theUsersData = person.data();
                                              }),
                                            },
                                            //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                            if(theUsersData?.isEmpty ?? true){
                                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => nonexistentUser())),
                                            }
                                            else{
                                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                            }
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
                                    replyToReplyTimeQaa = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies]![index]["time"];
                                    replyToReplyContentQaa = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies]![index]["replyContent"].toString();
                                    replyToReplyPosterQaa = mySublistsQaaThreadReplies[theCurrentPageQaaThreadReplies]![index]["replier"].toString();

                                    print("This is replyToReplyTime: $replyToReplyTimeQaa");

                                    if(firebaseDesktopHelper.onDesktop){
                                      var theQaaThreads = await firebaseDesktopHelper.getFirestoreCollection("Questions_And_Answers");
                                      var matchingThread = theQaaThreads.firstWhere((myDoc) => myDoc["threadId"] == int.parse(threadID), orElse: () => <String, dynamic>{});

                                      if(matchingThread.isNotEmpty){
                                        //Getting the document ID:
                                        myDocQaa = matchingThread["docId"];
                                        print("This is myDocQaa: ${myDocQaa}");
                                      }
                                      else{
                                        print("Sorry; the thread was not found");
                                      }

                                      var theQaaThreadsReplies = await firebaseDesktopHelper.getFirestoreSubcollection("Questions_And_Answers", myDocQaa, "Replies");
                                      var matchingReply = theQaaThreadsReplies.firstWhere((myDoc) => myDoc["time"] == replyToReplyTimeQaa, orElse: () => <String, dynamic>{});

                                      if(matchingReply.isNotEmpty){
                                        //Getting the document ID:
                                        replyToReplyDocQaa = matchingReply["docId"];
                                        print("This is replyToReplyDocQaa: ${replyToReplyDocQaa}");
                                      }
                                      else{
                                        print("Sorry; the thread was not found");
                                      }
                                    }
                                    else{
                                      await FirebaseFirestore.instance.collection("Questions_And_Answers").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                        myDocQaa = d.docs.first.id;
                                        print(myDocQaa);
                                      });

                                      await FirebaseFirestore.instance.collection("Questions_And_Answers").doc(myDocQaa).collection("Replies").where("time", isEqualTo: replyToReplyTimeQaa).get().then((rd) {
                                        replyToReplyDocQaa = rd.docs.first.id;
                                        print(replyToReplyDocQaa);
                                      });
                                    }

                                    print(theQaaThreadReplies);
                                    print(replyToReplyDocQaa);

                                    if(firebaseDesktopHelper.onDesktop){
                                      print("The doc: $myDocQaa");
                                      print("The subdoc: $replyToReplyDocQaa");

                                      try{
                                        Map<String, dynamic>? dsData = await firebaseDesktopHelper.getFirestoreSubcollectionDocument("Questions_And_Answers", myDocQaa, "Replies", replyToReplyDocQaa);

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
                                      DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Questions_And_Answers").doc(myDocQaa).collection("Replies").doc(replyToReplyDocQaa).get();
                                      print(ds.data());
                                      print(ds.data().runtimeType);
                                    }

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
                                    qaaNavigationDepth++;

                                    final myResult = await Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));

                                    //Refreshing the page after returning from a reply:
                                    if(myResult == true){
                                      setState((){
                                        theCurrentPageQaaThreadReplies = 0;
                                        myPaginatorResetValue++;
                                      });
                                    }

                                    //Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
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
              //Navigator.push(context, MaterialPageRoute(builder: (context) => const questionsAndAnswersPage())),
              print("We're going backwards. This is the depth: ${qaaNavigationDepth}"),

              if(Navigator.canPop(context)){
                Navigator.pop(context),
              },

              qaaNavigationDepth = 0,
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

                                  if(firebaseDesktopHelper.onDesktop){
                                    qaaNameData = await firebaseDesktopHelper.getFirestoreCollection("User"),
                                    theUsersData = qaaNameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == threadAuthorQaa.toLowerCase(), orElse: () => <String, dynamic>{}),
                                  }
                                  else{
                                    qaaNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: threadAuthorQaa.toLowerCase()).get(),
                                    qaaNameData.docs.forEach((person){
                                      theUsersData = person.data();
                                    }),
                                  },
                                  //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                  if(theUsersData?.isEmpty ?? true){
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => nonexistentUser())),
                                  }
                                  else{
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                  }
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
                      height: MediaQuery.of(context).size.height * 0.02734375,
                      child: Container(
                        alignment: Alignment.topCenter,
                        child: Text("Reply to thread", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                      ),
                    ),
                    onTap: () async {
                      questionsAndAnswersReplyingToReplyBool = false;
                      questionsAndAnswersReplyBool = true;
                      qaaNavigationDepth++;
                      print(reversedQuestionsAndAnswersThreadsIterable.toList());
                      print(threadID);

                      final myResult = await Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));

                      //Refreshing the page after returning from a reply:
                      if(myResult == true){
                        setState((){
                          theCurrentPageQaaThreadReplies = 0;
                          myPaginatorResetValue++;
                        });
                      }
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                      print('Replying to the thread');
                    }
                ),
                onPressed: (){
                  //Does nothing
                }
            ),
            Center(
              child: (myPagesQaaThreadReplies.isNotEmpty && theCurrentPageQaaThreadReplies < myPagesQaaThreadReplies.length)? myPagesQaaThreadReplies[theCurrentPageQaaThreadReplies] : Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.031250, MediaQuery.of(context).size.height * 0.062500, MediaQuery.of(context).size.width * 0.031250, 0.0), child: Text("There are no replies to this thread yet. Be the first to reply!", textAlign: TextAlign.center),),
            ),
            NumberPaginator(
              key: ValueKey(myPaginatorResetValue),
              height: MediaQuery.of(context).size.height * 0.0782125,
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