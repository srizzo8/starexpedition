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
import 'package:path_provider/path_provider.dart';
import 'package:starexpedition4/spectralClassPage.dart';

import 'package:starexpedition4/main.dart' as myMain;
import 'package:starexpedition4/discussionBoardPage.dart';
import 'package:starexpedition4/loginPage.dart';
import 'package:starexpedition4/registerPage.dart';
import 'package:starexpedition4/loginPage.dart' as theLoginPage;
import 'package:starexpedition4/device_information/deviceIdHelper.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class theBillingService{
  static const String myMonthlyId = "star_expedition_monthly";
  static const String myYearlyId = "star_expedition_yearly";

  StreamSubscription? purchaseSubscription;
  final Function(bool isSubscribed) onSubscriptionChanged;
  final Function(String? myProductId) onProductIdChanged;

  theBillingService({required this.onSubscriptionChanged, required this.onProductIdChanged});

  bool userIsSubscribed = false;

  //This broadcasts any time that a purchase ends up erroring or getting cancelled so that the Paywall page
  //can immediately clear its loading state rather than wait for the safety timeout:
  final StreamController<void> purchaseFailedController = StreamController<void>.broadcast();
  Stream<void> get purchaseFailedStream => purchaseFailedController.stream;

  //This completer completes once the first purchase-stream response has either been processed or timed out.
  //Thus, the initial access check can wait for actual billing data rather than trying to go ahead of it:
  final Completer<void> firstPurchaseCheckComplete = Completer<void>();
  bool hasReceivedFirstUpdate = false;

  Future<void> initialize() async{
    final bool isAvailable = await InAppPurchase.instance.isAvailable();
    print("Is the billing available? ${isAvailable}");

    purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      handleMyPurchaseUpdate,
      onError: (myError){
        print("This is the purchase stream error: ${myError}");

        if(!(firstPurchaseCheckComplete.isCompleted)){
          firstPurchaseCheckComplete.complete();
        }
      }
    );

    //Waiting some time to ensure that the stream is ready:
    await Future.delayed(Duration(seconds: 1));

    //Asking Google Play if the device has an active subscription:
    await InAppPurchase.instance.restorePurchases();

    //This is a safety timeout. If there are no purchase stream events found in the next three seconds (example: a user having no purchase history at all),
    //the app should proceed anyway so that it does not indefinitely wait for something that will never happen:
    Future.delayed(Duration(seconds: 3), (){
      if(!(firstPurchaseCheckComplete.isCompleted)){
        firstPurchaseCheckComplete.complete();
      }
    });
  }

  //This method will return a Firestore-safe document ID that is stable and based on the product one purchased and his or her device
  //instead of the purchase transaction itself. This will avoid iOS issues where purchaseID can be null on purchases that are restored.
  //Unfortunately, this ends up causing the app to hash the Apple App Store receipt (serverVerificationData), which is a value that is
  //occasionally unstable between fetches. As a result, a new "unique" ID and a new Firestore document are generated every time an
  //iOS user opens up Star Expedition, even for an already existing subscription. If the deviceId and productId are keyed instead, the
  //same Firestore document will be found and reused any time one opens Star Expedition, since a device only needs one active subscription
  //document per product:
  Future<String> getMyDocIdForPurchase(PurchaseDetails pd) async{
    final myDeviceId = await deviceIdHelper().getPlatformDeviceId();
    return "${myDeviceId}.${pd.productID}";
  }

  Future<void> updateDeviceIdIfNecessary(String myDocId) async{
    try{
      final myDeviceId = await deviceIdHelper().getPlatformDeviceId();

      final myDoc = await FirebaseFirestore.instance.collection("Subscriptions").doc(myDocId).get();

      //Firestore should only update if the stored deviceId is different from the current one instead of
      //updating unconditionally whenever one opens up Star Expedition:
      if(myDoc.exists && myDoc.data()!["deviceId"] == myDeviceId){
        print("Since the device ID already matches, no updates are necessary.");
        return;
      }

      await FirebaseFirestore.instance.collection("Subscriptions").doc(myDocId).update({
        "deviceId": myDeviceId,
        "lastUpdated": DateTime.now().toIso8601String(),
      });

      print("The device ID has refreshed for this subscription token");
    }
    catch (e){
      print("Unfortunately, there was an error in updating the device ID. This was the error: ${e}");
    }
  }

  Future<void> handleMyPurchaseUpdate(List<PurchaseDetails> myPurchases) async {
    print("The purchase update has been received: ${myPurchases.length} purchases");

    //If there are no relevant purchases found:
    final myRelevantPurchases = myPurchases.where((p) => p.productID == myMonthlyId || p.productID == myYearlyId);

    print("The relevant purchases: ${myRelevantPurchases.length}");

    if(myRelevantPurchases.isEmpty){
      print("No relevant purchases have been found");

      if(userIsSubscribed){
        final isStillActiveInFirestore = await isAnySubscriptionActiveInFirestore();

        if(!isStillActiveInFirestore){
          userIsSubscribed = false;
          onSubscriptionChanged(false);
          await markSubscriptionsAsExpiredInFirestore();
        }
        else{
          print("Google Play has returned no purchases, but according to Firestore, the subscription is still active. A user can continue to use Star Expedition until his or her subscription expires.");
        }
      }

      return;
    }

    //Collecting the result across every purchase before updating the state:
    bool anyActivePurchase = false;
    String? myActiveProductId;

    for(final myPurchase in myRelevantPurchases){
      print("The purchase status: ${myPurchase.status}");
      print("The purchase ID: ${myPurchase.productID}");

      if(myPurchase.status == PurchaseStatus.purchased || myPurchase.status == PurchaseStatus.restored){
        final myDocId = await getMyDocIdForPurchase(myPurchase);

        //Checking Firestore to see if the token is still active:
        final isActive = await isTokenActiveInFirestore(myDocId);
        print("Is the token active in Firestore? ${isActive}");

        if(isActive){
          print("Firestore confirms that there is an active subscription");
          completeMyPurchase(myPurchase);
          anyActivePurchase = true;
          myActiveProductId = myPurchase.productID;

          //Keeping the stored deviceId in sync in the case where it may be changed.
          //An example of this happening is where iOS identifierForVendor can change after
          //one reinstalls an application.
          //If the stored deviceId is kept in sync, expiry checks by deviceId will continue to work correctly:
          await updateDeviceIdIfNecessary(myDocId);
        }
        else {
          //A brand new purchase or a restored purchase that Firestore has not yet recorded has been made; save it to Firestore:
          print("A new or restored purchase has been made; saving it to Firestore");
          completeMyPurchase(myPurchase);
          await saveSubscriptionToFirestore(myPurchase);
          anyActivePurchase = true;
          myActiveProductId = myPurchase.productID;
        }
      }
      else if(myPurchase.status == PurchaseStatus.error || myPurchase.status == PurchaseStatus.canceled){
        print("Either there is a subscription error or the subscription has been cancelled.");
        purchaseFailedController.add(null);
      }
      else if(myPurchase.status == PurchaseStatus.pending){
        print("The purchase is pending. This is common for iOS devices, since they ask for user verification prior to purchase.");
      }
    }

    //Making a single state update after processing every purchase:
    if(anyActivePurchase){
      userIsSubscribed = true;
      onSubscriptionChanged(true);
      onProductIdChanged(myActiveProductId);
    }
    else{
      //Before revoking access, it should check Firestore in case Google Play returned tokens that are expired while an active subscription still exists in Firestore:
      final isStillActiveInFirestore = await isAnySubscriptionActiveInFirestore();

      if(isStillActiveInFirestore){
        print("Google Play returned tokens that are expired, but Firestore showed that the subscription is still active. Therefore, there will still be access.");

        if(!userIsSubscribed){
          userIsSubscribed = true;
          onSubscriptionChanged(true);
        }
      }
      else{
        if(userIsSubscribed){
          await markSubscriptionsAsExpiredInFirestore();
        }

        userIsSubscribed = false;
        onSubscriptionChanged(false);
        onProductIdChanged(null);
      }
    }

    //This happens at the end, after all of the processing has happened:
    if(!(firstPurchaseCheckComplete.isCompleted)){
      firstPurchaseCheckComplete.complete();
    }
  }

  //Checks to see if a certain purchase token is active in Firestore:
  Future<bool> isTokenActiveInFirestore(String myDocId) async{
    try{
      final myDoc = await FirebaseFirestore.instance.collection("Subscriptions").doc(myDocId).get();

      await FirebaseFirestore.instance.collection("Debug_Logs").add({
        "message": "isTokenActiveInFirestore - docId: ${myDocId}, exists: ${myDoc.exists}, data: ${myDoc.data()}",
        "timestamp": DateTime.now().toIso8601String(),
      });

      if(!myDoc.exists){
        print("The purchase token is not found in Firestore");
        return false;
      }

      final myExpiryDateString = myDoc.data()!["expiryDate"] as String;
      final myExpiryDate = DateTime.parse(myExpiryDateString);
      final isActive = DateTime.now().isBefore(myExpiryDate) && myDoc.data()!["isActive"] == true;

      print("Token expiration date: ${myExpiryDate}; is it active? ${isActive}");

      return isActive;
    }
    catch (e){
      print("There was an error when checking the token. This is the error: ${e}");

      await FirebaseFirestore.instance.collection("Debug_Logs").add({
        "message": "isTokenActiveInFirestore error for docId ${myDocId} is this: ${e}",
        "timestamp": DateTime.now().toIso8601String(),
      });

      return false;
    }
  }

  Future<void> saveSubscriptionToFirestore(PurchaseDetails pd) async{
    try{
      final myDocId = await getMyDocIdForPurchase(pd);
      final myPurchaseToken = pd.verificationData.serverVerificationData;

      //Getting the device ID:
      final myDeviceId = await deviceIdHelper().getPlatformDeviceId();

      //Calculating the expiry based on the product type:
      DateTime myExpiryDate;

      if(pd.productID == myMonthlyId){
        myExpiryDate = DateTime.now().add(Duration(days: 30));
      }
      else{
        myExpiryDate = DateTime.now().add(Duration(days: 365));
      }

      await FirebaseFirestore.instance.collection("Subscriptions").doc(myDocId).set({
        "productId": pd.productID,
        "purchaseToken": myPurchaseToken,
        "deviceId": myDeviceId,
        "expiryDate": myExpiryDate.toIso8601String(),
        "isActive": true,
        "lastUpdated": DateTime.now().toIso8601String(),
      });

      print("The subscription is saved to Firestore. It expires on: ${myExpiryDate}");

      await FirebaseFirestore.instance.collection("Debug_Logs").add({
        "message": "saveSubscriptionToFirestore is successful for docId ${myDocId}, deviceId: ${myDeviceId}, expiry: ${myExpiryDate}",
        "timestamp": DateTime.now().toIso8601String(),
      });
    }
    catch (e){
      print("There is an error saving the subscription. Here is the error: ${e}");
      await FirebaseFirestore.instance.collection("Debug_Logs").add({
        "message": "saveSubscriptionToFirestore had an error. This is the error: ${e}",
        "timestamp": DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> markSubscriptionAsExpired(String myDocId) async{
    try{
      await FirebaseFirestore.instance.collection("Subscriptions").doc(myDocId).update({"isActive": false, "expiryDate": DateTime.now().toIso8601String(), "lastUpdated": DateTime.now().toIso8601String()});

      print("The subscription is marked as expired");
    }
    catch (e){
      print("Unfortunately, there is an error marking the subscription as expired. Error: ${e}");
    }
  }

  Future<void> markSubscriptionsAsExpiredInFirestore() async{
    try{
      //Getting myDeviceId:
      final myDeviceId = await deviceIdHelper().getPlatformDeviceId();

      final QuerySnapshot mySnapshot = await FirebaseFirestore.instance.collection("Subscriptions").where("deviceId", isEqualTo: myDeviceId).where("isActive", isEqualTo: true).get();

      for(final myDoc in mySnapshot.docs){
        await myDoc.reference.update({"isActive": false, "expiryDate": DateTime.now().toIso8601String(), "lastUpdated": DateTime.now().toIso8601String()});

        print("Subscription is expired in Firestore for: ${myDoc.id}");
      }
    }
    catch(e){
      print("Unfortunately, there is an error in making the subscription expired. Here is the error: ${e}");
    }
  }

  Future<bool> isAnySubscriptionActiveInFirestore() async{
    try{
      final myDeviceId = await deviceIdHelper().getPlatformDeviceId();

      final mySnapshot = await FirebaseFirestore.instance.collection("Subscriptions").where("deviceId", isEqualTo: myDeviceId).where("isActive", isEqualTo: true).get();

      if(mySnapshot.docs.isEmpty){
        return false;
      }

      for(final myDoc in mySnapshot.docs){
        final myExpiryDateString = myDoc.data()["expiryDate"] as String;
        final myExpiryDate = DateTime.parse(myExpiryDateString);

        if(DateTime.now().isBefore(myExpiryDate)){
          return true;
        }
      }

      return false;
    }
    catch(e){
      print("Unfortunately, there was an error in checking Firestore for an active subscription. This is the error: ${e}");
      return false;
    }
  }

  Future<void> completeMyPurchase(PurchaseDetails myPurchase) async{
    if(myPurchase.pendingCompletePurchase){
      await InAppPurchase.instance.completePurchase(myPurchase);
    }
  }

  Future<List<ProductDetails>> getMyProducts() async{
    final myResponse = await InAppPurchase.instance.queryProductDetails({myMonthlyId, myYearlyId});
    return myResponse.productDetails;
  }

  Future<void> subscribe(ProductDetails myProduct) async{
    final myPurchaseParam = PurchaseParam(productDetails: myProduct);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: myPurchaseParam);
  }

  void dispose(){
    purchaseSubscription?.cancel();
    purchaseFailedController.close();
  }
}