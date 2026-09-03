import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:starexpedition4/projects_firestore_database_information/projectsRepliesDatabaseFirestoreInfo.dart';
import 'package:starexpedition4/projects_firestore_database_information/projectsRepliesInformation.dart';
import 'package:starexpedition4/projects_firestore_database_information/projectsRepliesToRepliesInformation.dart';
import 'package:starexpedition4/questions_and_answers_firestore_database_information/questionsAndAnswersRepliesDatabaseFirestoreInfo.dart';
import 'package:starexpedition4/questions_and_answers_firestore_database_information/questionsAndAnswersRepliesInformation.dart';
import 'package:starexpedition4/questions_and_answers_firestore_database_information/questionsAndAnswersRepliesToRepliesInformation.dart';
import 'package:starexpedition4/technologies_firestore_database_information/technologiesRepliesDatabaseFirestoreInfo.dart';
import 'package:starexpedition4/technologies_firestore_database_information/technologiesRepliesInformation.dart';
import 'package:starexpedition4/technologies_firestore_database_information/technologiesRepliesToRepliesInformation.dart';
//import 'package:video_compress/video_compress.dart';

import 'createThread.dart';
import 'discussionBoardUpdatesPage.dart' as discussionBoardUpdatesPage;
//import 'discussionBoardUpdatesPage.dart';
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesRepliesDatabaseFirestoreInfo.dart';
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesRepliesInformation.dart';
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesRepliesToRepliesDatabaseFirestoreInfo.dart';
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesRepliesToRepliesInformation.dart';
import 'emailNotifications.dart';
import 'login_information/loginStatus.dart';
import 'new_discoveries_firestore_database_information/newDiscoveriesRepliesDatabaseFirestoreInfo.dart';
import 'new_discoveries_firestore_database_information/newDiscoveriesRepliesInformation.dart';
import 'new_discoveries_firestore_database_information/newDiscoveriesRepliesToRepliesInformation.dart';
import 'feedback_and_suggestions_firestore_database_information/feedbackAndSuggestionsRepliesDatabaseFirestoreInfo.dart';
import 'feedback_and_suggestions_firestore_database_information/feedbackAndSuggestionsRepliesInformation.dart';
import 'feedback_and_suggestions_firestore_database_information/feedbackAndSuggestionsRepliesToRepliesInformation.dart';
import 'questionsAndAnswersPage.dart' as questionsAndAnswersPage;
import 'technologiesPage.dart' as technologiesPage;
import 'projectsPage.dart' as projectsPage;
import 'newDiscoveriesPage.dart' as newDiscoveriesPage;
import 'feedbackAndSuggestionsPage.dart' as feedbackAndSuggestionsPage;
import 'main.dart' as myMain;
import 'package:starexpedition4/loginPage.dart' as theLoginPage;
import 'package:starexpedition4/registerPage.dart' as theRegisterPage;
import 'package:starexpedition4/firebaseDesktopHelper.dart';
import 'package:starexpedition4/quill_information/quillEmbedHelper.dart';

import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesDatabaseFirestoreInfo.dart';
import 'discussion_board_updates_firestore_database_information/discussionBoardUpdatesInformation.dart';

import 'package:http_parser/http_parser.dart';

int replyNum = 0;
List<dynamic> info = [];
var myInfoForReplies;
var userDataForReplies;
var docNameForReplies;

var dbuDoc;
var qaaDoc;
var technologiesDoc;
var projectsDoc;
var ndDoc;
var fasDoc;

bool fromDbuReply = false;
bool fromQaaReply = false;
bool fromTechnologiesReply = false;
bool fromProjectsReply = false;
bool fromNdReply = false;
bool fromFasReply = false;

bool whitespaceChecker(String? myString){
  if(myString == null){
    return true;
  }

  //Removing unicode characters that are invisible and missed by the trim() method:
  final cleaned = myString.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u00A0]'), "");

  return cleaned.trim().isEmpty;
}

class replyThreadPage extends StatefulWidget{
  const replyThreadPage ({Key? key}) : super(key: key);

  @override
  replyThreadPageState createState() => replyThreadPageState();
}

class replyThreadPageState extends State<replyThreadPage> with RouteAware{
  static String replyThread = '/replyThreadPage';
  final usernameReplyController = TextEditingController();
  final replyContentController = TextEditingController();
  List<String> pendingDiscussionBoardUpdatesReply = [];
  List<String> pendingQuestionsAndAnswersReply = [];
  List<String> pendingTechnologiesReply = [];
  List<String> pendingProjectsReply = [];
  List<String> pendingNewDiscoveriesReply = [];
  List<String> pendingFeedbackAndSuggestionsReply = [];
  int threadNum = 0;

  List<String> replyInfo = [];
  List<Text> messageReplyThread = [];

  bool postingAReply = false;

  bool replyButton = false;

  //Scroll controller:
  final replyContentScrollController = ScrollController();

  //Quill controller:
  final QuillController replyQuillController = QuillController.basic();

  //StreamSubscription:
  late final StreamSubscription replyQuillSyncSubscription;

  bool uploadingReplyImage = false;
  bool uploadingReplyVideo = false;

  late final FocusNode replyContentFocusNode;

  @override
  void initState(){
    replyQuillSyncSubscription = replyQuillController.document.changes.listen((myEvent){
      replyContentController.text = jsonEncode(replyQuillController.document.toDelta().toJson());
    });

    replyContentFocusNode = FocusNode();
  }

  List<Text> createReplyDialogMessage(List<String> info){
    List<Text> messageForUserReplyToThread = [];
    if(whitespaceChecker(usernameReplyController.text)){
      messageForUserReplyToThread.add(Text("Username is empty"));
    }
    if(whitespaceChecker(replyContentController.text)){
      messageForUserReplyToThread.add(Text("Reply content is empty"));
    }

    return messageForUserReplyToThread;
  }

  Future<String> uploadMyImageToCloudinary(String myOriginalPath) async{
    const myCloudName = "qrbab8fp";
    const myUploadPreset = "star_expedition_reply_images";

    final myTempDirectory = await getTemporaryDirectory();
    final myUniqueName = "image_${DateTime.now().microsecondsSinceEpoch}.jpg";
    final myTargetPath = "${myTempDirectory.path}/${myUniqueName}";

    //Re-encoding the photo to a compressed .jpeg file:
    final myCompressedFile = await FlutterImageCompress.compressAndGetFile(myOriginalPath, myTargetPath, quality: 90, minHeight: 1920, minWidth: 1920, format: CompressFormat.jpeg);

    if(myCompressedFile == null){
      throw Exception("Unfortunately, the image was not able to be compressed.");
    }

    final myFreshFile = File(myCompressedFile.path);

    final myUri = Uri.parse("https://api.cloudinary.com/v1_1/${myCloudName}/image/upload");

    final myRequest = http.MultipartRequest("POST", myUri)
      ..fields["upload_preset"] = myUploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", myFreshFile.path));

    final myResponse = await myRequest.send();
    final myResponseBody = await myResponse.stream.bytesToString();

    //Cleaning up the temporary file after upload:
    try{
      await myFreshFile.delete();
    }
    catch(e){
      //Does nothing
    }

    if(myResponse.statusCode == 200){
      final myJsonResponse = jsonDecode(myResponseBody);

      //Returns the hosted image URL:
      return myJsonResponse["secure_url"];
    }
    else{
      throw Exception("Unfortunately, the Cloudinary image upload failed: ${myResponseBody}");
    }
  }

  Future<String> uploadMyVideoToCloudinary(String myOriginalPath) async{
    const myCloudName = "qrbab8fp";
    const myUploadPreset = "star_expedition_reply_videos";

    final myFile = File(myOriginalPath);

    //This handles files backed by iCloud that may not be fully downloaded yet:
    if(!(await myFile.exists())){
      throw Exception("Unfortunately, the video file cannot be found. If it is stored in iCloud, please make sure that it is completely downloaded first.");
    }

    //To see if a video is too large for your Cloudinary plan or not:
    final myFileSizeInMB = await myFile.length() / (1024 * 1024);

    if(myFileSizeInMB == 0){
      throw Exception("Unfortunately, the video appears to be empty. If it is stored in iCloud, please make sure that it is completely downloaded first.");
    }

    if(myFileSizeInMB > 100){
      throw Exception("Unfortunately, the video you uploaded was too large. Please upload a video that is under 100 MB");
    }

    final myUri = Uri.parse("https://api.cloudinary.com/v1_1/${myCloudName}/video/upload");

    //Setting the content type due to how iOS videos are generally .mov files. These files are not always correctly auto-detected:
    final myExtension = myFile.path.split(".").last.toLowerCase();

    final myContentType = (myExtension == "mov") ? MediaType("video", "quicktime") : MediaType("video", "mp4");

    final myRequest = http.MultipartRequest("POST", myUri)
      ..fields["upload_preset"] = myUploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", myFile.path, contentType: myContentType));

    final myResponse = await myRequest.send().timeout(
      Duration(seconds: 120), onTimeout: () => throw Exception("Unfortunately, the video upload has timed out"),
    );

    final myResponseBody = await myResponse.stream.bytesToString();

    if(myResponse.statusCode == 200){
      final myJsonResponse = jsonDecode(myResponseBody);

      //Returns the hosted image URL:
      return myJsonResponse["secure_url"];
    }
    else{
      throw Exception("Unfortunately, the Cloudinary video upload failed: ${myResponseBody}");
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
    replyQuillSyncSubscription.cancel();
    replyContentFocusNode.dispose();
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

  Widget build(BuildContext bc){
    final myLoginStatus = bc.watch<loginStatus>();

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_){
        FocusManager.instance.primaryFocus?.unfocus();
        SystemChannels.textInput.invokeMethod("TextInput.hide");
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Star Expedition"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () =>
            {
              myMain.myAccessCheckNotifier.value = DateTime.now(),
              showDialog(
                  context: context,
                  builder: (BuildContext myReplyContext) {
                    return AlertDialog(
                      title: const Text("Are you sure?"),
                      content: const Text("Your reply will not be saved."),
                      actions: [
                        TextButton(
                          onPressed: () =>
                          {
                            Navigator.pop(context),
                            Navigator.pop(context),
                          },
                          child: const Text("Yes"),
                        ),
                        TextButton(
                          onPressed: () =>
                          {
                            Navigator.pop(context),
                          },
                          child: const Text("No"),
                        ),
                      ],
                    );
                  }
              ),
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
                  child: Text("Making a reply", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0), textAlign: TextAlign.center),
                  alignment: Alignment.center,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.015625, MediaQuery.of(context).size.height * 0.031250, MediaQuery.of(context).size.width * 0.015625, 0.0),
                  child: (myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != "")?
                  SizedBox(
                    width: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
                    child: TextField(
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: "Username",
                      ),
                      maxLines: 1,
                      maxLength: 30,
                      enabled: false,
                      controller: TextEditingController()..text = myLoginStatus.myUsername,
                    ),
                  ): SizedBox(
                    width: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
                    child: TextField(),
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.015625, MediaQuery.of(context).size.height * 0.0078125, MediaQuery.of(context).size.width * 0.015625, 0.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.375000 : 320,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          QuillSimpleToolbar(
                            controller: replyQuillController,
                            config: QuillSimpleToolbarConfig(
                              showFontFamily: false,
                              showFontSize: false,
                              showColorButton: false,
                              showBackgroundColorButton: false,
                              multiRowsDisplay: true,
                              showStrikeThrough: false,
                              showInlineCode: false,
                              showCodeBlock: false,
                              showQuote: false,
                              showIndent: false,
                              showHeaderStyle: false,
                              showListCheck: false,
                              showListNumbers: false,
                              showListBullets: false,
                              showAlignmentButtons: false,
                              showLeftAlignment: false,
                              showCenterAlignment: false,
                              showRightAlignment: false,
                              showJustifyAlignment: false,
                              showDirection: false,
                              showClearFormat: false,
                              embedButtons: FlutterQuillEmbeds.toolbarButtons(
                                imageButtonOptions: QuillToolbarImageButtonOptions(
                                  imageButtonConfig: QuillToolbarImageConfig(
                                      onImageInsertCallback: (myImage, myController) async{
                                        setState(() => uploadingReplyImage = true);

                                        try{
                                          final myDownloadUrl = await uploadMyImageToCloudinary(myImage);

                                          quillEmbedHelper().addEmbedAndCleanUp(myController, BlockEmbed.image(myDownloadUrl));
                                        }
                                        catch (e){
                                          if(mounted){
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext bc){
                                                  return AlertDialog(
                                                    title: Text("Error"),
                                                    content: Text("Unfortunately, you were not successful in uploading the image."),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: (){
                                                          Navigator.of(bc).pop();
                                                        },
                                                        child: Text("Ok"),
                                                      )
                                                    ],
                                                  );
                                                }
                                            );
                                          }
                                        }
                                        finally{
                                          if(mounted){
                                            setState(() => uploadingReplyImage = false);
                                          }
                                        }
                                      }
                                  ),
                                ),
                                videoButtonOptions: QuillToolbarVideoButtonOptions(
                                  videoConfig: QuillToolbarVideoConfig(
                                      onVideoInsertCallback: (myVideo, myController) async{
                                        setState(() => uploadingReplyVideo = true);

                                        try{
                                          final myDownloadUrl = await uploadMyVideoToCloudinary(myVideo);

                                          quillEmbedHelper().addEmbedAndCleanUp(myController, BlockEmbed.video(myDownloadUrl));
                                        }
                                        catch (e){
                                          if(mounted){
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext bc){
                                                  return AlertDialog(
                                                    title: Text("Error"),
                                                    content: Text("Unfortunately, you were not successful in uploading the video."),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: (){
                                                          Navigator.of(bc).pop();
                                                        },
                                                        child: Text("Ok"),
                                                      )
                                                    ],
                                                  );
                                                }
                                            );
                                          }
                                        }
                                        finally{
                                          if(mounted){
                                            setState(() => uploadingReplyVideo = false);
                                          }
                                        }
                                      }
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if(uploadingReplyImage || uploadingReplyVideo)
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).dividerColor),
                            ),
                            height: 220,
                            child: Scrollbar(
                              controller: replyContentScrollController,
                              thumbVisibility: true,
                              child: QuillEditor(
                                controller: replyQuillController,
                                scrollController: replyContentScrollController,
                                focusNode: replyContentFocusNode,
                                config: QuillEditorConfig(
                                  padding: EdgeInsets.all(8.0),
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
                          ),
                        ],
                      ),
                      /*Scrollbar(
                        //child: SingleChildScrollView(
                          //scrollDirection: Axis.vertical,
                          //reverse: false,
                          controller: replyContentScrollController,
                          thumbVisibility: true,
                          child: SizedBox(
                            child: TextField(
                              scrollController: replyContentScrollController,
                              minLines: 5,
                              maxLines: 5,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Reply Content",
                              ),
                              maxLengthEnforcement: MaxLengthEnforcement.enforced,
                              controller: replyContentController,
                            ),
                          ),
                        //),
                      ),*/
                    ),
                  )
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.015625,
                ),
                Center(
                  child: AbsorbPointer(
                    absorbing: replyButton,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: InkWell(
                          child: Ink(
                            color: Colors.black,
                              child: Text("Reply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal), textAlign: TextAlign.center),
                            ),
                          ),
                        onPressed: () async{
                          if(replyButton){
                            return;
                          }

                          setState(() => replyButton = true);

                          //Ignoring extra clicks while posting reply:
                          if(postingAReply){
                            return;
                          }

                          setState((){
                            postingAReply = true;
                          });

                          try{
                            usernameReplyController.text = myLoginStatus.myUsername;

                            if(usernameReplyController.text != "" && replyContentController.text != "" && whitespaceChecker(usernameReplyController.text) == false && whitespaceChecker(replyContentController.text) == false){
                              if(discussionBoardUpdatesPage.discussionBoardUpdatesReplyBool == true){
                                //For the Discussion Board Updates subforum:
                                final discussionBoardUpdatesRepliesInfo = Get.put(discussionBoardUpdatesRepliesInformation());

                                final discussionBoardUpdatesRepliesToRepliesInfo = Get.put(discussionBoardUpdatesRepliesToRepliesInformation());

                                Future<void> createDiscussionBoardUpdatesReply(DiscussionBoardUpdatesReplies dbur, var docName) async{
                                  await discussionBoardUpdatesRepliesInfo.createMyDiscussionBoardUpdatesReply(dbur, docName);
                                }

                                Future<void> createDiscussionBoardUpdatesReplyToReply(DiscussionBoardUpdatesReplies dbur, var secondDocName) async{
                                  await discussionBoardUpdatesRepliesToRepliesInfo.createMyDiscussionBoardUpdatesReplyToReply(dbur, secondDocName);
                                }
                                if(discussionBoardUpdatesPage.discussionBoardUpdatesReplyingToReplyBool == false){
                                  threadNum = int.parse(discussionBoardUpdatesPage.threadID);

                                  assert(threadNum is int);
                                  print(threadNum.runtimeType);
                                  var myReply = DiscussionBoardUpdatesReplies(
                                      threadNumber: threadNum,
                                      time: DateTime.now().toUtc().toIso8601String(),
                                      replier: usernameReplyController.text,
                                      replyContent: replyContentController.text,
                                      theOriginalReplyInfo: {}
                                  );
                                  print("myReply: ${myReply}");
                                  print("discussionBoardUpdatesPage.myDocDbu: ${discussionBoardUpdatesPage.myDocDbu}");
                                  createDiscussionBoardUpdatesReply(myReply, discussionBoardUpdatesPage.myDocDbu);

                                  if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                    if(firebaseDesktopHelper.onDesktop){
                                      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                      var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theCorrectUser.isNotEmpty){
                                        userData = theCorrectUser;
                                        docName = theCorrectUser["docId"] ?? "N/A";

                                        print("userData: ${userData}");
                                        print("docName for your username: ${docName}");

                                        //Updating the document:
                                        try{
                                          //Getting the current information about a user:
                                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                          print("theCorrectUser: ${theCorrectUser}");
                                          print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                          print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                          print("Full user info: ${currentInfoOfUser}");
                                          print("Full user keys: ${currentInfoOfUser.keys}");

                                          //Incrementing the number of posts a user has:
                                          int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                          currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                          //Updating the information about a user:
                                          await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                            "usernameProfileInformation": currentInfoOfUser,
                                          });

                                          print("You have updated the number of posts for the user!");

                                          //Determining if the full document still has all of the fields
                                          List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                          var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                          print("The full document after the update: $theVerifiedUser");
                                        }
                                        catch (error){
                                          print("Error updating information of user: ${error}");
                                          print("Stack trace: ${StackTrace.current}");
                                        }
                                      }
                                      else{
                                        print("User not found");
                                      }

                                      //Getting information about the poster of the thread a user replied to:
                                      List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");
                                      var theThreadPoster = everyUser.firstWhere((user) => user["usernameLowercased"].toString() == (discussionBoardUpdatesPage.threadPosterUserIsReplyingToDbu).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theThreadPoster.isNotEmpty){
                                        var dbuThreadPosterData = theThreadPoster;
                                        var dbuThreadPosterDocName = dbuThreadPosterData["docId"] ?? "N/A";

                                        Map<String, dynamic> currentInfoOfDbuThreadPoster = Map<String, dynamic>.from(theThreadPoster["usernameProfileInformation"] ?? {});
                                        var dbuThreadPostersEmailAddress = currentInfoOfDbuThreadPoster["emailAddress"];

                                        //sendAnEmail(dbuThreadPostersEmailAddress, "Reply to Your Thread", "Hi ${discussionBoardUpdatesPage.threadPosterUserIsReplyingToDbu},<br><br>${myLoginStatus.myUsername} has replied to your thread from the Discussion Board Updates subforum titled ${discussionBoardUpdatesPage.titleOfThreadUserIsReplyingToDbu}. This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                        sendReplyToThreadNotificationEmail(dbuThreadPostersEmailAddress, discussionBoardUpdatesPage.threadPosterUserIsReplyingToDbu, myLoginStatus.myUsername, "Discussion Board Updates", discussionBoardUpdatesPage.titleOfThreadUserIsReplyingToDbu, replyContentController.text);
                                        discussionBoardUpdatesPage.threadPosterUserIsReplyingToDbu = "";
                                        discussionBoardUpdatesPage.titleOfThreadUserIsReplyingToDbu = "";
                                        dbuThreadPostersEmailAddress = "";
                                      }
                                    }
                                    else{
                                      myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                      myInfoForReplies.docs.forEach((resultExistingUsername){
                                        userDataForReplies = resultExistingUsername.data();
                                        docNameForReplies = resultExistingUsername.id;
                                      });

                                      print("userData: ${userDataForReplies}");
                                      print("docName: ${docNameForReplies}");

                                      FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                                        "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                      }).then((a){
                                        print("You have updated the post number for the existing user!");
                                      });

                                      //Getting information about the poster of the thread a user replied to:
                                      var theThreadPoster = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (discussionBoardUpdatesPage.threadPosterUserIsReplyingToDbu).toLowerCase()).get();
                                      var dbuThreadPosterDocName = theThreadPoster.docs.first;
                                      var dbuThreadPostersEmailAddress = dbuThreadPosterDocName.get("emailAddress");

                                      //sendAnEmail(dbuThreadPostersEmailAddress, "Reply to Your Thread", "Hi ${discussionBoardUpdatesPage.threadPosterUserIsReplyingToDbu},<br><br>${myLoginStatus.myUsername} has replied to your thread from the Discussion Board Updates subforum titled ${discussionBoardUpdatesPage.titleOfThreadUserIsReplyingToDbu}. This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                      sendReplyToThreadNotificationEmail(dbuThreadPostersEmailAddress, discussionBoardUpdatesPage.threadPosterUserIsReplyingToDbu, myLoginStatus.myUsername, "Discussion Board Updates", discussionBoardUpdatesPage.titleOfThreadUserIsReplyingToDbu, replyContentController.text);
                                      discussionBoardUpdatesPage.threadPosterUserIsReplyingToDbu = "";
                                      discussionBoardUpdatesPage.titleOfThreadUserIsReplyingToDbu = "";
                                      dbuThreadPostersEmailAddress = "";
                                    }
                                  }

                                  pendingDiscussionBoardUpdatesReply.add(DateTime.now().toUtc().toString());
                                  pendingDiscussionBoardUpdatesReply.add(usernameReplyController.text);
                                  pendingDiscussionBoardUpdatesReply.add(replyContentController.text);
                                }
                                else if(discussionBoardUpdatesPage.discussionBoardUpdatesReplyingToReplyBool == true){
                                  discussionBoardUpdatesPage.discussionBoardUpdatesReplyingToReplyBool = false;
                                  threadNum = int.parse(discussionBoardUpdatesPage.threadID);
                                  assert(threadNum is int);
                                  print(threadNum.runtimeType);
                                  replyNum = discussionBoardUpdatesPage.myIndex;
                                  var myReply = DiscussionBoardUpdatesReplies(
                                      threadNumber: threadNum,
                                      time: DateTime.now().toUtc().toIso8601String(),
                                      replier: usernameReplyController.text,
                                      replyContent: replyContentController.text,
                                      theOriginalReplyInfo: discussionBoardUpdatesPage.myReplyToReplyDbuMap
                                  );
                                  print("This is theOriginalReplyInfo: ${discussionBoardUpdatesPage.myReplyToReplyDbuMap}");
                                  createDiscussionBoardUpdatesReplyToReply(myReply, discussionBoardUpdatesPage.myDocDbu); //replyToReplyDocDbu//discussionBoardUpdatesPage.replyToReplyDocDbu

                                  if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                    if(firebaseDesktopHelper.onDesktop){
                                      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                      var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theCorrectUser.isNotEmpty){
                                        userData = theCorrectUser;
                                        docName = theCorrectUser["docId"] ?? "N/A";

                                        print("userData: ${userData}");
                                        print("docName for your username: ${docName}");

                                        //Updating the document:
                                        try{
                                          //Getting the current information about a user:
                                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                          print("theCorrectUser: ${theCorrectUser}");
                                          print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                          print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                          print("Full user info: ${currentInfoOfUser}");
                                          print("Full user keys: ${currentInfoOfUser.keys}");

                                          //Incrementing the number of posts a user has:
                                          int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                          currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                          //Updating the information about a user:
                                          await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                            "usernameProfileInformation": currentInfoOfUser,
                                          });

                                          print("You have updated the number of posts for the user!");

                                          //Determining if the full document still has all of the fields
                                          List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                          var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                          print("The full document after the update: $theVerifiedUser");
                                        }
                                        catch (error){
                                          print("Error updating information of user: ${error}");
                                          print("Stack trace: ${StackTrace.current}");
                                        }
                                      }
                                      else{
                                        print("User not found");
                                      }

                                      //Getting information about the poster of the reply a user replied to:
                                      List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");
                                      var theReplyPoster = everyUser.firstWhere((user) => user["usernameLowercased"].toString() == (discussionBoardUpdatesPage.replyPosterUserIsReplyingToDbu).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theReplyPoster.isNotEmpty){
                                        var dbuReplyPosterData = theReplyPoster;
                                        var dbuReplyPosterDocName = dbuReplyPosterData["docId"] ?? "N/A";

                                        Map<String, dynamic> currentInfoOfDbuReplyPoster = Map<String, dynamic>.from(theReplyPoster["usernameProfileInformation"] ?? {});
                                        var dbuReplyPostersEmailAddress = currentInfoOfDbuReplyPoster["emailAddress"];

                                        //sendAnEmail(dbuReplyPostersEmailAddress, "Reply to Your Reply", "Hi ${discussionBoardUpdatesPage.replyPosterUserIsReplyingToDbu},<br><br>${myLoginStatus.myUsername} has replied to your reply from the Discussion Board Updates subforum thread titled ${discussionBoardUpdatesPage.titleOfThreadUserIsReplyingToDbu}. Here was the content of your reply: <br><br>${discussionBoardUpdatesPage.contentOfReplyUserIsReplyingToDbu}<br><br>This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                        sendReplyToReplyNotificationEmail(dbuReplyPostersEmailAddress, discussionBoardUpdatesPage.replyPosterUserIsReplyingToDbu, myLoginStatus.myUsername, "Discussion Board Updates", discussionBoardUpdatesPage.titleOfThreadUserIsReplyingToDbu, discussionBoardUpdatesPage.contentOfReplyUserIsReplyingToDbu, replyContentController.text);
                                        discussionBoardUpdatesPage.replyPosterUserIsReplyingToDbu = "";
                                        discussionBoardUpdatesPage.contentOfReplyUserIsReplyingToDbu = "";
                                        discussionBoardUpdatesPage.titleOfThreadUserIsReplyingToDbu = "";
                                        dbuReplyPostersEmailAddress = "";
                                      }
                                    }
                                    else{
                                      myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                      myInfoForReplies.docs.forEach((resultExistingUsername){
                                        userDataForReplies = resultExistingUsername.data();
                                        docNameForReplies = resultExistingUsername.id;
                                      });

                                      print("userData: ${userDataForReplies}");
                                      print("docName: ${docNameForReplies}");

                                      FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                                        "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                      }).then((a){
                                        print("You have updated the post number for the existing user!");
                                      });

                                      //Getting information about the poster of the thread a user replied to:
                                      var theReplyPoster = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (discussionBoardUpdatesPage.replyPosterUserIsReplyingToDbu).toLowerCase()).get();
                                      var dbuReplyPosterDocName = theReplyPoster.docs.first;
                                      var dbuReplyPostersEmailAddress = dbuReplyPosterDocName.get("emailAddress");

                                      //sendAnEmail(dbuReplyPostersEmailAddress, "Reply to Your Reply", "Hi ${discussionBoardUpdatesPage.replyPosterUserIsReplyingToDbu},<br><br>${myLoginStatus.myUsername} has replied to your reply from the Discussion Board Updates subforum thread titled ${discussionBoardUpdatesPage.titleOfThreadUserIsReplyingToDbu}. Here was the content of your reply: <br><br>${discussionBoardUpdatesPage.contentOfReplyUserIsReplyingToDbu}<br><br>This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                      sendReplyToReplyNotificationEmail(dbuReplyPostersEmailAddress, discussionBoardUpdatesPage.replyPosterUserIsReplyingToDbu, myLoginStatus.myUsername, "Discussion Board Updates", discussionBoardUpdatesPage.titleOfThreadUserIsReplyingToDbu, discussionBoardUpdatesPage.contentOfReplyUserIsReplyingToDbu, replyContentController.text);
                                      discussionBoardUpdatesPage.replyPosterUserIsReplyingToDbu = "";
                                      discussionBoardUpdatesPage.contentOfReplyUserIsReplyingToDbu = "";
                                      discussionBoardUpdatesPage.titleOfThreadUserIsReplyingToDbu = "";
                                      dbuReplyPostersEmailAddress = "";
                                    }
                                  }
                                }
                                else{
                                  pendingDiscussionBoardUpdatesReply.add("");
                                  pendingDiscussionBoardUpdatesReply.add("");
                                  print("I do not exist");
                                }

                                print(discussionBoardUpdatesPage.reversedDiscussionBoardUpdatesThreadsIterable);
                                print(discussionBoardUpdatesPage.discussionBoardUpdatesReplies);

                                //Getting the information of the thread one replied to
                                print("page number: ${discussionBoardUpdatesPage.myLocation}, index place: ${discussionBoardUpdatesPage.myIndexPlaceDbu}");

                                var dbuReplies = discussionBoardUpdatesPage.theDbuThreadReplies;

                                print("${discussionBoardUpdatesPage.threadAuthorDbu} + ${discussionBoardUpdatesPage.threadTitleDbu} + ${discussionBoardUpdatesPage.threadContentDbu} + ${discussionBoardUpdatesPage.threadID}");

                                //Getting documents
                                if(firebaseDesktopHelper.onDesktop){
                                  List<Map<String, dynamic>> allDbuThreads = await firebaseDesktopHelper.getFirestoreCollection("Discussion_Board_Updates");

                                  print("allDbuThreads: ${allDbuThreads}");

                                  var matchingThread = allDbuThreads.firstWhere((myDbuThread) => myDbuThread["threadId"] == int.parse(discussionBoardUpdatesPage.threadID), orElse: () => <String, dynamic>{},);

                                  print("matchingThread: ${matchingThread}");

                                  if(matchingThread.isNotEmpty){
                                    dbuDoc = matchingThread["docId"];
                                    print("dbuDoc: ${dbuDoc}");
                                  }

                                  //Adding something so dbuReplies can have some replies, especially ones users recently made.
                                  dbuReplies = await firebaseDesktopHelper.getFirestoreSubcollection("Discussion_Board_Updates", dbuDoc, "Replies");

                                  print("dbuReplies: ${dbuReplies}");

                                  dbuReplies.sort((b, a){
                                    DateTime aTime = firebaseDesktopHelper.convertStringToDateTime(a["time"]);
                                    DateTime bTime = firebaseDesktopHelper.convertStringToDateTime(b["time"]);
                                    return aTime.compareTo(bTime);
                                  });
                                }
                                else{
                                  await FirebaseFirestore.instance.collection("Discussion_Board_Updates").where("threadId", isEqualTo: int.parse(discussionBoardUpdatesPage.threadID)).get().then((d) {
                                    dbuDoc = d.docs.first.id;
                                    print(dbuDoc);
                                  });

                                  //Getting the replies of the thread one made a reply to
                                  //await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(dbuDoc).collection("Replies");//.add(oneReply);

                                  QuerySnapshot dbuRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Discussion_Board_Updates").doc(dbuDoc).collection("Replies").get();//.do//.docs.map((myDoc) => myDoc.data()).toList();;
                                  print("dbuReplies: ${dbuReplies.length}");
                                  dbuReplies = dbuRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                                  print("dbuReplies: ${dbuReplies.length}");
                                  (dbuReplies as List<dynamic>).sort((b, a) => (DateTime.parse(a["time"])).compareTo(DateTime.parse(b["time"])));
                                }

                                discussionBoardUpdatesPage.theDbuThreadReplies = dbuReplies;
                                print("discussionBoardUpdatesPage.theDbuThreadReplies: ${discussionBoardUpdatesPage.theDbuThreadReplies}");

                                fromDbuReply = true;

                                Navigator.pop(context, true);

                                discussionBoardUpdatesPage.discussionBoardUpdatesReplyBool = false;
                              }
                              if(questionsAndAnswersPage.questionsAndAnswersReplyBool == true){
                                //For the Questions and Answers subforum:
                                final questionsAndAnswersRepliesInfo = Get.put(questionsAndAnswersRepliesInformation());

                                final questionsAndAnswersRepliesToRepliesInfo = Get.put(questionsAndAnswersRepliesToRepliesInformation());

                                Future<void> createQuestionsAndAnswersReply(QuestionsAndAnswersReplies qaar, var docName) async{
                                  await questionsAndAnswersRepliesInfo.createMyQuestionsAndAnswersReply(qaar, docName);
                                }

                                Future<void> createQuestionsAndAnswersReplyToReply(QuestionsAndAnswersReplies qaar, var secondDocName) async{
                                  await questionsAndAnswersRepliesToRepliesInfo.createMyQuestionsAndAnswersReplyToReply(qaar, secondDocName);
                                }
                                if(questionsAndAnswersPage.questionsAndAnswersReplyingToReplyBool == false){
                                  threadNum = int.parse(questionsAndAnswersPage.threadID);
                                  assert(threadNum is int);
                                  print(threadNum.runtimeType);
                                  var myReplyQuestionsAndAnswers = QuestionsAndAnswersReplies(
                                      threadNumber: threadNum,
                                      time: DateTime.now().toUtc().toIso8601String(),
                                      replier: usernameReplyController.text,
                                      replyContent: replyContentController.text,
                                      theOriginalReplyInfo: {}
                                  );
                                  createQuestionsAndAnswersReply(myReplyQuestionsAndAnswers, questionsAndAnswersPage.myDocQaa);

                                  if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                    if(firebaseDesktopHelper.onDesktop){
                                      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                      var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theCorrectUser.isNotEmpty){
                                        userData = theCorrectUser;
                                        docName = theCorrectUser["docId"] ?? "N/A";

                                        print("userData: ${userData}");
                                        print("docName for your username: ${docName}");

                                        //Updating the document:
                                        try{
                                          //Getting the current information about a user:
                                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                          print("theCorrectUser: ${theCorrectUser}");
                                          print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                          print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                          print("Full user info: ${currentInfoOfUser}");
                                          print("Full user keys: ${currentInfoOfUser.keys}");

                                          //Incrementing the number of posts a user has:
                                          int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                          currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                          //Updating the information about a user:
                                          await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                            "usernameProfileInformation": currentInfoOfUser,
                                          });

                                          print("You have updated the number of posts for the user!");

                                          //Determining if the full document still has all of the fields
                                          List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                          var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                          print("The full document after the update: $theVerifiedUser");
                                        }
                                        catch (error){
                                          print("Error updating information of user: ${error}");
                                          print("Stack trace: ${StackTrace.current}");
                                        }
                                      }
                                      else{
                                        print("User not found");
                                      }

                                      //Getting information about the poster of the thread a user replied to:
                                      List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");
                                      var theThreadPoster = everyUser.firstWhere((user) => user["usernameLowercased"].toString() == (questionsAndAnswersPage.threadPosterUserIsReplyingToQaa).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theThreadPoster.isNotEmpty){
                                        var qaaThreadPosterData = theThreadPoster;
                                        var qaaThreadPosterDocName = qaaThreadPosterData["docId"] ?? "N/A";

                                        Map<String, dynamic> currentInfoOfQaaThreadPoster = Map<String, dynamic>.from(theThreadPoster["usernameProfileInformation"] ?? {});
                                        var qaaThreadPostersEmailAddress = currentInfoOfQaaThreadPoster["emailAddress"];

                                        //sendAnEmail(qaaThreadPostersEmailAddress, "Reply to Your Thread", "Hi ${questionsAndAnswersPage.threadPosterUserIsReplyingToQaa},<br><br>${myLoginStatus.myUsername} has replied to your thread from the Questions and Answers subforum titled ${questionsAndAnswersPage.titleOfThreadUserIsReplyingToQaa}. This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                        sendReplyToThreadNotificationEmail(qaaThreadPostersEmailAddress, questionsAndAnswersPage.threadPosterUserIsReplyingToQaa, myLoginStatus.myUsername, "Questions and Answers", questionsAndAnswersPage.titleOfThreadUserIsReplyingToQaa, replyContentController.text);
                                        questionsAndAnswersPage.threadPosterUserIsReplyingToQaa = "";
                                        questionsAndAnswersPage.titleOfThreadUserIsReplyingToQaa = "";
                                        qaaThreadPostersEmailAddress = "";
                                      }
                                    }
                                    else{
                                      myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                      myInfoForReplies.docs.forEach((resultExistingUsername){
                                        userDataForReplies = resultExistingUsername.data();
                                        docNameForReplies = resultExistingUsername.id;
                                      });

                                      print("userData: ${userDataForReplies}");
                                      print("docName: ${docNameForReplies}");

                                      FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                                        "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                      }).then((a){
                                        print("You have updated the post number for the existing user!");
                                      });

                                      //Getting information about the poster of the thread a user replied to:
                                      var theThreadPoster = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (questionsAndAnswersPage.threadPosterUserIsReplyingToQaa).toLowerCase()).get();
                                      var qaaThreadPosterDocName = theThreadPoster.docs.first;
                                      var qaaThreadPostersEmailAddress = qaaThreadPosterDocName.get("emailAddress");

                                      //sendAnEmail(qaaThreadPostersEmailAddress, "Reply to Your Thread", "Hi ${questionsAndAnswersPage.threadPosterUserIsReplyingToQaa},<br><br>${myLoginStatus.myUsername} has replied to your thread from the Questions and Answers subforum titled ${questionsAndAnswersPage.titleOfThreadUserIsReplyingToQaa}. This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                      sendReplyToThreadNotificationEmail(qaaThreadPostersEmailAddress, questionsAndAnswersPage.threadPosterUserIsReplyingToQaa, myLoginStatus.myUsername, "Questions and Answers", questionsAndAnswersPage.titleOfThreadUserIsReplyingToQaa, replyContentController.text);
                                      questionsAndAnswersPage.threadPosterUserIsReplyingToQaa = "";
                                      questionsAndAnswersPage.titleOfThreadUserIsReplyingToQaa = "";
                                      qaaThreadPostersEmailAddress = "";
                                    }
                                  }

                                  pendingQuestionsAndAnswersReply.add(DateTime.now().toUtc().toString());
                                  pendingQuestionsAndAnswersReply.add(usernameReplyController.text);
                                  pendingQuestionsAndAnswersReply.add(replyContentController.text);
                                }
                                else if(questionsAndAnswersPage.questionsAndAnswersReplyingToReplyBool == true){
                                  questionsAndAnswersPage.questionsAndAnswersReplyingToReplyBool = false;
                                  threadNum = int.parse(questionsAndAnswersPage.threadID);
                                  assert(threadNum is int);
                                  print(threadNum.runtimeType);
                                  replyNum = questionsAndAnswersPage.myIndex;
                                  var myReplyQuestionsAndAnswers = QuestionsAndAnswersReplies(
                                      threadNumber: threadNum,
                                      time: DateTime.now().toUtc().toIso8601String(),
                                      replier: usernameReplyController.text,
                                      replyContent: replyContentController.text,
                                      theOriginalReplyInfo: questionsAndAnswersPage.myReplyToReplyQaaMap
                                  );
                                  print("This is theOriginalReplyInfo: ${questionsAndAnswersPage.myReplyToReplyQaaMap}");
                                  createQuestionsAndAnswersReplyToReply(myReplyQuestionsAndAnswers, questionsAndAnswersPage.myDocQaa);

                                  if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                    if(firebaseDesktopHelper.onDesktop){
                                      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                      var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theCorrectUser.isNotEmpty){
                                        userData = theCorrectUser;
                                        docName = theCorrectUser["docId"] ?? "N/A";

                                        print("userData: ${userData}");
                                        print("docName for your username: ${docName}");

                                        //Updating the document:
                                        try{
                                          //Getting the current information about a user:
                                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                          print("theCorrectUser: ${theCorrectUser}");
                                          print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                          print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                          print("Full user info: ${currentInfoOfUser}");
                                          print("Full user keys: ${currentInfoOfUser.keys}");

                                          //Incrementing the number of posts a user has:
                                          int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                          currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                          //Updating the information about a user:
                                          await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                            "usernameProfileInformation": currentInfoOfUser,
                                          });

                                          print("You have updated the number of posts for the user!");

                                          //Determining if the full document still has all of the fields
                                          List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                          var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                          print("The full document after the update: $theVerifiedUser");
                                        }
                                        catch (error){
                                          print("Error updating information of user: ${error}");
                                          print("Stack trace: ${StackTrace.current}");
                                        }
                                      }
                                      else{
                                        print("User not found");
                                      }

                                      //Getting information about the poster of the reply a user replied to:
                                      List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");
                                      var theReplyPoster = everyUser.firstWhere((user) => user["usernameLowercased"].toString() == (questionsAndAnswersPage.replyPosterUserIsReplyingToQaa).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theReplyPoster.isNotEmpty){
                                        var qaaReplyPosterData = theReplyPoster;
                                        var qaaReplyPosterDocName = qaaReplyPosterData["docId"] ?? "N/A";

                                        Map<String, dynamic> currentInfoOfQaaReplyPoster = Map<String, dynamic>.from(theReplyPoster["usernameProfileInformation"] ?? {});
                                        var qaaReplyPostersEmailAddress = currentInfoOfQaaReplyPoster["emailAddress"];

                                        //sendAnEmail(qaaReplyPostersEmailAddress, "Reply to Your Reply", "Hi ${questionsAndAnswersPage.replyPosterUserIsReplyingToQaa},<br><br>${myLoginStatus.myUsername} has replied to your reply from the Questions and Answers subforum thread titled ${questionsAndAnswersPage.titleOfThreadUserIsReplyingToQaa}. Here was the content of your reply: <br><br>${questionsAndAnswersPage.contentOfReplyUserIsReplyingToQaa}<br><br>This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                        sendReplyToReplyNotificationEmail(qaaReplyPostersEmailAddress, questionsAndAnswersPage.replyPosterUserIsReplyingToQaa, myLoginStatus.myUsername, "Questions and Answers", questionsAndAnswersPage.titleOfThreadUserIsReplyingToQaa, questionsAndAnswersPage.contentOfReplyUserIsReplyingToQaa, replyContentController.text);
                                        questionsAndAnswersPage.replyPosterUserIsReplyingToQaa = "";
                                        questionsAndAnswersPage.contentOfReplyUserIsReplyingToQaa = "";
                                        questionsAndAnswersPage.titleOfThreadUserIsReplyingToQaa = "";
                                        qaaReplyPostersEmailAddress = "";
                                      }
                                    }
                                    else{
                                      myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                      myInfoForReplies.docs.forEach((resultExistingUsername){
                                        userDataForReplies = resultExistingUsername.data();
                                        docNameForReplies = resultExistingUsername.id;
                                      });

                                      print("userData: ${userDataForReplies}");
                                      print("docName: ${docNameForReplies}");

                                      FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                                        "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                      }).then((a){
                                        print("You have updated the post number for the existing user!");
                                      });

                                      //Getting information about the poster of the thread a user replied to:
                                      var theReplyPoster = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (questionsAndAnswersPage.replyPosterUserIsReplyingToQaa).toLowerCase()).get();
                                      var qaaReplyPosterDocName = theReplyPoster.docs.first;
                                      var qaaReplyPostersEmailAddress = qaaReplyPosterDocName.get("emailAddress");

                                      //sendAnEmail(qaaReplyPostersEmailAddress, "Reply to Your Reply", "Hi ${questionsAndAnswersPage.replyPosterUserIsReplyingToQaa},<br><br>${myLoginStatus.myUsername} has replied to your reply from the Questions and Answers subforum thread titled ${questionsAndAnswersPage.titleOfThreadUserIsReplyingToQaa}. Here was the content of your reply: <br><br>${questionsAndAnswersPage.contentOfReplyUserIsReplyingToQaa}<br><br>This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                      sendReplyToReplyNotificationEmail(qaaReplyPostersEmailAddress, questionsAndAnswersPage.replyPosterUserIsReplyingToQaa, myLoginStatus.myUsername, "Questions and Answers", questionsAndAnswersPage.titleOfThreadUserIsReplyingToQaa, questionsAndAnswersPage.contentOfReplyUserIsReplyingToQaa, replyContentController.text);
                                      questionsAndAnswersPage.replyPosterUserIsReplyingToQaa = "";
                                      questionsAndAnswersPage.contentOfReplyUserIsReplyingToQaa = "";
                                      questionsAndAnswersPage.titleOfThreadUserIsReplyingToQaa = "";
                                      qaaReplyPostersEmailAddress = "";
                                    }
                                  }
                                }
                                else{
                                  pendingQuestionsAndAnswersReply.add("");
                                  pendingQuestionsAndAnswersReply.add("");
                                  print("I do not exist");
                                }

                                print(questionsAndAnswersPage.reversedQuestionsAndAnswersThreadsIterable);
                                print(questionsAndAnswersPage.questionsAndAnswersReplies);

                                //Getting thread information
                                print("page number: ${questionsAndAnswersPage.myLocation}, index place: ${questionsAndAnswersPage.myIndexPlaceQaa}");

                                var qaaReplies = questionsAndAnswersPage.theQaaThreadReplies;

                                print("${questionsAndAnswersPage.threadAuthorQaa} + ${questionsAndAnswersPage.threadTitleQaa} + ${questionsAndAnswersPage.threadContentQaa} + ${questionsAndAnswersPage.threadID}");

                                //Getting documents
                                if(firebaseDesktopHelper.onDesktop){
                                  List<Map<String, dynamic>> allQaaThreads = await firebaseDesktopHelper.getFirestoreCollection("Questions_And_Answers");

                                  print("allQaaThreads: ${allQaaThreads}");

                                  var matchingThread = allQaaThreads.firstWhere((myQaaThread) => myQaaThread["threadId"] == int.parse(questionsAndAnswersPage.threadID), orElse: () => <String, dynamic>{},);

                                  print("matchingThread: ${matchingThread}");

                                  if(matchingThread.isNotEmpty){
                                    qaaDoc = matchingThread["docId"];
                                    print("qaaDoc: ${qaaDoc}");
                                  }

                                  //Adding something so qaaReplies can have some replies, especially ones users recently made.

                                  qaaReplies = await firebaseDesktopHelper.getFirestoreSubcollection("Questions_And_Answers", qaaDoc, "Replies");

                                  print("qaaReplies: ${qaaReplies}");

                                  qaaReplies.sort((b, a){
                                    DateTime aTime = firebaseDesktopHelper.convertStringToDateTime(a["time"]);
                                    DateTime bTime = firebaseDesktopHelper.convertStringToDateTime(b["time"]);
                                    return aTime.compareTo(bTime);
                                  });
                                }
                                else{
                                  await FirebaseFirestore.instance.collection("Questions_And_Answers").where("threadId", isEqualTo: int.parse(questionsAndAnswersPage.threadID)).get().then((d) {
                                    qaaDoc = d.docs.first.id;
                                    print(qaaDoc);
                                  });

                                  //Getting the replies of the thread one made a reply to

                                  QuerySnapshot qaaRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Questions_And_Answers").doc(qaaDoc).collection("Replies").get();
                                  print("qaaReplies: ${qaaReplies.length}");
                                  qaaReplies = qaaRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                                  print("qaaReplies: ${qaaReplies.length}");
                                  (qaaReplies as List<dynamic>).sort((b, a) => (DateTime.parse(a["time"])).compareTo(DateTime.parse(b["time"])));
                                }

                                questionsAndAnswersPage.theQaaThreadReplies = qaaReplies;

                                print("questionsAndAnswersPage.theQaaThreadReplies: ${questionsAndAnswersPage.theQaaThreadReplies}");

                                fromQaaReply = true;

                                Navigator.pop(context, true);

                                questionsAndAnswersPage.questionsAndAnswersReplyBool = false;
                              }
                              if(technologiesPage.technologiesReplyBool == true){
                                final technologiesRepliesInfo = Get.put(technologiesRepliesInformation());

                                final technologiesRepliesToRepliesInfo = Get.put(technologiesRepliesToRepliesInformation());

                                Future<void> createTechnologiesReply(TechnologiesReplies tr, var docName) async{
                                  await technologiesRepliesInfo.createMyTechnologiesReply(tr, docName);
                                }

                                Future<void> createTechnologiesReplyToReply(TechnologiesReplies tr, var secondDocName) async{
                                  await technologiesRepliesToRepliesInfo.createMyTechnologiesReplyToReply(tr, secondDocName);
                                }
                                if(technologiesPage.technologiesReplyingToReplyBool == false){
                                  threadNum = int.parse(technologiesPage.threadID);
                                  assert(threadNum is int);
                                  print(threadNum.runtimeType);
                                  var myReplyTechnologies = TechnologiesReplies(
                                      threadNumber: threadNum,
                                      time: DateTime.now().toUtc().toIso8601String(),
                                      replier: usernameReplyController.text,
                                      replyContent: replyContentController.text,
                                      theOriginalReplyInfo: {}
                                  );
                                  createTechnologiesReply(myReplyTechnologies, technologiesPage.myDocT);

                                  if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                    if(firebaseDesktopHelper.onDesktop){
                                      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                      var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theCorrectUser.isNotEmpty){
                                        userData = theCorrectUser;
                                        docName = theCorrectUser["docId"] ?? "N/A";

                                        print("userData: ${userData}");
                                        print("docName for your username: ${docName}");

                                        //Updating the document:
                                        try{
                                          //Getting the current information about a user:
                                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                          print("theCorrectUser: ${theCorrectUser}");
                                          print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                          print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                          print("Full user info: ${currentInfoOfUser}");
                                          print("Full user keys: ${currentInfoOfUser.keys}");

                                          //Incrementing the number of posts a user has:
                                          int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                          currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                          //Updating the information about a user:
                                          await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                            "usernameProfileInformation": currentInfoOfUser,
                                          });

                                          print("You have updated the number of posts for the user!");

                                          //Determining if the full document still has all of the fields
                                          List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                          var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                          print("The full document after the update: $theVerifiedUser");
                                        }
                                        catch (error){
                                          print("Error updating information of user: ${error}");
                                          print("Stack trace: ${StackTrace.current}");
                                        }
                                      }
                                      else{
                                        print("User not found");
                                      }

                                      //Getting information about the poster of the thread a user replied to:
                                      List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");
                                      var theThreadPoster = everyUser.firstWhere((user) => user["usernameLowercased"].toString() == (technologiesPage.threadPosterUserIsReplyingToT).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theThreadPoster.isNotEmpty){
                                        var tThreadPosterData = theThreadPoster;
                                        var tThreadPosterDocName = tThreadPosterData["docId"] ?? "N/A";

                                        Map<String, dynamic> currentInfoOfTThreadPoster = Map<String, dynamic>.from(theThreadPoster["usernameProfileInformation"] ?? {});
                                        var tThreadPostersEmailAddress = currentInfoOfTThreadPoster["emailAddress"];

                                        //sendAnEmail(tThreadPostersEmailAddress, "Reply to Your Thread", "Hi ${technologiesPage.threadPosterUserIsReplyingToT},<br><br>${myLoginStatus.myUsername} has replied to your thread from the Technologies subforum titled ${technologiesPage.titleOfThreadUserIsReplyingToT}. This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                        sendReplyToThreadNotificationEmail(tThreadPostersEmailAddress, technologiesPage.threadPosterUserIsReplyingToT, myLoginStatus.myUsername, "Technologies", technologiesPage.titleOfThreadUserIsReplyingToT, replyContentController.text);
                                        technologiesPage.threadPosterUserIsReplyingToT = "";
                                        technologiesPage.titleOfThreadUserIsReplyingToT = "";
                                        tThreadPostersEmailAddress = "";
                                      }
                                    }
                                    else{
                                      myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                      myInfoForReplies.docs.forEach((resultExistingUsername){
                                        userDataForReplies = resultExistingUsername.data();
                                        docNameForReplies = resultExistingUsername.id;
                                      });

                                      print("userData: ${userDataForReplies}");
                                      print("docName: ${docNameForReplies}");

                                      FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                                        "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                      }).then((a){
                                        print("You have updated the post number for the existing user!");
                                      });

                                      //Getting information about the poster of the thread a user replied to:
                                      var theThreadPoster = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (technologiesPage.threadPosterUserIsReplyingToT).toLowerCase()).get();
                                      var tThreadPosterDocName = theThreadPoster.docs.first;
                                      var tThreadPostersEmailAddress = tThreadPosterDocName.get("emailAddress");

                                      //sendAnEmail(tThreadPostersEmailAddress, "Reply to Your Thread", "Hi ${technologiesPage.threadPosterUserIsReplyingToT},<br><br>${myLoginStatus.myUsername} has replied to your thread from the Technologies subforum titled ${technologiesPage.titleOfThreadUserIsReplyingToT}. This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                      sendReplyToThreadNotificationEmail(tThreadPostersEmailAddress, technologiesPage.threadPosterUserIsReplyingToT, myLoginStatus.myUsername, "Technologies", technologiesPage.titleOfThreadUserIsReplyingToT, replyContentController.text);
                                      technologiesPage.threadPosterUserIsReplyingToT = "";
                                      technologiesPage.titleOfThreadUserIsReplyingToT = "";
                                      tThreadPostersEmailAddress = "";
                                    }
                                  }

                                  pendingTechnologiesReply.add(DateTime.now().toUtc().toString());
                                  pendingTechnologiesReply.add(usernameReplyController.text);
                                  pendingTechnologiesReply.add(replyContentController.text);
                                }
                                else if(technologiesPage.technologiesReplyingToReplyBool == true){
                                  technologiesPage.technologiesReplyingToReplyBool = false;
                                  threadNum = int.parse(technologiesPage.threadID);
                                  assert(threadNum is int);
                                  print(threadNum.runtimeType);
                                  replyNum = technologiesPage.myIndex;
                                  var myReplyTechnologies = TechnologiesReplies(
                                      threadNumber: threadNum,
                                      time: DateTime.now().toUtc().toIso8601String(),
                                      replier: usernameReplyController.text,
                                      replyContent: replyContentController.text,
                                      theOriginalReplyInfo: technologiesPage.myReplyToReplyTMap
                                  );
                                  print("This is theOriginalReplyInfo: ${technologiesPage.myReplyToReplyTMap}");
                                  createTechnologiesReplyToReply(myReplyTechnologies, technologiesPage.myDocT);

                                  if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                    if(firebaseDesktopHelper.onDesktop){
                                      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                      var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theCorrectUser.isNotEmpty){
                                        userData = theCorrectUser;
                                        docName = theCorrectUser["docId"] ?? "N/A";

                                        print("userData: ${userData}");
                                        print("docName for your username: ${docName}");

                                        //Updating the document:
                                        try{
                                          //Getting the current information about a user:
                                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                          print("theCorrectUser: ${theCorrectUser}");
                                          print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                          print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                          print("Full user info: ${currentInfoOfUser}");
                                          print("Full user keys: ${currentInfoOfUser.keys}");

                                          //Incrementing the number of posts a user has:
                                          int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                          currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                          //Updating the information about a user:
                                          await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                            "usernameProfileInformation": currentInfoOfUser,
                                          });

                                          print("You have updated the number of posts for the user!");

                                          //Determining if the full document still has all of the fields
                                          List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                          var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                          print("The full document after the update: $theVerifiedUser");
                                        }
                                        catch (error){
                                          print("Error updating information of user: ${error}");
                                          print("Stack trace: ${StackTrace.current}");
                                        }
                                      }
                                      else{
                                        print("User not found");
                                      }

                                      //Getting information about the poster of the reply a user replied to:
                                      List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");
                                      var theReplyPoster = everyUser.firstWhere((user) => user["usernameLowercased"].toString() == (technologiesPage.replyPosterUserIsReplyingToT).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theReplyPoster.isNotEmpty){
                                        var tReplyPosterData = theReplyPoster;
                                        var tReplyPosterDocName = tReplyPosterData["docId"] ?? "N/A";

                                        Map<String, dynamic> currentInfoOfTReplyPoster = Map<String, dynamic>.from(theReplyPoster["usernameProfileInformation"] ?? {});
                                        var tReplyPostersEmailAddress = currentInfoOfTReplyPoster["emailAddress"];

                                        //sendAnEmail(tReplyPostersEmailAddress, "Reply to Your Reply", "Hi ${technologiesPage.replyPosterUserIsReplyingToT},<br><br>${myLoginStatus.myUsername} has replied to your reply from the Technologies subforum thread titled ${technologiesPage.titleOfThreadUserIsReplyingToT}. Here was the content of your reply: <br><br>${technologiesPage.contentOfReplyUserIsReplyingToT}<br><br>This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                        sendReplyToReplyNotificationEmail(tReplyPostersEmailAddress, technologiesPage.replyPosterUserIsReplyingToT, myLoginStatus.myUsername, "Technologies", technologiesPage.titleOfThreadUserIsReplyingToT, technologiesPage.contentOfReplyUserIsReplyingToT, replyContentController.text);
                                        technologiesPage.replyPosterUserIsReplyingToT = "";
                                        technologiesPage.contentOfReplyUserIsReplyingToT = "";
                                        technologiesPage.titleOfThreadUserIsReplyingToT = "";
                                        tReplyPostersEmailAddress = "";
                                      }
                                    }
                                    else{
                                      myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                      myInfoForReplies.docs.forEach((resultExistingUsername){
                                        userDataForReplies = resultExistingUsername.data();
                                        docNameForReplies = resultExistingUsername.id;
                                      });

                                      print("userData: ${userDataForReplies}");
                                      print("docName: ${docNameForReplies}");

                                      FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                                        "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                      }).then((a){
                                        print("You have updated the post number for the existing user!");
                                      });

                                      //Getting information about the poster of the thread a user replied to:
                                      var theReplyPoster = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (technologiesPage.replyPosterUserIsReplyingToT).toLowerCase()).get();
                                      var tReplyPosterDocName = theReplyPoster.docs.first;
                                      var tReplyPostersEmailAddress = tReplyPosterDocName.get("emailAddress");

                                      //sendAnEmail(tReplyPostersEmailAddress, "Reply to Your Reply", "Hi ${technologiesPage.replyPosterUserIsReplyingToT},<br><br>${myLoginStatus.myUsername} has replied to your reply from the Technologies subforum thread titled ${technologiesPage.titleOfThreadUserIsReplyingToT}. Here was the content of your reply: <br><br>${technologiesPage.contentOfReplyUserIsReplyingToT}<br><br>This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                      sendReplyToReplyNotificationEmail(tReplyPostersEmailAddress, technologiesPage.replyPosterUserIsReplyingToT, myLoginStatus.myUsername, "Technologies", technologiesPage.titleOfThreadUserIsReplyingToT, technologiesPage.contentOfReplyUserIsReplyingToT, replyContentController.text);
                                      technologiesPage.replyPosterUserIsReplyingToT = "";
                                      technologiesPage.contentOfReplyUserIsReplyingToT = "";
                                      technologiesPage.titleOfThreadUserIsReplyingToT = "";
                                      tReplyPostersEmailAddress = "";
                                    }
                                  }
                                }
                                else{
                                  pendingTechnologiesReply.add("");
                                  pendingTechnologiesReply.add("");
                                  print("I do not exist");
                                }
                                print(technologiesPage.reversedTechnologiesThreadsIterable);
                                print(technologiesPage.technologiesReplies);

                                //Getting thread information
                                print("page number: ${technologiesPage.myLocation}, index place: ${technologiesPage.myIndexPlaceTechnologies}");

                                var technologiesReplies = technologiesPage.theTThreadReplies;

                                //Getting documents
                                if(firebaseDesktopHelper.onDesktop){
                                  List<Map<String, dynamic>> allTThreads = await firebaseDesktopHelper.getFirestoreCollection("Technologies");

                                  print("allTThreads: ${allTThreads}");

                                  var matchingThread = allTThreads.firstWhere((myTThread) => myTThread["threadId"] == int.parse(technologiesPage.threadID), orElse: () => <String, dynamic>{},);

                                  print("matchingThread: ${matchingThread}");

                                  if(matchingThread.isNotEmpty){
                                    technologiesDoc = matchingThread["docId"];
                                    print("technologiesDoc: ${technologiesDoc}");
                                  }

                                  //Adding something so technologiesReplies can have some replies, especially ones users recently made.

                                  technologiesReplies = await firebaseDesktopHelper.getFirestoreSubcollection("Technologies", technologiesDoc, "Replies");

                                  print("tReplies: ${technologiesReplies}");

                                  technologiesReplies.sort((b, a){
                                    DateTime aTime = firebaseDesktopHelper.convertStringToDateTime(a["time"]);
                                    DateTime bTime = firebaseDesktopHelper.convertStringToDateTime(b["time"]);
                                    return aTime.compareTo(bTime);
                                  });
                                }
                                else{
                                  await FirebaseFirestore.instance.collection("Technologies").where("threadId", isEqualTo: int.parse(technologiesPage.threadID)).get().then((d) {
                                    technologiesDoc = d.docs.first.id;
                                    print(technologiesDoc);
                                  });

                                  //Getting the replies of the thread one made a reply to

                                  QuerySnapshot technologiesRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Technologies").doc(technologiesDoc).collection("Replies").get();
                                  print("technologiesReplies: ${technologiesReplies.length}");
                                  technologiesReplies = technologiesRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                                  print("technologiesReplies: ${technologiesReplies.length}");
                                  (technologiesReplies as List<dynamic>).sort((b, a) => (DateTime.parse(a["time"])).compareTo(DateTime.parse(b["time"])));
                                }

                                technologiesPage.theTThreadReplies = technologiesReplies;

                                fromTechnologiesReply = true;

                                Navigator.pop(context, true);

                                technologiesPage.technologiesReplyBool = false;
                              }
                              if(projectsPage.projectsReplyBool == true){
                                final projectsRepliesInfo = Get.put(projectsRepliesInformation());

                                final projectsRepliesToRepliesInfo = Get.put(projectsRepliesToRepliesInformation());

                                Future<void> createProjectsReply(ProjectsReplies pr, var docName) async{
                                  await projectsRepliesInfo.createMyProjectsReply(pr, docName);
                                }

                                Future<void> createProjectsReplyToReply(ProjectsReplies pr, var secondDocName) async{
                                  await projectsRepliesToRepliesInfo.createMyProjectsReplyToReply(pr, secondDocName);
                                }
                                if(projectsPage.projectsReplyingToReplyBool == false){
                                  threadNum = int.parse(projectsPage.threadID);
                                  assert(threadNum is int);
                                  print(threadNum.runtimeType);
                                  var myReplyProjects = ProjectsReplies(
                                      threadNumber: threadNum,
                                      time: DateTime.now().toUtc().toIso8601String(),
                                      replier: usernameReplyController.text,
                                      replyContent: replyContentController.text,
                                      theOriginalReplyInfo: {}
                                  );
                                  createProjectsReply(myReplyProjects, projectsPage.myDocP);

                                  if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                    if(firebaseDesktopHelper.onDesktop){
                                      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                      var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theCorrectUser.isNotEmpty){
                                        userData = theCorrectUser;
                                        docName = theCorrectUser["docId"] ?? "N/A";

                                        print("userData: ${userData}");
                                        print("docName for your username: ${docName}");

                                        //Updating the document:
                                        try{
                                          //Getting the current information about a user:
                                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                          print("theCorrectUser: ${theCorrectUser}");
                                          print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                          print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                          print("Full user info: ${currentInfoOfUser}");
                                          print("Full user keys: ${currentInfoOfUser.keys}");

                                          //Incrementing the number of posts a user has:
                                          int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                          currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                          //Updating the information about a user:
                                          await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                            "usernameProfileInformation": currentInfoOfUser,
                                          });

                                          print("You have updated the number of posts for the user!");

                                          //Determining if the full document still has all of the fields
                                          List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                          var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                          print("The full document after the update: $theVerifiedUser");
                                        }
                                        catch (error){
                                          print("Error updating information of user: ${error}");
                                          print("Stack trace: ${StackTrace.current}");
                                        }
                                      }
                                      else{
                                        print("User not found");
                                      }

                                      //Getting information about the poster of the thread a user replied to:
                                      List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");
                                      var theThreadPoster = everyUser.firstWhere((user) => user["usernameLowercased"].toString() == (projectsPage.threadPosterUserIsReplyingToP).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theThreadPoster.isNotEmpty){
                                        var pThreadPosterData = theThreadPoster;
                                        var pThreadPosterDocName = pThreadPosterData["docId"] ?? "N/A";

                                        Map<String, dynamic> currentInfoOfPThreadPoster = Map<String, dynamic>.from(theThreadPoster["usernameProfileInformation"] ?? {});
                                        var pThreadPostersEmailAddress = currentInfoOfPThreadPoster["emailAddress"];

                                        //sendAnEmail(pThreadPostersEmailAddress, "Reply to Your Thread", "Hi ${projectsPage.threadPosterUserIsReplyingToP},<br><br>${myLoginStatus.myUsername} has replied to your thread from the Projects subforum titled ${projectsPage.titleOfThreadUserIsReplyingToP}. This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                        sendReplyToThreadNotificationEmail(pThreadPostersEmailAddress, projectsPage.threadPosterUserIsReplyingToP, myLoginStatus.myUsername, "Technologies", projectsPage.titleOfThreadUserIsReplyingToP, replyContentController.text);
                                        projectsPage.threadPosterUserIsReplyingToP = "";
                                        projectsPage.titleOfThreadUserIsReplyingToP = "";
                                        pThreadPostersEmailAddress = "";
                                      }
                                    }
                                    else{
                                      myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                      myInfoForReplies.docs.forEach((resultExistingUsername){
                                        userDataForReplies = resultExistingUsername.data();
                                        docNameForReplies = resultExistingUsername.id;
                                      });

                                      print("userData: ${userDataForReplies}");
                                      print("docName: ${docNameForReplies}");

                                      FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                                        "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                      }).then((a){
                                        print("You have updated the post number for the existing user!");
                                      });

                                      //Getting information about the poster of the thread a user replied to:
                                      var theThreadPoster = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (projectsPage.threadPosterUserIsReplyingToP).toLowerCase()).get();
                                      var pThreadPosterDocName = theThreadPoster.docs.first;
                                      var pThreadPostersEmailAddress = pThreadPosterDocName.get("emailAddress");

                                      //sendAnEmail(pThreadPostersEmailAddress, "Reply to Your Thread", "Hi ${projectsPage.threadPosterUserIsReplyingToP},<br><br>${myLoginStatus.myUsername} has replied to your thread from the Projects subforum titled ${projectsPage.titleOfThreadUserIsReplyingToP}. This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                      sendReplyToThreadNotificationEmail(pThreadPostersEmailAddress, projectsPage.threadPosterUserIsReplyingToP, myLoginStatus.myUsername, "Technologies", projectsPage.titleOfThreadUserIsReplyingToP, replyContentController.text);
                                      projectsPage.threadPosterUserIsReplyingToP = "";
                                      projectsPage.titleOfThreadUserIsReplyingToP = "";
                                      pThreadPostersEmailAddress = "";
                                    }
                                  }

                                  pendingProjectsReply.add(DateTime.now().toUtc().toString());
                                  pendingProjectsReply.add(usernameReplyController.text);
                                  pendingProjectsReply.add(replyContentController.text);
                                }
                                else if(projectsPage.projectsReplyingToReplyBool == true){
                                  projectsPage.projectsReplyingToReplyBool = false;
                                  threadNum = int.parse(projectsPage.threadID);
                                  assert(threadNum is int);
                                  print(threadNum.runtimeType);
                                  replyNum = projectsPage.myIndex;
                                  var myReplyProjects = ProjectsReplies(
                                      threadNumber: threadNum,
                                      time: DateTime.now().toUtc().toIso8601String(),
                                      replier: usernameReplyController.text,
                                      replyContent: replyContentController.text,
                                      theOriginalReplyInfo: projectsPage.myReplyToReplyPMap
                                  );
                                  print("This is theOriginalReplyInfo: ${projectsPage.myReplyToReplyPMap}");
                                  createProjectsReplyToReply(myReplyProjects, projectsPage.myDocP);

                                  if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                    if(firebaseDesktopHelper.onDesktop){
                                      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                      var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theCorrectUser.isNotEmpty){
                                        userData = theCorrectUser;
                                        docName = theCorrectUser["docId"] ?? "N/A";

                                        print("userData: ${userData}");
                                        print("docName for your username: ${docName}");

                                        //Updating the document:
                                        try{
                                          //Getting the current information about a user:
                                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                          print("theCorrectUser: ${theCorrectUser}");
                                          print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                          print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                          print("Full user info: ${currentInfoOfUser}");
                                          print("Full user keys: ${currentInfoOfUser.keys}");

                                          //Incrementing the number of posts a user has:
                                          int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                          currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                          //Updating the information about a user:
                                          await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                            "usernameProfileInformation": currentInfoOfUser,
                                          });

                                          print("You have updated the number of posts for the user!");

                                          //Determining if the full document still has all of the fields
                                          List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                          var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                          print("The full document after the update: $theVerifiedUser");
                                        }
                                        catch (error){
                                          print("Error updating information of user: ${error}");
                                          print("Stack trace: ${StackTrace.current}");
                                        }
                                      }
                                      else{
                                        print("User not found");
                                      }

                                      //Getting information about the poster of the reply a user replied to:
                                      List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");
                                      var theReplyPoster = everyUser.firstWhere((user) => user["usernameLowercased"].toString() == (projectsPage.replyPosterUserIsReplyingToP).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theReplyPoster.isNotEmpty){
                                        var pReplyPosterData = theReplyPoster;
                                        var pReplyPosterDocName = pReplyPosterData["docId"] ?? "N/A";

                                        Map<String, dynamic> currentInfoOfPReplyPoster = Map<String, dynamic>.from(theReplyPoster["usernameProfileInformation"] ?? {});
                                        var pReplyPostersEmailAddress = currentInfoOfPReplyPoster["emailAddress"];

                                        //sendAnEmail(pReplyPostersEmailAddress, "Reply to Your Reply", "Hi ${projectsPage.replyPosterUserIsReplyingToP},<br><br>${myLoginStatus.myUsername} has replied to your reply from the Projects subforum thread titled ${projectsPage.titleOfThreadUserIsReplyingToP}. Here was the content of your reply: <br><br>${projectsPage.contentOfReplyUserIsReplyingToP}<br><br>This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                        sendReplyToReplyNotificationEmail(pReplyPostersEmailAddress, projectsPage.replyPosterUserIsReplyingToP, myLoginStatus.myUsername, "Projects", projectsPage.titleOfThreadUserIsReplyingToP, projectsPage.contentOfReplyUserIsReplyingToP, replyContentController.text);
                                        projectsPage.replyPosterUserIsReplyingToP = "";
                                        projectsPage.contentOfReplyUserIsReplyingToP = "";
                                        projectsPage.titleOfThreadUserIsReplyingToP = "";
                                        pReplyPostersEmailAddress = "";
                                      }
                                    }
                                    else{
                                      myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                      myInfoForReplies.docs.forEach((resultExistingUsername){
                                        userDataForReplies = resultExistingUsername.data();
                                        docNameForReplies = resultExistingUsername.id;
                                      });

                                      print("userData: ${userDataForReplies}");
                                      print("docName: ${docNameForReplies}");

                                      FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                                        "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                      }).then((a){
                                        print("You have updated the post number for the existing user!");
                                      });

                                      //Getting information about the poster of the thread a user replied to:
                                      var theReplyPoster = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (projectsPage.replyPosterUserIsReplyingToP).toLowerCase()).get();
                                      var pReplyPosterDocName = theReplyPoster.docs.first;
                                      var pReplyPostersEmailAddress = pReplyPosterDocName.get("emailAddress");

                                      //sendAnEmail(pReplyPostersEmailAddress, "Reply to Your Reply", "Hi ${projectsPage.replyPosterUserIsReplyingToP},<br><br>${myLoginStatus.myUsername} has replied to your reply from the Projects subforum thread titled ${projectsPage.titleOfThreadUserIsReplyingToP}. Here was the content of your reply: <br><br>${projectsPage.contentOfReplyUserIsReplyingToP}<br><br>This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                      sendReplyToReplyNotificationEmail(pReplyPostersEmailAddress, projectsPage.replyPosterUserIsReplyingToP, myLoginStatus.myUsername, "Projects", projectsPage.titleOfThreadUserIsReplyingToP, projectsPage.contentOfReplyUserIsReplyingToP, replyContentController.text);
                                      projectsPage.replyPosterUserIsReplyingToP = "";
                                      projectsPage.contentOfReplyUserIsReplyingToP = "";
                                      projectsPage.titleOfThreadUserIsReplyingToP = "";
                                      pReplyPostersEmailAddress = "";
                                    }
                                  }
                                }
                                else{
                                  pendingProjectsReply.add("");
                                  pendingProjectsReply.add("");
                                  print("I do not exist");
                                }
                                print(projectsPage.reversedProjectsThreadsIterable);
                                print(projectsPage.projectsReplies);

                                //Getting thread information
                                print("page number: ${projectsPage.myLocation}, index place: ${projectsPage.myIndexPlaceProjects}");

                                var projectsReplies = projectsPage.thePThreadReplies;

                                print("${projectsPage.threadAuthorP} + ${projectsPage.threadTitleP} + ${projectsPage.threadContentP} + ${projectsPage.threadID}");

                                if(firebaseDesktopHelper.onDesktop){
                                  List<Map<String, dynamic>> allProjectsThreads = await firebaseDesktopHelper.getFirestoreCollection("Projects");

                                  print("allProjectsThreads: ${allProjectsThreads}");

                                  var matchingThread = allProjectsThreads.firstWhere((myProjectsThread) => myProjectsThread["threadId"] == int.parse(projectsPage.threadID), orElse: () => <String, dynamic>{},);

                                  print("matchingThread: ${matchingThread}");

                                  if(matchingThread.isNotEmpty){
                                    projectsDoc = matchingThread["docId"];
                                    print("projectsDoc: ${projectsDoc}");
                                  }

                                  //Adding something so projectsReplies can have some replies, especially ones users recently made.

                                  projectsReplies = await firebaseDesktopHelper.getFirestoreSubcollection("Projects", projectsDoc, "Replies");

                                  print("projectsReplies: ${projectsReplies}");

                                  projectsReplies.sort((b, a){
                                    DateTime aTime = firebaseDesktopHelper.convertStringToDateTime(a["time"]);
                                    DateTime bTime = firebaseDesktopHelper.convertStringToDateTime(b["time"]);
                                    return aTime.compareTo(bTime);
                                  });
                                }
                                else{
                                  //Getting documents
                                  await FirebaseFirestore.instance.collection("Projects").where("threadId", isEqualTo: int.parse(projectsPage.threadID)).get().then((d) {
                                    projectsDoc = d.docs.first.id;
                                    print(projectsDoc);
                                  });

                                  //Getting the replies of the thread one made a reply to
                                  QuerySnapshot projectsRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Projects").doc(projectsDoc).collection("Replies").get();
                                  print("projectsReplies: ${projectsReplies.length}");
                                  projectsReplies = projectsRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                                  print("projectsReplies: ${projectsReplies.length}");
                                  (projectsReplies as List<dynamic>).sort((b, a) => (DateTime.parse(a["time"])).compareTo(DateTime.parse(b["time"])));
                                }

                                projectsPage.thePThreadReplies = projectsReplies;

                                fromProjectsReply = true;

                                //Navigator.push(context, MaterialPageRoute(builder: (context) => const projectsPage.projectsThreadsPage()));
                                Navigator.pop(context, true);

                                projectsPage.projectsReplyBool = false;
                              }
                              if(newDiscoveriesPage.newDiscoveriesReplyBool == true){
                                final newDiscoveriesRepliesInfo = Get.put(newDiscoveriesRepliesInformation());

                                final newDiscoveriesRepliesToRepliesInfo = Get.put(newDiscoveriesRepliesToRepliesInformation());

                                Future<void> createNewDiscoveriesReply(NewDiscoveriesReplies ndr, var docName) async{
                                  await newDiscoveriesRepliesInfo.createMyNewDiscoveriesReply(ndr, docName);
                                }

                                Future<void> createNewDiscoveriesReplyToReply(NewDiscoveriesReplies ndr, var secondDocName) async{
                                  await newDiscoveriesRepliesToRepliesInfo.createMyNewDiscoveriesReplyToReply(ndr, secondDocName);
                                }
                                if(newDiscoveriesPage.newDiscoveriesReplyingToReplyBool == false){
                                  threadNum = int.parse(newDiscoveriesPage.threadID);
                                  assert(threadNum is int);
                                  print(threadNum.runtimeType);
                                  var myReplyNewDiscoveries = NewDiscoveriesReplies(
                                      threadNumber: threadNum,
                                      time: DateTime.now().toUtc().toIso8601String(),
                                      replier: usernameReplyController.text,
                                      replyContent: replyContentController.text,
                                      theOriginalReplyInfo: {}
                                  );
                                  createNewDiscoveriesReply(myReplyNewDiscoveries, newDiscoveriesPage.myDocNd);

                                  if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                    if(firebaseDesktopHelper.onDesktop){
                                      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                      var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theCorrectUser.isNotEmpty){
                                        userData = theCorrectUser;
                                        docName = theCorrectUser["docId"] ?? "N/A";

                                        print("userData: ${userData}");
                                        print("docName for your username: ${docName}");

                                        //Updating the document:
                                        try{
                                          //Getting the current information about a user:
                                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                          print("theCorrectUser: ${theCorrectUser}");
                                          print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                          print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                          print("Full user info: ${currentInfoOfUser}");
                                          print("Full user keys: ${currentInfoOfUser.keys}");

                                          //Incrementing the number of posts a user has:
                                          int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                          currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                          //Updating the information about a user:
                                          await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                            "usernameProfileInformation": currentInfoOfUser,
                                          });

                                          print("You have updated the number of posts for the user!");

                                          //Determining if the full document still has all of the fields
                                          List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                          var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                          print("The full document after the update: $theVerifiedUser");
                                        }
                                        catch (error){
                                          print("Error updating information of user: ${error}");
                                          print("Stack trace: ${StackTrace.current}");
                                        }
                                      }
                                      else{
                                        print("User not found");
                                      }

                                      //Getting information about the poster of the thread a user replied to:
                                      List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");
                                      var theThreadPoster = everyUser.firstWhere((user) => user["usernameLowercased"].toString() == (newDiscoveriesPage.threadPosterUserIsReplyingToNd).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theThreadPoster.isNotEmpty){
                                        var ndThreadPosterData = theThreadPoster;
                                        var ndThreadPosterDocName = ndThreadPosterData["docId"] ?? "N/A";

                                        Map<String, dynamic> currentInfoOfNdThreadPoster = Map<String, dynamic>.from(theThreadPoster["usernameProfileInformation"] ?? {});
                                        var ndThreadPostersEmailAddress = currentInfoOfNdThreadPoster["emailAddress"];

                                        //sendAnEmail(ndThreadPostersEmailAddress, "Reply to Your Thread", "Hi ${newDiscoveriesPage.threadPosterUserIsReplyingToNd},<br><br>${myLoginStatus.myUsername} has replied to your thread from the New Discoveries subforum titled ${newDiscoveriesPage.titleOfThreadUserIsReplyingToNd}. This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                        sendReplyToThreadNotificationEmail(ndThreadPostersEmailAddress, newDiscoveriesPage.threadPosterUserIsReplyingToNd, myLoginStatus.myUsername, "New Discoveries", newDiscoveriesPage.titleOfThreadUserIsReplyingToNd, replyContentController.text);
                                        newDiscoveriesPage.threadPosterUserIsReplyingToNd = "";
                                        newDiscoveriesPage.titleOfThreadUserIsReplyingToNd = "";
                                        ndThreadPostersEmailAddress = "";
                                      }
                                    }
                                    else{
                                      myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                      myInfoForReplies.docs.forEach((resultExistingUsername){
                                        userDataForReplies = resultExistingUsername.data();
                                        docNameForReplies = resultExistingUsername.id;
                                      });

                                      print("userData: ${userDataForReplies}");
                                      print("docName: ${docNameForReplies}");

                                      FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                                        "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                      }).then((a){
                                        print("You have updated the post number for the existing user!");
                                      });

                                      //Getting information about the poster of the thread a user replied to:
                                      var theThreadPoster = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (newDiscoveriesPage.threadPosterUserIsReplyingToNd).toLowerCase()).get();
                                      var ndThreadPosterDocName = theThreadPoster.docs.first;
                                      var ndThreadPostersEmailAddress = ndThreadPosterDocName.get("emailAddress");

                                      //sendAnEmail(ndThreadPostersEmailAddress, "Reply to Your Thread", "Hi ${newDiscoveriesPage.threadPosterUserIsReplyingToNd},<br><br>${myLoginStatus.myUsername} has replied to your thread from the New Discoveries subforum titled ${newDiscoveriesPage.titleOfThreadUserIsReplyingToNd}. This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                      sendReplyToThreadNotificationEmail(ndThreadPostersEmailAddress, newDiscoveriesPage.threadPosterUserIsReplyingToNd, myLoginStatus.myUsername, "New Discoveries", newDiscoveriesPage.titleOfThreadUserIsReplyingToNd, replyContentController.text);
                                      newDiscoveriesPage.threadPosterUserIsReplyingToNd = "";
                                      newDiscoveriesPage.titleOfThreadUserIsReplyingToNd = "";
                                      ndThreadPostersEmailAddress = "";
                                    }
                                  }

                                  pendingNewDiscoveriesReply.add(DateTime.now().toUtc().toString());
                                  pendingNewDiscoveriesReply.add(usernameReplyController.text);
                                  pendingNewDiscoveriesReply.add(replyContentController.text);
                                }
                                else if(newDiscoveriesPage.newDiscoveriesReplyingToReplyBool == true){
                                  newDiscoveriesPage.newDiscoveriesReplyingToReplyBool = false;
                                  threadNum = int.parse(newDiscoveriesPage.threadID);
                                  assert(threadNum is int);
                                  print(threadNum.runtimeType);
                                  replyNum = newDiscoveriesPage.myIndex;
                                  var myReplyNewDiscoveries = NewDiscoveriesReplies(
                                      threadNumber: threadNum,
                                      time: DateTime.now().toUtc().toIso8601String(),
                                      replier: usernameReplyController.text,
                                      replyContent: replyContentController.text,
                                      theOriginalReplyInfo: newDiscoveriesPage.myReplyToReplyNdMap
                                  );
                                  print("This is theOriginalReplyInfo: ${newDiscoveriesPage.myReplyToReplyNdMap}");
                                  createNewDiscoveriesReplyToReply(myReplyNewDiscoveries, newDiscoveriesPage.myDocNd);

                                  if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                    if(firebaseDesktopHelper.onDesktop){
                                      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                      var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theCorrectUser.isNotEmpty){
                                        userData = theCorrectUser;
                                        docName = theCorrectUser["docId"] ?? "N/A";

                                        print("userData: ${userData}");
                                        print("docName for your username: ${docName}");

                                        //Updating the document:
                                        try{
                                          //Getting the current information about a user:
                                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                          print("theCorrectUser: ${theCorrectUser}");
                                          print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                          print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                          print("Full user info: ${currentInfoOfUser}");
                                          print("Full user keys: ${currentInfoOfUser.keys}");

                                          //Incrementing the number of posts a user has:
                                          int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                          currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                          //Updating the information about a user:
                                          await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                            "usernameProfileInformation": currentInfoOfUser,
                                          });

                                          print("You have updated the number of posts for the user!");

                                          //Determining if the full document still has all of the fields
                                          List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                          var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                          print("The full document after the update: $theVerifiedUser");
                                        }
                                        catch (error){
                                          print("Error updating information of user: ${error}");
                                          print("Stack trace: ${StackTrace.current}");
                                        }
                                      }
                                      else{
                                        print("User not found");
                                      }

                                      //Getting information about the poster of the reply a user replied to:
                                      List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");
                                      var theReplyPoster = everyUser.firstWhere((user) => user["usernameLowercased"].toString() == (newDiscoveriesPage.replyPosterUserIsReplyingToNd).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theReplyPoster.isNotEmpty){
                                        var ndReplyPosterData = theReplyPoster;
                                        var ndReplyPosterDocName = ndReplyPosterData["docId"] ?? "N/A";

                                        Map<String, dynamic> currentInfoOfNdReplyPoster = Map<String, dynamic>.from(theReplyPoster["usernameProfileInformation"] ?? {});
                                        var ndReplyPostersEmailAddress = currentInfoOfNdReplyPoster["emailAddress"];

                                        //sendAnEmail(ndReplyPostersEmailAddress, "Reply to Your Reply", "Hi ${newDiscoveriesPage.replyPosterUserIsReplyingToNd},<br><br>${myLoginStatus.myUsername} has replied to your reply from the New Discoveries subforum thread titled ${newDiscoveriesPage.titleOfThreadUserIsReplyingToNd}. Here was the content of your reply: <br><br>${newDiscoveriesPage.contentOfReplyUserIsReplyingToNd}<br><br>This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                        sendReplyToReplyNotificationEmail(ndReplyPostersEmailAddress, newDiscoveriesPage.replyPosterUserIsReplyingToNd, myLoginStatus.myUsername, "New Discoveries", newDiscoveriesPage.titleOfThreadUserIsReplyingToNd, newDiscoveriesPage.contentOfReplyUserIsReplyingToNd, replyContentController.text);
                                        newDiscoveriesPage.replyPosterUserIsReplyingToNd = "";
                                        newDiscoveriesPage.contentOfReplyUserIsReplyingToNd = "";
                                        newDiscoveriesPage.titleOfThreadUserIsReplyingToNd = "";
                                        ndReplyPostersEmailAddress = "";
                                      }
                                    }
                                    else{
                                      myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                      myInfoForReplies.docs.forEach((resultExistingUsername){
                                        userDataForReplies = resultExistingUsername.data();
                                        docNameForReplies = resultExistingUsername.id;
                                      });

                                      print("userData: ${userDataForReplies}");
                                      print("docName: ${docNameForReplies}");

                                      FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                                        "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                      }).then((a){
                                        print("You have updated the post number for the existing user!");
                                      });

                                      //Getting information about the poster of the thread a user replied to:
                                      var theReplyPoster = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (newDiscoveriesPage.replyPosterUserIsReplyingToNd).toLowerCase()).get();
                                      var ndReplyPosterDocName = theReplyPoster.docs.first;
                                      var ndReplyPostersEmailAddress = ndReplyPosterDocName.get("emailAddress");

                                      //sendAnEmail(ndReplyPostersEmailAddress, "Reply to Your Reply", "Hi ${newDiscoveriesPage.replyPosterUserIsReplyingToNd},<br><br>${myLoginStatus.myUsername} has replied to your reply from the New Discoveries subforum thread titled ${newDiscoveriesPage.titleOfThreadUserIsReplyingToNd}. Here was the content of your reply: <br><br>${newDiscoveriesPage.contentOfReplyUserIsReplyingToNd}<br><br>This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                      sendReplyToReplyNotificationEmail(ndReplyPostersEmailAddress, newDiscoveriesPage.replyPosterUserIsReplyingToNd, myLoginStatus.myUsername, "New Discoveries", newDiscoveriesPage.titleOfThreadUserIsReplyingToNd, newDiscoveriesPage.contentOfReplyUserIsReplyingToNd, replyContentController.text);
                                      newDiscoveriesPage.replyPosterUserIsReplyingToNd = "";
                                      newDiscoveriesPage.contentOfReplyUserIsReplyingToNd = "";
                                      newDiscoveriesPage.titleOfThreadUserIsReplyingToNd = "";
                                      ndReplyPostersEmailAddress = "";
                                    }
                                  }
                                }
                                else{
                                  pendingNewDiscoveriesReply.add("");
                                  pendingNewDiscoveriesReply.add("");
                                  print("I do not exist");
                                }
                                print(newDiscoveriesPage.reversedNewDiscoveriesThreadsIterable);
                                print(newDiscoveriesPage.newDiscoveriesReplies);

                                //Getting thread information
                                print("page number: ${newDiscoveriesPage.myLocation}, index place: ${newDiscoveriesPage.myIndexPlaceNewDiscoveries}");

                                var newDiscoveriesReplies = newDiscoveriesPage.theNdThreadReplies;

                                print("${newDiscoveriesPage.threadAuthorNd} + ${newDiscoveriesPage.threadTitleNd} + ${newDiscoveriesPage.threadContentNd} + ${newDiscoveriesPage.threadID}");

                                //Getting documents
                                if(firebaseDesktopHelper.onDesktop){
                                  List<Map<String, dynamic>> allNdThreads = await firebaseDesktopHelper.getFirestoreCollection("New_Discoveries");

                                  print("allNdThreads: ${allNdThreads}");

                                  var matchingThread = allNdThreads.firstWhere((myNdThread) => myNdThread["threadId"] == int.parse(newDiscoveriesPage.threadID), orElse: () => <String, dynamic>{},);

                                  print("matchingThread: ${matchingThread}");

                                  if(matchingThread.isNotEmpty){
                                    ndDoc = matchingThread["docId"];
                                    print("ndDoc: ${ndDoc}");
                                  }
                                  //Adding something so ndReplies can have some replies, especially ones users recently made.
                                  newDiscoveriesReplies = await firebaseDesktopHelper.getFirestoreSubcollection("New_Discoveries", ndDoc, "Replies");
                                  print("newDiscoveriesReplies: ${newDiscoveriesReplies}");
                                  newDiscoveriesReplies.sort((b, a){
                                    DateTime aTime = firebaseDesktopHelper.convertStringToDateTime(a["time"]);
                                    DateTime bTime = firebaseDesktopHelper.convertStringToDateTime(b["time"]);
                                    return aTime.compareTo(bTime);
                                  });
                                }
                                else{
                                  await FirebaseFirestore.instance.collection("New_Discoveries").where("threadId", isEqualTo: int.parse(newDiscoveriesPage.threadID)).get().then((d) {
                                    ndDoc = d.docs.first.id;
                                    print(ndDoc);
                                  });

                                  //Getting the replies of the thread one made a reply to:
                                  QuerySnapshot newDiscoveriesRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("New_Discoveries").doc(ndDoc).collection("Replies").get();
                                  print("newDiscoveriesReplies: ${newDiscoveriesReplies.length}");
                                  newDiscoveriesReplies = newDiscoveriesRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                                  print("newDiscoveriesReplies: ${newDiscoveriesReplies.length}");
                                  (newDiscoveriesReplies as List<dynamic>).sort((b, a) => (DateTime.parse(a["time"])).compareTo(DateTime.parse(b["time"])));
                                }

                                newDiscoveriesPage.theNdThreadReplies = newDiscoveriesReplies;

                                fromNdReply = true;

                                Navigator.pop(context, true);

                                newDiscoveriesPage.newDiscoveriesReplyBool = false;
                              }
                              if(feedbackAndSuggestionsPage.fasReplyBool == true){
                                final feedbackAndSuggestionsRepliesInfo = Get.put(feedbackAndSuggestionsRepliesInformation());

                                final feedbackAndSuggestionsRepliesToRepliesInfo = Get.put(feedbackAndSuggestionsRepliesToRepliesInformation());

                                Future<void> createFeedbackAndSuggestionsReply(FeedbackAndSuggestionsReplies fasr, var docName) async{
                                  await feedbackAndSuggestionsRepliesInfo.createMyFeedbackAndSuggestionsReply(fasr, docName);
                                }

                                Future<void> createFeedbackAndSuggestionsReplyToReply(FeedbackAndSuggestionsReplies fasr, var secondDocName) async{
                                  await feedbackAndSuggestionsRepliesToRepliesInfo.createMyFeedbackAndSuggestionsReplyToReply(fasr, secondDocName);
                                }
                                if(feedbackAndSuggestionsPage.fasReplyingToReplyBool == false){
                                  threadNum = int.parse(feedbackAndSuggestionsPage.threadID);
                                  assert(threadNum is int);
                                  print(threadNum.runtimeType);
                                  var myReplyFeedbackAndSuggestions = FeedbackAndSuggestionsReplies(
                                      threadNumber: threadNum,
                                      time: DateTime.now().toUtc().toIso8601String(),
                                      replier: usernameReplyController.text,
                                      replyContent: replyContentController.text,
                                      theOriginalReplyInfo: {}
                                  );
                                  createFeedbackAndSuggestionsReply(myReplyFeedbackAndSuggestions, feedbackAndSuggestionsPage.myDocFas);

                                  if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                    if(firebaseDesktopHelper.onDesktop){
                                      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                      var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theCorrectUser.isNotEmpty){
                                        userData = theCorrectUser;
                                        docName = theCorrectUser["docId"] ?? "N/A";

                                        print("userData: ${userData}");
                                        print("docName for your username: ${docName}");

                                        //Updating the document:
                                        try{
                                          //Getting the current information about a user:
                                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                          print("theCorrectUser: ${theCorrectUser}");
                                          print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                          print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                          print("Full user info: ${currentInfoOfUser}");
                                          print("Full user keys: ${currentInfoOfUser.keys}");

                                          //Incrementing the number of posts a user has:
                                          int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                          currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                          //Updating the information about a user:
                                          await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                            "usernameProfileInformation": currentInfoOfUser,
                                          });

                                          print("You have updated the number of posts for the user!");

                                          //Determining if the full document still has all of the fields
                                          List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                          var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                          print("The full document after the update: $theVerifiedUser");
                                        }
                                        catch (error){
                                          print("Error updating information of user: ${error}");
                                          print("Stack trace: ${StackTrace.current}");
                                        }
                                      }
                                      else{
                                        print("User not found");
                                      }

                                      //Getting information about the poster of the thread a user replied to:
                                      List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");
                                      var theThreadPoster = everyUser.firstWhere((user) => user["usernameLowercased"].toString() == (feedbackAndSuggestionsPage.threadPosterUserIsReplyingToFas).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theThreadPoster.isNotEmpty){
                                        var fasThreadPosterData = theThreadPoster;
                                        var fasThreadPosterDocName = fasThreadPosterData["docId"] ?? "N/A";

                                        Map<String, dynamic> currentInfoOfFasThreadPoster = Map<String, dynamic>.from(theThreadPoster["usernameProfileInformation"] ?? {});
                                        var fasThreadPostersEmailAddress = currentInfoOfFasThreadPoster["emailAddress"];

                                        //sendAnEmail(fasThreadPostersEmailAddress, "Reply to Your Thread", "Hi ${feedbackAndSuggestionsPage.threadPosterUserIsReplyingToFas},<br><br>${myLoginStatus.myUsername} has replied to your thread from the Feedback and Suggestions subforum titled ${feedbackAndSuggestionsPage.titleOfThreadUserIsReplyingToFas}. This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                        sendReplyToThreadNotificationEmail(fasThreadPostersEmailAddress, feedbackAndSuggestionsPage.threadPosterUserIsReplyingToFas, myLoginStatus.myUsername, "Feedback and Suggestions", feedbackAndSuggestionsPage.titleOfThreadUserIsReplyingToFas, replyContentController.text);
                                        feedbackAndSuggestionsPage.threadPosterUserIsReplyingToFas = "";
                                        feedbackAndSuggestionsPage.titleOfThreadUserIsReplyingToFas = "";
                                        fasThreadPostersEmailAddress = "";
                                      }
                                    }
                                    else{
                                      myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                      myInfoForReplies.docs.forEach((resultExistingUsername){
                                        userDataForReplies = resultExistingUsername.data();
                                        docNameForReplies = resultExistingUsername.id;
                                      });

                                      print("userData: ${userDataForReplies}");
                                      print("docName: ${docNameForReplies}");

                                      FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                                        "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                      }).then((a){
                                        print("You have updated the post number for the existing user!");
                                      });

                                      //Getting information about the poster of the thread a user replied to:
                                      var theThreadPoster = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (feedbackAndSuggestionsPage.threadPosterUserIsReplyingToFas).toLowerCase()).get();
                                      var fasThreadPosterDocName = theThreadPoster.docs.first;
                                      var fasThreadPostersEmailAddress = fasThreadPosterDocName.get("emailAddress");

                                      //sendAnEmail(fasThreadPostersEmailAddress, "Reply to Your Thread", "Hi ${feedbackAndSuggestionsPage.threadPosterUserIsReplyingToFas},<br><br>${myLoginStatus.myUsername} has replied to your thread from the Feedback and Suggestions subforum titled ${feedbackAndSuggestionsPage.titleOfThreadUserIsReplyingToFas}. This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                      sendReplyToThreadNotificationEmail(fasThreadPostersEmailAddress, feedbackAndSuggestionsPage.threadPosterUserIsReplyingToFas, myLoginStatus.myUsername, "Feedback and Suggestions", feedbackAndSuggestionsPage.titleOfThreadUserIsReplyingToFas, replyContentController.text);
                                      feedbackAndSuggestionsPage.threadPosterUserIsReplyingToFas = "";
                                      feedbackAndSuggestionsPage.titleOfThreadUserIsReplyingToFas = "";
                                      fasThreadPostersEmailAddress = "";
                                    }
                                  }

                                  pendingFeedbackAndSuggestionsReply.add(DateTime.now().toUtc().toString());
                                  pendingFeedbackAndSuggestionsReply.add(usernameReplyController.text);
                                  pendingFeedbackAndSuggestionsReply.add(replyContentController.text);
                                }
                                else if(feedbackAndSuggestionsPage.fasReplyingToReplyBool == true){
                                  feedbackAndSuggestionsPage.fasReplyingToReplyBool = false;
                                  threadNum = int.parse(feedbackAndSuggestionsPage.threadID);
                                  assert(threadNum is int);
                                  print(threadNum.runtimeType);
                                  replyNum = feedbackAndSuggestionsPage.myIndex;
                                  var myReplyFeedbackAndSuggestions = FeedbackAndSuggestionsReplies(
                                      threadNumber: threadNum,
                                      time: DateTime.now().toUtc().toIso8601String(),
                                      replier: usernameReplyController.text,
                                      replyContent: replyContentController.text,
                                      theOriginalReplyInfo: feedbackAndSuggestionsPage.myReplyToReplyFasMap
                                  );
                                  print("This is theOriginalReplyInfo: ${feedbackAndSuggestionsPage.myReplyToReplyFasMap}");
                                  createFeedbackAndSuggestionsReplyToReply(myReplyFeedbackAndSuggestions, feedbackAndSuggestionsPage.myDocFas);

                                  if(myLoginStatus.userIsLoggedIn == true && myLoginStatus.myUsername != ""){
                                    if(firebaseDesktopHelper.onDesktop){
                                      List<Map<String, dynamic>> allUsers = await firebaseDesktopHelper.getFirestoreCollection("User");

                                      var theCorrectUser = allUsers.firstWhere((user) => user["usernameLowercased"].toString() == (myLoginStatus.myUsername).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theCorrectUser.isNotEmpty){
                                        userData = theCorrectUser;
                                        docName = theCorrectUser["docId"] ?? "N/A";

                                        print("userData: ${userData}");
                                        print("docName for your username: ${docName}");

                                        //Updating the document:
                                        try{
                                          //Getting the current information about a user:
                                          Map<String, dynamic> currentInfoOfUser = Map<String, dynamic>.from(theCorrectUser["usernameProfileInformation"] ?? {});

                                          print("theCorrectUser: ${theCorrectUser}");
                                          print("Value of numberOfPosts: ${currentInfoOfUser["numberOfPosts"]}");
                                          print("Runtime type of numberOfPosts: ${currentInfoOfUser["numberOfPosts"].runtimeType}");
                                          print("Full user info: ${currentInfoOfUser}");
                                          print("Full user keys: ${currentInfoOfUser.keys}");

                                          //Incrementing the number of posts a user has:
                                          int currentPostsForUser = currentInfoOfUser["numberOfPosts"];
                                          currentInfoOfUser["numberOfPosts"] = currentPostsForUser + 1;

                                          //Updating the information about a user:
                                          await firebaseDesktopHelper.updateFirestoreDocument("User/$docName", {
                                            "usernameProfileInformation": currentInfoOfUser,
                                          });

                                          print("You have updated the number of posts for the user!");

                                          //Determining if the full document still has all of the fields
                                          List<Map<String, dynamic>> myVerify = await firebaseDesktopHelper.getFirestoreCollection("User");
                                          var theVerifiedUser = myVerify.firstWhere((user) => user["docId"] == docName);
                                          print("The full document after the update: $theVerifiedUser");
                                        }
                                        catch (error){
                                          print("Error updating information of user: ${error}");
                                          print("Stack trace: ${StackTrace.current}");
                                        }
                                      }
                                      else{
                                        print("User not found");
                                      }

                                      //Getting information about the poster of the reply a user replied to:
                                      List<Map<String, dynamic>> everyUser = await firebaseDesktopHelper.getFirestoreCollection("User");
                                      var theReplyPoster = everyUser.firstWhere((user) => user["usernameLowercased"].toString() == (feedbackAndSuggestionsPage.replyPosterUserIsReplyingToFas).toLowerCase(), orElse: () => <String, dynamic>{});

                                      if(theReplyPoster.isNotEmpty){
                                        var fasReplyPosterData = theReplyPoster;
                                        var fasReplyPosterDocName = fasReplyPosterData["docId"] ?? "N/A";

                                        Map<String, dynamic> currentInfoOfFasReplyPoster = Map<String, dynamic>.from(theReplyPoster["usernameProfileInformation"] ?? {});
                                        var fasReplyPostersEmailAddress = currentInfoOfFasReplyPoster["emailAddress"];

                                        //sendAnEmail(fasReplyPostersEmailAddress, "Reply to Your Reply", "Hi ${feedbackAndSuggestionsPage.replyPosterUserIsReplyingToFas},<br><br>${myLoginStatus.myUsername} has replied to your reply from the Feedback and Suggestions subforum thread titled ${feedbackAndSuggestionsPage.titleOfThreadUserIsReplyingToFas}. Here was the content of your reply: <br><br>${feedbackAndSuggestionsPage.contentOfReplyUserIsReplyingToFas}<br><br>This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                        sendReplyToReplyNotificationEmail(fasReplyPostersEmailAddress, feedbackAndSuggestionsPage.replyPosterUserIsReplyingToFas, myLoginStatus.myUsername, "Feedback and Suggestions", feedbackAndSuggestionsPage.titleOfThreadUserIsReplyingToFas, feedbackAndSuggestionsPage.contentOfReplyUserIsReplyingToFas, replyContentController.text);
                                        feedbackAndSuggestionsPage.replyPosterUserIsReplyingToFas = "";
                                        feedbackAndSuggestionsPage.contentOfReplyUserIsReplyingToFas = "";
                                        feedbackAndSuggestionsPage.titleOfThreadUserIsReplyingToFas = "";
                                        fasReplyPostersEmailAddress = "";
                                      }
                                    }
                                    else{
                                      myInfoForReplies = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (myLoginStatus.myUsername).toLowerCase()).get();
                                      myInfoForReplies.docs.forEach((resultExistingUsername){
                                        userDataForReplies = resultExistingUsername.data();
                                        docNameForReplies = resultExistingUsername.id;
                                      });

                                      print("userData: ${userDataForReplies}");
                                      print("docName: ${docNameForReplies}");

                                      FirebaseFirestore.instance.collection("User").doc(docNameForReplies).update({
                                        "usernameProfileInformation.numberOfPosts": FieldValue.increment(1),
                                      }).then((a){
                                        print("You have updated the post number for the existing user!");
                                      });

                                      //Getting information about the poster of the thread a user replied to:
                                      var theReplyPoster = await FirebaseFirestore.instance.collection("User").where("usernameLowercased", isEqualTo: (feedbackAndSuggestionsPage.replyPosterUserIsReplyingToFas).toLowerCase()).get();
                                      var fasReplyPosterDocName = theReplyPoster.docs.first;
                                      var fasReplyPostersEmailAddress = fasReplyPosterDocName.get("emailAddress");

                                      //sendAnEmail(fasReplyPostersEmailAddress, "Reply to Your Reply", "Hi ${feedbackAndSuggestionsPage.replyPosterUserIsReplyingToFas},<br><br>${myLoginStatus.myUsername} has replied to your reply from the Feedback and Suggestions subforum thread titled ${feedbackAndSuggestionsPage.titleOfThreadUserIsReplyingToFas}. Here was the content of your reply: <br><br>${feedbackAndSuggestionsPage.contentOfReplyUserIsReplyingToFas}<br><br>This was what he or she has said: <br><br>${replyContentController.text}<br><br>Best,<br>Star Expedition");
                                      sendReplyToReplyNotificationEmail(fasReplyPostersEmailAddress, feedbackAndSuggestionsPage.replyPosterUserIsReplyingToFas, myLoginStatus.myUsername, "Feedback and Suggestions", feedbackAndSuggestionsPage.titleOfThreadUserIsReplyingToFas, feedbackAndSuggestionsPage.contentOfReplyUserIsReplyingToFas, replyContentController.text);
                                      feedbackAndSuggestionsPage.replyPosterUserIsReplyingToFas = "";
                                      feedbackAndSuggestionsPage.contentOfReplyUserIsReplyingToFas = "";
                                      feedbackAndSuggestionsPage.titleOfThreadUserIsReplyingToFas = "";
                                      fasReplyPostersEmailAddress = "";
                                    }
                                  }
                                }
                                else{
                                  pendingFeedbackAndSuggestionsReply.add("");
                                  pendingFeedbackAndSuggestionsReply.add("");
                                  print("I do not exist");
                                }
                                print(feedbackAndSuggestionsPage.reversedFasThreadsIterable);
                                print(feedbackAndSuggestionsPage.fasReplies);

                                //Getting thread information
                                print("page number: ${feedbackAndSuggestionsPage.myLocation}, index place: ${feedbackAndSuggestionsPage.myIndexPlaceFas}");

                                var feedbackAndSuggestionsReplies = feedbackAndSuggestionsPage.theFasThreadReplies;

                                print("${feedbackAndSuggestionsPage.threadAuthorFas} + ${feedbackAndSuggestionsPage.threadTitleFas} + ${feedbackAndSuggestionsPage.threadContentFas} + ${feedbackAndSuggestionsPage.threadID}");

                                //Getting documents
                                if(firebaseDesktopHelper.onDesktop){
                                  List<Map<String, dynamic>> allFasThreads = await firebaseDesktopHelper.getFirestoreCollection("Feedback_And_Suggestions");

                                  print("allFasThreads: ${allFasThreads}");

                                  var matchingThread = allFasThreads.firstWhere((myFasThread) => myFasThread["threadId"] == int.parse(feedbackAndSuggestionsPage.threadID), orElse: () => <String, dynamic>{},);

                                  print("matchingThread: ${matchingThread}");

                                  if(matchingThread.isNotEmpty){
                                    fasDoc = matchingThread["docId"];
                                    print("fasDoc: ${fasDoc}");
                                  }

                                  //Adding something so dbuReplies can have some replies, especially ones users recently made.
                                  feedbackAndSuggestionsReplies = await firebaseDesktopHelper.getFirestoreSubcollection("Feedback_And_Suggestions", fasDoc, "Replies");

                                  print("feedbackAndSuggestionsReplies: ${feedbackAndSuggestionsReplies}");

                                  feedbackAndSuggestionsReplies.sort((b, a){
                                    DateTime aTime = firebaseDesktopHelper.convertStringToDateTime(a["time"]);
                                    DateTime bTime = firebaseDesktopHelper.convertStringToDateTime(b["time"]);
                                    return aTime.compareTo(bTime);
                                  });
                                }
                                else{
                                  await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").where("threadId", isEqualTo: int.parse(feedbackAndSuggestionsPage.threadID)).get().then((d) {
                                    fasDoc = d.docs.first.id;
                                    print(fasDoc);
                                  });

                                  //Getting the replies of the thread one made a reply to
                                  QuerySnapshot feedbackAndSuggestionsRepliesQuerySnapshot = await FirebaseFirestore.instance.collection("Feedback_And_Suggestions").doc(fasDoc).collection("Replies").get();
                                  print("feedbackAndSuggestionsReplies: ${feedbackAndSuggestionsReplies.length}");
                                  feedbackAndSuggestionsReplies = feedbackAndSuggestionsRepliesQuerySnapshot.docs.map((replies) => replies.data()).toList();
                                  print("feedbackAndSuggestionsReplies: ${feedbackAndSuggestionsReplies.length}");
                                  (feedbackAndSuggestionsReplies as List<dynamic>).sort((b, a) => (DateTime.parse(a["time"])).compareTo(DateTime.parse(b["time"])));
                                }

                                feedbackAndSuggestionsPage.theFasThreadReplies = feedbackAndSuggestionsReplies;

                                fromFasReply = true;

                                Navigator.pop(context, true);

                                feedbackAndSuggestionsPage.fasReplyBool = false;
                              }
                            }
                            else{
                              replyInfo.add(usernameReplyController.text);
                              replyInfo.add(replyContentController.text);

                              messageReplyThread = createReplyDialogMessage(replyInfo);

                              myMain.myAccessCheckNotifier.value = DateTime.now();

                              showDialog(
                                  context: context,
                                  builder: (BuildContext myContext){
                                    return AlertDialog(
                                      title: const Text("Unable to post thread"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: List.generate(messageReplyThread.length, (i){
                                          return messageReplyThread[i];
                                        }),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => {
                                            Navigator.pop(context),
                                          },
                                          child: const Text("Ok"),
                                        ),
                                      ],
                                    );
                                  }
                              );
                            }
                          }
                          finally{
                            if(mounted){
                              postingAReply = false;
                            }
                          }
                          if(mounted){
                            setState(() => replyButton = false);
                          }
                        }
                    ),
                  ),
                ),
                Container(
                  height: 350,
                ),
              ],
            ),
          ),
      ),
    );
  }
}