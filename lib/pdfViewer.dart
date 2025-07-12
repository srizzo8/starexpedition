import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
//import 'dart:js';
import 'dart:math';
//import 'dart:html';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:starexpedition4/spectralClassPage.dart';

import 'package:starexpedition4/discussionBoardPage.dart';
import 'package:starexpedition4/loginPage.dart';
import 'package:starexpedition4/registerPage.dart';
import 'package:starexpedition4/loginPage.dart' as theLoginPage;
import 'package:flutter/services.dart' show FilteringTextInputFormatter, rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';
import 'package:starexpedition4/spectralClassPage.dart';
import 'package:starexpedition4/whyStarExpeditionWasMade.dart';
import 'package:starexpedition4/conversionCalculator.dart';
import 'package:starexpedition4/settingsPage.dart';
import 'package:starexpedition4/userProfile.dart';
import 'package:starexpedition4/userSearchBar.dart';

import 'loginPage.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:starexpedition4/main.dart' as myMain;

import 'package:http/http.dart' as http;

import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

class pdfViewer extends StatefulWidget{
  const pdfViewer({Key? key}) : super(key: key);

  @override
  pdfViewerState createState() => pdfViewerState();
}

class pdfViewerState extends State<pdfViewer>{
  TextEditingController starPdfPageController = TextEditingController();
  int myStarPdfPage = 0;
  int totalStarPdfPages = 0;
  List<PDFPage?> starPdfPages = [];
  late PageController starPageController;
  late int myStarPageNumber;
  List<Text> myStarPdfMessage = [];

  TextEditingController planetPdfPageController = TextEditingController();
  int myPlanetPdfPage = 0;
  int totalPlanetPdfPages = 0;
  List<PDFPage?> planetPdfPages = [];
  late PageController planetPageController;
  late int myPlanetPageNumber;
  List<Text> myPlanetPdfMessage = [];

  void goToStarPdfPage({int? myPage}){
    starPageController.jumpToPage(myPage != null ? myPage : myStarPageNumber - 1);
  }

  void animateToStarPdfPage({int? myPage}){
    starPageController.animateToPage(myPage != null ? myPage : myStarPageNumber - 1, duration: Duration(milliseconds: 150), curve: Curves.easeIn);
  }

  void goToPlanetPdfPage({int? myPage}){
    planetPageController.jumpToPage(myPage != null ? myPage : myPlanetPageNumber - 1);
  }

  void animateToPlanetPdfPage({int? myPage}){
    planetPageController.animateToPage(myPage != null ? myPage : myPlanetPageNumber - 1, duration: Duration(milliseconds: 150), curve: Curves.easeIn);
  }

  bool checkNumbersOnly(String num){
    List<String> validCharacters = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];

    for(int i = 0; i < num.length; i++){
      if(!(validCharacters.contains(num[i]))){
        return false;
      }
    }

    return true;
  }

  List<Text> pdfDialogMessage(String s, String t){
    List<Text> messageForUser = [];

    print("this is s: $s");
    print("this is t: $t");

    if(s == ""){
      messageForUser.add(Text("Page number cannot be left blank"));
    }
    else if(s != ""){
      if(checkNumbersOnly(s) == true && (int.parse(s) < 1 || int.parse(s) > int.parse(t))){
        messageForUser.add(Text("Page number is invalid"));
      }
      else{
        //continue
      }
    }
    return messageForUser;
  }

  @override
  Widget build(BuildContext bc){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () =>{
              if(myMain.starPdfBool == true){
                myMain.starPdfBool = false,
                Navigator.pop(bc),
              }
              else if(myMain.planetPdfBool == true){
                myMain.planetPdfBool = false,
                myMain.myPlanetPdfFile = null,
                Navigator.pop(bc),
              }
            }
        ),
      ),
      body: myMain.starPdfBool == true && myMain.planetPdfBool == false?
      Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder(
                  future: myMain.myStarPdfFile,
                  builder: (bc, snapshot){
                    if(snapshot.hasData){
                      starPdfPages = List.filled((snapshot.data as PDFDocument).count, null);
                      starPageController = PageController();
                      myStarPageNumber = starPageController.initialPage + 1;
                      print(starPdfPages.length);
                      print(myStarPageNumber);
                      totalStarPdfPages = (snapshot.data as PDFDocument).count;
                      return PDFViewer(
                        document: snapshot.data as PDFDocument,
                        showPicker: false,
                        showNavigation: false,
                        onPageChanged: (int myCurrentPage){
                          myStarPdfPage = myCurrentPage;
                          print("myStarPdfPage: ${myStarPdfPage}");
                        },
                        controller: starPageController,
                      );
                    }
                    else{
                      return Center(child: CircularProgressIndicator());
                    }
                  }
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: starPdfPageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: "Page:",
                      ),
                    ),
                  ),
                  Container(
                    height: 5,
                  ),
                  ElevatedButton(
                      child: Text("Go", textAlign: TextAlign.center),
                      onPressed: (){
                        int? pageUserIsOn = int.tryParse(starPdfPageController.text);
                        if(pageUserIsOn != null && pageUserIsOn >= 1 && pageUserIsOn <= totalStarPdfPages && !pageUserIsOn.toString().contains(".")){
                          myStarPageNumber = pageUserIsOn;

                          animateToStarPdfPage();
                          goToStarPdfPage();

                          print("myStarPdfPage: ${myStarPdfPage}");
                        }
                        else{
                          if(pageUserIsOn == null){
                            print("a page number is null");
                            myStarPdfMessage = pdfDialogMessage("", totalStarPdfPages.toString());
                          }
                          else{
                            myStarPdfMessage = pdfDialogMessage(pageUserIsOn.toString(), totalStarPdfPages.toString());
                          }

                          showDialog(
                            context: bc,
                            builder: (myContent) => AlertDialog(
                              title: const Text("Error"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(myStarPdfMessage.length, (i){
                                  return myStarPdfMessage[i];
                                }),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: (){
                                    Navigator.of(myContent).pop();
                                  },
                                  child: Container(
                                    child: const Text("Ok"),
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                      }
                  ),
                ],
              ),
            ),
            Container(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    child: Container(
                      child: Text("|<", textAlign: TextAlign.center),
                    ),
                    onPressed: (){
                      if(myStarPageNumber > 1){
                        myStarPageNumber = 1;
                        animateToStarPdfPage();
                        goToStarPdfPage();
                      }
                      else{
                        print("Nothing needed");
                      }
                    }
                  ),
                  ElevatedButton(
                      child: Container(
                        child: Text("<", textAlign: TextAlign.center),
                      ),
                      onPressed: (){
                        if(myStarPageNumber > 1){
                          myStarPageNumber = myStarPageNumber - 1;
                          animateToStarPdfPage();
                          goToStarPdfPage();
                        }
                        else{
                          print("Nothing needed");
                        }
                      }
                  ),
                  ElevatedButton(
                      child: Container(
                        child: Text(">", textAlign: TextAlign.center),
                      ),
                      onPressed: (){
                        if(myStarPageNumber < totalStarPdfPages){
                          myStarPageNumber = myStarPageNumber + 1;
                          animateToStarPdfPage();
                          goToStarPdfPage();
                        }
                        else{
                          print("Nothing needed");
                        }
                      }
                  ),
                  ElevatedButton(
                      child: Container(
                        child: Text(">|", textAlign: TextAlign.center),
                      ),
                      onPressed: (){
                        if(myStarPageNumber < totalStarPdfPages){
                          myStarPageNumber = totalStarPdfPages;
                          animateToStarPdfPage();
                          goToStarPdfPage();
                        }
                        else{
                          print("Nothing needed");
                        }
                      }
                  ),
                ],
              ),
            ),
          ],
      ): myMain.starPdfBool == false && myMain.planetPdfBool == true?
        Column(
          children: <Widget>[
            Expanded(
            child: FutureBuilder(
                future: myMain.myPlanetPdfFile,
                builder: (bc, snapshot){
                  if(snapshot.hasData){
                    planetPdfPages = List.filled((snapshot.data as PDFDocument).count, null);
                    planetPageController = PageController();
                    myPlanetPageNumber = planetPageController.initialPage + 1;
                    print(planetPdfPages.length);
                    print(myPlanetPageNumber);
                    totalPlanetPdfPages = (snapshot.data as PDFDocument).count;
                    return PDFViewer(
                      document: snapshot.data as PDFDocument,
                      showPicker: false,
                      showNavigation: false,
                      onPageChanged: (int myCurrentPage){
                        myPlanetPdfPage = myCurrentPage;
                        print("myPlanetPdfPage: ${myPlanetPdfPage}");
                      },
                      controller: planetPageController,
                    );
                  }
                  else{
                    return Center(child: CircularProgressIndicator());
                  }
                }
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: planetPdfPageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: "Page:",
                    ),
                  ),
                ),
                Container(
                  height: 5,
                ),
                ElevatedButton(
                    child: Text("Go", textAlign: TextAlign.center),
                    onPressed: (){
                      int? pageUserIsOn = int.tryParse(planetPdfPageController.text);
                      if(pageUserIsOn != null && pageUserIsOn >= 1 && pageUserIsOn <= totalPlanetPdfPages && !pageUserIsOn.toString().contains(".")){
                        myPlanetPageNumber = pageUserIsOn;

                        animateToPlanetPdfPage();
                        goToPlanetPdfPage();

                        print("myPlanetPdfPage: ${myPlanetPdfPage}");
                      }
                      else{
                        if(pageUserIsOn == null){
                          print("a page number is null");
                          myPlanetPdfMessage = pdfDialogMessage("", totalPlanetPdfPages.toString());
                        }
                        else{
                          myPlanetPdfMessage = pdfDialogMessage(pageUserIsOn.toString(), totalPlanetPdfPages.toString());
                        }

                        showDialog(
                          context: bc,
                          builder: (myContent) => AlertDialog(
                            title: const Text("Error"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(myPlanetPdfMessage.length, (i){
                                return myPlanetPdfMessage[i];
                              }),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: (){
                                  Navigator.of(myContent).pop();
                                },
                                child: Container(
                                  child: const Text("Ok"),
                                ),
                              )
                            ],
                          ),
                        );
                      }
                    }
                ),
              ],
            ),
          ),
          Container(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                    child: Container(
                      child: Text("|<", textAlign: TextAlign.center),
                    ),
                    onPressed: (){
                      if(myPlanetPageNumber > 1){
                        myPlanetPageNumber = 1;
                        animateToPlanetPdfPage();
                        goToPlanetPdfPage();
                      }
                      else{
                        print("Nothing needed");
                      }
                    }
                ),
                ElevatedButton(
                    child: Container(
                      child: Text("<", textAlign: TextAlign.center),
                    ),
                    onPressed: (){
                      if(myPlanetPageNumber > 1){
                        myPlanetPageNumber = myPlanetPageNumber - 1;
                        animateToPlanetPdfPage();
                        goToPlanetPdfPage();
                      }
                      else{
                        print("Nothing needed");
                      }
                    }
                ),
                ElevatedButton(
                    child: Container(
                      child: Text(">", textAlign: TextAlign.center),
                    ),
                    onPressed: (){
                      if(myPlanetPageNumber < totalPlanetPdfPages){
                        myPlanetPageNumber = myPlanetPageNumber + 1;
                        animateToPlanetPdfPage();
                        goToPlanetPdfPage();
                      }
                      else{
                        print("Nothing needed");
                      }
                    }
                ),
                ElevatedButton(
                    child: Container(
                      child: Text(">|", textAlign: TextAlign.center),
                    ),
                    onPressed: (){
                      if(myPlanetPageNumber < totalPlanetPdfPages){
                        myPlanetPageNumber = totalPlanetPdfPages;
                        animateToPlanetPdfPage();
                        goToPlanetPdfPage();
                      }
                      else{
                        print("Nothing needed");
                      }
                    }
                ),
              ],
            ),
          ),
        ],
      ):
      SizedBox.expand(),
    );
  }
}