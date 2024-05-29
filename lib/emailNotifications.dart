import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mailer/mailer.dart';
//import 'package:url_launcher/url_launcher.dart';
//import 'package:mailer/mailer.dart';
//import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
//import 'package:backendless_sdk/backendless_sdk.dart';
import 'googleAuthApi.dart';
import 'main.dart' as myMain;
import 'registerPage.dart' as registerPage;
//import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

class emailNotifications extends StatelessWidget {
  const emailNotifications ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Email Notifications",
    );
  }
}

Future<void> registrationConfirmationEmail() async{
  /*final Uri par = Uri(
      scheme: 'mailto',
      path: registerPage.myNewEmail,
      queryParameters: {
        'subject': 'Welcome to Star Expedition!',
        'body': 'I hope you enjoy your time on here!'
      }
  );
  if(await canLaunchUrl(par)){
    await launchUrl(par);
  }
  else{
    print("Unable to launch the Url, which is ${par.toString()}");
  }*/

  //Second attempt (with the Email class):
  /*
  final Email myEmail = Email(
    subject: "Welcome to Star Expedition!",
    body: "I hope you enjoy your time on here!",
    recipients: [registerPage.myNewEmail],
    isHTML: false
  );

  print("Sending email");

  await FlutterEmailSender.send(myEmail);*/

  var smtpServer = hotmail(registerPage.myNewEmail, registerPage.myNewPassword);

  if(registerPage.myNewEmail.contains("@gmail.com")){
    smtpServer = gmail(registerPage.myNewEmail, registerPage.myNewPassword);
  }
  else if(registerPage.myNewEmail.contains("@yahoo.com")){
    smtpServer = yahoo(registerPage.myNewEmail, registerPage.myNewPassword);
  }
  else if(registerPage.myNewEmail.contains("@hotmail.com")){
    smtpServer = hotmail(registerPage.myNewEmail, registerPage.myNewPassword);
  }
  else{
    print("Email is invalid.");
  }

  var myMessage = Message()
    ..from = Address("starexpedition@hotmail.com")
    ..recipients.add(registerPage.myNewEmail)
    ..subject = "Welcome to Star Expedition!"
    ..text = "We hope you enjoy your time on here!"
  ;

  try{
    final sendingReport = await send(myMessage, smtpServer);
    print("The message sent: ${sendingReport.toString()}");
  }
  on MailerException catch(e){
    print("The message was not sent: ${e.toString()}");
  }

  var theConnection = PersistentConnection(smtpServer);
  await theConnection.send(myMessage);
  await theConnection.close();
}