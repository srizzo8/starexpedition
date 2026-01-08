import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
//import 'dart:html';

import 'package:flutter/foundation.dart';
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
import 'package:flutter/services.dart' show FilteringTextInputFormatter, TextInputFormatter, rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';
import 'package:starexpedition4/firebaseDesktopHelper.dart';

class conversionCalculatorPage extends StatefulWidget{
  const conversionCalculatorPage ({Key? key}) : super(key: key);

  @override
  conversionCalculatorPageState createState() => conversionCalculatorPageState();
}

class decimalAndMinusExpectedFormat extends TextInputFormatter{
  @override
  TextEditingValue formatEditUpdate(TextEditingValue myOldValue, TextEditingValue myNewValue){
    final myText = myNewValue.text;

    //Empty values being allowed
    if(myText.isEmpty){
      return myNewValue;
    }

    //This allows users to enter just "-" in the textbox (it assumes that they will enter a number in afterward):
    if(myText == "-"){
      return myNewValue;
    }

    final validDecimalAndMinusFormat = RegExp(r"^-?\d+(\.\d*)?$");
    return validDecimalAndMinusFormat.hasMatch(myText)? myNewValue: myOldValue;
  }
}

List<String> temperatureUnits = ["Celsius", "Fahrenheit", "Kelvin"];
String dropdownTempValue = temperatureUnits[2];
String secondDropdownTempValue = temperatureUnits[1];

List<String> lengthUnits = ["AU", "Kilometers", "Light-years", "Miles", "Parsecs"];
String dropdownLengthValue = lengthUnits[2];
String secondDropdownLengthValue = lengthUnits[3];
double tempResults = 0.0;
double lengthResults = 0.0;

class conversionCalculatorPageState extends State<conversionCalculatorPage>{
  static String nameOfRoute = '/conversionCalculator';

  TextEditingController myTemperature = TextEditingController();
  TextEditingController myLength = TextEditingController();

  @override
  void initState(){
    super.initState();

    //The temperature and length results become zero if a user leaves the Conversion Calculator page:
    tempResults = 0.0;
    lengthResults = 0.0;

    //The temperature and length results become zero when a user erases the values in the text boxes:
    myTemperature.addListener((){
      if(myTemperature.text.isEmpty){
        setState((){
          tempResults = 0.0;
        });
      }
    });

    myLength.addListener((){
      if(myLength.text.isEmpty){
        setState((){
          lengthResults = 0.0;
        });
      }
    });
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
      ),
      body: Wrap(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Center(
            child: Container(
              child: Text("Conversion Calculator", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015625),
              child: Text("The left side is the unit of measurement you want to convert from. The right side " +
                "is the unit of measurement you want to convert to.", textAlign: TextAlign.center)
            ),
          ),
          Center(
            child: Container(
              child: Text("\nConverting Temperature", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
            ),
          ),
          /*Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015625),
            alignment: Alignment.centerLeft,
            child: Text("Number"),
            height: 500,
            width: 150,
          ),*/
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Padding(
            padding: (kIsWeb || firebaseDesktopHelper.onDesktop)? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.15, 0.0, 0.0, 0.0) : EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
            child: Row(
              children: <Widget>[
                Container(
                  padding: (kIsWeb || firebaseDesktopHelper.onDesktop)? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.0281875, 0.0, 0.0, 0.0) : EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
                  width: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.33333 : 180,
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: myTemperature,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9.-]")),
                        decimalAndMinusExpectedFormat(),
                      ],
                      onChanged: (theTemp){
                        if(theTemp.isNotEmpty && theTemp != "." && theTemp != "-" && "-".allMatches(myTemperature.text).length < 2 && ".".allMatches(myTemperature.text).length < 2){
                          setState((){
                            if(dropdownTempValue == "Celsius" && secondDropdownTempValue == "Celsius"){
                              tempResults = double.parse(myTemperature.text);
                            }
                            else if(dropdownTempValue == "Celsius" && secondDropdownTempValue == "Fahrenheit"){
                              tempResults = ((double.parse(myTemperature.text)) * (9/5) + 32);
                            }
                            else if(dropdownTempValue == "Celsius" && secondDropdownTempValue == "Kelvin"){
                              tempResults = ((double.parse(myTemperature.text)) + 273.15);
                            }
                            else if(dropdownTempValue == "Fahrenheit" && secondDropdownTempValue == "Celsius"){
                              tempResults = (((double.parse(myTemperature.text)) - 32) * (5/9));
                            }
                            else if(dropdownTempValue == "Fahrenheit" && secondDropdownTempValue == "Fahrenheit"){
                              tempResults = double.parse(myTemperature.text);
                            }
                            else if(dropdownTempValue == "Fahrenheit" && secondDropdownTempValue == "Kelvin"){
                              tempResults = ((((double.parse(myTemperature.text)) - 32) * (5/9)) + 273.15);
                            }
                            else if(dropdownTempValue == "Kelvin" && secondDropdownTempValue == "Celsius"){
                              tempResults = ((double.parse(myTemperature.text)) - 273.15);
                            }
                            else if(dropdownTempValue == "Kelvin" && secondDropdownTempValue == "Kelvin"){
                              tempResults = double.parse(myTemperature.text);
                            }
                            else if(dropdownTempValue == "Kelvin" && secondDropdownTempValue == "Fahrenheit"){
                              tempResults = ((((double.parse(myTemperature.text)) - 273.15) * 1.8) + 32);
                            }
                          });
                        }
                      }
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.025, 0.0, 0.0, 0.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.0333,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: dropdownTempValue,
                        icon: Icon(Icons.keyboard_arrow_down),
                        items: temperatureUnits.map((String tu){
                          return DropdownMenuItem(
                            value: tu,
                            child: Text(tu),
                          );
                        }).toList(),
                        onChanged: (String? newTempUnit){
                          setState((){
                            dropdownTempValue = newTempUnit!;
                          });
                        }
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.025, 0.0, 0.0, 0.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.0333,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: secondDropdownTempValue,
                        icon: Icon(Icons.keyboard_arrow_down),
                        items: temperatureUnits.map((String stu){
                          return DropdownMenuItem(
                            value: stu,
                            child: Text(stu),
                          );
                        }).toList(),
                        onChanged: (String? secondNewTempUnit){
                          setState((){
                            secondDropdownTempValue = secondNewTempUnit!;
                          });
                        }
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Result: ${tempResults.toString()}"),
          ),
          Center(
            child: Container(
              child: Text("\nConverting Length", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
            ),
          ),
          /*Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015625),
            alignment: Alignment.centerLeft,
            child: Text("Number"),
            height: 20,
            width: 150,
          ),*/
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Padding(
            padding: (kIsWeb || firebaseDesktopHelper.onDesktop)? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.15, 0.0, 0.0, 0.0) : EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
            child: Row(
              children: <Widget>[
                Container(
                  padding: (kIsWeb || firebaseDesktopHelper.onDesktop)? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.0281875, 0.0, 0.0, 0.0) : EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
                  width: (kIsWeb || firebaseDesktopHelper.onDesktop)? MediaQuery.of(context).size.width * 0.33333 : 180,
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    child: TextField(
                      controller: myLength,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                        decimalAndMinusExpectedFormat(),
                      ],
                      onChanged: (theLength){
                        setState((){
                          if(theLength.isNotEmpty && theLength != "." && theLength != "-" && "-".allMatches(myLength.text).length < 2 && ".".allMatches(myLength.text).length < 2){
                            if(dropdownLengthValue == "AU" && secondDropdownLengthValue == "AU"){
                              lengthResults = double.parse(myLength.text);
                            }
                            else if(dropdownLengthValue == "AU" && secondDropdownLengthValue == "Kilometers"){
                              lengthResults = (double.parse(myLength.text) * 149597870.691);
                            }
                            else if(dropdownLengthValue == "AU" && secondDropdownLengthValue == "Light-years"){
                              lengthResults = ((double.parse(myLength.text)) * (1/63241.077));
                            }
                            else if(dropdownLengthValue == "AU" && secondDropdownLengthValue == "Miles"){
                              lengthResults = ((double.parse(myLength.text)) * 92955807.267);
                            }
                            else if(dropdownLengthValue == "AU" && secondDropdownLengthValue == "Parsecs"){
                              lengthResults = (double.parse(myLength.text) / 206264.800);
                            }
                            else if(dropdownLengthValue == "Kilometers" && secondDropdownLengthValue == "AU"){
                              lengthResults = ((double.parse(myLength.text)) / 149597870.691);
                            }
                            else if(dropdownLengthValue == "Kilometers" && secondDropdownLengthValue == "Kilometers"){
                              lengthResults = double.parse(myLength.text);
                            }
                            else if(dropdownLengthValue == "Kilometers" && secondDropdownLengthValue == "Light-years"){
                              lengthResults = ((double.parse(myLength.text)) / 9460730472580);
                            }
                            else if(dropdownLengthValue == "Kilometers" && secondDropdownLengthValue == "Miles"){
                              lengthResults = ((double.parse(myLength.text)) * 0.621371);
                            }
                            else if(dropdownLengthValue == "Kilometers" && secondDropdownLengthValue == "Parsecs"){
                              lengthResults = ((double.parse(myLength.text)) / 30856775814671.900);
                            }
                            else if(dropdownLengthValue == "Light-years" && secondDropdownLengthValue == "AU"){
                              lengthResults = ((double.parse(myLength.text)) * 63241.077);
                            }
                            else if(dropdownLengthValue == "Light-years" && secondDropdownLengthValue == "Kilometers"){
                              lengthResults = ((double.parse(myLength.text)) * 9460730572580);
                            }
                            else if(dropdownLengthValue == "Light-years" && secondDropdownLengthValue == "Light-years"){
                              lengthResults = double.parse(myLength.text);
                            }
                            else if(dropdownLengthValue == "Light-years" && secondDropdownLengthValue == "Miles"){
                              lengthResults = ((double.parse(myLength.text)) * 5878612843200);
                            }
                            else if(dropdownLengthValue == "Light-years" && secondDropdownLengthValue == "Parsecs"){
                              lengthResults = ((double.parse(myLength.text)) * 0.3066014);
                            }
                            else if(dropdownLengthValue == "Miles" && secondDropdownLengthValue == "AU"){
                              lengthResults = ((double.parse(myLength.text)) / 92955807.267);
                            }
                            else if(dropdownLengthValue == "Miles" && secondDropdownLengthValue == "Kilometers"){
                              lengthResults = ((double.parse(myLength.text)) * 1.609344);
                            }
                            else if(dropdownLengthValue == "Miles" && secondDropdownLengthValue == "Light-years"){
                              lengthResults = ((double.parse(myLength.text)) / 5878612843200);
                            }
                            else if(dropdownLengthValue == "Miles" && secondDropdownLengthValue == "Miles"){
                              lengthResults = double.parse(myLength.text);
                            }
                            else if(dropdownLengthValue == "Miles" && secondDropdownLengthValue == "Parsecs"){
                              lengthResults = ((double.parse(myLength.text)) / 19173511575400);
                            }
                            else if(dropdownLengthValue == "Parsecs" && secondDropdownLengthValue == "AU"){
                              lengthResults = ((double.parse(myLength.text)) * 206264.984);
                            }
                            else if(dropdownLengthValue == "Parsecs" && secondDropdownLengthValue == "Kilometers"){
                              lengthResults = ((double.parse(myLength.text)) * 30856775812800);
                            }
                            else if(dropdownLengthValue == "Parsecs" && secondDropdownLengthValue == "Light-years"){
                              lengthResults = ((double.parse(myLength.text)) * 3.26156378);
                            }
                            else if(dropdownLengthValue == "Parsecs" && secondDropdownLengthValue == "Miles"){
                              lengthResults = ((double.parse(myLength.text)) * 19173511575400);
                            }
                            else if(dropdownLengthValue == "Parsecs" && secondDropdownLengthValue == "Parsecs"){
                              lengthResults = double.parse(myLength.text);
                            }
                          }
                        });
                      }
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.025, 0.0, 0.0, 0.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.0333,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: dropdownLengthValue,
                        icon: Icon(Icons.keyboard_arrow_down),
                        items: lengthUnits.map((String lu){
                          return DropdownMenuItem(
                            value: lu,
                            child: Text(lu),
                          );
                        }).toList(),
                        onChanged: (String? newLengthUnit){
                          setState((){
                            dropdownLengthValue = newLengthUnit!;
                          });
                        }
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.025, 0.0, 0.0, 0.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.0333,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: secondDropdownLengthValue,
                        icon: Icon(Icons.keyboard_arrow_down),
                        items: lengthUnits.map((String slu){
                          return DropdownMenuItem(
                            value: slu,
                            child: Text(slu),
                          );
                        }).toList(),
                        onChanged: (String? secondNewLengthUnit){
                          setState((){
                            secondDropdownLengthValue = secondNewLengthUnit!;
                          });
                        }
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.015625,
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Result: ${lengthResults.toString()}"),
          ),
          /*Center(
            child: InkWell(
              child: Ink(
                color: Colors.black,
                padding: EdgeInsets.all(5.0),
                child: Text("Convert", style: TextStyle(color: Colors.white)),
              ),
              onTap: (){
                showDialog(
                  context: context,
                  builder: (theContext) => AlertDialog(
                    title: const Text("Conversion"),
                    content: dropdownLengthValue == "AU" && secondDropdownLengthValue == "AU"?
                    Text("You cannot convert AU to AU"):
                    dropdownLengthValue == "AU" && secondDropdownLengthValue == "Kilometers"?
                    Text("${myLength.text} AU is: \n${(double.parse(myLength.text) * 149597870.691)} kilometers"):
                    dropdownLengthValue == "AU" && secondDropdownLengthValue == "Light-years"?
                    Text("${myLength.text} AU is: \n${((double.parse(myLength.text)) * (1/63241.077))} light-years"):
                    dropdownLengthValue == "AU" && secondDropdownLengthValue == "Miles"?
                    Text("${myLength.text} AU is: \n${((double.parse(myLength.text)) * 92955807.267)} miles"):
                    dropdownLengthValue == "AU" && secondDropdownLengthValue == "Parsecs"?
                    Text("${myLength.text} AU is: \n${(double.parse(myLength.text) / 206264.800)} parsecs"):
                    dropdownLengthValue == "Kilometers" && secondDropdownLengthValue == "AU"?
                    Text("${myLength.text} kilometers is: \n${((double.parse(myLength.text)) / 149597870.691)} AU"):
                    dropdownLengthValue == "Kilometers" && secondDropdownLengthValue == "Kilometers"?
                    Text("You cannot convert kilometers to kilometers"):
                    dropdownLengthValue == "Kilometers" && secondDropdownLengthValue == "Light-years"?
                    Text("${myLength.text} kilometers is: \n${((double.parse(myLength.text)) / 9460730472580)} light-years"):
                    dropdownLengthValue == "Kilometers" && secondDropdownLengthValue == "Miles"?
                    Text("${myLength.text} kilometers is: \n${((double.parse(myLength.text)) * 0.621371)} miles"):
                    dropdownLengthValue == "Kilometers" && secondDropdownLengthValue == "Parsecs"?
                    Text("${myLength.text} kilometers is: \n${((double.parse(myLength.text)) / 30856775814671.900)} parsecs"):
                    dropdownLengthValue == "Light-years" && secondDropdownLengthValue == "AU"?
                    Text("${myLength.text} light-years is: \n${((double.parse(myLength.text)) * 63241.077)} AU"):
                    dropdownLengthValue == "Light-years" && secondDropdownLengthValue == "Kilometers"?
                    Text("${myLength.text} light-years is: \n${((double.parse(myLength.text)) * 9460730572580)} kilometers"):
                    dropdownLengthValue == "Light-years" && secondDropdownLengthValue == "Light-years"?
                    Text("You cannot convert light-years to light-years"):
                    dropdownLengthValue == "Light-years" && secondDropdownLengthValue == "Miles"?
                    Text("${myLength.text} light-years is: \n${((double.parse(myLength.text)) * 5878612843200)} miles"):
                    dropdownLengthValue == "Light-years" && secondDropdownLengthValue == "Parsecs"?
                    Text("${myLength.text} light-years is: \n${((double.parse(myLength.text)) * 0.3066014)} parsecs"):
                    dropdownLengthValue == "Miles" && secondDropdownLengthValue == "AU"?
                    Text("${myLength.text} miles is: \n${((double.parse(myLength.text)) / 92955807.267)} AU"):
                    dropdownLengthValue == "Miles" && secondDropdownLengthValue == "Kilometers"?
                    Text("${myLength.text} miles is: \n${((double.parse(myLength.text)) * 1.609344)} kilometers"):
                    dropdownLengthValue == "Miles" && secondDropdownLengthValue == "Light-years"?
                    Text("${myLength.text} miles is: \n${((double.parse(myLength.text)) / 5878612843200)} light-years"):
                    dropdownLengthValue == "Miles" && secondDropdownLengthValue == "Miles"?
                    Text("You cannot convert miles to miles"):
                    dropdownLengthValue == "Miles" && secondDropdownLengthValue == "Parsecs"?
                    Text("${myLength.text} miles is: \n${((double.parse(myLength.text)) / 19173511575400)} parsecs"):
                    dropdownLengthValue == "Parsecs" && secondDropdownLengthValue == "AU"?
                    Text("${myLength.text} parsecs is: \n${((double.parse(myLength.text)) * 206264.984)} AU"):
                    dropdownLengthValue == "Parsecs" && secondDropdownLengthValue == "Kilometers"?
                    Text("${myLength.text} parsecs is: \n${((double.parse(myLength.text)) * 30856775812800)} kilometers"):
                    dropdownLengthValue == "Parsecs" && secondDropdownLengthValue == "Light-years"?
                    Text("${myLength.text} parsecs is: \n${((double.parse(myLength.text)) * 3.26156378)} light-years"):
                    dropdownLengthValue == "Parsecs" && secondDropdownLengthValue == "Miles"?
                    Text("${myLength.text} parsecs is: \n${((double.parse(myLength.text)) * 19173511575400)} miles"):
                    dropdownLengthValue == "Parsecs" && secondDropdownLengthValue == "Parsecs"?
                    Text("You cannot convert parsecs to parsecs"):
                    Text(""),
                    actions: <Widget>[
                      TextButton(
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          child: const Text("Ok"),
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
          ),*/
        ],
      ),
      drawer: myMain.starExpeditionNavigationDrawer(),
    );
  }
}