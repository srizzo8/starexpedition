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
import 'package:flutter/services.dart' show rootBundle;
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

  TextEditingController planetPdfPageController = TextEditingController();
  int myPlanetPdfPage = 1;
  int totalPlanetPdfPages = 0;

  void goToPage({int? myPage}){
    starPageController.jumpToPage(myPage != null ? myPage : myStarPageNumber - 1);
  }

  void animateToPage({int? myPage}){
    starPageController.animateToPage(myPage != null ? myPage : myStarPageNumber - 1, duration: Duration(milliseconds: 150), curve: Curves.easeIn);
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
                        if(pageUserIsOn != null && pageUserIsOn >= 1 && pageUserIsOn <= totalStarPdfPages){
                          myStarPageNumber = pageUserIsOn;

                          animateToPage();
                          goToPage();

                          print("myStarPdfPage: ${myStarPdfPage}");
                        }
                        else{
                          showDialog(
                            context: bc,
                            builder: (myContent) => AlertDialog(
                              title: const Text("Error"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Center(
                                    child: Text("The page number that you have entered in is invalid."),
                                  ),
                                ],
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
                        animateToPage();
                        goToPage();
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
                          animateToPage();
                          goToPage();
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
                          animateToPage();
                          goToPage();
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
                          animateToPage();
                          goToPage();
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
      ): myMain.starPdfBool == false && myMain.planetPdfBool == true? SizedBox.expand(
        child: FutureBuilder(
            future: myMain.myPlanetPdfFile,
            builder: (bc, snapshot){
              if(snapshot.hasData){
                return PDFViewer(
                    document: snapshot.data as PDFDocument,
                    pickerButtonColor: Colors.red,
                    onPageChanged: (int myCurrentPage){
                      myPlanetPdfPage = myCurrentPage;
                    }
                );
              }
              else{
                return Center(child: CircularProgressIndicator());
              }
            }
        ),
      ):
      SizedBox.expand(),
    );
  }
}