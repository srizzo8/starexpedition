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
import 'package:in_app_purchase/in_app_purchase.dart';

class theBillingService{
  static const String myMonthlyId = "star_expedition_monthly";
  static const String myYearlyId = "star_expedition_yearly";

  StreamSubscription? purchaseSubscription;
  final Function(bool isSubscribed) onSubscriptionChanged;

  theBillingService({required this.onSubscriptionChanged});

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
    await InAppPurchase.instance.restorePurchases();

    //Asking Google Play if the device has an active subscription:
    await InAppPurchase.instance.restorePurchases();
  }

  void handleMyPurchaseUpdate(List<PurchaseDetails> myPurchases){
    print("The purchase update has been received: ${myPurchases.length} purchases");

    for(final myPurchase in myPurchases){
      print("The purchase status: ${myPurchase.status}");
      print("The purchase ID: ${myPurchase.productID}");

      if(myPurchase.status == PurchaseStatus.purchased || myPurchase.status == PurchaseStatus.restored){
        print("An active subscription has been found. The app will be unlocked.");
        completeMyPurchase(myPurchase);
        onSubscriptionChanged(true);
      }
      else if(myPurchase.status == PurchaseStatus.error || myPurchase.status == PurchaseStatus.canceled){
        print("Either there is a subscription error or the subscription has been cancelled.");
        onSubscriptionChanged(false);
      }
    }

    //If there are no relevant purchases found:
    final myRelevantPurchases = myPurchases.where((p) => p.productID == myMonthlyId || p.productID == myYearlyId);

    print("The relevant purchases: ${myRelevantPurchases.length}");

    if(myRelevantPurchases.isEmpty){
      print("No relevant purchases have been found");
      onSubscriptionChanged(false);
      return;
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