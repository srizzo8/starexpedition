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
import 'package:flutter/services.dart' show FilteringTextInputFormatter, rootBundle;
import 'package:flutter/src/services/asset_bundle.dart';
import 'package:json_editor/json_editor.dart';

class conversionCalculatorPage extends StatefulWidget{
  const conversionCalculatorPage ({Key? key}) : super(key: key);

  @override
  conversionCalculatorPageState createState() => conversionCalculatorPageState();
}

List<String> temperatureUnits = ["Celsius", "Fahrenheit", "Kelvin"];
String dropdownTempValue = temperatureUnits[2];
String secondDropdownTempValue = temperatureUnits[1];

List<String> lengthUnits = ["AU", "Kilometers", "Light-years", "Miles", "Parsecs"];
String dropdownLengthValue = lengthUnits[2];
String secondDropdownLengthValue = lengthUnits[3];

class conversionCalculatorPageState extends State<conversionCalculatorPage>{
  static String nameOfRoute = '/conversionCalculator';

  TextEditingController myTemperature = TextEditingController();
  TextEditingController myLength = TextEditingController();

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Expedition"),
      ),
      body: Wrap(
        children: <Widget>[
          Center(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Text("Conversion Calculator", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
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
            width: 150,
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: myTemperature,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9]")),
              ]
              /*inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],*/
            ),
          ),
          DropdownButton(
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
          DropdownButton(
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
          Container(
            height: 5,
          ),
          Center(
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
                    Text("${int.parse(myTemperature.text)} degrees Celsius is: \n${((int.parse(myTemperature.text)) * (9/5) + 32).toStringAsFixed(4)} degrees Fahrenheit"):
                    dropdownTempValue == "Celsius" && secondDropdownTempValue == "Kelvin"?
                    Text("${int.parse(myTemperature.text)} degrees Celsius is: \n${((int.parse(myTemperature.text)) + 273.15).toStringAsFixed(4)} degrees Kelvin"):
                    dropdownTempValue == "Fahrenheit" && secondDropdownTempValue == "Celsius"?
                    Text("${int.parse(myTemperature.text)} degrees Fahrenheit is: \n${(((int.parse(myTemperature.text)) - 32) * (5/9)).toStringAsFixed(4)} degrees Celsius"):
                    dropdownTempValue == "Fahrenheit" && secondDropdownTempValue == "Fahrenheit"?
                    Text("You cannot convert Fahrenheit to Fahrenheit"):
                    dropdownTempValue == "Fahrenheit" && secondDropdownTempValue == "Kelvin"?
                    Text("${int.parse(myTemperature.text)} degrees Fahrenheit is: \n${((((int.parse(myTemperature.text)) - 32) * (5/9)) + 273.15).toStringAsFixed(4)} degrees Kelvin"):
                    dropdownTempValue == "Kelvin" && secondDropdownTempValue == "Celsius"?
                    Text("${int.parse(myTemperature.text)} degrees Kelvin is: \n${((int.parse(myTemperature.text)) - 273.15).toStringAsFixed(4)} degrees Celsius"):
                    dropdownTempValue == "Kelvin" && secondDropdownTempValue == "Kelvin"?
                    Text("You cannot convert Kelvin to Kelvin"):
                    dropdownTempValue == "Kelvin" && secondDropdownTempValue == "Fahrenheit"?
                    Text("${int.parse(myTemperature.text)} degrees Kelvin is: \n${((((int.parse(myTemperature.text)) - 273.15) * 1.8) + 32).toStringAsFixed(4)} degrees Fahrenheit"):
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
          ),
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
            width: 150,
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: myLength,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9]")),
              ],
            ),
          ),
          DropdownButton(
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
          DropdownButton(
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
          Center(
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
                    Text("${int.parse(myLength.text)} AU is: \n${(int.parse(myLength.text) * 149597870.691).toStringAsFixed(4)} kilometers"):
                    dropdownLengthValue == "AU" && secondDropdownLengthValue == "Light-years"?
                    Text("${int.parse(myLength.text)} AU is: \n${((int.parse(myLength.text)) * (1/63241.077)).toStringAsFixed(4)} light-years"):
                    dropdownLengthValue == "AU" && secondDropdownLengthValue == "Miles"?
                    Text("${int.parse(myLength.text)} AU is: \n${((int.parse(myLength.text)) * 92955807.267).toStringAsFixed(4)} miles"):
                    dropdownLengthValue == "AU" && secondDropdownLengthValue == "Parsecs"?
                    Text("${int.parse(myLength.text)} AU is: \n${(int.parse(myLength.text) / 206264.800).toStringAsFixed(4)} parsecs"):
                    dropdownLengthValue == "Kilometers" && secondDropdownLengthValue == "AU"?
                    Text("${int.parse(myLength.text)} kilometers is: \n${((int.parse(myLength.text)) / 149597870.691).toStringAsFixed(4)} AU"):
                    dropdownLengthValue == "Kilometers" && secondDropdownLengthValue == "Kilometers"?
                    Text("You cannot convert kilometers to kilometers"):
                    dropdownLengthValue == "Kilometers" && secondDropdownLengthValue == "Light-years"?
                    Text("${int.parse(myLength.text)} kilometers is: \n${((int.parse(myLength.text)) / 9460730472580).toStringAsFixed(4)} light-years"):
                    dropdownLengthValue == "Kilometers" && secondDropdownLengthValue == "Miles"?
                    Text("${int.parse(myLength.text)} kilometers is: \n${((int.parse(myLength.text)) * 0.621371).toStringAsFixed(4)} miles"):
                    dropdownLengthValue == "Kilometers" && secondDropdownLengthValue == "Parsecs"?
                    Text("${int.parse(myLength.text)} kilometers is: \n${((int.parse(myLength.text)) / 30856775814671.900).toStringAsFixed(4)} parsecs"):
                    dropdownLengthValue == "Light-years" && secondDropdownLengthValue == "AU"?
                    Text("${int.parse(myLength.text)} light-years is: \n${((int.parse(myLength.text)) * 63241.077).toStringAsFixed(4)} AU"):
                    dropdownLengthValue == "Light-years" && secondDropdownLengthValue == "Kilometers"?
                    Text("${int.parse(myLength.text)} light-years is: \n${((int.parse(myLength.text)) * 9460730572580).toStringAsFixed(4)} kilometers"):
                    dropdownLengthValue == "Light-years" && secondDropdownLengthValue == "Light-years"?
                    Text("You cannot convert light-years to light-years"):
                    dropdownLengthValue == "Light-years" && secondDropdownLengthValue == "Miles"?
                    Text("${int.parse(myLength.text)} light-years is: \n${((int.parse(myLength.text)) * 5878612843200).toStringAsFixed(4)} miles"):
                    dropdownLengthValue == "Light-years" && secondDropdownLengthValue == "Parsecs"?
                    Text("${int.parse(myLength.text)} light-years is: \n${((int.parse(myLength.text)) * 0.3066014).toStringAsFixed(4)} parsecs"):
                    dropdownLengthValue == "Miles" && secondDropdownLengthValue == "AU"?
                    Text("${int.parse(myLength.text)} miles is: \n${((int.parse(myLength.text)) / 92955807.267).toStringAsFixed(4)} AU"):
                    dropdownLengthValue == "Miles" && secondDropdownLengthValue == "Kilometers"?
                    Text("${int.parse(myLength.text)} miles is: \n${((int.parse(myLength.text)) * 1.609344).toStringAsFixed(4)} kilometers"):
                    dropdownLengthValue == "Miles" && secondDropdownLengthValue == "Light-years"?
                    Text("${int.parse(myLength.text)} miles is: \n${((int.parse(myLength.text)) / 5878612843200).toStringAsFixed(4)} light-years"):
                    dropdownLengthValue == "Miles" && secondDropdownLengthValue == "Miles"?
                    Text("You cannot convert miles to miles"):
                    dropdownLengthValue == "Miles" && secondDropdownLengthValue == "Parsecs"?
                    Text("${int.parse(myLength.text)} miles is: \n${((int.parse(myLength.text)) / 19173511575400).toStringAsFixed(4)} parsecs"):
                    dropdownLengthValue == "Parsecs" && secondDropdownLengthValue == "AU"?
                    Text("${int.parse(myLength.text)} parsecs is: \n${((int.parse(myLength.text)) * 206264.984).toStringAsFixed(4)} AU"):
                    dropdownLengthValue == "Parsecs" && secondDropdownLengthValue == "Kilometers"?
                    Text("${int.parse(myLength.text)} parsecs is: \n${((int.parse(myLength.text)) * 30856775812800).toStringAsFixed(4)} kilometers"):
                    dropdownLengthValue == "Parsecs" && secondDropdownLengthValue == "Light-years"?
                    Text("${int.parse(myLength.text)} parsecs is: \n${((int.parse(myLength.text)) * 3.26156378).toStringAsFixed(4)} light-years"):
                    dropdownLengthValue == "Parsecs" && secondDropdownLengthValue == "Miles"?
                    Text("${int.parse(myLength.text)} parsecs is: \n${((int.parse(myLength.text)) * 19173511575400).toStringAsFixed(4)} miles"):
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
          ),
        ],
      ),
      drawer: myMain.starExpeditionNavigationDrawer(),
    );
  }
}