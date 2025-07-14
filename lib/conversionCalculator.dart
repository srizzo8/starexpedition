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
import 'package:flutter/services.dart' show FilteringTextInputFormatter, TextInputFormatter, rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';

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

    /*//Making sure the negative sign is only acceptable if it is the very first character
    if(validDecimalFormat){
      return myNewValue;
    }

    //If it meets none of the if statements, the old value is returned:
    return myOldValue;*/
  }
}

/*class minusExpectedFormat extends TextInputFormatter{
  @override
  TextEditingValue formatEditUpdate(TextEditingValue myOldValue, TextEditingValue myNewValue){
    final myText = myNewValue.text;

    //Empty values being allowed
    if(myText.isEmpty){
      return myNewValue;
    }

    final validMinusFormat = RegExp(r"^-?\d+\.?\d*$");
    return validMinusFormat.hasMatch(myText)? myNewValue: myOldValue;

    /*//Making sure the negative sign is only acceptable if it is the very first character
    if(validMinusFormat){
      return myNewValue;
    }

    //If it meets none of the if statements, the old value is returned:
    return myOldValue;*/
  }
}*/

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

  /*bool decimalUseValid = false;

  bool decimalUseIsValid(String myNum){
    //bool validDecimalFormat = RegExp(r"^-?\d*\.?\d*$").hasMatch(myNum);

    bool decimalIsValid = false;
    List<String> myCharacters = myNum.split("");

    for(int i = 0; i < myCharacters.length; i++){
      if(i < 1 || i > (myCharacters.length - 2)){
        if(myCharacters[i] == "."){
          decimalIsValid = false;
        }
        else{
          //continue
        }
      }
      else{
        //continue unless it is last character
        if(i == (myCharacters.length - 1)){
          decimalIsValid = true;
        }
      }
    }

    return decimalIsValid;
  }

  bool negativeUseIsValid(String myNum){
    bool negativeIsValid = false;
    List<String> myCharacters = myNum.split("");

    for(int j = 0; j < myCharacters.length; j++){
      if(j > 0){
        if(myCharacters[j] == "-"){
          negativeIsValid = false;
        }
        else{
          //continue
        }
      }
      else{
        //continue until last character
        if(j == (myCharacters.length - 1)){
          negativeIsValid = true;
        }
      }
    }

    return negativeIsValid;
  }*/

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
      ),
      body: Wrap(
        children: <Widget>[
          Container(
            height: 5,
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Text("Conversion Calculator", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Text("The left side is the unit of measurement you want to convert from. The right side " +
                "is the unit of measurement you want to convert to.")
            ),
          ),
          Container(
            height: 10,
          ),
          Center(
            child: Container(
              child: Text("Converting Temperature", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            alignment: Alignment.centerLeft,
            child: Text("Number"),
            height: 20,
            width: 150,
          ),
          Container(
            height: 5,
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            height: 50,
            width: 175,
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: myTemperature,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(5.0),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9.-]")),
                decimalAndMinusExpectedFormat(),
              ],
              /*inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],*/
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
          DropdownButtonHideUnderline(
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
          DropdownButtonHideUnderline(
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
          Container(
            height: 5,
          ),
          Container(
            alignment: Alignment.center,
            child: Text("Result: ${tempResults.toString()}"),
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
                    content: dropdownTempValue == "Celsius" && secondDropdownTempValue == "Celsius"?
                    Text("You cannot convert Celsius to Celsius"):
                    dropdownTempValue == "Celsius" && secondDropdownTempValue == "Fahrenheit"?
                    Text("${myTemperature.text} degrees Celsius is: \n${((double.parse(myTemperature.text)) * (9/5) + 32)} degrees Fahrenheit"):
                    dropdownTempValue == "Celsius" && secondDropdownTempValue == "Kelvin"?
                    Text("${myTemperature.text} degrees Celsius is: \n${((double.parse(myTemperature.text)) + 273.15)} degrees Kelvin"):
                    dropdownTempValue == "Fahrenheit" && secondDropdownTempValue == "Celsius"?
                    Text("${myTemperature.text} degrees Fahrenheit is: \n${(((double.parse(myTemperature.text)) - 32) * (5/9))} degrees Celsius"):
                    dropdownTempValue == "Fahrenheit" && secondDropdownTempValue == "Fahrenheit"?
                    Text("You cannot convert Fahrenheit to Fahrenheit"):
                    dropdownTempValue == "Fahrenheit" && secondDropdownTempValue == "Kelvin"?
                    Text("${myTemperature.text} degrees Fahrenheit is: \n${((((double.parse(myTemperature.text)) - 32) * (5/9)) + 273.15)} degrees Kelvin"):
                    dropdownTempValue == "Kelvin" && secondDropdownTempValue == "Celsius"?
                    Text("${myTemperature.text} degrees Kelvin is: \n${((double.parse(myTemperature.text)) - 273.15)} degrees Celsius"):
                    dropdownTempValue == "Kelvin" && secondDropdownTempValue == "Kelvin"?
                    Text("You cannot convert Kelvin to Kelvin"):
                    dropdownTempValue == "Kelvin" && secondDropdownTempValue == "Fahrenheit"?
                    Text("${myTemperature.text} degrees Kelvin is: \n${((((double.parse(myTemperature.text)) - 273.15) * 1.8) + 32)} degrees Fahrenheit"):
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
          Container(
            height: 20,
          ),
          Center(
            child: Container(
              child: Text("Converting Length", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            alignment: Alignment.centerLeft,
            child: Text("Number"),
            height: 20,
            width: 150,
          ),
          Container(
            height: 5,
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            height: 50,
            width: 175,
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: myLength,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(5.0),
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
          DropdownButtonHideUnderline(
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
          DropdownButtonHideUnderline(
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
          Container(
            height: 5,
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