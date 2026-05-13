import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
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

class subscriptionGateState extends State<subscriptionGate> with WidgetsBindingObserver{
  myAccessState myAccess = myAccessState.loading;
  late theBillingService myBillingService;
  final theTrialService myTrialService = theTrialService();
  bool userIsSubscribed = false;
  String? myActiveProductId;
  Timer? myAccessTimer;
  OverlayEntry? myPaywallOverlay;
  bool paywallShowing = false;

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    //Listening for navigation events that are occurring in the app:
    myMain.myAccessCheckNotifier.addListener(onNavigationEvent);

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
    print("init - inTrial: ${inTrial}");
    print("init - userIsSubscribed: ${userIsSubscribed}");

    //Updates here only happen if the billing has not unlocked yet:
    if(!userIsSubscribed && mounted){
      setState(() => myAccess = inTrial? myAccessState.permitted : myAccessState.blocked);
      print("init - myAccess: ${myAccess}");
    }

    startAccessMonitoring();
  }

  //Method to check if one's subscription is active in Firestore:
  Future<bool> isSubscriptionActiveInFirestore() async{
    try{
      //Getting the device ID:
      final myDeviceInfo = DeviceInfoPlugin();
      final myAndroidInfo = await myDeviceInfo.androidInfo;
      final myDeviceId = myAndroidInfo.id;

      print("Checking Firestore for the device id: ${myDeviceId}");

      //Getting subscriptions from a certain device:
      final myDoc = await FirebaseFirestore.instance.collection("Subscriptions").where("deviceId", isEqualTo: myDeviceId).where("isActive", isEqualTo: true).orderBy("lastUpdated", descending: true).limit(1).get();

      print("The documents found: ${myDoc.docs.length}");

      if(myDoc.docs.isEmpty){
        return false;
      }

      final myExpiryDateString = myDoc.docs.first.data()["expiryDate"] as String;
      final myExpiryDate = DateTime.parse(myExpiryDateString);
      final subscriptionIsActive = DateTime.now().isBefore(myExpiryDate);

      print("Expiry date in Firestore: ${myExpiryDate}");
      print("Today's date: ${DateTime.now()}");
      print("subscriptionIsActive: ${subscriptionIsActive}");

      return subscriptionIsActive;
    }
    catch(e){
      print("There is an error catching the Firestore subscription. Here is the error: ${e}");
      return false;
    }
  }

  void startAccessMonitoring(){
    print("startAccessMonitoring started at: ${DateTime.now()}");
    myAccessTimer = Timer.periodic(const Duration(seconds: 30), (_) async{
      print("Timer started at: ${DateTime.now()}");

      if(!mounted){
        print("Not mounting, so it is returning");
        return;
      }

      if(paywallShowing){
        return;
      }

      print("Timer fired");

      //Rechecking subscription from Google Play:
      print("Calling for the restore of purchases");
      await InAppPurchase.instance.restorePurchases();
      await Future.delayed(Duration(seconds: 2));

      if(!mounted){
        return;
      }

      final isInTrial = await myTrialService.isInTrial();
      print("This is isInTrial: ${isInTrial}");

      //The user is still in his or her trial, so there is no need to check for his or her subscription:
      if(isInTrial){
        return;
      }

      //Check Firestore only if Google Play also confirms a user is not subscribed:
      if(!userIsSubscribed){
        print("Google Play says you are not subscribed. Checking Firestore.");
        final isSubscriptionActive = await isSubscriptionActiveInFirestore();
        print("isSubscriptionActive: ${isSubscriptionActive}");

        if(!isInTrial && !userIsSubscribed && mounted){
          //The state is updated (subscriptionGate is now on the top, and it rebuilds to the paywall page):
          print("Showing the paywall page");

          setState((){
            myAccess = myAccessState.blocked;
            myActiveProductId = null;
          });

          //Showing paywall on top of everything:
          showPaywallOverlay();
        }
      }
      else{
        print("Since Google Play says you are subscribed, the paywall page will not be shown");
      }
    });
  }

  void showPaywallOverlay(){
    if(paywallShowing == true){
      print("The paywall is already showing, so therefore, the app is skipping");
      return;
    }

    print("Is the Navigator context null? ${myMain.myNavigatorKey.currentContext == null}");
    print("Is the Navigator state null? ${myMain.myNavigatorKey.currentState == null}");

    if(myMain.myNavigatorKey.currentContext == null){
      print("The navigator is not ready, and as a result, the paywall cannot be shown");
      return;
    }

    paywallShowing = true;
    print("Showing the paywall overlay");

    //Waiting for the navigator key to be ready:
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(myMain.myNavigatorKey.currentContext == null){
        print("Unfortunately, the navigator is still not ready");
        return;
      }
    });

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
    ).then((_){
      //paywallShowing is back to false when the dialog is dismissed:
      paywallShowing = false;
    });
  }

  void removePaywallOverlay(){
    paywallShowing = false;
    myPaywallOverlay?.remove();
    myPaywallOverlay = null;
  }

  void onNavigationEvent(){
    print("Navigation has been detected, so access will be checked");
    checkingAccess();
  }

  Future<void> checkingAccess() async{
    if(!mounted){
      return;
    }

    if(paywallShowing){
      return;
    }

    final isInTrial = await myTrialService.isInTrial();
    print("Navigation check - isInTrial: ${isInTrial}");
    print("Navigation check - userIsSubscribed: ${userIsSubscribed}");

    if(!isInTrial && !userIsSubscribed && mounted){
      print("Navigation check - showing the paywall page");

      setState((){
        myAccess = myAccessState.blocked;
        myActiveProductId = null;
      });

      showPaywallOverlay();
    }
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
    myMain.myAccessCheckNotifier.removeListener(onNavigationEvent);
    WidgetsBinding.instance.removeObserver(this);
    myAccessTimer?.cancel();
    myBillingService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState myState){
    if(myState == AppLifecycleState.resumed){
      print("The app has resumed, and access will be checked");
      checkAccessOnResume();
    }
  }

  Future<void> checkAccessOnResume() async{
    if(!mounted){
      return;
    }

    await InAppPurchase.instance.restorePurchases();
    await Future.delayed(Duration(seconds: 2));

    if(!mounted){
      return;
    }

    final isInTrial = await myTrialService.isInTrial();
    print("On resume - isInTrial: ${isInTrial}");
    print("On resume - userIsSubscribed: ${userIsSubscribed}");

    if(!isInTrial && !userIsSubscribed && mounted){
      print("On resume - showing the paywall page");

      setState((){
        myAccess = myAccessState.blocked;
        myActiveProductId = null;
      });

      showPaywallOverlay();
    }
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