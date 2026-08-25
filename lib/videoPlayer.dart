import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:starexpedition4/spectralClassPage.dart';

import 'package:starexpedition4/main.dart' as myMain;
import 'package:starexpedition4/discussionBoardPage.dart';
import 'package:starexpedition4/loginPage.dart';
import 'package:starexpedition4/registerPage.dart';
import 'package:starexpedition4/loginPage.dart' as theLoginPage;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';
import 'package:video_player/video_player.dart';

//A global registry that makes sure that only one video plays at a time:
class videoPlayerRegistry{
  static VoidCallback? currentStopCallback;

  //Method that stops what was playing previously:
  static void registerActive(VoidCallback stopCallback){
    currentStopCallback?.call();
    currentStopCallback = stopCallback;
  }

  static void unregister(VoidCallback stopCallback){
    if(currentStopCallback == stopCallback){
      currentStopCallback = null;
    }
  }
}

class videoPlayer extends StatefulWidget{
  final String myUrl;
  const videoPlayer({required this.myUrl, super.key});

  @override
  State<videoPlayer> createState() => videoPlayerState();
}

class videoPlayerState extends State<videoPlayer>{
  VideoPlayerController? myVideoController;
  bool isInitializing = false;
  bool failed = false;
  bool isPlaying = false;

  Future<void> initializeAndPlayVideo() async{
    setState((){
      isInitializing = true;
      failed = false;
    });

    try{
      //Telling the registry you are about to become active (this stops any video that is currently playing before starting to play another video):
      videoPlayerRegistry.registerActive(stopAndRelease);

      final myController = VideoPlayerController.networkUrl(Uri.parse(widget.myUrl));

      await myController.initialize();

      if(!mounted){
        myController.dispose();
        return;
      }

      setState((){
        myVideoController = myController;
        isInitializing = false;
        isPlaying = true;
      });

      myController.play();
    }
    catch(e){
      if(mounted){
        setState((){
          isInitializing = false;
          failed = true;
        });
      }
    }
  }

  void togglePlayPause(){
    if(myVideoController == null){
      return;
    }

    setState((){
      if(myVideoController!.value.isPlaying){
        myVideoController!.pause();
        isPlaying = false;
      }
      else{
        //If you are resuming the video:
        //videoPlayerRegistry.registerActive(stopAndRelease);
        myVideoController!.play();
        isPlaying = true;
      }
    });
  }

  void stopAndRelease(){
    myVideoController?.pause();
    myVideoController?.dispose();
    videoPlayerRegistry.unregister(stopAndRelease);

    setState((){
      myVideoController = null;
      isPlaying = false;
    });
  }

  @override
  void dispose(){
    videoPlayerRegistry.unregister(stopAndRelease);
    myVideoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext bc){
    if(myVideoController != null && myVideoController!.value.isInitialized){
      return AspectRatio(
        aspectRatio: myVideoController!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
              onTap: togglePlayPause,
              child: VideoPlayer(myVideoController!),
            ),
            VideoProgressIndicator(myVideoController!, allowScrubbing: true),
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: stopAndRelease,
              ),
            ),
            if(!isPlaying)
              Center(
                child: IgnorePointer(
                  child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
                ),
              ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: isInitializing ? null : initializeAndPlayVideo,
      child: Container(
        height: 200,
        color: Colors.black,
        child: Center(
          child: isInitializing ?
          CircularProgressIndicator() :
          failed ?
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Unfortunately, there was an error."),
              TextButton(
                onPressed: initializeAndPlayVideo,
                child: Text("Retry"),
              ),
            ],
          ) :
          IgnorePointer(
            child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
          ),
        ),
      ),
    );
  }
}