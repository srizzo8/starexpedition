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
import 'package:starexpedition4/firebaseDesktopHelper.dart';

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

int theCurrentPageDbu = 0;

int dbuNavigationDepth = 0;

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

    //double threadContainerHeight = 45.0;
    //double myFontSize = threadContainerHeight / 3.0;

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
                                        text: "${mySublistsDbu[theCurrentPageDbu][index]["threadTitle"].toString()}\nBy: ",
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, height: 1.1),
                                        children: [
                                          TextSpan(
                                              text: "${mySublistsDbu[theCurrentPageDbu][index]["poster"].toString()}",
                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, height: 1.1),
                                              recognizer: TapGestureRecognizer()..onTap = () async =>{
                                                dbuClickedOnUser = true,

                                                if(firebaseDesktopHelper.onDesktop){
                                                  nameData = await firebaseDesktopHelper.getFirestoreCollection("User"),
                                                  theUsersData = nameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsDbu[theCurrentPageDbu][index]["poster"].toString().toLowerCase(), orElse: () => <String, dynamic>{}),
                                                }
                                                else{
                                                  nameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsDbu[theCurrentPageDbu][index]["poster"].toString().toLowerCase()).get(),
                                                  nameData.docs.forEach((person){
                                                    theUsersData = person.data();
                                                  }),
                                                },

                                                print("This is nameData: ${nameData}"),
                                                //print("This is the poster: ${mySublistsDbu[theCurrentPageDbu][index]["poster"].toString()}"),
                                                print("This is theUsersData: ${theUsersData}"),

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
                            print("listOfDbuThreads is null? ${listOfDbuThreads == null}");
                            print("I clicked on a thread");

                            myIndexPlaceDbu = index;
                            myLocation = theCurrentPageDbu;
                            threadAuthorDbu = mySublistsDbu[theCurrentPageDbu][index]["poster"].toString();//reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][0];
                            threadTitleDbu = mySublistsDbu[theCurrentPageDbu][index]["threadTitle"].toString();//reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][1];
                            threadContentDbu = mySublistsDbu[theCurrentPageDbu][index]["threadContent"].toString();//reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][2];
                            threadID = mySublistsDbu[theCurrentPageDbu][index]["threadId"].toString();//reversedDiscussionBoardUpdatesThreadsIterable.toList()[index][3];
                            print("${threadAuthorDbu} + ${threadTitleDbu} + ${threadContentDbu} + ${threadID}");
                            print("context: ${context}");

                            if(firebaseDesktopHelper.onDesktop){
                              var theDbuThreads = await firebaseDesktopHelper.getFirestoreCollection("Discussion_Board_Updates");
                              var matchingThread = theDbuThreads.firstWhere((myDoc) => myDoc["threadId"] == int.parse(threadID), orElse: () => <String, dynamic>{});

                              if(matchingThread.isNotEmpty){
                                //Getting the document ID:
                                myDocDbu = matchingThread["docId"];
                                print("This is myDocDbu: ${myDocDbu}");
                              }
                              else{
                                print("Sorry; the thread was not found");
                              }
                            }
                            else{
                              await FirebaseFirestore.instance.collection("Discussion_Board_Updates").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                myDocDbu = d.docs.first.id;
                                print("This is myDocDbu: ${myDocDbu}");
                              });
                            }

                            //Getting the replies of a thread
                            if(firebaseDesktopHelper.onDesktop){
                              theDbuThreadReplies = await firebaseDesktopHelper.getFirestoreSubcollection("Discussion_Board_Updates", myDocDbu, "Replies");

                              print(theDbuThreadReplies.runtimeType);

                              print(DateTime.now().runtimeType);

                              theDbuThreadReplies.sort((b, a){
                                DateTime dta = firebaseDesktopHelper.convertStringToDateTime(a["time"]);
                                DateTime dtb = firebaseDesktopHelper.convertStringToDateTime(b["time"]);
                                return dta.compareTo(dtb);
                              });
                            }
                            else{
                              await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDocDbu).collection("Replies");//.add(oneReply);

                              QuerySnapshot dbuRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDocDbu).collection("Replies").get();//.do//.docs.map((myDoc) => myDoc.data()).toList();;
                              theDbuThreadReplies = dbuRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                              print(theDbuThreadReplies.runtimeType);

                              print(DateTime.now().runtimeType);

                              (theDbuThreadReplies as List<dynamic>).sort((b, a) => (DateTime.parse(a["time"])).compareTo(DateTime.parse(b["time"])));
                            }
                            print("Number of theDbuThreadReplies: ${theDbuThreadReplies.length}");

                            Navigator.push(context, MaterialPageRoute(builder: (context) => discussionBoardUpdatesThreadsPage()));
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
              theCurrentPageDbu = 0,
            }
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            child: Text("Discussion Board Updates Subforum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
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
                    //padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.0031250),
                    //height: 40,
                    //width: 150,
                    //child: Center(
                    child: Text("Post New Thread", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white), textAlign: TextAlign.center),
                    //),
                    //margin: EdgeInsets.only(left: 250.0),
                    //alignment: Alignment.center,
                  ),
                ),
                onPressed: (){
                  print(discussionBoardUpdatesBool);
                  discussionBoardUpdatesBool = true;
                  print(discussionBoardUpdatesBool);
                  dbuNavigationDepth++;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                  print("I am going to write a new thread.");
                }
            ),
          ),
          Expanded(
            child: listOfDbuThreads.length != 0? myPagesDbu[theCurrentPageDbu] : Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.031250, 0.0, MediaQuery.of(context).size.width * 0.031250, 0.0), child: Text("There are no threads in this subforum yet. Be the first to post a thread!", textAlign: TextAlign.center),),//myPagesDbu[theCurrentPageDbu],
          ),
          NumberPaginator(
              height: MediaQuery.of(context).size.height * 0.0782125,
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

  var listOfDbuThreadReplies;
  var mySublistsDbuThreadReplies = [];
  int portionSizeDbuThreadReplies = 10;

  @override
  Widget build(BuildContext context) {
    listOfDbuThreadReplies = theDbuThreadReplies;

    //Clearing outdated sublists:
    mySublistsDbuThreadReplies.clear();

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
              itemCount: (mySublistsDbuThreadReplies.isNotEmpty && theCurrentPageDbuThreadReplies < mySublistsDbuThreadReplies.length) ? mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies].length : 0,//mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies].length,//FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").length//5,//discussionBoardUpdatesThreads[int.parse(threadID)][4].length,
              itemBuilder: (context, index){
                return Column(
                  children: <Widget>[
                    mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["theOriginalReplyInfo"]["replyContent"] != null && mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["theOriginalReplyInfo"]["replier"] != null?//theDbuThreadReplies.length > 0?//discussionBoardUpdatesThreads[int.parse(threadID)][4][index][3] != "" && discussionBoardUpdatesThreads[int.parse(threadID)][4][index][4] != ""?
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

                                            if(firebaseDesktopHelper.onDesktop){
                                              nameData = await firebaseDesktopHelper.getFirestoreCollection("User"),
                                              theUsersData = nameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString().toLowerCase(), orElse: () => <String, dynamic>{}),
                                            }
                                            else{
                                              nameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString().toLowerCase()).get(),
                                              nameData.docs.forEach((person){
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
                                color: Colors.blueGrey[300], //theDbuThreadReplies[index]["theOriginalReplyInfo"].toString(), theDbuThreadReplies[index]["theOriginalReplyInfo"].toString()
                                width: MediaQuery.of(context).size.width * 0.5,
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
                                    text: "Posted on: ${firebaseDesktopHelper.formatMyTimestamp(mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["time"].toString())}",
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
                                            if(firebaseDesktopHelper.onDesktop){
                                              nameData = await firebaseDesktopHelper.getFirestoreCollection("User"),
                                              theUsersData = nameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString().toLowerCase(), orElse: () => <String, dynamic>{}),
                                            }
                                            else{
                                              nameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString().toLowerCase()).get(),
                                              nameData.docs.forEach((person){
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
                                        text: "\n${mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replyContent"].toString()}",
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
                              ),
                              onPressed: () async{
                                replyToReplyTimeDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["time"];//.toString();
                                replyToReplyContentDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["replyContent"].toString();
                                replyToReplyPosterDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["replier"].toString();
                                //replyToReplyOriginalInfoDbu = theDbuThreadReplies![index]["originalReplyInfo"].toString();
                                //print("This is replyToReplyOriginalInfoDbu: ${replyToReplyOriginalInfoDbu["replyContent"]}");
                                print("This is replyToReplyTime: $replyToReplyTimeDbu");

                                if(firebaseDesktopHelper.onDesktop){
                                  var theDocDbu = await firebaseDesktopHelper.getFirestoreCollection("Discussion_Board_Updates");
                                  print("Hello. This is theDocDbu: $theDocDbu");
                                  myDocDbu = theDocDbu.firstWhere((myThreadId) => myThreadId["threadId"] == int.parse(threadID), orElse: () => <String, dynamic>{})["docId"];
                                  print("Hello. This is myDocDbu: $myDocDbu");
                                  print("Hello. This is the runtime type of myDocDbu: ${myDocDbu.runtimeType}");

                                  var tempReplyToReplyVar = await firebaseDesktopHelper.getFirestoreSubcollection("Discussion_Board_Updates", myDocDbu, "Replies");
                                  print("Hello. This is tempReplyToReplyVar: ${tempReplyToReplyVar}");
                                  print("Hello. This is the replyToReplyTimeDbu variable: ${replyToReplyTimeDbu}");
                                  replyToReplyDocDbu = tempReplyToReplyVar.firstWhere((myTime) => firebaseDesktopHelper.formatMyTimestamp(myTime["time"]) == replyToReplyTimeDbu.toString(), orElse: () => <String, dynamic>{});
                                  print("Hello. This is replyToReplyDocDbu: ${replyToReplyDocDbu}");
                                }
                                else{
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
                                }

                                //var theReply = FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").where();

                                //.add(oneReply);

                                //QuerySnapshot dbuRepliesQuerySnapshot = (await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").doc(replyToReplyDoc).get()) as QuerySnapshot<Object?>;//.do//.docs.map((myDoc) => myDoc.data()).toList();;
                                //theDbuThreadReplies = dbuRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                                print(theDbuThreadReplies);
                                print(replyToReplyDocDbu);
                                //print(replyToReplyDoc.snapshot);
                                //print(replyContent);

                                if(firebaseDesktopHelper.onDesktop){
                                  /*DocumentSnapshot ds = await firebaseDesktopHelper.getFirestoreSubcollectionDocument("Discussion_Board_Updates", myDocDbu, "Replies", replyToReplyDocDbu) as DocumentSnapshot;
                                print(ds.data());
                                print(ds.data().runtimeType);*/
                                  /*List<Map<String, dynamic>> docsList = await firebaseDesktopHelper.getFirestoreSubcollection("Discussion_Board_Updates", myDocDbu, "Replies");
                                for (var d in docsList){
                                  if(d == replyToReplyDocDbu){
                                    print("This is d: $d");
                                    break;
                                  }
                                  else{
                                    //continue
                                  }
                                }
                                print(ds.data());
                                print(ds.data().runtimeType);*/
                                  print("The doc: $myDocDbu");
                                  print("The subdoc: $replyToReplyDocDbu");

                                  try{
                                    Map<String, dynamic>? dsData = await firebaseDesktopHelper.getFirestoreSubcollectionDocument("Discussion_Board_Updates", myDocDbu, "Replies", replyToReplyDocDbu);

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
                                  DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDocDbu).collection("Replies").doc(replyToReplyDocDbu).get();
                                  print(ds.data());
                                  print(ds.data().runtimeType);
                                }
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
                                dbuNavigationDepth++;

                                final myResult = await Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));

                                //Refreshing the page after returning from a reply:
                                if(myResult == true){
                                  setState((){
                                    //Clears sublists and forces a rebuild with new data:
                                    mySublistsDbuThreadReplies.clear();
                                  });
                                }

                                //Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
                                //print('Reply no. ' + index.toString());
                                //print('Replying to this reply: ' + discussionBoardUpdatesThreads[int.parse(threadID)][4][myIndex][2].toString());
                              }
                          ),
                        ]
                    ): Column(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * 0.015625,
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
                                    text: "Posted on: ${firebaseDesktopHelper.formatMyTimestamp(mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["time"].toString())}",
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

                                            if(firebaseDesktopHelper.onDesktop){
                                              nameData = await firebaseDesktopHelper.getFirestoreCollection("User"),
                                              theUsersData = nameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString().toLowerCase(), orElse: () => <String, dynamic>{}),
                                              print("theUsersData is this on Desktop: ${theUsersData}"),
                                            }
                                            else{
                                              nameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString().toLowerCase()).get(),
                                              nameData.docs.forEach((person){
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
                                        text: "\n${mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replyContent"].toString()}",
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
                              ),
                              onPressed: () async{
                                replyToReplyTimeDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["time"];//.toString();
                                replyToReplyContentDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["replyContent"].toString();
                                replyToReplyPosterDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["replier"].toString();
                                //replyToReplyOriginalInfoDbu = theDbuThreadReplies![index]["originalReplyInfo"].toString();
                                //print("This is replyToReplyOriginalInfoDbu: $replyToReplyOriginalInfoDbu");
                                print("This is replyToReplyTime: $replyToReplyTimeDbu");

                                if(firebaseDesktopHelper.onDesktop){
                                  /*await FirebaseFirestore.instance.collection("Discussion_Board_Updates").where("threadId", isEqualTo: int.parse(threadID)).get().then((d) {
                                  myDocDbu = d.docs.first.id;
                                  print(myDocDbu);
                                });
                                await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDocDbu).collection("Replies").where("time", isEqualTo: replyToReplyTimeDbu).get().then((rd) {
                                  replyToReplyDocDbu = rd.docs.first.id;
                                  print(replyToReplyDocDbu);
                                });*/

                                  /*var theDocDbu = await firebaseDesktopHelper.getFirestoreCollection("Discussion_Board_Updates");
                                myDocDbu = theDocDbu.firstWhere((myThreadId) => myThreadId["threadId"] == int.parse(threadID), orElse: () => {} as Map<String, dynamic>);

                                var tempReplyToReplyVar = await firebaseDesktopHelper.getFirestoreSubcollection("Discussion_Board_Updates", myDocDbu, "Replies");
                                replyToReplyDocDbu = tempReplyToReplyVar.firstWhere((myTime) => myTime["time"] == replyToReplyTimeDbu, orElse: () => {} as Map<String, dynamic>);*/
                                  var theDbuThreads = await firebaseDesktopHelper.getFirestoreCollection("Discussion_Board_Updates");
                                  var matchingThread = theDbuThreads.firstWhere((myDoc) => myDoc["threadId"] == int.parse(threadID), orElse: () => <String, dynamic>{});

                                  if(matchingThread.isNotEmpty){
                                    //Getting the document ID:
                                    myDocDbu = matchingThread["docId"];
                                    print("This is myDocDbu: ${myDocDbu}");
                                  }
                                  else{
                                    print("Sorry; the thread was not found");
                                  }

                                  var theDbuThreadsReplies = await firebaseDesktopHelper.getFirestoreSubcollection("Discussion_Board_Updates", myDocDbu, "Replies");
                                  var matchingReply = theDbuThreadsReplies.firstWhere((myDoc) => myDoc["time"] == replyToReplyTimeDbu, orElse: () => <String, dynamic>{});

                                  if(matchingReply.isNotEmpty){
                                    //Getting the document ID:
                                    replyToReplyDocDbu = matchingReply["docId"];
                                    print("This is replyToReplyDocDbu: ${replyToReplyDocDbu}");
                                  }
                                  else{
                                    print("Sorry; the thread was not found");
                                  }
                                }
                                else{
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
                                }

                                //var theReply = FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").where();

                                //.add(oneReply);

                                //QuerySnapshot dbuRepliesQuerySnapshot = (await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDoc).collection("Replies").doc(replyToReplyDoc).get()) as QuerySnapshot<Object?>;//.do//.docs.map((myDoc) => myDoc.data()).toList();;
                                //theDbuThreadReplies = dbuRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();

                                print(theDbuThreadReplies);
                                print(replyToReplyDocDbu);
                                //print(replyToReplyDoc.snapshot);
                                //print(replyContent);

                                if(firebaseDesktopHelper.onDesktop){
                                  /*DocumentSnapshot ds = await firebaseDesktopHelper.getFirestoreSubcollectionDocument("Discussion_Board_Updates", myDocDbu, "Replies", replyToReplyDocDbu) as DocumentSnapshot;
                                print(ds.data());
                                print(ds.data().runtimeType);*/
                                  print("The doc: $myDocDbu");
                                  print("The subdoc: $replyToReplyDocDbu");

                                  try{
                                    Map<String, dynamic>? dsData = await firebaseDesktopHelper.getFirestoreSubcollectionDocument("Discussion_Board_Updates", myDocDbu, "Replies", replyToReplyDocDbu);

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
                                  DocumentSnapshot ds = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(myDocDbu).collection("Replies").doc(replyToReplyDocDbu).get();
                                  print(ds.data());
                                  print(ds.data().runtimeType);
                                }


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
                                dbuNavigationDepth++;

                                final myResult = await Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));

                                //Refreshing the page after returning from a reply:
                                if(myResult == true){
                                  setState((){
                                    //Clears sublists and forces a rebuild with new data:
                                    mySublistsDbuThreadReplies.clear();
                                  });
                                }

                                //Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));
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
              //Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardUpdatesPage())),
              print("We're going backwards. This is the depth: ${dbuNavigationDepth}"),

              if(Navigator.canPop(context)){
                Navigator.pop(context),
              },

              dbuNavigationDepth = 0,
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

                                  if(firebaseDesktopHelper.onDesktop){
                                    nameData = await firebaseDesktopHelper.getFirestoreCollection("User"),
                                    theUsersData = nameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == threadAuthorDbu.toLowerCase(), orElse: () => <String, dynamic>{}),
                                  }
                                  else{
                                    nameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: threadAuthorDbu.toLowerCase()).get(),
                                    nameData.docs.forEach((person){
                                      theUsersData = person.data();
                                    }),
                                  },

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
                    height: MediaQuery.of(context).size.height * 0.02734375,
                    child: Container(
                      alignment: Alignment.topCenter,
                      child: Text("Reply to thread", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                    ),
                  ),
                ),
                onPressed: () async {
                  discussionBoardUpdatesReplyingToReplyBool = false;
                  discussionBoardUpdatesReplyBool = true;
                  dbuNavigationDepth++;
                  print(reversedDiscussionBoardUpdatesThreadsIterable.toList());
                  //myIndexPlace = discussionBoardUpdatesPageState.index;
                  //myIndexPlace = reversedDiscussionBoardUpdatesThreadsIterable.toList().indexWhere((reversedDiscussionBoardUpdatesThreadsIterable) => reversedDiscussionBoardUpdatesThreadsIterable.contains("[" + threadAuthorDbu + ", " + threadTitleDbu + ", " + threadContentDbu + "]"));
                  print(threadID);
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));

                  final myResult = await Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));

                  //Refreshing the page after returning from a reply:
                  if(myResult == true){
                    setState((){
                      //Clears sublists and forces a rebuild with new data:
                      mySublistsDbuThreadReplies.clear();
                    });
                  }

                  print('Replying to the thread');
                }
            ),
            /*Container(
              height: MediaQuery.of(context).size.height * 0.015625,
            ),*/
            Center(
              child: (myPagesDbuThreadReplies.isNotEmpty && theCurrentPageDbuThreadReplies < myPagesDbuThreadReplies.length)? myPagesDbuThreadReplies[theCurrentPageDbuThreadReplies] : Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.031250, MediaQuery.of(context).size.height * 0.062500, MediaQuery.of(context).size.width * 0.031250, 0.0), child: Text("There are no replies to this thread yet. Be the first to reply!", textAlign: TextAlign.center),),
            ),
            NumberPaginator(
                height: MediaQuery.of(context).size.height * 0.0782125,
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