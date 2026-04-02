import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:starexpedition4/settingsPage.dart';
import 'package:starexpedition4/spectralClassPage.dart';

import 'package:starexpedition4/main.dart' as myMain;
import 'package:starexpedition4/discussionBoardPage.dart';
import 'package:starexpedition4/loginPage.dart';
import 'package:starexpedition4/registerPage.dart';
import 'package:starexpedition4/loginPage.dart' as theLoginPage;
import 'package:flutter/services.dart' show MaxLengthEnforcement, rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';
import 'package:starexpedition4/userSearchBar.dart';

import 'discussionBoardUpdatesPage.dart';
import 'newDiscoveriesPage.dart';
import 'projectsPage.dart';
import 'questionsAndAnswersPage.dart';
import 'technologiesPage.dart';
import 'feedbackAndSuggestionsPage.dart';

import 'package:starexpedition4/firebaseDesktopHelper.dart';

import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';

var myInformation;
var myInterests;
var myLocation;
var dataOfUser;
var myDocName;
var userInformation;

bool fromUserProfileInUserPerspective = false;
bool fromUserProfileInOtherUsersPerspective = false;

bool whitespaceChecker(String? myString){
  if(myString == null){
    return true;
  }

  //Removing unicode characters that are invisible and missed by the trim() method:
  final cleaned = myString.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u00A0]'), "");

  return cleaned.trim().isEmpty;
}

//For profile pictures:
//Choosing the image from a gallery:
Future<Uint8List?> chooseProfilePicture() async{
  if(!firebaseDesktopHelper.onDesktop){
    final XFile? pickedPicture = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );

    if(pickedPicture == null){
      return null;
    }

    return await pickedPicture.readAsBytes();
  }

  const myTypeGroup = XTypeGroup(label: "Images", extensions: ["png", "jpg", "jpeg", "webp"],);

  final XFile? myFile = await openFile(acceptedTypeGroups: [myTypeGroup]);

  if(myFile == null){
    return null;
  }

  return await myFile.readAsBytes();
}

//Converting the image to Base64 and saving it to Firestore:
Future<void> uploadAndStoreProfilePicture(Uint8List myBytes, String nameOfUser) async{
  var myInformation;
  var usersData;
  var docsName;
  final myBase64Image = base64Encode(myBytes);

  if(firebaseDesktopHelper.onDesktop){
    List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

    var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == nameOfUser.toLowerCase(), orElse: () => <String, dynamic>{});

    docsName = usersProfileInfo["docId"];

    //Getting the user's current profile information:
    Map<String, dynamic> usersCurrentInfo = Map<String, dynamic>.from(usersProfileInfo["usernameProfileInformation"]);
    usersCurrentInfo["userProfilePicture"] = myBase64Image;

    //Updating the user's profile picture:
    await firebaseDesktopHelper.updateFirestoreDocument("User/${docsName}", {
      "usernameProfileInformation": usersCurrentInfo,
    });
  }
  else{
    myInformation = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: nameOfUser.toLowerCase()).get();
    myInformation.docs.forEach((myResult){
      usersData = myResult.data();
      docsName = myResult.id;
    });

    await FirebaseFirestore.instance.collection("User").doc(docsName).update({"usernameProfileInformation.userProfilePicture": myBase64Image});
  }
}

Future<void> removeProfilePicture(String nameOfUser) async{
  var myInformation;
  var usersData;
  var docsName;

  if(firebaseDesktopHelper.onDesktop){
    List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

    var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == nameOfUser.toLowerCase(), orElse: () => <String, dynamic>{});

    docsName = usersProfileInfo["docId"];

    //Getting the user's current profile information:
    Map<String, dynamic> usersCurrentInfo = Map<String, dynamic>.from(usersProfileInfo["usernameProfileInformation"]);
    usersCurrentInfo["userProfilePicture"] = "";

    //Updating the user's profile picture:
    await firebaseDesktopHelper.updateFirestoreDocument("User/${docsName}", {
      "usernameProfileInformation": usersCurrentInfo,
    });
  }
  else{
    myInformation = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: nameOfUser.toLowerCase()).get();
    myInformation.docs.forEach((myResult){
      usersData = myResult.data();
      docsName = myResult.id;
    });

    await FirebaseFirestore.instance.collection("User").doc(docsName).update({"usernameProfileInformation.userProfilePicture": ""});
  }
}

class userProfilePage extends StatefulWidget{
  const userProfilePage ({Key? key}) : super(key: key);

  @override
  userProfilePageState createState() => userProfilePageState();
}

class userProfilePageState extends State<userProfilePage>{
  String nameOfRoute = '/userProfilePage';

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () =>{
              Navigator.push(bc, MaterialPageRoute(builder: (BuildContext context) => myMain.StarExpedition())),
            }
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            child: Text("User Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
              child: Text("User")
          ),
          InkWell(
              child: Ink(
                child: Container(
                  child: Text("Edit My User Profile", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  color: Colors.black,
                ),
              ),
              onTap: (){
                print("Button clicked!");
              }
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            child: Text("Information about me", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
          ),
          Container(
            child: Text(""),
          ),
        ],
      ),
    );
  }
}

class editingMyUserProfile extends StatefulWidget{
  const editingMyUserProfile({Key? key}): super(key: key);

  @override
  editingMyUserProfileState createState() => editingMyUserProfileState();
}

class editingMyUserProfileState extends State<editingMyUserProfile>{
  TextEditingController informationAboutMyselfController = TextEditingController();
  TextEditingController interestsController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  final FocusNode myFieldFocus = FocusNode();

  //For profile pictures:
  Uint8List? myImageBytes;
  bool isSaving = false;
  bool holdingRemovalOfPicture = false;

  //Loading existing photo from Firestore when user arrives on the page:
  Future<void> loadMyProfilePicture(String theUsersName) async{
    var usersData;
    var docsName;
    String? myBase64String;

    if(myUsername != "" && myNewUsername == ""){
      theUsersName = myUsername;
    }
    else if(myUsername == "" && myNewUsername != ""){
      theUsersName = myNewUsername;
    }

    if(firebaseDesktopHelper.onDesktop){
      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

      var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == theUsersName.toLowerCase(), orElse: () => <String, dynamic>{});

      myBase64String = usersProfileInfo["usernameProfileInformation"]?["userProfilePicture"] as String?;
    }
    else{
      myInformation = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theUsersName.toLowerCase()).get();
      myInformation.docs.forEach((myResult){
        docsName = myResult.id;
      });

      final myDoc = await FirebaseFirestore.instance.collection("User").doc(docsName).get();

      myBase64String = myDoc["usernameProfileInformation"]["userProfilePicture"] as String?;
    }

    if(myBase64String != null && myBase64String.isNotEmpty){
      setState(() => myImageBytes = base64Decode(myBase64String!));
    }

    if(mounted){
      FocusScope.of(context).requestFocus(myFieldFocus);
    }
  }

  //Opens a user's gallery on his or her device:
  Future<void> handlingMyPick() async{
    final myBytes = await chooseProfilePicture();

    if(myBytes == null){
      return;
    }

    setState(() => myImageBytes = myBytes);

    /*if(myUsername != "" && myNewUsername == ""){
      await uploadAndStoreProfilePicture(myBytes, myUsername);
    }
    else if(myUsername == "" && myNewUsername != ""){
      await uploadAndStoreProfilePicture(myBytes, myNewUsername);
    }

    setState((){
      myImageBytes = myBytes;
      isSaving = false;
    });*/

  }

  @override
  void initState(){
    super.initState();

    informationAboutMyselfController.text = "${myMain.usersBlurb}";
    interestsController.text = "${myMain.usersInterests}";
    locationController.text = "${myMain.usersLocation}";

    String theNameOfUser = myUsername != "" && myNewUsername == ""? myUsername : myNewUsername;
    loadMyProfilePicture(theNameOfUser);

    //Requesting focus on the first text field after the page builds:
    WidgetsBinding.instance.addPostFrameCallback((_){
      FocusScope.of(context).requestFocus(myFieldFocus);
    });
  }

  @override
  void dispose(){
    myFieldFocus.dispose();
    super.dispose();
  }

  Widget build(BuildContext context){
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Star Expedition"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () =>{
                holdingRemovalOfPicture = false,
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => settingsPage())),
                print("Going back to settings page"),
              }
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.015625,
                ),
                Container(
                  child: Text("Editing Your Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.015625,
                ),
                IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Flexible(
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.015625, MediaQuery.of(context).size.height * 0.031250, MediaQuery.of(context).size.width * 0.015625, 0.0),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
                                ),
                                child: Scrollbar(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    reverse: true,
                                    child: SizedBox(
                                      child: TextField(
                                        minLines: 5,
                                        maxLines: 5,
                                        focusNode: myFieldFocus,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: "Information about yourself",
                                          //contentPadding: EdgeInsets.symmetric(vertical: 80),
                                        ),
                                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                        controller: informationAboutMyselfController,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]
                  ),
              ),
              IntrinsicHeight(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.015625, MediaQuery.of(context).size.height * 0.031250, MediaQuery.of(context).size.width * 0.015625, 0.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
                              ),
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  reverse: true,
                                  child: SizedBox(
                                    child: TextField(
                                      minLines: 5,
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Your interests",
                                      ),
                                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                      controller: interestsController,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                ),
              ),
              IntrinsicHeight(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.015625, MediaQuery.of(context).size.height * 0.031250, MediaQuery.of(context).size.width * 0.015625, 0.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
                              ),
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  reverse: true,
                                  child: SizedBox(
                                    child: TextField(
                                      minLines: 5,
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Your location",
                                      ),
                                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                      controller: locationController,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                ),
              ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.015625,
                ),
                CircleAvatar(
                  radius: 80,
                  backgroundImage: (myImageBytes != null && !holdingRemovalOfPicture) ? MemoryImage(myImageBytes!) : null,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.015625,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.015625, MediaQuery.of(context).size.height * 0.031250, MediaQuery.of(context).size.width * 0.015625, 0.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                      ),
                      child: InkWell(
                        child: Ink(
                          color: Colors.black,
                          child: Text("Update Profile Picture", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                        ),
                      ),
                      onPressed: () async{
                        holdingRemovalOfPicture = false;
                        handlingMyPick();
                      }
                  ),
                ),
                /*Container(
                  height: MediaQuery.of(context).size.height * 0.015625,
                ),*/
                if((hasProfilePicture == true || myImageBytes != null) && holdingRemovalOfPicture == false)
                  Padding(
                  padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.015625, MediaQuery.of(context).size.height * 0.031250, MediaQuery.of(context).size.width * 0.015625, 0.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                      ),
                      child: InkWell(
                        child: Ink(
                          color: Colors.black,
                          child: Text("Remove Profile Picture", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                        ),
                      ),
                      onPressed: () async{
                        setState((){
                          holdingRemovalOfPicture = true;
                        });
                      }
                  ),
                ),
                /*Container(
                  height: MediaQuery.of(context).size.height * 0.015625,
                ),*/
                Padding(
                  padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.015625, MediaQuery.of(context).size.height * 0.031250, MediaQuery.of(context).size.width * 0.015625, 0.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                      ),
                      child: InkWell(
                        child: Ink(
                          color: Colors.black,
                          //padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015625),
                          child: Text("Update Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                        ),
                      ),
                      onPressed: () async{
                        final theUsername = myUsername != "" && myNewUsername == "" ? myUsername : myNewUsername;

                        if(myImageBytes != null){
                          await uploadAndStoreProfilePicture(myImageBytes!, theUsername);
                        }

                        if(holdingRemovalOfPicture == true){
                          if(myUsername != "" && myNewUsername == ""){
                            removeProfilePicture(myUsername);
                          }
                          else if(myUsername == "" && myNewUsername != ""){
                            removeProfilePicture(myNewUsername);
                          }
                          holdingRemovalOfPicture = false;
                          hasProfilePicture == false;
                        }

                        if(myUsername != "" && myNewUsername == ""){
                          if(firebaseDesktopHelper.onDesktop){
                            List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                            var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                            myDocName = usersProfileInfo["docId"];

                            //Getting the current profile info of the user:
                            Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(usersProfileInfo["usernameProfileInformation"] ?? {});

                            currentInfoOfUser["userInformation"] = informationAboutMyselfController.text;
                            currentInfoOfUser["userInterests"] = interestsController.text;
                            currentInfoOfUser["userLocation"] = locationController.text;

                            //Seeing what is in currentInfoOfUser:
                            print("User information: ${currentInfoOfUser["userInformation"]}");
                            print("User interests: ${currentInfoOfUser["userInterests"]}");
                            print("User location: ${currentInfoOfUser["userLocation"]}");

                            //Updating a user's changes:
                            await firebaseDesktopHelper.updateFirestoreDocument("User/$myDocName", {
                              "usernameProfileInformation": currentInfoOfUser,
                            });
                          }
                          else{
                            myInformation = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                            myInformation.docs.forEach((myResult){
                              dataOfUser = myResult.data();
                              myDocName = myResult.id;
                            });

                            FirebaseFirestore.instance.collection("User").doc(myDocName).update({
                              "usernameProfileInformation.userInformation": informationAboutMyselfController.text,
                            }).then((i){
                              print("You have updated the user information (for already existing users)!");
                            });

                            myInterests = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                            myInterests.docs.forEach((myResult){
                              dataOfUser = myResult.data();
                              myDocName = myResult.id;
                            });

                            FirebaseFirestore.instance.collection("User").doc(myDocName).update({
                              "usernameProfileInformation.userInterests": interestsController.text,
                            }).then((i){
                              print("You have updated the user interests (for already existing users)!");
                            });

                            myLocation = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                            myLocation.docs.forEach((myResult){
                              dataOfUser = myResult.data();
                              myDocName = myResult.id;
                            });

                            FirebaseFirestore.instance.collection("User").doc(myDocName).update({
                              "usernameProfileInformation.userLocation": locationController.text,
                            }).then((i){
                              print("You have updated the user location (for already existing users)!");
                            });
                          }

                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => settingsPage()));
                        }
                        else if(myUsername == "" && myNewUsername != ""){
                          if(firebaseDesktopHelper.onDesktop){
                            List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                            var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                            myDocName = usersProfileInfo["docId"];

                            //Getting the current profile info of the user:
                            Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(usersProfileInfo["usernameProfileInformation"] ?? {});

                            currentInfoOfUser["userInformation"] = informationAboutMyselfController.text;
                            currentInfoOfUser["userInterests"] = interestsController.text;
                            currentInfoOfUser["userLocation"] = locationController.text;

                            //Seeing what is in currentInfoOfUser:
                            print("User information: ${currentInfoOfUser["userInformation"]}");
                            print("User interests: ${currentInfoOfUser["userInterests"]}");
                            print("User location: ${currentInfoOfUser["userLocation"]}");

                            //Updating a user's changes:
                            await firebaseDesktopHelper.updateFirestoreDocument("User/$myDocName", {
                              "usernameProfileInformation": currentInfoOfUser,
                            });
                          }
                          else{
                            myInformation = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                            myInformation.docs.forEach((myResult){
                              dataOfUser = myResult.data();
                              myDocName = myResult.id;
                            });

                            FirebaseFirestore.instance.collection("User").doc(myDocName).update({
                              "usernameProfileInformation.userInformation": informationAboutMyselfController.text,
                            }).then((j){
                              print("You have updated the user information (for new users)!");
                            });

                            myInterests = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                            myInformation.docs.forEach((myResult){
                              dataOfUser = myResult.data();
                              myDocName = myResult.id;
                            });

                            FirebaseFirestore.instance.collection("User").doc(myDocName).update({
                              "usernameProfileInformation.userInterests": interestsController.text,
                            }).then((j){
                              print("You have updated the user interests (for new users)!");
                            });

                            myLocation = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                            myLocation.docs.forEach((myResult){
                              dataOfUser = myResult.data();
                              myDocName = myResult.id;
                            });

                            FirebaseFirestore.instance.collection("User").doc(myDocName).update({
                              "usernameProfileInformation.userLocation": locationController.text,
                            }).then((j){
                              print("You have updated the user location (for new users)!");
                            });
                          }

                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => settingsPage()));
                        }
                      }
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.015625,
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class userProfileInUserPerspective extends StatefulWidget{
  const userProfileInUserPerspective ({Key? key}) : super(key: key);

  @override
  userProfileInUserPerspectiveState createState() => userProfileInUserPerspectiveState();
}

class userProfileInUserPerspectiveState extends State<userProfileInUserPerspective>{
  static String nameOfRoute = '/userProfileInUserPerspective';
  Uint8List? myImageBytes;

  myMain.myStars clickedStar = myMain.myStars(starName: "not available");

  @override
  void initState(){
    super.initState();
    loadProfilePictureInUsersPerspective();
  }

  Future<void> loadProfilePictureInUsersPerspective() async{
    final theUsersName = myUsername != "" && myNewUsername == "" ? myUsername : myNewUsername;
    var docsName;
    String? myBase64String;

    if(firebaseDesktopHelper.onDesktop){
      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");
      var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == theUsersName.toLowerCase(), orElse: () => <String, dynamic>{});
      myBase64String = usersProfileInfo["usernameProfileInformation"]?["userProfilePicture"] as String?;
    }
    else{
      final myResult = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: theUsersName.toLowerCase()).get();
      myResult.docs.forEach((myDoc) => docsName = myDoc.id);
      final myDoc = await FirebaseFirestore.instance.collection("User").doc(docsName).get();
      myBase64String = myDoc["usernameProfileInformation"]["userProfilePicture"] as String?;
    }

    if(myBase64String != null && myBase64String.isNotEmpty){
      setState(() => myImageBytes = base64Decode(myBase64String!));
    }
  }

  Widget build(BuildContext bc){
    List<String> informationAboutClickedStar = [];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () =>{
              Navigator.push(bc, MaterialPageRoute(builder: (BuildContext context) => myMain.StarExpedition())),
            }
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: myUsername != "" && myNewUsername == ""?
              Text("${myUsername}'s Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)):
              Text("${myNewUsername}'s Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
            ),
            Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),
            myImageBytes != null? CircleAvatar(
              radius: 80,
              backgroundImage: myImageBytes != null ? MemoryImage(myImageBytes!) : null,
            ): Container(),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nInformation About You:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: myUsername != "" && myNewUsername == ""?
                (myMain.usersBlurb != "" && whitespaceChecker(myMain.usersBlurb) == false? Text("${myMain.usersBlurb}", textAlign: TextAlign.center): Text("N/A", textAlign: TextAlign.center)):
                (myMain.usersBlurb != "" && whitespaceChecker(myMain.usersBlurb) == false? Text("${myMain.usersBlurb}", textAlign: TextAlign.center): Text("N/A", textAlign: TextAlign.center)),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nYour Interests:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: myUsername != "" && myNewUsername == ""?
                (myMain.usersInterests != "" && whitespaceChecker(myMain.usersInterests) == false? Text("${myMain.usersInterests}", textAlign: TextAlign.center): Text("N/A", textAlign: TextAlign.center)):
                (myMain.usersInterests != "" && whitespaceChecker(myMain.usersInterests) == false? Text("${myMain.usersInterests}", textAlign: TextAlign.center): Text("N/A", textAlign: TextAlign.center)),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nYour Location:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: myUsername != "" && myNewUsername == ""?
                (myMain.usersLocation != "" && whitespaceChecker(myMain.usersLocation) == false? Text("${myMain.usersLocation}", textAlign: TextAlign.center): Text("N/A", textAlign: TextAlign.center)):
                (myMain.usersLocation != "" && whitespaceChecker(myMain.usersLocation) == false? Text("${myMain.usersLocation}", textAlign: TextAlign.center): Text("N/A", textAlign: TextAlign.center)),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nTotal Posts on the Discussion Board:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("${myMain.numberOfPostsUserHasMade}", textAlign: TextAlign.center),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nStars Tracked:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            /*SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: ListView.builder(
                itemCount: myMain.starsUserTracked.length,
                shrinkWrap: true,
                itemBuilder: (bc, myIndexStars){
                  return Container(
                    child: Text("${myMain.starsUserTracked.keys}\n${myMain.starsUserTracked.values}\n\n"),
                  );
                }),
          ),*/
            Column(
              children: <Widget>[
                //var starsUserTrackedKeys = myMain.starsUserTracked.keys as List;
                if(!(myMain.starsUserTracked.isEmpty))
                  for(int s = 0; s < (myMain.starsUserTracked.keys.toList()).length; s++)
                    Column(
                      children: <Widget>[
                        GestureDetector(
                          child: Text("${myMain.starsUserTracked.keys.toList()[s]}", textAlign: TextAlign.center),
                          onTap: () async{
                            myMain.correctStar = myMain.starsUserTracked.keys.toList()[s];
                            print(myMain.correctStar);
                            clickedStar.starName = myMain.correctStar;
                            print(clickedStar.starName);

                            informationAboutClickedStar = await myMain.getStarInformation();
                            print(informationAboutClickedStar);
                            fromUserProfileInUserPerspective = true;

                            myMain.starFileContent = await myMain.readStarFile();
                            myMain.listOfStarUrls = myMain.starFileContent.replaceAll("\n", "").replaceAll("\r", "|").split("|");

                            myMain.listOfStarUrls.removeWhere((myUrl) => myUrl == "" || myUrl == " ");

                            //Is a user tracking this star?
                            if(myNewUsername != "" && myUsername == ""){
                              if(firebaseDesktopHelper.onDesktop){
                                List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                //var docNameForNewUsers = usersProfileInfo["docId"];

                                Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(usersProfileInfo["usernameProfileInformation"] ?? {});

                                myMain.starTracked = currentInfoOfNewUser?["starsTracked"].containsKey(myMain.correctStar);
                                print("starTracked: ${myMain.starTracked}");
                              }
                              else{
                                var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                var docNameForNewUsers;
                                theNewUser.docs.forEach((result){
                                  docNameForNewUsers = result.id;
                                });

                                DocumentSnapshot<Map<dynamic, dynamic>> snapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForNewUsers).get();
                                Map<dynamic, dynamic>? individual = snapshotNewUsers.data();

                                myMain.starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(myMain.correctStar);
                                print("starTracked: ${myMain.starTracked}");
                              }
                            }
                            else if(myNewUsername == "" && myUsername != ""){
                              if(firebaseDesktopHelper.onDesktop){
                                List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                //var docNameForExistingUsers = usersProfileInfo["docId"];

                                Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(usersProfileInfo["usernameProfileInformation"] ?? {});

                                myMain.starTracked = currentInfoOfExistingUser?["starsTracked"].containsKey(myMain.correctStar);
                                print("starTracked: ${myMain.starTracked}");
                              }
                              else{
                                var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                var docNameForExistingUsers;
                                theExistingUser.docs.forEach((result){
                                docNameForExistingUsers = result.id;
                                });

                                DocumentSnapshot<Map<dynamic, dynamic>> snapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForExistingUsers).get();
                                Map<dynamic, dynamic>? individual = snapshotExistingUsers.data();

                                myMain.starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(myMain.correctStar);
                                print("starTracked: ${myMain.starTracked}");
                              }
                            }

                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => myMain.articlePage(informationAboutClickedStar), settings: RouteSettings(arguments: clickedStar)));
                          }
                        ),
                        Text("\n${myMain.starsUserTracked.values.toList()[s]}\n", textAlign: TextAlign.center),
                      ],
                    ),

                if(myMain.starsUserTracked.isEmpty)
                  Text("N/A", textAlign: TextAlign.center),
                /*}
              else{
                Text("N/A", textAlign: TextAlign.center),
              }*/
              ],
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nPlanets Tracked:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Column(
              children: <Widget>[
                //var starsUserTrackedKeys = myMain.starsUserTracked.keys as List;
                if(!(myMain.planetsUserTracked.isEmpty))
                  for(int p = 0; p < (myMain.planetsUserTracked.keys.toList()).length; p++)
                    Column(
                      children: <Widget>[
                        GestureDetector(
                          child: Text("${myMain.planetsUserTracked.keys.toList()[p]}", textAlign: TextAlign.center),
                          onTap: () async{
                            myMain.correctPlanet = myMain.planetsUserTracked.keys.toList()[p];

                            myMain.starsAndTheirPlanets.forEach((key, value){
                              print("key: ${key}, value: ${value}");
                              for(var v in value){
                                if(v == myMain.correctPlanet){
                                  myMain.correctStar = key;
                                  break;
                                }
                                else{
                                  //continue
                                }
                              }
                            });

                            var theStarInfo = await myMain.getStarInformation();

                            myMain.informationAboutPlanet = await myMain.articlePage(theStarInfo).getPlanetData();

                            fromUserProfileInUserPerspective = true;

                            myMain.planetFileContent = await myMain.readPlanetFile(myMain.informationAboutPlanet[6].toString());
                            myMain.listOfPlanetUrls = myMain.planetFileContent.replaceAll("\n", "").replaceAll("\r", "|").split("|");

                            myMain.listOfPlanetUrls.removeWhere((myUrl) => myUrl == "" || myUrl == " ");

                            print("listOfPlanetUrls: ${myMain.listOfPlanetUrls}");

                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => myMain.planetArticle(myMain.informationAboutPlanet)));
                            //Navigator.push(context, new MaterialPageRoute(builder: (context) => articlePage(articlepage: ));
                            //Navigator.push(context, new MaterialPageRoute(builder: (context) => new planetArticle(starAndPlanetInfo: new starAndPlanetInformation)));

                            //Is the planet tracked by the user?
                            if(myNewUsername != "" && myUsername == ""){
                              if(firebaseDesktopHelper.onDesktop){
                                var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                //Getting the current profile info of the user:
                                Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                                myMain.planetTracked = currentInfoOfNewUser["planetsTracked"].containsKey(myMain.correctPlanet);
                                print("planetTracked: ${myMain.planetTracked}");
                              }
                              else{
                                var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                var theDocNameForNewUsers;
                                theNewUser.docs.forEach((result){
                                  theDocNameForNewUsers = result.id;
                                });

                                DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForNewUsers).get();
                                Map<dynamic, dynamic>? individual = theSnapshotNewUsers.data();

                                myMain.planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(myMain.correctPlanet);
                                print("planetTracked: ${myMain.planetTracked}");
                              }
                            }
                            else if(myNewUsername == "" && myUsername != ""){
                              if(firebaseDesktopHelper.onDesktop){
                                var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                //Getting the current profile info of the user:
                                Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                                myMain.planetTracked = currentInfoOfExistingUser["planetsTracked"].containsKey(myMain.correctPlanet);
                                print("planetTracked: ${myMain.planetTracked}");
                              }
                              else{
                                var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                var theDocNameForExistingUsers;
                                theExistingUser.docs.forEach((result){
                                  theDocNameForExistingUsers = result.id;
                                });

                                DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForExistingUsers).get();
                                Map<dynamic, dynamic>? individual = theSnapshotExistingUsers.data();

                                myMain.planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(myMain.correctPlanet);
                                print("planetTracked: ${myMain.planetTracked}");
                              }
                            }
                          }
                        ),
                        Text("\n${myMain.planetsUserTracked.values.toList()[p]}\n", textAlign: TextAlign.center),
                      ],
                    ),

                if(myMain.planetsUserTracked.isEmpty)
                  Text("N/A", textAlign: TextAlign.center),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class userProfileInOtherUsersPerspective extends StatefulWidget{
  const userProfileInOtherUsersPerspective ({Key? key}) : super(key: key);

  @override
  userProfileInOtherUsersPerspectiveState createState() => userProfileInOtherUsersPerspectiveState();
}

class userProfileInOtherUsersPerspectiveState extends State<userProfileInOtherUsersPerspective>{
  static String nameOfRoute = '/userProfileInOtherUsersPerspective';
  Uint8List? myImageBytes;

  myMain.myStars clickedStar = myMain.myStars(starName: "not available");

  @override
  void initState(){
    super.initState();
    loadProfilePictureInOtherUsersPerspective();
  }

  Future<void> loadProfilePictureInOtherUsersPerspective() async{
    final myBase64String = theUsersData["usernameProfileInformation"]?["userProfilePicture"] as String?;

    if(myBase64String != null && myBase64String.isNotEmpty){
      setState(() => myImageBytes = base64Decode(myBase64String));
    }
  }

  Widget build(BuildContext bc){
    List<String> informationAboutClickedStar = [];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () =>{
              if(dbuClickedOnUser == true && ndClickedOnUser == false && projectsClickedOnUser == false && qaaClickedOnUser == false && technologiesClickedOnUser == false && fasClickedOnUser == false && fromDbuThread == false && fromNdThread == false && fromPThread == false && fromQaaThread == false && fromTThread == false && fromFasThread == false && fromDbuPage == false && fromNdPage == false && fromPPage == false && fromQaaPage == false && fromTPage == false && fromFasPage == false){
                dbuClickedOnUser = false,
                Navigator.of(bc).pop(),
              }
              else if(dbuClickedOnUser == false && ndClickedOnUser == true && projectsClickedOnUser == false && qaaClickedOnUser == false && technologiesClickedOnUser == false && fasClickedOnUser == false && fromDbuThread == false && fromNdThread == false && fromPThread == false && fromQaaThread == false && fromTThread == false && fromFasThread == false && fromDbuPage == false && fromNdPage == false && fromPPage == false && fromQaaPage == false && fromTPage == false && fromFasPage == false){
                ndClickedOnUser = false,
                Navigator.of(bc).pop(),
              }
              else if(dbuClickedOnUser == false && ndClickedOnUser == false && projectsClickedOnUser == true && qaaClickedOnUser == false && technologiesClickedOnUser == false && fasClickedOnUser == false && fromDbuThread == false && fromNdThread == false && fromPThread == false && fromQaaThread == false && fromTThread == false && fromFasThread == false && fromDbuPage == false && fromNdPage == false && fromPPage == false && fromQaaPage == false && fromTPage == false && fromFasPage == false){
                  projectsClickedOnUser = false,
                  Navigator.of(bc).pop(),
                }
                else if(dbuClickedOnUser == false && ndClickedOnUser == false && projectsClickedOnUser == false && qaaClickedOnUser == true && technologiesClickedOnUser == false && fasClickedOnUser == false && fromDbuThread == false && fromNdThread == false && fromPThread == false && fromQaaThread == false && fromTThread == false && fromFasThread == false && fromDbuPage == false && fromNdPage == false && fromPPage == false && fromQaaPage == false && fromTPage == false && fromFasPage == false){
                    qaaClickedOnUser = false,
                    Navigator.of(bc).pop(),
                  }
                  else if(dbuClickedOnUser == false && ndClickedOnUser == false && projectsClickedOnUser == false && qaaClickedOnUser == false && technologiesClickedOnUser == true && fasClickedOnUser == false && fromDbuThread == false && fromNdThread == false && fromPThread == false && fromQaaThread == false && fromTThread == false && fromFasThread == false && fromDbuPage == false && fromNdPage == false && fromPPage == false && fromQaaPage == false && fromTPage == false && fromFasPage == false){
                      technologiesClickedOnUser = false,
                      Navigator.of(bc).pop(),
                    }
                    else if(dbuClickedOnUser == false && ndClickedOnUser == false && projectsClickedOnUser == false && qaaClickedOnUser == false && technologiesClickedOnUser == false && fasClickedOnUser == true && fromDbuThread == false && fromNdThread == false && fromPThread == false && fromQaaThread == false && fromTThread == false && fromFasThread == false && fromDbuPage == false && fromNdPage == false && fromPPage == false && fromQaaPage == false && fromTPage == false && fromFasPage == false){
                        fasClickedOnUser = false,
                        Navigator.of(bc).pop(),
                      }
                      else if(fromDbuThread == true && fromNdThread == false && fromPThread == false && fromQaaThread == false && fromTThread == false && fromFasThread == false){
                          fromDbuThread = false,
                          Navigator.push(context, MaterialPageRoute(builder: (context) => discussionBoardUpdatesThreadsPage())),
                        }
                        else if(fromDbuThread == false && fromNdThread == true && fromPThread == false && fromQaaThread == false && fromTThread == false && fromFasThread == false){
                            fromNdThread = false,
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => newDiscoveriesThreadsPage())),
                          }
                          else if(fromDbuThread == false && fromNdThread == false && fromPThread == true && fromQaaThread == false && fromTThread == false && fromFasThread == false){
                              fromPThread = false,
                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => projectsThreadsPage())),
                            }
                            else if(fromDbuThread == false && fromNdThread == false && fromPThread == false && fromQaaThread == true && fromTThread == false && fromFasThread == false){
                                fromQaaThread = false,
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => questionsAndAnswersThreadsPage())),
                              }
                              else if(fromDbuThread == false && fromNdThread == false && fromPThread == false && fromQaaThread == false && fromTThread == true && fromFasThread == false){
                                  fromTThread = false,
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => technologiesThreadsPage())),
                                }
                                else if(fromDbuThread == false && fromNdThread == false && fromPThread == false && fromQaaThread == false && fromTThread == false && fromFasThread == true){
                                    fromFasThread = false,
                                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => feedbackAndSuggestionsThreadsPage())),
                                  }
                                  else if(fromDbuPage == true && fromNdPage == false && fromPPage == false && fromQaaPage == false && fromTPage == false && fromFasPage == false){
                                      fromDbuPage = false,
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const discussionBoardUpdatesPage())),
                                    }
                                    else if(fromDbuPage == false && fromNdPage == true && fromPPage == false && fromQaaPage == false && fromTPage == false && fromFasPage == false){
                                        fromNdPage = false,
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const newDiscoveriesPage())),
                                      }
                                      else if(fromDbuPage == false && fromNdPage == false && fromPPage == true && fromQaaPage == false && fromTPage == false && fromFasPage == false){
                                          fromPPage = false,
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => const projectsPage())),
                                        }
                                        else if(fromDbuPage == false && fromNdPage == false && fromPPage == false && fromQaaPage == true && fromTPage == false && fromFasPage == false){
                                            fromQaaPage = false,
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => const questionsAndAnswersPage())),
                                          }
                                          else if(fromDbuPage == false && fromNdPage == false && fromPPage == false && fromQaaPage == false && fromTPage == true && fromFasPage == false){
                                              fromTPage = false,
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => const technologiesPage())),
                                            }
                                            else if(fromDbuPage == false && fromNdPage == false && fromPPage == false && fromQaaPage == false && fromTPage == false && fromFasPage == true){
                                                fromFasPage = false,
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => const feedbackAndSuggestionsPage())),
                                              }
                                  else{
                                      showSearch(
                                        context: bc,
                                        delegate: mySearch(),
                                      ),
                                    }
            }
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("${theUsersData["username"]}'s Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
            ),
            Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),
            myImageBytes != null? CircleAvatar(
              radius: 80,
              backgroundImage: myImageBytes != null ? MemoryImage(myImageBytes!) : null,
            ): Container(),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nInformation About ${theUsersData["username"]}:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: !(theUsersData["usernameProfileInformation"]["userInformation"].isEmpty) && whitespaceChecker(theUsersData["usernameProfileInformation"]["userInformation"]) == false?
                Text("${theUsersData["usernameProfileInformation"]["userInformation"]}", textAlign: TextAlign.center):
                Text("N/A", textAlign: TextAlign.center),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\n${theUsersData["username"]}'s Interests:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: !(theUsersData["usernameProfileInformation"]["userInterests"].isEmpty) && whitespaceChecker(theUsersData["usernameProfileInformation"]["userInterests"]) == false?
              Text("${theUsersData["usernameProfileInformation"]["userInterests"]}", textAlign: TextAlign.center):
              Text("N/A", textAlign: TextAlign.center),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\n${theUsersData["username"]}'s Location:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: !(theUsersData["usernameProfileInformation"]["userLocation"].isEmpty) && whitespaceChecker(theUsersData["usernameProfileInformation"]["userLocation"]) == false?
                Text("${theUsersData["usernameProfileInformation"]["userLocation"]}", textAlign: TextAlign.center):
                Text("N/A", textAlign: TextAlign.center),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nTotal Posts on the Discussion Board:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, 0.0, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("${theUsersData["usernameProfileInformation"]["numberOfPosts"]}"),
            ),
            /*Container(
              height : MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nStars Tracked:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Column(
              children: <Widget>[
                if(!(theUsersData["usernameProfileInformation"]["starsTracked"].isEmpty))
                  for(int s = 0; s < (theUsersData["usernameProfileInformation"]["starsTracked"].keys.toList()).length; s++)
                    Column(
                      children: <Widget>[
                        GestureDetector(
                          child: Text("${theUsersData["usernameProfileInformation"]["starsTracked"].keys.toList()[s]}", textAlign: TextAlign.center),
                          onTap: () async{
                            myMain.correctStar = theUsersData["usernameProfileInformation"]["starsTracked"].keys.toList()[s];
                            print(myMain.correctStar);
                            clickedStar.starName = myMain.correctStar;
                            print(clickedStar.starName);

                            informationAboutClickedStar = await myMain.getStarInformation();
                            print(informationAboutClickedStar);
                            fromUserProfileInOtherUsersPerspective = true;

                            myMain.starFileContent = await myMain.readStarFile();
                            myMain.listOfStarUrls = myMain.starFileContent.replaceAll("\n", "").replaceAll("\r", "|").split("|");

                            myMain.listOfStarUrls.removeWhere((myUrl) => myUrl == "" || myUrl == " ");

                            //Is a user tracking this star?
                            if(myNewUsername != "" && myUsername == ""){
                              if(firebaseDesktopHelper.onDesktop){
                                List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                //var docNameForNewUsers = usersProfileInfo["docId"];

                                Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(usersProfileInfo["usernameProfileInformation"] ?? {});

                                myMain.starTracked = currentInfoOfNewUser?["starsTracked"].containsKey(myMain.correctStar);
                                print("starTracked: ${myMain.starTracked}");
                              }
                              else{
                                var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                var docNameForNewUsers;
                                theNewUser.docs.forEach((result){
                                  docNameForNewUsers = result.id;
                                });

                                DocumentSnapshot<Map<dynamic, dynamic>> snapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForNewUsers).get();
                                Map<dynamic, dynamic>? individual = snapshotNewUsers.data();

                                myMain.starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(myMain.correctStar);
                                print("starTracked: ${myMain.starTracked}");
                              }
                            }
                            else if(myNewUsername == "" && myUsername != ""){
                              if(firebaseDesktopHelper.onDesktop){
                                List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                var usersProfileInfo = allUsers.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                //var docNameForExistingUsers = usersProfileInfo["docId"];

                                Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(usersProfileInfo["usernameProfileInformation"] ?? {});

                                myMain.starTracked = currentInfoOfExistingUser?["starsTracked"].containsKey(myMain.correctStar);
                                print("starTracked: ${myMain.starTracked}");
                              }
                              else{
                                var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                var docNameForExistingUsers;
                                theExistingUser.docs.forEach((result){
                                  docNameForExistingUsers = result.id;
                                });

                                DocumentSnapshot<Map<dynamic, dynamic>> snapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(docNameForExistingUsers).get();
                                Map<dynamic, dynamic>? individual = snapshotExistingUsers.data();

                                myMain.starTracked = individual?["usernameProfileInformation"]["starsTracked"].containsKey(myMain.correctStar);
                                print("starTracked: ${myMain.starTracked}");
                              }
                            }

                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => myMain.articlePage(informationAboutClickedStar), settings: RouteSettings(arguments: clickedStar)));
                          }
                        ),
                        Text("\n${theUsersData["usernameProfileInformation"]["starsTracked"].values.toList()[s]}\n", textAlign: TextAlign.center),
                      ],
                    ),

                if(theUsersData["usernameProfileInformation"]["starsTracked"].isEmpty)
                  Text("N/A", textAlign: TextAlign.center),
              ],
            ),
            /*Container(
              height: MediaQuery.of(bc).size.height * 0.015625,
            ),*/
            Container(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(bc).size.width * 0.015625, MediaQuery.of(bc).size.height * 0.015625, MediaQuery.of(bc).size.width * 0.015625, 0.0),
              child: Text("\nPlanets Tracked:", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Column(
              children: <Widget>[
                //var starsUserTrackedKeys = myMain.starsUserTracked.keys as List;
                if(!(theUsersData["usernameProfileInformation"]["planetsTracked"].isEmpty))
                  for(int p = 0; p < (theUsersData["usernameProfileInformation"]["planetsTracked"].keys.toList()).length; p++)
                    Column(
                      children: <Widget>[
                        GestureDetector(
                          child: Text("${theUsersData["usernameProfileInformation"]["planetsTracked"].keys.toList()[p]}", textAlign: TextAlign.center),
                          onTap: () async{
                            myMain.correctPlanet = theUsersData["usernameProfileInformation"]["planetsTracked"].keys.toList()[p];

                            myMain.starsAndTheirPlanets.forEach((key, value){
                              print("key: ${key}, value: ${value}");
                              for(var v in value){
                                if(v == myMain.correctPlanet){
                                  myMain.correctStar = key;
                                  break;
                                }
                                else{
                                  //continue
                                }
                              }
                            });

                            var theStarInfo = await myMain.getStarInformation();

                            myMain.informationAboutPlanet = await myMain.articlePage(theStarInfo).getPlanetData();

                            fromUserProfileInOtherUsersPerspective = true;

                            myMain.planetFileContent = await myMain.readPlanetFile(myMain.informationAboutPlanet[6].toString());
                            myMain.listOfPlanetUrls = myMain.planetFileContent.replaceAll("\n", "").replaceAll("\r", "|").split("|");

                            myMain.listOfPlanetUrls.removeWhere((myUrl) => myUrl == "" || myUrl == " ");

                            print("listOfPlanetUrls: ${myMain.listOfPlanetUrls}");

                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => myMain.planetArticle(myMain.informationAboutPlanet)));
                            //Navigator.push(context, new MaterialPageRoute(builder: (context) => articlePage(articlepage: ));
                            //Navigator.push(context, new MaterialPageRoute(builder: (context) => new planetArticle(starAndPlanetInfo: new starAndPlanetInformation)));

                            //Is the planet tracked by the user?
                            if(myNewUsername != "" && myUsername == ""){
                              if(firebaseDesktopHelper.onDesktop){
                                var newUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                var newUsersDoc = newUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myNewUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                //Getting the current profile info of the user:
                                Map<String, dynamic> currentInfoOfNewUser = Map<String, dynamic>.from(newUsersDoc["usernameProfileInformation"] ?? {});
                                myMain.planetTracked = currentInfoOfNewUser["planetsTracked"].containsKey(myMain.correctPlanet);
                                print("planetTracked: ${myMain.planetTracked}");
                              }
                              else{
                                var theNewUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myNewUsername.toLowerCase()).get();
                                var theDocNameForNewUsers;
                                theNewUser.docs.forEach((result){
                                  theDocNameForNewUsers = result.id;
                                });

                                DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotNewUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForNewUsers).get();
                                Map<dynamic, dynamic>? individual = theSnapshotNewUsers.data();

                                myMain.planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(myMain.correctPlanet);
                                print("planetTracked: ${myMain.planetTracked}");
                              }
                            }
                            else if(myNewUsername == "" && myUsername != ""){
                              if(firebaseDesktopHelper.onDesktop){
                                var existingUserNeeded = await firebaseDesktopHelper.getFirestoreCollection("User");
                                var existingUsersDoc = existingUserNeeded.firstWhere((myUser) => myUser["usernameLowercased"].toString() == myUsername.toLowerCase(), orElse: () => <String, dynamic>{});

                                //Getting the current profile info of the user:
                                Map<String, dynamic> currentInfoOfExistingUser = Map<String, dynamic>.from(existingUsersDoc["usernameProfileInformation"] ?? {});
                                myMain.planetTracked = currentInfoOfExistingUser["planetsTracked"].containsKey(myMain.correctPlanet);
                                print("planetTracked: ${myMain.planetTracked}");
                              }
                              else{
                                var theExistingUser = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: myUsername.toLowerCase()).get();
                                var theDocNameForExistingUsers;
                                theExistingUser.docs.forEach((result){
                                  theDocNameForExistingUsers = result.id;
                                });

                                DocumentSnapshot<Map<dynamic, dynamic>> theSnapshotExistingUsers = await FirebaseFirestore.instance.collection("User").doc(theDocNameForExistingUsers).get();
                                Map<dynamic, dynamic>? individual = theSnapshotExistingUsers.data();

                                myMain.planetTracked = individual?["usernameProfileInformation"]["planetsTracked"].containsKey(myMain.correctPlanet);
                                print("planetTracked: ${myMain.planetTracked}");
                              }
                            }
                          }
                        ),
                        Text("\n${theUsersData["usernameProfileInformation"]["planetsTracked"].values.toList()[p]}\n", textAlign: TextAlign.center),
                      ],
                    ),

                if(theUsersData["usernameProfileInformation"]["planetsTracked"].isEmpty)
                  Text("N/A", textAlign: TextAlign.center),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class nonexistentUser extends StatelessWidget{
  static String nameOfRoute = '/nonexistentUser';

  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
      centerTitle: true,
      title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () =>{
            Navigator.pop(bc),
          }
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(bc).size.height * 0.015625,
          ),
          Center(
            child: Text("Error", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          Container(
            height: MediaQuery.of(bc).size.height * 0.015625,
          ),
          Container(
            padding: EdgeInsets.all(MediaQuery.of(bc).size.height * 0.015625),
            child: Text("Unfortunately, this user does not exist.",textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}