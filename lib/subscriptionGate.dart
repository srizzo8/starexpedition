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
  bool userIsSubscribed = false;
  String? myActiveProductId;
  Timer? myAccessTimer;

  @override
  void initState(){
    super.initState();

    myBillingService = theBillingService(
      onSubscriptionChanged: (isSubscribed) async{
        userIsSubscribed = isSubscribed;
        if(isSubscribed){
          setState(() => myAccess = myAccessState.permitted);
        }
        else{
          final inTrial = await myTrialService.isInTrial();
          setState(() => myAccess = inTrial? myAccessState.permitted : myAccessState.blocked);
        }
      },
      onProductIdChanged: (myProductId){
        setState(() => myActiveProductId = myProductId);
      },
    );

    init();
  }

  Future<void> init() async{
    await myTrialService.getInstallationDate();

    //Giving some billing time to restore purchases:
    await Future.delayed(Duration(seconds: 3));
    await myBillingService.initialize();

    final inTrial = await myTrialService.isInTrial();

    //Updates here only happen if the billing has not unlocked yet:
    if(!userIsSubscribed){
      setState(() => myAccess = inTrial? myAccessState.permitted : myAccessState.blocked);
    }

    startAccessMonitoring();
  }

  void startAccessMonitoring(){
    myAccessTimer = Timer.periodic(const Duration(seconds: 10), (_) async{
      if(!mounted){
        return;
      }

      if(userIsSubscribed){
        return;
      }

      final isInTrial = await myTrialService.isInTrial();

      if(!userIsSubscribed && !isInTrial){
        if(mounted && myAccess != myAccessState.blocked){
          setState((){
            myAccess = myAccessState.blocked;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext myContext){
    if(myAccess == myAccessState.loading){
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        home: gateLoadingPage(),
      );
    }
    else if(myAccess == myAccessState.permitted){
      return WillPopScope(
        onWillPop: () async => false,
        child: widget.myChild,
      );
    }
    else{
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        home: WillPopScope(
          onWillPop: () async => false,
          child: paywallPage(
            myBillingService: myBillingService,
            isExpired: true,
            activeProductId: myActiveProductId,
          ),
        ),
      );
    }
  }

  @override
  void dispose(){
    myAccessTimer?.cancel();
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
        child: CircularProgressIndicator(color: Colors.red,),
      ),
    );
  }
}