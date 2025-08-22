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
var myDocDbu;
var replyToReplyDocDbu;
var replyToReplyTimeDbu;
var replyToReplyContentDbu;
var replyToReplyPosterDbu;
var myReplyToReplyDbu;
var replyToReplyOriginalInfoDbu;
List<List> dbuRepliesToReplies = [];
Map<String, dynamic> myReplyToReplyDbuMap = {};

var nameData;
bool dbuClickedOnUser = false;

var mySublistsDbuInformation;
var myIndexPlaceDbu;
var myLocation;

class discussionBoardUpdatesPage extends StatefulWidget{
  const discussionBoardUpdatesPage ({Key? key}) : super(key: key);

  @override
  discussionBoardUpdatesPageState createState() => discussionBoardUpdatesPageState();
}

class discussionBoardUpdatesThreadsPage extends StatefulWidget{
  const discussionBoardUpdatesThreadsPage({Key? key}) : super(key: key);

  @override
  discussionBoardUpdatesThreadContent createState() => discussionBoardUpdatesThreadContent();
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
  int numberOfPagesDbu = (((discussionBoardPage.discussionBoardUpdatesThreads.length)/10)).ceil();
  int theCurrentPageDbu = 0;

  //Getting the threads that will appear in a page
  var listOfDbuThreads;
  var mySublistsDbu = [];
  var portionSizeDbu = 10;

  /*Future<List<dynamic>> getDbuThreads() async{
    var theSublistDbu = [];
    var myIndex;

    for(int i = 0; i < listOfDbuThreads.length; i += portionSizeDbu){
      theSublistDbu.add(listOfDbuThreads.sublist(i, i + portionSizeDbu > listOfDbuThreads.length ? listOfDbuThreads.length : i + portionSizeDbu));
      //print("i: $i");
    }

    //pageNumDbu = theCurrentPageDbu;

    return Future.delayed(Duration(seconds: 1), () {
      return theSublistDbu;
    });
  }*/

  //build method
  Widget build(BuildContext bc){
    listOfDbuThreads = discussionBoardPage.discussionBoardUpdatesThreads;
    for(int i = 0; i < listOfDbuThreads.length; i += portionSizeDbu){
      mySublistsDbu.add(listOfDbuThreads.sublist(i, i + portionSizeDbu > listOfDbuThreads.length ? listOfDbuThreads.length : i + portionSizeDbu));
    }
    print("listOfDbuThreads.length: ${listOfDbuThreads.length}");

    mySublistsDbuInformation = mySublistsDbu;

    var myPagesDbu = List.generate(
      numberOfPagesDbu,
          (index) => Center(
            child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: mySublistsDbu[theCurrentPageDbu].length,//mySublistsDbu[theCurrentPageDbu].length,//discussionBoardPage.discussionBoardUpdatesThreads.length,//discussionBoardUpdatesThreads.reversed.toList().length,
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
                          //child: Text(discussionBoardPage.discussionBoardUpdatesThreads[index]["threadTitle"].toString() + "\n" + "By: " + discussionBoardPage.discussionBoardUpdatesThreads[index]["poster"].toString()),//Text(reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][1] + "\n" + "By: " + reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][0]),
                          child: Text.rich(
                            TextSpan(
                              text: "${mySublistsDbu[theCurrentPageDbu][index]["threadTitle"].toString()}\nBy: ",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "${mySublistsDbu[theCurrentPageDbu][index]["poster"].toString()}",
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                  recognizer: TapGestureRecognizer()..onTap = () async =>{
                                  dbuClickedOnUser = true,
                                  nameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsDbu[theCurrentPageDbu][index]["poster"].toString().toLowerCase()).get(),
                                  nameData.docs.forEach((person){
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
                      onPressed: () async {
                        print("This is index: $index");
                        print("listOfDbuThreads is null? ${listOfDbuThreads == null}");
                        print("I clicked on a thread");
                        //print('You clicked on: ' + reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][1]);
                        //if(discussionBoardPage.discussionBoardUpdatesThreads[index].isNotEmpty){
                        myIndexPlaceDbu = index;
                        myLocation = theCurrentPageDbu;
                        threadAuthorDbu = mySublistsDbu[theCurrentPageDbu][index]["poster"].toString();//reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][0];
                        threadTitleDbu = mySublistsDbu[theCurrentPageDbu][index]["threadTitle"].toString();//reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][1];
                        threadContentDbu = mySublistsDbu[theCurrentPageDbu][index]["threadContent"].toString();//reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][2];
                        threadID = mySublistsDbu[theCurrentPageDbu][index]["threadId"].toString();//reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][3];
                        print("${threadAuthorDbu} + ${threadTitleDbu} + ${threadContentDbu} + ${threadID}");
                        print("context: ${context}");
                        await FirebaseFirestore.instance.collection("Discussion_Board_Updates").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                          myDocDbu = d.docs.first.id;
                          print(myDocDbu);
                        });
                        //var oneReply = {"animal": "dog", "breed": "belgian tervuren"};

                        //Getting the replies of a thread
                        await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDocDbu).collection("Replies");//.add(oneReply);

                        QuerySnapshot dbuRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDocDbu).collection("Replies").get();//.do//.docs.map((myDoc) => myDoc.data()).toList();;
                        theDbuThreadReplies = dbuRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                        print(theDbuThreadReplies.runtimeType);
                        //print(theDbuThreadReplies[0]["time"].toDate().runtimeType);
                        //print(theDbuThreadReplies[0]["time"].runtimeType);
                        //print(theDbuThreadReplies((a, b) => a[0]["time"].compareTo(b[0]["time"])));

                        print(DateTime.now().runtimeType);

                        (theDbuThreadReplies as List<dynamic>).sort((b, a) => (a["time"].toDate()).compareTo(b["time"].toDate()));
                        //print("theDbuThreadRepliesSorted: ${sortedList}");

                        /*
                                if(theDbuThreadReplies.length >= 2){
                                theDbuThreadReplies.sort((r1, r2){
                                  print("r1 and r2: ${r1}, ${r2}");
                                  if(r1["time"].isBefore(r2["time"]) && !(r2["time"].isBefore(r1["time"]))){
                                    return 1;
                                  }
                                  else if(r2["time"].isBefore(r1["time"]) && !(r1["time"].isBefore(r2["time"]))){
                                    return -1;
                                  }
                                  return r1["time"].compareTo(r2["time"]);
                                });
                                }
                                else{
                                  print("You need at least two elements in theDbuThreadReplies! ${theDbuThreadReplies.length}");
                                }

                                if(theDbuThreadReplies.length >= 2){
                                  print("theDbuThreadReplies: $theDbuThreadReplies");
                                  var i = theDbuThreadReplies.sort((r1, r2) => r1["time"].toString().compareTo(r2["time"].toString()));
                                  print("Value of i: $i");
                                }
                                else{
                                  print("theDbuThreadReplies: $theDbuThreadReplies");
                                  //print("theDbuThreadReplies[0][time]: ${theDbuThreadReplies[0]["time"]}");
                                }*/

                        //print(theDbuThreadReplies[0]["threadNumber"]);
                        //print(theDbuThreadReplies.where((sr) => sr.replyContent == "Four!"));
                        print("Number of theDbuThreadReplies: ${theDbuThreadReplies.length}");
                        //}
                        /*await FirebaseFirestore.instance.collection("Discussion_Board_Updates").where("threadId", isEqualTo: int.parse(reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][3])).get().then((num){
                                  discussionBoardUpdatesThreadId = num.docs.first.data()["threadId"];
                                });*/
                        //print("This is discussionBoardUpdatesThreadId: ${discussionBoardUpdatesThreadId}");
                        Navigator.push(context, MaterialPageRoute(builder: (context) => discussionBoardUpdatesThreadsPage()));//myIndexPlace = index;
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
            child: Text("Discussion Board Updates Subforum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
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
                  width: 150,
                  //margin: EdgeInsets.only(left: 250.0),
                  //alignment: Alignment.center,
                ),
              ),
              onPressed: (){
                print(discussionBoardUpdatesBool);
                discussionBoardUpdatesBool = true;
                print(discussionBoardUpdatesBool);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                print("I am going to write a new thread.");
              }
            ),
          ),
          Expanded(
            child: listOfDbuThreads.length != 0? myPagesDbu[theCurrentPageDbu] : Text("There are no threads in this subforum yet. Be the first to post a thread!", textAlign: TextAlign.center),//myPagesDbu[theCurrentPageDbu],
          ),
          NumberPaginator(
            height: 50,
            numberPages: listOfDbuThreads.length != 0? numberOfPagesDbu : 1,//numberOfPagesDbu,
            onPageChange: (myIndexDbu){
              setState((){
                theCurrentPageDbu = myIndexDbu;
                print("theCurrentPageDbu: ${theCurrentPageDbu}, myIndexDbu: ${myIndexDbu}");
              });
            }
          ),
        ],

        /*children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            child: Text("Discussion Board Updates Subforum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: 30,
            width: 120,
            margin: EdgeInsets.only(left: 250.0),
            alignment: Alignment.center,
            child: InkWell(
                child: Ink(
                  color: Colors.black,
                  padding: EdgeInsets.all(5.0),
                  child: Text("Post new thread", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                ),
                onTap: (){
                  print(discussionBoardUpdatesBool);
                  discussionBoardUpdatesBool = true;
                  print(discussionBoardUpdatesBool);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                  print("I am going to write a new thread.");
                }
            ),
          ),
          Expanded(
            child: myPagesDbu[theCurrentPageDbu],
          ),
          NumberPaginator(
              height: 50,
              numberPages: numberOfPagesDbu,
              onPageChange: (myIndexDbu){
                setState((){
                  theCurrentPageDbu = myIndexDbu;
                });
              }
          ),
        ],*/
      ),
    );
  }
}

class discussionBoardUpdatesThreadContent extends State<discussionBoardUpdatesThreadsPage>{
  int numberOfPagesDbuThreadReplies = 0;
  int theCurrentPageDbuThreadReplies = 0;

  var listOfDbuThreadReplies = theDbuThreadReplies;
  var mySublistsDbuThreadReplies = [];
  int portionSizeDbuThreadReplies = 10;

  @override
  Widget build(BuildContext context) {
    if(listOfDbuThreadReplies == []){
      numberOfPagesDbuThreadReplies = 1;
    }
    else{
      numberOfPagesDbuThreadReplies = (((theDbuThreadReplies.length)/10)).ceil();

      for(int i = 0; i < listOfDbuThreadReplies.length; i += portionSizeDbuThreadReplies){
        mySublistsDbuThreadReplies.add(listOfDbuThreadReplies.sublist(i, i + portionSizeDbuThreadReplies > listOfDbuThreadReplies.length ? listOfDbuThreadReplies.length : i + portionSizeDbuThreadReplies));
      }
    }

    /*for(int i = 0; i < listOfDbuThreadReplies.length; i += portionSizeDbuThreadReplies){
      mySublistsDbuThreadReplies.add(listOfDbuThreadReplies.sublist(i, i + portionSizeDbuThreadReplies > listOfDbuThreadReplies.length ? listOfDbuThreadReplies.length : i + portionSizeDbuThreadReplies));
    }*/

    var myPagesDbuThreadReplies = List.generate(
      numberOfPagesDbuThreadReplies,
          (myIndex) => Column(
        children: <Widget>[
          ListView.builder(
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies].length,//FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").length//5,//discussionBoardUpdatesThreads[int.parse(threadID)][4].length,
              itemBuilder: (context, index){
                return Column(
                  children: <Widget>[
                    mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["theOriginalReplyInfo"]["replyContent"] != null && mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["theOriginalReplyInfo"]["replier"] != null?//theDbuThreadReplies.length > 0?//discussionBoardUpdatesThreads[int.parse(threadID)][4][index][3] != "" && discussionBoardUpdatesThreads[int.parse(threadID)][4][index][4] != ""?
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
                              //Reply to: Reply content, reply poster
                              //child: Text("Reply to: " + theDbuThreadReplies[index]["theOriginalReplyInfo"]["replyContent"].toString() + "\n" + "Posted by: " + theDbuThreadReplies[index]["theOriginalReplyInfo"]["replier"].toString()),
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                  text: "Reply to: ${mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["theOriginalReplyInfo"]["replyContent"].toString()}",
                                  children: <TextSpan>[
                                    TextSpan(
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                      text: "\nPosted by: ",
                                    ),
                                    TextSpan(
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                      text: "${mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString()}",
                                      recognizer: TapGestureRecognizer()..onTap = () async =>{
                                        dbuClickedOnUser = true,
                                        nameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString().toLowerCase()).get(),
                                        nameData.docs.forEach((person){
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
                              color: Colors.blueGrey[300], //theDbuThreadReplies[index]["theOriginalReplyInfo"].toString(), theDbuThreadReplies[index]["theOriginalReplyInfo"].toString()
                              width: 320,
                            ),
                            onPressed: (){
                              //Does nothing
                            }
                          ),
                          //if(discussionBoardUpdatesThreads[int.parse(threadID)][4] != null)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey[300],
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Container(
                              //child: Text("Posted on: " + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][2] + "\n" + "Posted by: " + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][0] + "\n" + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][1]),
                              //child: Text("Posted on: " + theDbuThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + theDbuThreadReplies[index]["replier"].toString() + "\n" + theDbuThreadReplies[index]["replyContent"].toString()),
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                  text: "Posted on: ${mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["time"].toDate().toString()}",
                                  children: <TextSpan>[
                                    TextSpan(
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                      text: "\nPosted by: ",
                                    ),
                                    TextSpan(
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                      text: "${mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString()}",
                                      recognizer: TapGestureRecognizer()..onTap = () async =>{
                                        dbuClickedOnUser = true,
                                        nameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString().toLowerCase()).get(),
                                        nameData.docs.forEach((person){
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
                                      text: "\n${mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replyContent"].toString()}",
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
                            ),
                            onPressed: () async{
                              replyToReplyTimeDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["time"];//.toString();
                              replyToReplyContentDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["replyContent"].toString();
                              replyToReplyPosterDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["replier"].toString();
                              //replyToReplyOriginalInfoDbu = theDbuThreadReplies![index]["originalReplyInfo"].toString();
                              //print("This is replyToReplyOriginalInfoDbu: ${replyToReplyOriginalInfoDbu["replyContent"]}");
                              print("This is replyToReplyTime: $replyToReplyTimeDbu");

                              await FirebaseFirestore.instance.collection("Discussion_Board_Updates").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                myDocDbu = d.docs.first.id;
                                print(myDocDbu);
                              });
                              await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDocDbu).collection("Replies").where("time", isEqualTo: replyToReplyTimeDbu).get().then((rd) {
                                replyToReplyDocDbu = rd.docs.first.id;
                                //replyToReplyTime = rd.docs.first["time"];
                                //print("This is t: $replyToReplyTime");
                                //replyContent = dbuRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                                print(replyToReplyDocDbu);
                              });

                              //var theReply = FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").where();

                              //.add(oneReply);

                              //QuerySnapshot dbuRepliesQuerySnapshot = (await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").doc(replyToReplyDoc).get()) as QuerySnapshot<Object?>;//.do//.docs.map((myDoc) => myDoc.data()).toList();;
                              //theDbuThreadReplies = dbuRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                              print(theDbuThreadReplies);
                              print(replyToReplyDocDbu);
                              //print(replyToReplyDoc.snapshot);
                              //print(replyContent);
                              DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDocDbu).collection("Replies").doc(replyToReplyDocDbu).get();
                              print(ds.data());
                              print(ds.data().runtimeType);
                              print(mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeDbu));
                              myIndex = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeDbu); //where replyToReplyDoc is in theDbuThreadReplies.
                              myReplyToReplyDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][myIndex];
                              //print("myReplyToReplyDbu runtime type: ${myReplyToReplyDbu.runtimeType}");
                              //myReplyToReplyDbu.forEach((k, v) => myReplyToReplyDbuList.);//List.from(myReplyToReplyDbu);//Map.from(myReplyToReplyDbu);
                              myReplyToReplyDbuMap = Map.from(myReplyToReplyDbu);
                              //myReplyToReplyDbuList = myReplyToReplyDbuMap.entries.map((myEntry) => "${myEntry.key}: ${myEntry.value}").toList();

                              List<dynamic> tempReplyToReplyList = [replyToReplyContentDbu, replyToReplyPosterDbu, myReplyToReplyDbuMap];
                              dbuRepliesToReplies.add(tempReplyToReplyList);

                              print("myReplyToReplyDbuMap: ${myReplyToReplyDbuMap}");

                              print("myReplyToReplyDbu: ${myReplyToReplyDbu["replyContent"]}");
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
                            height: 10,
                          ),
                          //if(discussionBoardUpdatesThreads[int.parse(threadID)][4] != null)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey[300],
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Container(
                              //child: Text("Posted on: " + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][2] + "\n" + "Posted by: " + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][0] + "\n" + reversedDiscussionBoardUpdatesRepliesIterable.toList()[index][1]),
                              //child: Text("Posted on: " + theDbuThreadReplies[index]["time"].toDate().toString() + "\n" + "Posted by: " + theDbuThreadReplies[index]["replier"].toString() + "\n" + theDbuThreadReplies[index]["replyContent"].toString()),
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                  text: "Posted on: ${mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["time"].toDate().toString()}",
                                  children: <TextSpan>[
                                    TextSpan(
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                      text: "\nPosted by: ",
                                    ),
                                    TextSpan(
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                      text: "${mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString()}",
                                      recognizer: TapGestureRecognizer()..onTap = () async =>{
                                        dbuClickedOnUser = true,
                                        nameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString().toLowerCase()).get(),
                                        nameData.docs.forEach((person){
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
                                      text: "\n${mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replyContent"].toString()}",
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
                            ),
                            onPressed: () async{
                              replyToReplyTimeDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["time"];//.toString();
                              replyToReplyContentDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["replyContent"].toString();
                              replyToReplyPosterDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["replier"].toString();
                              //replyToReplyOriginalInfoDbu = theDbuThreadReplies![index]["originalReplyInfo"].toString();
                              //print("This is replyToReplyOriginalInfoDbu: $replyToReplyOriginalInfoDbu");
                              print("This is replyToReplyTime: $replyToReplyTimeDbu");

                              await FirebaseFirestore.instance.collection("Discussion_Board_Updates").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                myDocDbu = d.docs.first.id;
                                print(myDocDbu);
                              });
                              await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDocDbu).collection("Replies").where("time", isEqualTo: replyToReplyTimeDbu).get().then((rd) {
                                replyToReplyDocDbu = rd.docs.first.id;
                                //replyToReplyTime = rd.docs.first["time"];
                                //print("This is t: $replyToReplyTime");
                                //replyContent = dbuRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                                print(replyToReplyDocDbu);
                              });

                              //var theReply = FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").where();

                              //.add(oneReply);

                              //QuerySnapshot dbuRepliesQuerySnapshot = (await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").doc(replyToReplyDoc).get()) as QuerySnapshot<Object?>;//.do//.docs.map((myDoc) => myDoc.data()).toList();;
                              //theDbuThreadReplies = dbuRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                              print(theDbuThreadReplies);
                              print(replyToReplyDocDbu);
                              //print(replyToReplyDoc.snapshot);
                              //print(replyContent);
                              DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDocDbu).collection("Replies").doc(replyToReplyDocDbu).get();
                              print(ds.data());
                              print(ds.data().runtimeType);
                              //print(theDbuThreadReplies[1].runtimeType);
                              myIndex = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeDbu);
                              //where replyToReplyDoc is in theDbuThreadReplies.
                              print(mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeDbu));
                              myReplyToReplyDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][myIndex];
                              //print("myReplyToReplyDbu runtime type: ${myReplyToReplyDbu.runtimeType}");
                              myReplyToReplyDbuMap = Map.from(myReplyToReplyDbu);
                              //myReplyToReplyDbuList = myReplyToReplyDbuMap.entries.map((myEntry) => "${myEntry.key}: ${myEntry.value}").toList();

                              List<dynamic> tempReplyToReplyList = [replyToReplyContentDbu, replyToReplyPosterDbu, myReplyToReplyDbuMap];
                              dbuRepliesToReplies.add(tempReplyToReplyList);

                              //print("This is replyToReplyOriginalInfoDbu: ${replyToReplyOriginalInfoDbu["replyContent"]}");
                              //print(myReplyToReplyDbuList["replyContent"]);
                              print("myReplyToReplyDbuMap: ${myReplyToReplyDbuMap}");

                              print("myReplyToReplyDbu: ${myReplyToReplyDbu["replyContent"]}");
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
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () => {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardUpdatesPage())),
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
                        text: "Thread title: ${threadTitleDbu}\n",
                        children: <TextSpan>[
                          TextSpan(
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                            text: "Posted by: ",
                          ),
                          TextSpan(
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                            text: "${threadAuthorDbu}",
                            recognizer: TapGestureRecognizer()..onTap = () async =>{
                              dbuClickedOnUser = true,
                              nameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: threadAuthorDbu.toLowerCase()).get(),
                              nameData.docs.forEach((person){
                                theUsersData = person.data();
                              }),
                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                            }
                          ),
                          TextSpan(
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                            text: " \n",
                          ),
                          TextSpan(
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                            text: "${threadContentDbu}",
                          ),
                        ],
                      ),
                    ),
                  ),//Text("Thread title: " + threadTitleDbu + "\n" + "Posted by: " + threadAuthorDbu + "\n" + threadContentDbu),
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
              ),
              onPressed: (){
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
            Container(
              height: 10,
            ),
            Center(
              child: listOfDbuThreadReplies.length != 0? myPagesDbuThreadReplies[theCurrentPageDbuThreadReplies] : Text("There are no replies to this thread yet. Be the first to reply!"),
            ),
            NumberPaginator(
                height: 50,
                numberPages: listOfDbuThreadReplies.length != 0? numberOfPagesDbuThreadReplies : 1,
                onPageChange: (myIndexDbuThreadReplies){
                  setState((){
                    theCurrentPageDbuThreadReplies = myIndexDbuThreadReplies;
                  });
                }
            ),
          ],
        ),
      ),
    );
  }
}