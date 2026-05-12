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

  Future<void> initialize() async{
    final bool available = await InAppPurchase.instance.isAvailable();
    print("Is the billing available? ${available}");

    purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      handleMyPurchaseUpdate,
      onError: (myError){
        print("The purchase stream error: ${myError}");
      }
    );

    //Waiting some time to ensure that the stream is ready:
    await Future.delayed(Duration(seconds: 2));

    //Asking Google Play if the device has an active subscription:
    await InAppPurchase.instance.restorePurchases();
  }

  Future<void> handleMyPurchaseUpdate(List<PurchaseDetails> myPurchases) async {
    print("The purchase update has been received: ${myPurchases.length} purchases");

    //If there are no relevant purchases found:
    final myRelevantPurchases = myPurchases.where((p) => p.productID == myMonthlyId || p.productID == myYearlyId);

    print("The relevant purchases: ${myRelevantPurchases.length}");

    if(myRelevantPurchases.isEmpty){
      print("No relevant purchases have been found");
      onSubscriptionChanged(false);
      onProductIdChanged(null);
      return;
    }

    for(final myPurchase in myRelevantPurchases){
      print("The purchase status: ${myPurchase.status}");
      print("The purchase ID: ${myPurchase.productID}");

      if(myPurchase.status == PurchaseStatus.purchased || myPurchase.status == PurchaseStatus.restored){
        final myPurchaseToken = myPurchase.verificationData.serverVerificationData;

        //Checking Firestore to see if the token is still active:
        final isActive = await isTokenActiveInFirestore(myPurchaseToken);
        print("Is the token active in Firestore? ${isActive}");

        if(isActive){
          print("Firestore confirms that there is an active subscription");
          completeMyPurchase(myPurchase);
          onSubscriptionChanged(true);
          onProductIdChanged(myPurchase.productID);
        }
        else if(myPurchase.status == PurchaseStatus.purchased){
          //A brand new purchase has been made; save it to Firestore:
          print("A new purchase has been made; saving it to Firestore");
          completeMyPurchase(myPurchase);
          await saveSubscriptionToFirestore(myPurchase);
          onSubscriptionChanged(true);
          onProductIdChanged(myPurchase.productID);
        }
        else{
          //Treat this as inactive because although it is restored, it is expired or not in Firestore:
          print("Since the restored purchase is not active on Firestore, it is being treated as expired");
          onSubscriptionChanged(false);
          onProductIdChanged(null);
        }
      }
      else if(myPurchase.status == PurchaseStatus.error || myPurchase.status == PurchaseStatus.canceled){
        print("Either there is a subscription error or the subscription has been cancelled.");

        onSubscriptionChanged(false);
        onProductIdChanged(null);
      }
    }
  }

  //Checks to see if a certain purchase token is active in Firestore:
  Future<bool> isTokenActiveInFirestore(String myPurchaseToken) async{
    try{
      final myDoc = await FirebaseFirestore.instance.collection("Subscriptions").doc(myPurchaseToken).get();

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
      return false;
    }
  }

  Future<void> saveSubscriptionToFirestore(PurchaseDetails pd) async{
    try{
      final myPurchaseToken = pd.verificationData.serverVerificationData;

      //Getting the device ID:
      final myDeviceInfo = DeviceInfoPlugin();
      final myAndroidInfo = await myDeviceInfo.androidInfo;
      final myDeviceId = myAndroidInfo.id;

      //Calculating the expiry based on the product type:
      DateTime myExpiryDate;

      if(pd.productID == myMonthlyId){
        myExpiryDate = DateTime.now().add(Duration(days: 30));
      }
      else{
        myExpiryDate = DateTime.now().add(Duration(days: 365));
      }

      await FirebaseFirestore.instance.collection("Subscriptions").doc(myPurchaseToken).set({
        "productId": pd.productID,
        "purchaseToken": myPurchaseToken,
        "deviceId": myDeviceId,
        "expiryDate": myExpiryDate.toIso8601String(),
        "isActive": true,
        "lastUpdated": DateTime.now().toIso8601String(),
      });

      print("The subscription is saved to Firestore. It expires on: ${myExpiryDate}");
    }
    catch (e){
      print("There is an error saving the subscription. Here is the error: ${e}");
    }
  }

  Future<void> markSubscriptionAsExpired(String myPurchaseToken) async{
    try{
      await FirebaseFirestore.instance.collection("Subscriptions").doc(myPurchaseToken).update({"isActive": false, "expiryDate": DateTime.now().toIso8601String(), "lastUpdated": DateTime.now().toIso8601String()});

      print("The subscription is marked as expired");
    }
    catch (e){
      print("Unfortunately, there is an error marking the subscription as expired. Error: ${e}");
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
  }
}