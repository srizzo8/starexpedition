import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
//import 'dart:js';
import 'dart:math';
//import 'dart:html';
//import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
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

import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';

class pdfViewer extends StatefulWidget{
  const pdfViewer({Key? key}) : super(key: key);

  @override
  pdfViewerState createState() => pdfViewerState();
}

class pdfViewerState extends State<pdfViewer>{
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
            Navigator.pop(bc),
          }
        ),
      ),
      body: SizedBox.expand(
        child: FutureBuilder(
          future: PDFDocument.fromURL(myMain.listOfStarUrls[myMain.starListUrlIndex]),
          builder: (bc, snapshot){
            if(snapshot.hasData){
              return PDFViewer(
                document: snapshot.data as PDFDocument,
              );
            }
            else{
              return Container(
                child: Text("PDF not found", textAlign: TextAlign.center),
              );
            }
          }
        )
      )
    );
  }
}