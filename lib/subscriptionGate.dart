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
import 'package:shared_preferences/shared_preferences.dart';

import 'package:starexpedition4/trials_and_payments/theBillingService.dart';
import 'package:starexpedition4/trials_and_payments/theTrialService.dart';
import 'package:starexpedition4/paywallPage.dart';

enum myAccessState {loading, permitted, blocked}

class subscriptionGate extends StatefulWidget{
  final Widget myChild; //this variable represents my app

  const subscriptionGate({required this.myChild, super.key});

  @override
  State<subscriptionGate> createState() => subscriptionGateState();
}

class subscriptionGateState extends State<subscriptionGate>{
  myAccessState myAccess = myAccessState.loading;
  late theBillingService myBillingService;
  final theTrialService myTrialService = theTrialService();

  @override
  void initState(){
    super.initState();

    myBillingService = theBillingService(
      onSubscriptionChanged: (isSubscribed) async{
        if(isSubscribed){
          setState(() => myAccess = myAccessState.permitted);
        }
        else{
          final inTrial = await myTrialService.isInTrial();
          setState(() => myAccess = inTrial? myAccessState.permitted : myAccessState.blocked);
        }
      }
    );

    init();
  }

  Future<void> init() async{
    await myTrialService.getInstallationDate();
    await myBillingService.initialize();

    final inTrial = await myTrialService.isInTrial();

    setState(() => myAccess = inTrial? myAccessState.permitted : myAccessState.blocked);
  }

  @override
  Widget build(BuildContext myContext){
    if(myAccess == myAccessState.loading){
      //A brief loading moment on the launch:
      return MaterialApp(debugShowCheckedModeBanner: false, home: gateLoadingPage());
    }
    else if(myAccess == myAccessState.permitted){
      //If one is subscribed or if he or she has a trial that exists, the existing app shows as is:
      return widget.myChild;
    }
    else{
      //If the trial has expired or if one is not subscribed, the paywall should show:
      return MaterialApp(debugShowCheckedModeBanner: false, home: paywallPage(myBillingService: myBillingService, isExpired: true,),);
    }
  }

  @override
  void dispose(){
    myBillingService.dispose();
    super.dispose();
  }
}

class gateLoadingPage extends StatelessWidget{
  const gateLoadingPage();

  @override
  Widget build(BuildContext theContext){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}