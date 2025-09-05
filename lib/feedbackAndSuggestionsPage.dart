import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:starexpedition4/replyThreadPage.dart';
import 'package:starexpedition4/userProfile.dart';
import 'package:starexpedition4/userSearchBar.dart';

import 'createThread.dart';
import 'discussionBoardPage.dart' as discussionBoardPage;
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesRepliesDatabaseFirestoreInfo.dart';
import 'replyThreadPage.dart';
import 'main.dart' as myMain;

bool fasBool = false;
bool fasReplyBool = false;
bool fasReplyingToReplyBool = false;
var fasThreads = [];
var fasReplies = [];
int myIndex = -1;

var reversedFasThreadsIterable = fasThreads.reversed;
var reversedFasRepliesIterable = fasReplies.reversed;
String threadAuthorFas = "";
String threadTitleFas = "";
String threadContentFas = "";

String threadID = "";
int fasThreadId = -1;
var theFasThreadReplies;
var myDocFas;
var replyToReplyDocFas;
var replyToReplyTimeFas;
var replyToReplyContentFas;
var replyToReplyPosterFas;
var myReplyToReplyFas;
var replyToReplyOriginalInfoFas;
List<List> fasRepliesToReplies = [];
Map<String, dynamic> myReplyToReplyFasMap = {};

var fasNameData;
bool fasClickedOnUser = false;

var mySublistsFasInformation;
var myIndexPlaceFas;
var myLocation;

class feedbackAndSuggestionsPage extends StatefulWidget{
  const feedbackAndSuggestionsPage ({Key? key}) : super(key: key);

  @override
  feedbackAndSuggestionsPageState createState() => feedbackAndSuggestionsPageState();
}

class feedbackAndSuggestionsThreadsPage extends StatefulWidget{
  const feedbackAndSuggestionsThreadsPage ({Key? key}) : super(key: key);

  @override
  feedbackAndSuggestionsThreadContent createState() => feedbackAndSuggestionsThreadContent();
}

class MyFeedbackAndSuggestionsPage extends StatelessWidget{
  const MyFeedbackAndSuggestionsPage ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext bcfas){
    return MaterialApp(
      title: 'Feedback And Suggestions Page',
      routes: {
        routeToCreateThread.createThreadPage: (context) => createThread(),
        routeToReplyToThreadFas.replyThreadPage: (context) => replyThreadPage(),
      }
    );
  }
}

class routeToCreateThread{
  static String createThreadPage = createThreadState.threadCreator;
}

class routeToReplyToThreadFas{
  static String replyThreadPage = replyThreadPageState.replyThread;
}

class feedbackAndSuggestionsPageState extends State<feedbackAndSuggestionsPage>{
  static String fasRoute = '/feedbackAndSuggestionsPage';
  int numberOfPagesFas = (((discussionBoardPage.feedbackAndSuggestionsThreads.length)/10)).ceil();
  int theCurrentPageFas = 0;

  var listOfFasThreads = discussionBoardPage.feedbackAndSuggestionsThreads;
  var mySublistsFas = [];
  var portionSizeFas = 10;

  Widget build(BuildContext buildContext){
    for(int i = 0; i < listOfFasThreads.length; i += portionSizeFas){
      mySublistsFas.add(listOfFasThreads.sublist(i, i + portionSizeFas > listOfFasThreads.length ? listOfFasThreads.length : i + portionSizeFas));
    }

    mySublistsFasInformation = mySublistsFas;

    var myPagesFas = List.generate(
      numberOfPagesFas,
          (index) => Center(
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: mySublistsFas[theCurrentPageFas].length,
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
                          child: Text.rich(
                            TextSpan(
                              text: "${mySublistsFas[theCurrentPageFas][index]["threadTitle"].toString()}\nBy: ",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                              children: <TextSpan>[
                                TextSpan(
                                    text: "${mySublistsFas[theCurrentPageFas][index]["poster"].toString()}",
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                    recognizer: TapGestureRecognizer()..onTap = () async =>{
                                      fasClickedOnUser = true,
                                      fasNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsFas[theCurrentPageFas][index]["poster"].toString().toLowerCase()).get(),
                                      fasNameData.docs.forEach((person){
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
                          width: 320,
                          color: Colors.grey[300],
                        ),
                      ),
                      onPressed: () async{
                        print("This is index: $index");
                        print("listOfFasThreads is null? ${listOfFasThreads == null}");
                        print("I clicked on a thread");

                        myIndexPlaceFas = index;
                        myLocation = theCurrentPageFas;

                        threadAuthorFas = mySublistsFas[theCurrentPageFas][index]["poster"].toString();
                        threadTitleFas = mySublistsFas[theCurrentPageFas][index]["threadTitle"].toString();
                        threadContentFas = mySublistsFas[theCurrentPageFas][index]["threadContent"].toString();
                        threadID = mySublistsFas[theCurrentPageFas][index]["threadId"].toString();

                        print(discussionBoardPage.feedbackAndSuggestionsThreads![index]);
                        print("${threadAuthorFas} + ${threadTitleFas} + ${threadContentFas} + ${threadID}");
                        print("context: ${context}");
                        await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                          myDocFas = d.docs.first.id;
                          print(myDocFas);
                        });

                        await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").doc(myDocFas).collection("Replies");

                        QuerySnapshot fasRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").doc(myDocFas).collection("Replies").get();
                        theFasThreadReplies = fasRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                        print(theFasThreadReplies.runtimeType);

                        print(DateTime.now().runtimeType);

                        (theFasThreadReplies as List<dynamic>).sort((b2, a2) => (a2["time"].toDate()).compareTo(b2["time"].toDate()));

                        print("Number of theFasThreadReplies: ${theFasThreadReplies.length}");

                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => feedbackAndSuggestionsThreadsPage()));
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
            height: 5,
          ),
          Container(
            child: Text("Feedback and Suggestions Subforum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          //InkWell(
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
                  padding: EdgeInsets.all(10.0),
                  height: 40,
                  width: 150,
                  child: Center(
                    child: Text("Post New Thread", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white), textAlign: TextAlign.center),
                  ),
                ),
              ),
              onPressed: (){
                print(fasBool);
                fasBool = true;
                print(fasBool);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                print("I am going to write a new thread.");
              }
            ),
          ),
          Expanded(
            child: listOfFasThreads.length != 0? myPagesFas[theCurrentPageFas] : Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0), child: Text("There are no threads in this subforum yet. Be the first to post a thread!", textAlign: TextAlign.center),),
          ),
          NumberPaginator(
            height: 50,
            numberPages: listOfFasThreads.length != 0? numberOfPagesFas : 1,
            onPageChange: (myIndexFas){
              setState((){
                theCurrentPageFas = myIndexFas;
              });
            }
          ),
        ],
      ),
    );
  }
}

class feedbackAndSuggestionsThreadContent extends State<feedbackAndSuggestionsThreadsPage>{
  int numberOfPagesFasThreadReplies = 0;
  int theCurrentPageFasThreadReplies = 0;

  var listOfFasThreadReplies = theFasThreadReplies;
  var mySublistsFasThreadReplies = [];
  int portionSizeFasThreadReplies = 10;

  @override
  Widget build(BuildContext context){
    if(listOfFasThreadReplies == []){
      numberOfPagesFasThreadReplies = 1;
    }
    else{
      numberOfPagesFasThreadReplies = (((theFasThreadReplies.length)/10)).ceil();

      for(int i = 0; i < listOfFasThreadReplies.length; i += portionSizeFasThreadReplies){
        mySublistsFasThreadReplies.add(listOfFasThreadReplies.sublist(i, i + portionSizeFasThreadReplies > listOfFasThreadReplies.length ? listOfFasThreadReplies.length : i + portionSizeFasThreadReplies));
      }
    }

    var myPagesFasThreadReplies = List.generate(
      numberOfPagesFasThreadReplies,
          (myIndex) => Column(
        children: <Widget>[
          ListView.builder(
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: mySublistsFasThreadReplies[theCurrentPageFasThreadReplies].length,
              itemBuilder: (context, index){
                return Column(
                  children: <Widget>[
                    mySublistsFasThreadReplies[theCurrentPageFasThreadReplies][index]["theOriginalReplyInfo"]["replyContent"] != null && mySublistsFasThreadReplies[theCurrentPageFasThreadReplies][index]["theOriginalReplyInfo"]["replier"] != null?
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
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                  text: "Reply to: ${mySublistsFasThreadReplies[theCurrentPageFasThreadReplies][index]["theOriginalReplyInfo"]["replyContent"].toString()}\nPosted by: ",
                                  children: <TextSpan>[
                                    TextSpan(
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                      text: "${mySublistsFasThreadReplies[theCurrentPageFasThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString()}",
                                      recognizer: TapGestureRecognizer()..onTap = () async =>{
                                        fasClickedOnUser = true,
                                        fasNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsFasThreadReplies[theCurrentPageFasThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString().toLowerCase()).get(),
                                        fasNameData.docs.forEach((person){
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
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                  text: "Posted on: ${mySublistsFasThreadReplies[theCurrentPageFasThreadReplies][index]["time"].toDate().toString()}\nPosted by: ",
                                  children: <TextSpan>[
                                    TextSpan(
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                      text: "${mySublistsFasThreadReplies[theCurrentPageFasThreadReplies][index]["replier"].toString()}",
                                      recognizer: TapGestureRecognizer()..onTap = () async =>{
                                        fasClickedOnUser = true,
                                        fasNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsFasThreadReplies[theCurrentPageFasThreadReplies][index]["replier"].toString().toLowerCase()).get(),
                                        fasNameData.docs.forEach((person){
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
                                      text: "\n${mySublistsFasThreadReplies[theCurrentPageFasThreadReplies][index]["replyContent"].toString()}",
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
                                replyToReplyTimeFas = mySublistsFasThreadReplies[theCurrentPageFasThreadReplies]![index]["time"];
                                replyToReplyContentFas = mySublistsFasThreadReplies[theCurrentPageFasThreadReplies]![index]["replyContent"].toString();
                                replyToReplyPosterFas = mySublistsFasThreadReplies[theCurrentPageFasThreadReplies]![index]["replier"].toString();

                                print("This is replyToReplyTime: $replyToReplyTimeFas");

                                await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                  myDocFas = d.docs.first.id;
                                  print(myDocFas);
                                });

                                await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").doc(myDocFas).collection("Replies").where("time", isEqualTo: replyToReplyTimeFas).get().then((rd) {
                                  replyToReplyDocFas = rd.docs.first.id;
                                  print(replyToReplyDocFas);
                                });

                                print(theFasThreadReplies);
                                print(replyToReplyDocFas);

                                DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").doc(myDocFas).collection("Replies").doc(replyToReplyDocFas).get();
                                print(ds.data());
                                print(ds.data().runtimeType);
                                print(mySublistsFasThreadReplies[theCurrentPageFasThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeFas));

                                myIndex = mySublistsFasThreadReplies[theCurrentPageFasThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeFas);
                                myReplyToReplyFas = mySublistsFasThreadReplies[theCurrentPageFasThreadReplies][myIndex];
                                myReplyToReplyFasMap = Map.from(myReplyToReplyFas);

                                List<dynamic> tempReplyToReplyList = [replyToReplyContentFas, replyToReplyPosterFas, myReplyToReplyFasMap];
                                fasRepliesToReplies.add(tempReplyToReplyList);

                                print("myReplyToReplyFasMap: ${myReplyToReplyFasMap}");
                                print("myReplyToReplyFas: ${myReplyToReplyFas["replyContent"]}");
                                print("This is myIndex: $myIndex");

                                fasReplyBool = true;
                                fasReplyingToReplyBool = true;
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
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
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                  text: "Posted on: ${mySublistsFasThreadReplies[theCurrentPageFasThreadReplies][index]["time"].toDate().toString()}\nPosted by: ",
                                  children: <TextSpan>[
                                    TextSpan(
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                      text: "${mySublistsFasThreadReplies[theCurrentPageFasThreadReplies][index]["replier"].toString()}",
                                      recognizer: TapGestureRecognizer()..onTap = () async =>{
                                        fasClickedOnUser = true,
                                        fasNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsFasThreadReplies[theCurrentPageFasThreadReplies][index]["replier"].toString().toLowerCase()).get(),
                                        fasNameData.docs.forEach((person){
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
                                      text: "\n${mySublistsFasThreadReplies[theCurrentPageFasThreadReplies][index]["replyContent"].toString()}",
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
                                replyToReplyTimeFas = mySublistsFasThreadReplies[theCurrentPageFasThreadReplies]![index]["time"];
                                replyToReplyContentFas = mySublistsFasThreadReplies[theCurrentPageFasThreadReplies]![index]["replyContent"].toString();
                                replyToReplyPosterFas = mySublistsFasThreadReplies[theCurrentPageFasThreadReplies]![index]["replier"].toString();

                                print("This is replyToReplyTime: $replyToReplyTimeFas");

                                await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                  myDocFas = d.docs.first.id;
                                  print(myDocFas);
                                });

                                await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").doc(myDocFas).collection("Replies").where("time", isEqualTo: replyToReplyTimeFas).get().then((rd) {
                                  replyToReplyDocFas = rd.docs.first.id;
                                  print(replyToReplyDocFas);
                                });

                                print(theFasThreadReplies);
                                print(replyToReplyDocFas);

                                DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").doc(myDocFas).collection("Replies").doc(replyToReplyDocFas).get();
                                print(ds.data());
                                print(ds.data().runtimeType);

                                myIndex = mySublistsFasThreadReplies[theCurrentPageFasThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeFas);

                                print(mySublistsFasThreadReplies[theCurrentPageFasThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeFas));
                                myReplyToReplyFas = mySublistsFasThreadReplies[theCurrentPageFasThreadReplies][myIndex];

                                myReplyToReplyFasMap = Map.from(myReplyToReplyFas);

                                List<dynamic> tempReplyToReplyList = [replyToReplyContentFas, replyToReplyPosterFas, myReplyToReplyFasMap];
                                fasRepliesToReplies.add(tempReplyToReplyList);

                                print("myReplyToReplyFasMap: ${myReplyToReplyFasMap}");

                                print("myReplyToReplyFas: ${myReplyToReplyFas["replyContent"]}");
                                print("This is myIndex: $myIndex");

                                fasReplyBool = true;
                                fasReplyingToReplyBool = true;
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const feedbackAndSuggestionsPage())),
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
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                        text: "Thread title: ${threadTitleFas}\nPosted by: ",
                        children: <TextSpan>[
                          TextSpan(
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                            text: "${threadAuthorFas}",
                            recognizer: TapGestureRecognizer()..onTap = () async =>{
                              fasClickedOnUser = true,
                              fasNameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: threadAuthorFas.toLowerCase()).get(),
                              fasNameData.docs.forEach((person){
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
                            text: "\n${threadContentFas}",
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
                  height: 20,
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: Text("Reply to thread", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                  ),
                ),
                onTap: (){
                  fasReplyingToReplyBool = false;
                  fasReplyBool = true;
                  print(reversedFasThreadsIterable.toList());
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
              child: listOfFasThreadReplies.length != 0? myPagesFasThreadReplies[theCurrentPageFasThreadReplies] : Padding(padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0), child: Text("There are no replies to this thread yet. Be the first to reply!"),),
            ),
            NumberPaginator(
                height: 50,
                numberPages: listOfFasThreadReplies.length != 0? numberOfPagesFasThreadReplies : 1,
                onPageChange: (myIndexFasThreadReplies){
                  setState((){
                    theCurrentPageFasThreadReplies = myIndexFasThreadReplies;
                  });
                }
            ),
          ],
        ),
      ),
    );
  }
}