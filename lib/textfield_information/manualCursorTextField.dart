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
import 'package:flutter/rendering.dart';

class manualCursorTextField extends StatefulWidget{
  final TextEditingController myController;
  final String? myLabelText;
  final bool obscureText;

  const manualCursorTextField({super.key, required this.myController, this.myLabelText, this.obscureText = false});

  @override
  State<manualCursorTextField> createState() => manualCursorTextFieldState();
}

class manualCursorTextFieldState extends State<manualCursorTextField>{
  final GlobalKey myFieldKey = GlobalKey();

  //This method is trying to find a hidden object called RenderEditable in a TextField's widget tree.
  //The RenderEditable knows where every letter is positioned in the screen.
  //This method is also going to find and give one the RenderEditable.
  RenderEditable? findMyRenderEditable(){
    //This line below grabs the outermost render object of a TextField (Flutter uses render objects to "draw" things on screen; the render object here is found in a TextField's global key):
    final myRenderObject = myFieldKey.currentContext?.findRenderObject();

    //This is an empty box where one can eventually give an answer once it is found:
    RenderEditable? found;

    //This is a safety check. If the method is not on a user's screen yet, the search ends:
    if(myRenderObject == null){
      return null;
    }

    void myVisitor(RenderObject myChild){
      if(myChild is RenderEditable){
        //If myChild a RenderEditable, it goes to found:
        found = myChild;
      }
      else{
        //If myChild is not a RenderEditable, this line will look at its children until one is discovered to be a RenderEditable or until everything is checked:
        myChild.visitChildren(myVisitor);
      }
    }

    //This ensures that starting from the TextField's outer render object, all of its children will be checked:
    myRenderObject.visitChildren(myVisitor);

    return found;
  }

  void handleTapUp(TapUpDetails myDetails){
    final myRenderEditable = findMyRenderEditable();

    if(myRenderEditable == null){
      return;
    }

    //This is trying to find which character position in the text
    //is the screen coordinate closest to:
    final myPosition = myRenderEditable.getPositionForPoint(myDetails.globalPosition);

    //This is where the code manually sets the cursor to a certain calculated position rather than using the built-in tap-handling Flutter has:
    widget.myController.selection = TextSelection.collapsed(offset: myPosition.offset);
  }

  @override
  Widget build(BuildContext bc){
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: handleTapUp,
      child: TextField(
        key: myFieldKey,
        controller: widget.myController,
        obscureText: widget.obscureText,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: widget.myLabelText,
        ),
      ),
    );
  }
}