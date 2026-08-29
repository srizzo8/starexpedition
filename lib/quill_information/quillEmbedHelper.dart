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
import 'package:flutter_quill/flutter_quill.dart';

class quillEmbedHelper{
  //This method inserts an image or video and removes any automatically added extra line Quill adds beneath the image or video. It does not affect new lines made by users:
  void addEmbedAndCleanUp(QuillController myQuillController, Embeddable myEmbeddable){
    final myIndex = myQuillController.selection.baseOffset;
    final myLength = myQuillController.selection.extentOffset - myIndex;

    myQuillController.replaceText(myIndex, myLength, myEmbeddable, null);

    final myPlainText = myQuillController.document.toPlainText();

    int myPosition = myIndex + 1;
    int myConsecutiveNewLines = 0;

    while(myPosition < myPlainText.length && myPlainText[myPosition] == "\n"){
      myConsecutiveNewLines++;
      myPosition++;
    }

    //Quill will require only one new line after a block embed.
    //Any instance of "\n" made by Quill (not by a user) after the first one will be removed here:
    if(myConsecutiveNewLines > 1){
      myQuillController.replaceText(myIndex + 2, myConsecutiveNewLines - 1, "", null);
    }
  }
}