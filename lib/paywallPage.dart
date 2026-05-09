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
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:starexpedition4/trials_and_payments/theBillingService.dart';

class paywallPage extends StatefulWidget{
  final theBillingService myBillingService;
  final bool isExpired;
  final String? activeProductId;

  const paywallPage({required this.myBillingService, this.isExpired = false, this.activeProductId, super.key});

  @override
  paywallPageState createState() => paywallPageState();
}

class paywallPageState extends State<paywallPage>{
  List<ProductDetails> myProducts = [];
  bool isLoading = true;

  @override
  void initState(){
    super.initState();
    loadMyProducts();
  }

  Future<void> loadMyProducts() async{
    final theProducts = await widget.myBillingService.getMyProducts();
    print("The products loaded: ${theProducts.length}");

    for(final myProduct in theProducts){
      print("Product: ${myProduct.id}, ${myProduct.price}");
    }

    setState((){
      myProducts = theProducts;
      isLoading = false;
    });
  }

  ProductDetails? getMyProduct(String myId){
    try{
      return myProducts.firstWhere((p) => p.id == myId);
    }
    catch(_){
      return null;
    }
  }

  @override
  Widget build(BuildContext context){
    final monthly = getMyProduct(theBillingService.myMonthlyId);
    final yearly = getMyProduct(theBillingService.myYearlyId);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Text(
            widget.isExpired? "Your free trial or subscription has unfortunately ended." : "Welcome to our free trial!",
            style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.031250,
          ),
          Text(
            widget.isExpired? "Subscribe to continue using Star Expedition." : "Choose your plan.",
            style: TextStyle(color: Colors.black),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.031250,
          ),

          //The subscription plan buttons:
          if(isLoading)
            const CircularProgressIndicator(color: Colors.red)
          else ...[
            if(monthly != null)...[
              Container(
                alignment: Alignment.topCenter,
                child: const Text("Our monthly plan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    //When onPressed is null, this button is grey[500]:
                    primary: widget.activeProductId == theBillingService.myMonthlyId? Colors.grey[500] : Colors.black,
                    onPrimary: Colors.white,

                    //Overriding the disabled opacity:
                    elevation: 0,
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (states) => widget.activeProductId == theBillingService.myMonthlyId? Colors.grey[500] : Colors.black,
                    ),
                  ),
                  child: Text(widget.activeProductId == theBillingService.myMonthlyId? "Your current plan" : widget.activeProductId == theBillingService.myYearlyId? "Switch to Monthly (${monthly?.price}/month)" : "${monthly?.price}/month", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white), textAlign: TextAlign.center),
                  //Does nothing if a user already has an active monthly plan:
                  onPressed: widget.activeProductId == theBillingService.myMonthlyId? null : (){
                    print("Paying for a monthly subscription");
                    widget.myBillingService.subscribe(monthly!);
                  }
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.015625,
              ),
            ],
            if(yearly != null)...[
              Container(
                alignment: Alignment.topCenter,
                child: const Text("Our yearly plan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              Center(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      //When onPressed is null, this button is grey[500]:
                      primary: widget.activeProductId == theBillingService.myYearlyId? Colors.grey[500] : Colors.black,
                      onPrimary: Colors.white,

                      //Overriding the disabled opacity:
                      elevation: 0,
                    ).copyWith(
                      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                        (states) => widget.activeProductId == theBillingService.myYearlyId? Colors.grey[500] : Colors.black,
                      ),
                    ),
                    child: Text(widget.activeProductId == theBillingService.myYearlyId? "Your current plan" : widget.activeProductId == theBillingService.myMonthlyId? "Switch to Yearly (${yearly?.price}/year)" : "${yearly?.price}/year", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white), textAlign: TextAlign.center),
                    //Does nothing if a user already has an active yearly plan:
                    onPressed: widget.activeProductId == theBillingService.myYearlyId? null : (){
                      print("Paying for a yearly subscription");
                      widget.myBillingService.subscribe(yearly!);
                    }
                ),
              ),
            ],
            //If neither the monthly nor yearly subscription products are available:
            if(monthly == null && yearly == null)
              Container(
                child: Text("\nThe subscription plans are currently unavailable. We are sorry for the inconvenience.", textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
              ),
            Container(
              height: MediaQuery.of(context).size.height * 0.031250,
            ),
          ],
          Container(
            alignment: Alignment.topCenter,
            child: const Text("You can cancel at any time on Google Play.\nThere are no charges during your free trial.", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}