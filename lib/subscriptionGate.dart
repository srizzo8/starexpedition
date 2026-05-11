import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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
  OverlayEntry? myPaywallOverlay;

  @override
  void initState(){
    super.initState();

    myBillingService = theBillingService(
      onSubscriptionChanged: (isSubscribed) async{
        userIsSubscribed = isSubscribed;
        if(isSubscribed){
          removePaywallOverlay();
          if(mounted){
            setState(() => myAccess = myAccessState.permitted);
          }
        }
        else{
          final inTrial = await myTrialService.isInTrial();

          if(mounted){
            setState(() => myAccess = inTrial ? myAccessState.permitted : myAccessState.blocked);

            if(!inTrial){
              showPaywallOverlay();
            }
          }
        }
      },
      onProductIdChanged: (myProductId){
        if(mounted){
          setState(() => myActiveProductId = myProductId);
        }
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
    if(!userIsSubscribed && mounted){
      setState(() => myAccess = inTrial? myAccessState.permitted : myAccessState.blocked);
    }

    startAccessMonitoring();
  }

  void startAccessMonitoring(){
    myAccessTimer = Timer.periodic(const Duration(seconds: 30), (_) async{
      print("Timer fired");

      if(!mounted){
        print("Not mounting, so it is returning");
        return;
      }

      //Rechecking subscription from Google Play:
      print("Calling for the restore of purchases");
      await InAppPurchase.instance.restorePurchases();
      await Future.delayed(Duration(seconds: 2));

      if(!mounted){
        return;
      }

      final isInTrial = await myTrialService.isInTrial();
      print("This is isInTrial: ${isInTrial}");
      print("This is userIsSubscribed: ${userIsSubscribed}");

      if(!mounted){
        return;
      }

      if(!isInTrial && !userIsSubscribed){
        //The state is updated (subscriptionGate is now on the top, and it rebuilds to the paywall page):
        print("Showing the paywall page");

        setState((){
          myAccess = myAccessState.blocked;
          myActiveProductId = null;
        });

        //Showing paywall on top of everything:
        showPaywallOverlay();
      }
    });
  }

  void showPaywallOverlay(){
    //Checking if the navigator key is ready:
    if(myMain.myNavigatorKey.currentContext == null){
      return;
    }

    print("Showing the paywall overlay");

    showGeneralDialog(
      context: myMain.myNavigatorKey.currentContext!,
      barrierDismissible: false,
      barrierColor: Colors.white,
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation){
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            body: paywallPage(
              myBillingService: myBillingService,
              isExpired: true,
              activeProductId: null,
            ),
          ),
        );
      }
    );
  }

  void removePaywallOverlay(){
    myPaywallOverlay?.remove();
    myPaywallOverlay = null;
  }

  @override
  Widget build(BuildContext myContext){
    if(myAccess == myAccessState.loading){
      return gateLoadingPage();
    }
    else if(myAccess == myAccessState.permitted){
      return widget.myChild;
    }
    else{
      return WillPopScope(
        onWillPop: () async => false,
        child: paywallPage(
          myBillingService: myBillingService,
          isExpired: true,
          activeProductId: myActiveProductId,
        ),
      );
    }
  }

  @override
  void dispose(){
    removePaywallOverlay();
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