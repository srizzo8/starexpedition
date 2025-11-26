import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:email_sender/email_sender.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'googleAuthApi.dart';
import 'main.dart' as myMain;
import 'registerPage.dart' as registerPage;
//import 'package:flutter_secure_storage/flutter_secure_storage.dart' as secureStorage;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:starexpedition4/settingsPage.dart' as settingsPage;
import 'package:starexpedition4/forgottenPassword.dart' as forgottenPassword;
import 'package:http/http.dart' as http;

var myPort;

class emailNotifications extends StatelessWidget {
  const emailNotifications ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Email Notifications",
    );
  }
}

Future<void> sendAnEmail(String to, String mySubject, String myHtml) async{
  final myResponse = await http.post(
    Uri.parse("https://star-expedition-emails.vercel.app/api/sendEmails"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"to": to, "subject": mySubject, "html": myHtml}),
  );

  print("myResponse.body: ${myResponse.body}");
}

Future<String> sixDigitCode() async{
  Random r = new Random();
  List<int> myCode = [];

  for(int i = 0; i < 6; i++){
    int digit = 0;
    if(i == 0){
      digit = r.nextInt(9) + 1;
    }
    else{
      digit = r.nextInt(10);
    }
    myCode.add(digit);
  }

  var joinDigits = myCode.join('');
  String mySixDigitCode = joinDigits;
  return mySixDigitCode;
}