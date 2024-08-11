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

class conversionCalculatorPage extends StatefulWidget{
  const conversionCalculatorPage ({Key? key}) : super(key: key);

  @override
  conversionCalculatorPageState createState() => conversionCalculatorPageState();
}

List<String> temperatureUnits = ["Celsius", "Kelvin", "Fahrenheit"];
String dropdownTempValue = temperatureUnits[1];
String secondDropdownTempValue = temperatureUnits[2];

class conversionCalculatorPageState extends State<conversionCalculatorPage>{
  static String nameOfRoute = '/conversionCalculator';

  TextEditingController myTemperature = TextEditingController();

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
          Container(
            child: Text("Converting Temperature", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
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
                    Text("${int.parse(myTemperature.text)} degrees Celsius is: \n${((int.parse(myTemperature.text)) * (9/5) + 32)} degrees Fahrenheit"):
                    dropdownTempValue == "Celsius" && secondDropdownTempValue == "Kelvin"?
                    Text("${int.parse(myTemperature.text)} degrees Celsius is: \n${((int.parse(myTemperature.text)) + 273.15)} degrees Kelvin"):
                    dropdownTempValue == "Fahrenheit" && secondDropdownTempValue == "Celsius"?
                    Text("${int.parse(myTemperature.text)} degrees Fahrenheit is: \n${((int.parse(myTemperature.text)) - 32) * (5/9)} degrees Celsius"):
                    dropdownTempValue == "Fahrenheit" && secondDropdownTempValue == "Fahrenheit"?
                    Text("You cannot convert Fahrenheit to Fahrenheit"):
                    dropdownTempValue == "Fahrenheit" && secondDropdownTempValue == "Kelvin"?
                    Text("${int.parse(myTemperature.text)} degrees Fahrenheit is: \n${((((int.parse(myTemperature.text)) - 32) * (5/9)) + 273.15)} degrees Kelvin"):
                    dropdownTempValue == "Kelvin" && secondDropdownTempValue == "Celsius"?
                    Text("${int.parse(myTemperature.text)} degrees Kelvin is: \n${((int.parse(myTemperature.text)) - 273.15)} degrees Celsius"):
                    dropdownTempValue == "Kelvin" && secondDropdownTempValue == "Kelvin"?
                    Text("You cannot convert Kelvin to Kelvin"):
                    dropdownTempValue == "Kelvin" && secondDropdownTempValue == "Fahrenheit"?
                    Text("${int.parse(myTemperature.text)} degrees Kelvin is: \n${(((int.parse(myTemperature.text)) - 273.15) * 1.8) + 32} degrees Fahrenheit"):
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
      )
    );
  }
}