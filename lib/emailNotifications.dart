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
final myClient = http.Client();

class emailNotifications extends StatelessWidget {
  const emailNotifications ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Email Notifications",
    );
  }
}

String convertFromDeltaToHtml(dynamic deltaJson){
  //This accepts either a JSON string or a list that has already been decoded:
  final List<dynamic> myOps = deltaJson is String ? jsonDecode(deltaJson) as List<dynamic> : deltaJson as List<dynamic>;

  final myBuffer = StringBuffer();

  for(final myOp in myOps){
    final myInsert = myOp["insert"];

    if(myInsert is String){
      //In here, escape HTML special chars and new lines are handled accordingly:
      final myEscape = myInsert.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
      myBuffer.write(myEscape.replaceAll('\n', '<br>'));
    }
    else if(myInsert is Map){
      if(myInsert.containsKey("image")){
        //Most email clients can see images:
        final myUrl = myInsert["image"];
        myBuffer.write('<img src="${myUrl}" style="max-width:100%; height:auto;" /><br>');
      }
      else if(myInsert.containsKey("video")){
        //Most email clients, unfortunately, cannot see videos:
        final myUrl = myInsert["video"];
        myBuffer.write('<a href="${myUrl}" target="_blank">Watch Video</a><br>');
      }
    }
  }

  return myBuffer.toString();
}

Future<void> sendAnEmail(String to, String mySubject, String myHtml) async{
  final myResponse = await myClient.post(
    Uri.parse("https://star-expedition-emails.vercel.app/api/sendEmails"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"to": to, "subject": mySubject, "html": myHtml}),
  );

  print("myResponse.body: ${myResponse.body}");
}

Future<void> sendReplyToThreadNotificationEmail(String emailAddressOfTo, String to, String myReplierName, String subforumName, String threadName, String theirReplyData) async{
  final theirReplyHtml = convertFromDeltaToHtml(theirReplyData);

  final myHtml = '''
    <p>Hi ${to},</p>
    <p>${myReplierName} has replied to your thread from the ${subforumName} subforum thread titled ${threadName}. This is what he or she has said:</p>
    <div>${theirReplyHtml}</div>
    <p>Best,<br>Star Expedition</p>
  ''';

  await sendAnEmail(emailAddressOfTo, "Reply to your thread", myHtml);
}

Future<void> sendReplyToReplyNotificationEmail(String emailAddressOfTo, String to, String myReplierName, String subforumName, String threadName, String myReplyData, String theirReplyData) async{
  final myReplyHtml = convertFromDeltaToHtml(myReplyData);
  final theirReplyHtml = convertFromDeltaToHtml(theirReplyData);

  final myHtml = '''
    <p>Hi ${to},</p>
    <p>${myReplierName} has replied to your reply from the ${subforumName} subforum thread titled ${threadName}. Here was the content of your reply:</p>
    <div>${myReplyHtml}</div>
    <p>This is what he or she has said:</p>
    <div>${theirReplyHtml}</div>
    <p>Best,<br>Star Expedition</p>
  ''';

  await sendAnEmail(emailAddressOfTo, "Reply to your reply", myHtml);
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