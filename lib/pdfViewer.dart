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

import 'package:url_launcher/url_launcher.dart';

import 'package:starexpedition4/main.dart' as myMain;

import 'package:http/http.dart' as http;

//import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

import 'package:pdfx/pdfx.dart';

import 'package:starexpedition4/firebaseDesktopHelper.dart';

class pdfViewer extends StatefulWidget{
  const pdfViewer({Key? key}) : super(key: key);

  @override
  pdfViewerState createState() => pdfViewerState();
}

class pdfViewerState extends State<pdfViewer>{
  TextEditingController starPdfPageController = TextEditingController();
  int myStarPdfPage = 0;
  int totalStarPdfPages = 0;
  //List<PDFPage?> starPdfPages = [];
  //List<PdfPage?> starPdfPagesDesktop = [];
  late PageController starPageController;
  late PdfController myStarPdfxController;
  late int myStarPageNumber;
  List<Text> myStarPdfMessage = [];

  TextEditingController planetPdfPageController = TextEditingController();
  int myPlanetPdfPage = 0;
  int totalPlanetPdfPages = 0;
  //List<PDFPage?> planetPdfPages = [];
  //List<PdfPage?> planetPdfPagesDesktop = [];
  late PageController planetPageController;
  late PdfController myPlanetPdfxController;
  late int myPlanetPageNumber;
  List<Text> myPlanetPdfMessage = [];

  //var pageUserIsOn;
  bool snapshotExistsStars = false;
  bool snapshotExistsPlanets = false;

  void goToStarPdfPage({int? myPage}){
    myStarPdfxController.jumpToPage((myPage != null ? myPage : myStarPageNumber) - 1);
  }

  void animateToStarPdfPage({int? myPage}){
    myStarPdfxController.animateToPage((myPage != null ? myPage : myStarPageNumber) - 1, duration: Duration(milliseconds: 150), curve: Curves.easeIn);
  }

  void goToPlanetPdfPage({int? myPage}){
    myPlanetPdfxController.jumpToPage(myPage != null ? myPage : myPlanetPageNumber);
  }

  void animateToPlanetPdfPage({int? myPage}){
    myPlanetPdfxController.animateToPage(myPage != null ? myPage : myPlanetPageNumber, duration: Duration(milliseconds: 150), curve: Curves.easeIn);
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
                snapshotExistsStars = false,
                print("snapshotExistsStars: ${snapshotExistsStars}"),
                Navigator.pop(bc),
              }
              else if(myMain.planetPdfBool == true){
                myMain.planetPdfBool = false,
                myMain.myPlanetPdfFile = null,
                snapshotExistsPlanets = false,
                Navigator.pop(bc),
              }
            }
        ),
      ),
      body: myMain.starPdfBool == true && myMain.planetPdfBool == false?
      Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.015625,
            ),
            Expanded(
              child: FutureBuilder(
                  future: myMain.myStarPdfFile,
                  builder: (bc, snapshot){
                    if(snapshot.hasData){
                      final docForPdfx = snapshot.data as PdfDocument;
                      totalStarPdfPages = docForPdfx.pagesCount;

                      if(snapshotExistsStars == false){
                        snapshotExistsStars = true;
                        myStarPdfxController = PdfController(document: Future.value(docForPdfx));

                        //Initializing page numbers immediately:
                        WidgetsBinding.instance.addPostFrameCallback((myVar){
                          setState((){
                            myStarPageNumber = 1;
                            myStarPdfPage = 1;
                          });
                        });

                        print("snapshotExistsStars: ${snapshotExistsStars}");
                      }

                      return PdfView(
                        onPageChanged: (int myCurrentPage){
                          setState((){
                            myStarPdfPage = myCurrentPage;
                            myStarPageNumber = myCurrentPage;
                            print("myStarPdfPage: ${myStarPdfPage}");
                          });
                        },
                        controller: myStarPdfxController,
                      );
                    }
                    else{
                      return Center(child: CircularProgressIndicator());
                    }
                  }
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.031250, 0.0, MediaQuery.of(context).size.width * 0.031250, 0.0),//const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
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
                    height: MediaQuery.of(context).size.height * 0.015625,
                  ),
                  ElevatedButton(
                      child: Text("Go", textAlign: TextAlign.center),
                      onPressed: (){
                        int? pageUserIsOn = int.tryParse(starPdfPageController.text);
                        if(pageUserIsOn != null && pageUserIsOn >= 1 && pageUserIsOn <= totalStarPdfPages && !pageUserIsOn.toString().contains(".")){
                          myStarPdfxController.jumpToPage(pageUserIsOn);

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
              height: MediaQuery.of(context).size.height * 0.015625,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.031250, 0.0, MediaQuery.of(context).size.width * 0.031250, 0.0),//const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    child: Container(
                      child: Text("|<", textAlign: TextAlign.center),
                    ),
                    onPressed: (){
                      if(myStarPageNumber > 1){
                        myStarPdfxController.jumpToPage(1);
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
                          myStarPdfxController.jumpToPage(myStarPageNumber - 1);
                          print("myStarPageNumber: ${myStarPageNumber}");
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
                          myStarPdfxController.jumpToPage(myStarPageNumber + 1);
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
                          myStarPdfxController.jumpToPage(totalStarPdfPages);
                        }
                        else{
                          print("Nothing needed");
                        }
                      }
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.015625,
            ),
            Container(
              alignment: Alignment.center,
              child: snapshotExistsStars == true? Text("Page: ${myStarPdfPage} of ${totalStarPdfPages}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)) : Text(""),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.015625,
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
                    final docForPdfx = snapshot.data as PdfDocument;
                    totalPlanetPdfPages = docForPdfx.pagesCount;

                    myPlanetPdfxController = PdfController(document: Future.value(docForPdfx));

                    myPlanetPageNumber = myPlanetPdfxController.initialPage;

                    return PdfView(
                      onPageChanged: (int myCurrentPage){
                        myPlanetPdfPage = myCurrentPage;
                        myPlanetPageNumber = myCurrentPage;
                        print("myPlanetPdfPage: ${myPlanetPdfPage}");
                      },
                      controller: myPlanetPdfxController,
                    );
                  }
                  else{
                    return Center(child: CircularProgressIndicator());
                  }
                }
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.031250, 0.0, MediaQuery.of(context).size.width * 0.031250, 0.0),//const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
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
                  height: MediaQuery.of(context).size.height * 0.015625,
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
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.031250, 0.0, MediaQuery.of(context).size.width * 0.031250, 0.0),//const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
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