import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
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
int theCurrentPageDbuThreadReplies = 0;

int dbuNavigationDepth = 0;

bool fromDbuThread = false;
bool fromDbuPage = false;

var theDbuThreadResult;
var dbuThreadClickedData;
var specificDbuThreadData;

var threadPosterUserIsReplyingToDbu;
var replyPosterUserIsReplyingToDbu;
var contentOfReplyUserIsReplyingToDbu;
var titleOfThreadUserIsReplyingToDbu;

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

class myDbuSearch extends SearchDelegate{
  List<dynamic> listOfDbuThreads = discussionBoardPage.discussionBoardUpdatesThreads;

  final ScrollController myScrollController = ScrollController();

  ValueNotifier<bool> dbuSearchNavigation = ValueNotifier(false);

  @override
  TextInputAction get textInputAction => TextInputAction.search;

  @override
  List<Widget>? buildActions(BuildContext bc){
    return [
      IconButton(
        onPressed: (){
          query = "";
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext bc2){
    return IconButton(
      onPressed: (){
        //close(bc2, null);
        Navigator.push(bc2, MaterialPageRoute(builder: (BuildContext context) => discussionBoardUpdatesPage()));
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext bc3){
    List<dynamic> myMatchQuery = [];

    if(!myScrollController.hasListeners){
      myScrollController.addListener((){
        SystemChannels.textInput.invokeMethod("TextInput.hide");
      });
    }

    SystemChannels.textInput.invokeMethod("TextInput.hide");

    WidgetsBinding.instance.addPostFrameCallback((_){
      SystemChannels.textInput.invokeMethod("TextInput.hide");
      FocusScope.of(bc3).requestFocus(FocusNode());}
    );

    Future.delayed(Duration(milliseconds: 50), (){
      SystemChannels.textInput.invokeMethod("TextInput.hide");
    });

    Future.delayed(Duration(milliseconds: 100), (){
      SystemChannels.textInput.invokeMethod("TextInput.hide");
    });

    Future.delayed(Duration(milliseconds: 250), (){
      SystemChannels.textInput.invokeMethod("TextInput.hide");
    });

    Future.delayed(Duration(milliseconds: 500), (){
      SystemChannels.textInput.invokeMethod("TextInput.hide");
    });

    for(var dbuThread in listOfDbuThreads){
      if(dbuThread["threadTitle"].toLowerCase().contains(query.toLowerCase())){
        myMatchQuery.add([dbuThread["threadTitle"], dbuThread["poster"]]);
      }
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: (){
        SystemChannels.textInput.invokeMethod("TextInput.hide");
      },
      onPanDown: (_){
        SystemChannels.textInput.invokeMethod("TextInput.hide");
      },
      child: ListView.builder(
          controller: myScrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: myMatchQuery.length,
          itemBuilder: (bc3, index){
            var myResult = myMatchQuery[index];
            return ListTile(
              title: Text("${myResult[0]}\nBy: ${myResult[1]}"),
            );
          }
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext bc4){
    List<dynamic> myMatchQuery = [];
    for(var dbuThread in listOfDbuThreads){
      if(dbuThread["threadTitle"].toLowerCase().contains(query.toLowerCase())){
        myMatchQuery.add([dbuThread["threadTitle"], dbuThread["poster"]]);
      }
    }

    myMatchQuery.sort((dbu1, dbu2) => dbu1[0].compareTo(dbu2[0]));

    return GestureDetector(
      onTap: () => FocusScope.of(bc4).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: myMatchQuery.length,
          itemBuilder: (bc4, index){
            var myResult = myMatchQuery[index];
            return ValueListenableBuilder<bool>(
              valueListenable: dbuSearchNavigation,
              builder: (context, dbuSearch, child){
                return AbsorbPointer(
                  absorbing: dbuSearch,
                  child: ListTile(
                    title: Text("${myResult[0]}\nBy: ${myResult[1]}"),
                    onTap: () async{
                      if(dbuSearchNavigation.value){
                        return;
                      }

                      dbuSearchNavigation.value = true;

                      SystemChannels.textInput.invokeMethod("TextInput.hide");

                      theDbuThreadResult = myResult[0];

                      //Finding the thread from listOfDbuThreads:
                      final myMatch = listOfDbuThreads.firstWhere((myDbuThread) => myDbuThread["threadTitle"] == myResult[0], orElse: () => null);

                      if(myMatch == null){
                        print("Unfortunately, the thread data for ${myResult[0]} cannot be found");
                        return;
                      }

                      specificDbuThreadData = myMatch;

                      if(firebaseDesktopHelper.onDesktop){
                        dbuThreadClickedData = await firebaseDesktopHelper.getFirestoreCollection("Discussion_Board_Updates");
                        specificDbuThreadData = dbuThreadClickedData.firstWhere((myDbuThread) => myDbuThread["threadTitle"].toString().toLowerCase() == myResult[0].toLowerCase(), orElse: () => {} as Map<String, dynamic>);
                        print("dbuThreadClickedData: ${dbuThreadClickedData}");
                        print("specifcDbuThreadData: ${specificDbuThreadData}");

                        threadAuthorDbu = specificDbuThreadData["poster"].toString();
                        threadTitleDbu = specificDbuThreadData["threadTitle"].toString();
                        threadContentDbu = specificDbuThreadData["threadContent"].toString();
                        threadID = specificDbuThreadData["threadId"].toString();

                        //Navigator.push(bc4, MaterialPageRoute(builder: (BuildContext context) => discussionBoardUpdatesThreadsPage()));
                      }
                      else{
                        dbuThreadClickedData = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").where("threadTitle", isEqualTo: myResult[0].toLowerCase()).get();
                        dbuThreadClickedData.docs.forEach((myThread){
                          specificDbuThreadData = myThread.data();
                        });

                        threadAuthorDbu = specificDbuThreadData["poster"].toString();
                        threadTitleDbu = specificDbuThreadData["threadTitle"].toString();
                        threadContentDbu = specificDbuThreadData["threadContent"].toString();
                        threadID = specificDbuThreadData["threadId"].toString();

                        print("You clicked on a thread title: ${myResult}");
                        print("The DBU thread data: ${specificDbuThreadData}");
                        print("Content of the DBU thread: ${specificDbuThreadData["threadContent"]}");
                        print("Thread ID of the DBU thread: ${specificDbuThreadData["threadId"]}");
                        //Navigator.push(bc4, MaterialPageRoute(builder: (BuildContext context) => discussionBoardUpdatesThreadsPage()));
                      }

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

                      if(!bc4.mounted){
                        return;
                      }

                      Navigator.push(bc4, MaterialPageRoute(builder: (BuildContext context) => discussionBoardUpdatesThreadsPage()));
                      dbuSearchNavigation.value = false;
                    }
                  )
                );
              }
            );
        }
      ),
    );
  }
}

class routeToCreateThread{
  static String createThreadPage = createThreadState.threadCreator;
}

class routeToReplyToThreadDiscussionBoardUpdates{
  static String replyThreadPage = replyThreadPageState.replyThread;
}

class discussionBoardUpdatesPageState extends State<discussionBoardUpdatesPage> with RouteAware{
  static String dBoardRoute = '/discussionBoardUpdatesPage';
  int numberOfPagesDbu = (((discussionBoardPage.discussionBoardUpdatesThreads.length)/10)).ceil();
  //int theCurrentPageDbu = 0;

  //Getting the threads that will appear in a page
  var listOfDbuThreads = [];
  var mySublistsDbu = [];
  var portionSizeDbu = 10;

  int previousThreadsLength = -1;

  TextEditingController dbuQuery = TextEditingController();
  myDbuSearch mdbus = new myDbuSearch();

  bool createThreadButton = false;
  bool clickThread = false;
  bool clickUsername = false;

  @override
  void initState(){
    super.initState();
    listOfDbuThreads = discussionBoardPage.discussionBoardUpdatesThreads;
    rebuildSublistsIfNecessary();
  }

  void rebuildSublistsIfNecessary(){
    int myCurrentLength = listOfDbuThreads?.length ?? 0;

    if(previousThreadsLength != myCurrentLength){
      previousThreadsLength = myCurrentLength;
      mySublistsDbu.clear();

      if(myCurrentLength == 0){
        numberOfPagesDbu = 1;
      }
      else{
        numberOfPagesDbu = (myCurrentLength / 10).ceil();

        for(int i = 0; i < myCurrentLength; i += portionSizeDbu){
          mySublistsDbu.add(listOfDbuThreads.sublist(i, i + portionSizeDbu > myCurrentLength ? myCurrentLength : i + portionSizeDbu));
        }
      }

      mySublistsDbuInformation = mySublistsDbu;
    }
  }

  //Lifecycle methods (didChangeDependencies() and dispose()):
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    myMain.routesToOtherPages.myRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose(){
    myMain.routesToOtherPages.myRouteObserver.unsubscribe(this);
    super.dispose();
  }

  //RouteAware methods (didPopNext() and didPush()):
  @override
  void didPopNext(){
    //Called when returning to this page:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  @override
  void didPush(){
    //Called when the page is pushed:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  //build method
  Widget build(BuildContext bc){
    listOfDbuThreads = discussionBoardPage.discussionBoardUpdatesThreads;

    rebuildSublistsIfNecessary();

    var myPagesDbu = List.generate(
      numberOfPagesDbu,
          (index) => Center(
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: (mySublistsDbu.isNotEmpty && theCurrentPageDbu < mySublistsDbu.length) ? mySublistsDbu[theCurrentPageDbu].length : 0,//mySublistsDbu[theCurrentPageDbu].length,//mySublistsDbu[theCurrentPageDbu].length,//discussionBoardPage.discussionBoardUpdatesThreads.length,//discussionBoardUpdatesThreads.reversed.toList().length,
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
                      child: AbsorbPointer(
                        absorbing: clickThread,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
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
                                    child: AbsorbPointer(
                                      absorbing: clickUsername,
                                      child: Text.rich(
                                        TextSpan(
                                          text: "${mySublistsDbu[theCurrentPageDbu][index]["threadTitle"].toString()}\nBy: ",
                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, height: 1.1),
                                          children: [
                                            TextSpan(
                                                text: "${mySublistsDbu[theCurrentPageDbu][index]["poster"].toString()}",
                                                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue, fontWeight: FontWeight.normal, height: 1.1),
                                                recognizer: TapGestureRecognizer()..onTap = () async {
                                                  if(clickUsername){
                                                    return;
                                                  }

                                                  setState(() => clickUsername = true);

                                                  dbuClickedOnUser = true;

                                                  if(firebaseDesktopHelper.onDesktop){
                                                    nameData = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                    theUsersData = nameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsDbu[theCurrentPageDbu][index]["poster"].toString().toLowerCase(), orElse: () => <String, dynamic>{});
                                                  }
                                                  else{
                                                    nameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsDbu[theCurrentPageDbu][index]["poster"].toString().toLowerCase()).get();
                                                    nameData.docs.forEach((person){
                                                      theUsersData = person.data();
                                                    });
                                                  };

                                                  print("This is nameData: ${nameData}");
                                                  //print("This is the poster: ${mySublistsDbu[theCurrentPageDbu][index]["poster"].toString()}"),
                                                  print("This is theUsersData: ${theUsersData}");

                                                  //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                                  if(theUsersData?.isEmpty ?? true){
                                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => nonexistentUser())).then((_){
                                                      if(mounted){
                                                        setState(() => clickUsername = false);
                                                      }
                                                    });
                                                  }
                                                  else{
                                                    theUsernameResult = mySublistsDbu[theCurrentPageDbu][index]["poster"].toString();
                                                    fromDbuPage = true;
                                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())).then((_){
                                                      if(mounted){
                                                        setState(() => clickUsername = false);
                                                      }
                                                    });
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
                                ),
                              ]
                          ),
                          onPressed: () async{
                            if(clickThread){
                              return;
                            }

                            setState(() => clickThread = true);

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

                            if(mounted){
                              setState(() => clickThread = false);
                            }
                          }
                        ),
                      ),
                    ),
                  ),
                  index == mySublistsDbu[theCurrentPageDbu].length - 1? Container(
                    height: MediaQuery.of(context).size.height * 0.015625,
                  ):
                  Container(),
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
          Container(
            child: Text("Looking for a specific thread? Use the search bar below.", textAlign: TextAlign.center),
          ),
          Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015625),
            child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: dbuQuery,
                readOnly: true,
                focusNode: FocusNode(canRequestFocus: false),
                onTap: (){
                  print("List of dbu threads: ${listOfDbuThreads}");
                  myMain.myAccessCheckNotifier.value = DateTime.now();
                  showSearch(
                    context: context,
                    delegate: myDbuSearch(),
                  );
                }
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Center(
            child: AbsorbPointer(
              absorbing: createThreadButton,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: InkWell(
                  child: Ink(
                    color: Colors.black,
                    child: Text("Post New Thread", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white), textAlign: TextAlign.center),
                  ),
                ),
                onPressed: (){
                  if(createThreadButton){
                    return;
                  }

                  setState(() => createThreadButton = true);

                  print(discussionBoardUpdatesBool);
                  discussionBoardUpdatesBool = true;
                  print(discussionBoardUpdatesBool);
                  dbuNavigationDepth++;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const createThread()));
                  print("I am going to write a new thread.");

                  if(mounted){
                    setState(() => createThreadButton = false);
                  }
                }
              ),
            ),
          ),
          Expanded(
            child: listOfDbuThreads.length != 0? myPagesDbu[theCurrentPageDbu] : Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.031250, MediaQuery.of(context).size.height * 0.031250, MediaQuery.of(context).size.width * 0.031250, 0.0), child: Text("There are no threads in this subforum yet. Be the first to post a thread!", textAlign: TextAlign.center),),//myPagesDbu[theCurrentPageDbu],
          ),
          NumberPaginator(
              initialPage: theCurrentPageDbu,
              //height: MediaQuery.of(context).size.height * 0.0782125,
              numberPages: listOfDbuThreads.length != 0? numberOfPagesDbu : 1,//numberOfPagesDbu,
              onPageChange: (myIndexDbu){
                setState((){
                  theCurrentPageDbu = myIndexDbu;
                  print("theCurrentPageDbu: ${theCurrentPageDbu}, myIndexDbu: ${myIndexDbu}");
                });
              }
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
        ],
      ),
    );
  }
}

class discussionBoardUpdatesThreadContent extends State<discussionBoardUpdatesThreadsPage> with RouteAware{
  int numberOfPagesDbuThreadReplies = 0;
  //int theCurrentPageDbuThreadReplies = 0;

  var listOfDbuThreadReplies;
  var mySublistsDbuThreadReplies = [];
  int portionSizeDbuThreadReplies = 10;

  int myPaginatorResetValue = 0;
  int previousDataLength = -1;

  bool clickUsername = false;
  bool replyButton = false;

  Document buildMyDocumentFromDbuThreadContent(String myRawContent){
    try{
      return Document.fromJson(jsonDecode(myRawContent));
    }
    catch (e){
      //For older formats (the raw content is in plain text instead of JSON):
      return Document.fromJson([{"insert": "${myRawContent}\n"}]);
    }
  }

  Document buildMyDocumentFromDbuReplyContent(String myRawContent){
    try{
      return Document.fromJson(jsonDecode(myRawContent));
    }
    catch (e){
      //For older formats (the raw content is in plain text instead of JSON):
      return Document.fromJson([{"insert": "${myRawContent}\n"}]);
    }
  }

  //Lifecycle methods (didChangeDependencies() and dispose()):
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    myMain.routesToOtherPages.myRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose(){
    myMain.routesToOtherPages.myRouteObserver.unsubscribe(this);
    super.dispose();
  }

  //RouteAware methods (didPopNext() and didPush()):
  @override
  void didPopNext(){
    //Called when returning to this page:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  @override
  void didPush(){
    //Called when the page is pushed:
    myMain.myAccessCheckNotifier.value = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    listOfDbuThreadReplies = theDbuThreadReplies;

    int currentDataLength = listOfDbuThreadReplies?.length ?? 0;

    if(previousDataLength != currentDataLength){
      previousDataLength = currentDataLength;
      //Clearing outdated sublists:
      mySublistsDbuThreadReplies.clear();

      if(currentDataLength == 0){
        numberOfPagesDbuThreadReplies = 1;
      }
      else{
        numberOfPagesDbuThreadReplies = (((theDbuThreadReplies.length)/10)).ceil();

        for(int i = 0; i < listOfDbuThreadReplies.length; i += portionSizeDbuThreadReplies){
          mySublistsDbuThreadReplies.add(listOfDbuThreadReplies.sublist(i, i + portionSizeDbuThreadReplies > listOfDbuThreadReplies.length ? listOfDbuThreadReplies.length : i + portionSizeDbuThreadReplies));
        }
      }
    }

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
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.tealAccent),
                                overlayColor: MaterialStateProperty.all(Colors.transparent),
                                splashFactory: NoSplash.splashFactory,
                                elevation: MaterialStateProperty.all(0),
                                shadowColor: MaterialStateProperty.all(Colors.transparent),
                                minimumSize: MaterialStateProperty.all(Size.zero),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Container(
                                child: AbsorbPointer(
                                  absorbing: clickUsername,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Reply to:\n", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),

                                      //Reply content:
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          textTheme: Theme.of(context).textTheme.apply(
                                            bodyColor: Colors.black,
                                            displayColor: Colors.black,
                                          ),
                                        ),
                                        child: QuillEditor(
                                          controller: QuillController(
                                            document: buildMyDocumentFromDbuReplyContent(mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["theOriginalReplyInfo"]["replyContent"].toString()),
                                            selection: TextSelection.collapsed(offset: 0),
                                            readOnly: true,
                                          ),
                                          focusNode: FocusNode(),
                                          scrollController: ScrollController(),
                                          config: QuillEditorConfig(
                                            padding: EdgeInsets.zero,
                                            embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                                            customStyles: DefaultStyles(
                                              paragraph: DefaultTextBlockStyle(
                                                TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                                HorizontalSpacing.zero,
                                                VerticalSpacing.zero,
                                                VerticalSpacing.zero,
                                                null,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                          text: "\nPosted by: ",
                                          children: <TextSpan>[
                                            TextSpan(
                                                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue, fontWeight: FontWeight.normal),
                                                text: "${mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString()}",
                                                recognizer: TapGestureRecognizer()..onTap = () async {
                                                  if(clickUsername){
                                                    return;
                                                  }

                                                  setState(() => clickUsername = true);

                                                  dbuClickedOnUser = true;

                                                  if(firebaseDesktopHelper.onDesktop){
                                                    nameData = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                    theUsersData = nameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString().toLowerCase(), orElse: () => <String, dynamic>{});
                                                  }
                                                  else{
                                                    nameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString().toLowerCase()).get();
                                                    nameData.docs.forEach((person){
                                                      theUsersData = person.data();
                                                    });
                                                  };
                                                  //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                                  if(theUsersData?.isEmpty ?? true){
                                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => nonexistentUser())).then((_){
                                                      if(mounted){
                                                        setState(() => clickUsername = false);
                                                      }
                                                    });
                                                  }
                                                  else{
                                                    theUsernameResult = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["theOriginalReplyInfo"]["replier"].toString();
                                                    fromDbuThread = true;
                                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())).then((_){
                                                      if(mounted){
                                                        setState(() => clickUsername = false);
                                                      }
                                                    });
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
                                    ],
                                  ),
                                ),
                                color: Colors.tealAccent, //theDbuThreadReplies[index]["theOriginalReplyInfo"].toString(), theDbuThreadReplies[index]["theOriginalReplyInfo"].toString()
                                width: MediaQuery.of(context).size.width * 0.5,
                              ),
                              onPressed: (){
                                //Does nothing
                              }
                          ),
                          //if(discussionBoardUpdatesThreads[int.parse(threadID)][4] != null)
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.grey[300]),
                                overlayColor: MaterialStateProperty.all(Colors.transparent),
                                splashFactory: NoSplash.splashFactory,
                                elevation: MaterialStateProperty.all(0),
                                shadowColor: MaterialStateProperty.all(Colors.transparent),
                                minimumSize: MaterialStateProperty.all(Size.zero),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Container(
                                child: AbsorbPointer(
                                  absorbing: clickUsername,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      //Reply content:
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          textTheme: Theme.of(context).textTheme.apply(
                                            bodyColor: Colors.black,
                                            displayColor: Colors.black,
                                          ),
                                        ),
                                        child: QuillEditor(
                                          controller: QuillController(
                                            document: buildMyDocumentFromDbuReplyContent(mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replyContent"].toString()),
                                            selection: TextSelection.collapsed(offset: 0),
                                            readOnly: true,
                                          ),
                                          focusNode: FocusNode(),
                                          scrollController: ScrollController(),
                                          config: QuillEditorConfig(
                                            padding: EdgeInsets.zero,
                                            embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                                            customStyles: DefaultStyles(
                                              paragraph: DefaultTextBlockStyle(
                                                TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                                HorizontalSpacing.zero,
                                                VerticalSpacing.zero,
                                                VerticalSpacing.zero,
                                                null,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      //Time and author of reply:
                                      Text.rich(
                                        TextSpan(
                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                          text: "\nPosted on: ${firebaseDesktopHelper.formatMyTimestamp(mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["time"].toString())}\nPosted by: ",
                                          children: <TextSpan>[
                                            TextSpan(
                                                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue, fontWeight: FontWeight.normal),
                                                text: "${mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString()}",
                                                recognizer: TapGestureRecognizer()..onTap = () async {
                                                  if(clickUsername){
                                                    return;
                                                  }

                                                  setState(() => clickUsername = true);

                                                  dbuClickedOnUser = true;
                                                  if(firebaseDesktopHelper.onDesktop){
                                                    nameData = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                    theUsersData = nameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString().toLowerCase(), orElse: () => <String, dynamic>{});
                                                  }
                                                  else{
                                                    nameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString().toLowerCase()).get();
                                                    nameData.docs.forEach((person){
                                                      theUsersData = person.data();
                                                    });
                                                  };
                                                  //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())),
                                                  if(theUsersData?.isEmpty ?? true){
                                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => nonexistentUser())).then((_){
                                                      if(mounted){
                                                        setState(() => clickUsername = false);
                                                      }
                                                    });
                                                  }
                                                  else{
                                                    theUsernameResult = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString();
                                                    fromDbuThread = true;
                                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())).then((_){
                                                      if(mounted){
                                                        setState(() => clickUsername = false);
                                                      }
                                                    });
                                                  }
                                                }
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                                color: Colors.grey[300],
                                width: MediaQuery.of(context).size.width * 0.5,
                              ),
                              onPressed: (){
                                //Does nothing
                              }
                          ),
                          AbsorbPointer(
                            absorbing: replyButton,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[500],
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
                                if(replyButton){
                                  return;
                                }

                                setState(() => replyButton = true);

                                replyPosterUserIsReplyingToDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString();
                                contentOfReplyUserIsReplyingToDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replyContent"].toString();
                                titleOfThreadUserIsReplyingToDbu = threadTitleDbu;

                                replyToReplyTimeDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["time"];//.toString();
                                replyToReplyContentDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["replyContent"].toString();
                                replyToReplyPosterDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["replier"].toString();

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
                                    print(replyToReplyDocDbu);
                                  });
                                }

                                print(theDbuThreadReplies);
                                print(replyToReplyDocDbu);

                                if(firebaseDesktopHelper.onDesktop){
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
                                myReplyToReplyDbuMap = Map.from(myReplyToReplyDbu);

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
                                if(!mounted){
                                  return;
                                }

                                if(myResult == true){
                                  setState((){
                                    theCurrentPageDbuThreadReplies = 0;
                                    myPaginatorResetValue++;
                                  });
                                }

                                setState(() => replyButton = false);
                              }
                            ),
                          ),
                          index == mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies].length - 1? Container(
                            height: MediaQuery.of(context).size.height * 0.015625,
                          ):
                          Container(),
                        ]
                    ): Column(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * 0.015625,
                          ),
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.grey[300]),
                                overlayColor: MaterialStateProperty.all(Colors.transparent),
                                splashFactory: NoSplash.splashFactory,
                                elevation: MaterialStateProperty.all(0),
                                shadowColor: MaterialStateProperty.all(Colors.transparent),
                                minimumSize: MaterialStateProperty.all(Size.zero),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Container(
                                child: AbsorbPointer(
                                  absorbing: clickUsername,
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        //Reply content:
                                        Theme(
                                          data: Theme.of(context).copyWith(
                                            textTheme: Theme.of(context).textTheme.apply(
                                              bodyColor: Colors.black,
                                              displayColor: Colors.black,
                                            ),
                                          ),
                                          child: QuillEditor(
                                            controller: QuillController(
                                              document: buildMyDocumentFromDbuReplyContent(mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replyContent"].toString()),
                                              selection: TextSelection.collapsed(offset: 0),
                                              readOnly: true,
                                            ),
                                            focusNode: FocusNode(),
                                            scrollController: ScrollController(),
                                            config: QuillEditorConfig(
                                              padding: EdgeInsets.zero,
                                              embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                                              customStyles: DefaultStyles(
                                                paragraph: DefaultTextBlockStyle(
                                                  TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                                  HorizontalSpacing.zero,
                                                  VerticalSpacing.zero,
                                                  VerticalSpacing.zero,
                                                  null,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        //Time and author of reply:
                                        Text.rich(
                                          TextSpan(
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                            text: "\nPosted on: ${firebaseDesktopHelper.formatMyTimestamp(mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["time"].toString())}\nPosted by: ",
                                            children: <TextSpan>[
                                              TextSpan(
                                                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue, fontWeight: FontWeight.normal),
                                                  text: "${mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString()}",
                                                  recognizer: TapGestureRecognizer()..onTap = () async {
                                                    if(clickUsername){
                                                      return;
                                                    }

                                                    setState(() => clickUsername = true);

                                                    dbuClickedOnUser = true;

                                                    if(firebaseDesktopHelper.onDesktop){
                                                      nameData = await firebaseDesktopHelper.getFirestoreCollection("User");
                                                      theUsersData = nameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString().toLowerCase(), orElse: () => <String, dynamic>{});
                                                      print("theUsersData is this on Desktop: ${theUsersData}");
                                                    }
                                                    else{
                                                      nameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString().toLowerCase()).get();
                                                      nameData.docs.forEach((person){
                                                        theUsersData = person.data();
                                                      });
                                                    };

                                                    if(theUsersData?.isEmpty ?? true){
                                                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => nonexistentUser())).then((_){
                                                      if(mounted){
                                                        setState(() => clickUsername = false);
                                                        }
                                                      });
                                                    }
                                                    else{
                                                      theUsernameResult = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString();
                                                      fromDbuThread = true;
                                                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())).then((_){
                                                        if(mounted){
                                                          setState(() => clickUsername = false);
                                                        }
                                                      });
                                                    }
                                                  }
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]
                                  ),
                                ),
                                color: Colors.grey[300],
                                width: MediaQuery.of(context).size.width * 0.5,
                              ),
                              onPressed: (){
                                //Does nothing
                              }
                          ),
                          AbsorbPointer(
                            absorbing: replyButton,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[500],
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
                                  if(replyButton){
                                    return;
                                  }

                                  setState(() => replyButton = true);

                                  replyPosterUserIsReplyingToDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replier"].toString();
                                  contentOfReplyUserIsReplyingToDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][index]["replyContent"].toString();
                                  titleOfThreadUserIsReplyingToDbu = threadTitleDbu;

                                  replyToReplyTimeDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["time"];//.toString();
                                  replyToReplyContentDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["replyContent"].toString();
                                  replyToReplyPosterDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies]![index]["replier"].toString();
                                  print("This is replyToReplyTime: $replyToReplyTimeDbu");

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
                                      print(replyToReplyDocDbu);
                                    });
                                  }

                                  print(theDbuThreadReplies);
                                  print(replyToReplyDocDbu);

                                  if(firebaseDesktopHelper.onDesktop){
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

                                  myIndex = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeDbu);
                                  //where replyToReplyDoc is in theDbuThreadReplies.
                                  print(mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies].indexWhere((i) => i["time"] == replyToReplyTimeDbu));
                                  myReplyToReplyDbu = mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies][myIndex];

                                  myReplyToReplyDbuMap = Map.from(myReplyToReplyDbu);

                                  List<dynamic> tempReplyToReplyList = [replyToReplyContentDbu, replyToReplyPosterDbu, myReplyToReplyDbuMap];
                                  dbuRepliesToReplies.add(tempReplyToReplyList);

                                  print("myReplyToReplyDbuMap: ${myReplyToReplyDbuMap}");

                                  print("myReplyToReplyDbu: ${myReplyToReplyDbu["replyContent"]}");
                                  print("This is myIndex: $myIndex");
                                  discussionBoardUpdatesReplyBool = true;
                                  discussionBoardUpdatesReplyingToReplyBool = true;
                                  dbuNavigationDepth++;

                                  final myResult = await Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));

                                  if(!mounted){
                                    return;
                                  }

                                  //Refreshing the page after returning from a reply:
                                  if(myResult == true){
                                    setState((){
                                      theCurrentPageDbuThreadReplies = 0;
                                      myPaginatorResetValue++;
                                    });
                                  }
                                  setState(() => replyButton = false);
                                }
                              ),
                          ),
                          index == mySublistsDbuThreadReplies[theCurrentPageDbuThreadReplies].length - 1? Container(
                            height: MediaQuery.of(context).size.height * 0.015625,
                          ):
                          Container(),
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
              print("We're going backwards. This is the depth: ${dbuNavigationDepth}"),

              if(Navigator.canPop(context)){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardUpdatesPage())),
              },

              theCurrentPageDbuThreadReplies = 0,
              dbuNavigationDepth = 0,
            }
        ),
      ),
      body: SingleChildScrollView(
        child: Wrap(
          children: <Widget>[
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.031250),
                      child: AbsorbPointer(
                        absorbing: clickUsername,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${threadTitleDbu}\n", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),

                            //The thread content:
                            Theme(
                              data: Theme.of(context).copyWith(
                                textTheme: Theme.of(context).textTheme.apply(
                                  bodyColor: Colors.black,
                                  displayColor: Colors.black,
                                ),
                              ),
                              child: QuillEditor(
                                controller: QuillController(
                                  document: buildMyDocumentFromDbuThreadContent(threadContentDbu),
                                  selection: TextSelection.collapsed(offset: 0),
                                  readOnly: true,
                                ),
                                focusNode: FocusNode(),
                                scrollController: ScrollController(),
                                config: QuillEditorConfig(
                                  padding: EdgeInsets.zero,
                                  embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                                  customStyles: DefaultStyles(
                                    paragraph: DefaultTextBlockStyle(
                                      TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                                      HorizontalSpacing.zero,
                                      VerticalSpacing.zero,
                                      VerticalSpacing.zero,
                                      null,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            //Author of thread:
                            Text.rich(
                              TextSpan(
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                text: "\nPosted by: ",
                                children: <TextSpan>[
                                  TextSpan(
                                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue, fontWeight: FontWeight.normal),
                                      text: "${threadAuthorDbu}",
                                      recognizer: TapGestureRecognizer()..onTap = () async {
                                        if(clickUsername){
                                          return;
                                        }

                                        setState(() => clickUsername = true);

                                        dbuClickedOnUser = true;

                                        if(firebaseDesktopHelper.onDesktop){
                                          nameData = await firebaseDesktopHelper.getFirestoreCollection("User");
                                          theUsersData = nameData.firstWhere((myUser) => myUser["usernameLowercased"].toString() == threadAuthorDbu.toLowerCase(), orElse: () => <String, dynamic>{});
                                        }
                                        else{
                                          nameData = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: threadAuthorDbu.toLowerCase()).get();
                                          nameData.docs.forEach((person){
                                            theUsersData = person.data();
                                          });
                                        };

                                        if(theUsersData?.isEmpty ?? true){
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => nonexistentUser())).then((_){
                                            if(mounted){
                                              setState(() => clickUsername = false);
                                            }
                                          });
                                        }
                                        else{
                                          theUsernameResult = threadAuthorDbu;
                                          fromDbuThread = true;
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => userProfileInOtherUsersPerspective())).then((_){
                                            if(mounted){
                                              setState(() => clickUsername = false);
                                            }
                                          });
                                        }
                                      }
                                  ),
                                ],
                              ),
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
            AbsorbPointer(
              absorbing: replyButton,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[500],
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: InkWell(
                  child: Ink(
                    color: Colors.grey[500],
                    height: MediaQuery.of(context).size.height * 0.02734375,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text("Reply to thread", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal), textAlign: TextAlign.center,),
                    ),
                  ),
                ),
                onPressed: () async {
                  if(replyButton){
                    return;
                  }

                  setState(() => replyButton = true);

                  threadPosterUserIsReplyingToDbu = threadAuthorDbu;
                  titleOfThreadUserIsReplyingToDbu = threadTitleDbu;
                  print("Pages length: ${myPagesDbuThreadReplies.length}");

                  discussionBoardUpdatesReplyingToReplyBool = false;
                  discussionBoardUpdatesReplyBool = true;
                  dbuNavigationDepth++;
                  print(reversedDiscussionBoardUpdatesThreadsIterable.toList());
                  print(threadID);

                  final myResult = await Navigator.push(context, MaterialPageRoute(builder: (context) => const replyThreadPage()));

                  if(!mounted){
                    return;
                  }

                  //Refreshing the page after returning from a reply:
                  if(myResult == true){
                    setState((){
                      theCurrentPageDbuThreadReplies = 0;
                      myPaginatorResetValue++;
                    });
                  }

                  setState(() => replyButton = false);

                  print('Replying to the thread');
                }
              ),
            ),
            Center(
              child: (myPagesDbuThreadReplies.isNotEmpty && theCurrentPageDbuThreadReplies < myPagesDbuThreadReplies.length && mySublistsDbuThreadReplies.isNotEmpty)? myPagesDbuThreadReplies[theCurrentPageDbuThreadReplies] : Container(padding: EdgeInsets.fromLTRB(0.0, MediaQuery.of(context).size.height * 0.015625, 0.0, MediaQuery.of(context).size.height * 0.015625), child: Text("There are no replies to this thread yet. Be the first to reply!", textAlign: TextAlign.center),),
            ),
            NumberPaginator(
              initialPage: theCurrentPageDbuThreadReplies,
              numberPages: listOfDbuThreadReplies.length != 0? numberOfPagesDbuThreadReplies : 1,
              onPageChange: (myIndexDbuThreadReplies){
                setState((){
                  theCurrentPageDbuThreadReplies = myIndexDbuThreadReplies;
                });
              }
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.015625,
            ),
          ],
        ),
      ),
    );
  }
}