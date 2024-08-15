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

class settingsPage extends StatefulWidget{
  const settingsPage ({Key? key}) : super(key: key);

  @override
  settingsPageState createState() => settingsPageState();
}

class settingsPageState extends State<settingsPage>{
  static String nameOfRoute = '/settings';

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  var usernameUsed;

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () async =>{
            Navigator.pop(context),
          }
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Container(
            child: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ),
          InkWell(
            child: Ink(
              //alignment: Alignment.center,
              child: Text("Change Password"),
            ),
            onTap: (){
              showDialog(
                context: context,
                builder: (BuildContext bc){
                  return AlertDialog(
                    title: Text("Change your password"),
                    content: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Enter in your current password",
                              border: OutlineInputBorder(),
                            ),
                            controller: oldPasswordController,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Enter in your new password",
                              border: OutlineInputBorder(),
                            ),
                            controller: newPasswordController,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>{
                          if(oldPasswordController.text != "" && newPasswordController.text != ""){
                            Navigator.of(context).pop(),
                          }
                          else{
                            //User needs to enter in his or her old password and/or his or her new password.
                          }
                        },
                        child: Text("Confirm"),
                      ),
                      TextButton(
                        onPressed: () =>{
                          Navigator.of(context).pop(),
                        },
                        child: Text("Cancel"),
                      ),
                    ],
                  );
                }
              );
            }
          ),
        ],
      ),
    );
  }
}