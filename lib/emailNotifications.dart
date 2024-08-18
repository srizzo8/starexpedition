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
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'googleAuthApi.dart';
import 'main.dart' as myMain;
import 'registerPage.dart' as registerPage;
//import 'package:flutter_secure_storage/flutter_secure_storage.dart' as secureStorage;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:starexpedition4/settingsPage.dart' as settingsPage;

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

  await dotenv.load(fileName: "dotenv.env");

  var emailForSmtpServer = dotenv.env["EMAIL_ADDRESS"];
  var passwordForSmtpServer = dotenv.env["PASS"];

  /*
  var myStorage = FlutterSecureStorage();
  await myStorage.write(key: emailForSmtpServer, value: passwordForSmtpServer);
  print("This is myStorage: ${myStorage!.toString()}");*/


  var smtpServer = hotmail(emailForSmtpServer!, passwordForSmtpServer!);

  /*
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
  }*/

  var myMessage = Message()
    ..from = Address("starexpedition@hotmail.com")
    ..recipients.add(registerPage.myNewEmail)
    ..subject = "Welcome to Star Expedition!"
    ..text = "We hope you enjoy your time on here, ${registerPage.myNewUsername}!\n\nIf you have any questions or concerns, please send an email to starexpedition@hotmail.com."
  ;

  try{
    final sendingReport = await send(myMessage, smtpServer);
    print("The message sent: ${sendingReport.toString()}");
  }
  on MailerException catch(e){
    print("The message was not sent: ${e.toString()}");
  }

  var theConnection = PersistentConnection(smtpServer);
  //await theConnection.send(myMessage);
  await theConnection.close();
}

Future<void> passwordChangeConfirmationEmail() async{
  await dotenv.load(fileName: "dotenv.env");

  var myEmailForSmtpServer = dotenv.env["EMAIL_ADDRESS"];
  var myPasswordForSmtpServer = dotenv.env["PASS"];

  var mySmtpServer = hotmail(myEmailForSmtpServer!, myPasswordForSmtpServer!);

  if(settingsPage.theUser != "" && settingsPage.theNewUser == ""){
    var passwordChangeConfirmationMessageExistingUser = Message()
      ..from = Address("starexpedition@hotmail.com")
      ..recipients.add(settingsPage.usersEmail)
      ..subject = "Password Change Confirmation"
      ..text = "Hi ${settingsPage.theUser},\nWe have noticed that you have changed your password. If you did not do this, please contact starexpedition@hotmail.com as soon as possible.\nBest,\nStar Expedition"
    ;

    try{
      final sendingReportExistingUser = await send(passwordChangeConfirmationMessageExistingUser, mySmtpServer);
      print("The message sent: ${sendingReportExistingUser.toString()}");
    }
    on MailerException catch(e){
      print("The message was not sent: ${e.toString()}");
      print("More issues: ${e.message}");
    }

    var theConnectionExistingUser = PersistentConnection(mySmtpServer);
    await theConnectionExistingUser.close();
  }
  else if(settingsPage.theUser == "" && settingsPage.theNewUser != ""){
    var passwordChangeConfirmationMessageNewUser = Message()
      ..from = Address("starexpedition@hotmail.com")
      ..recipients.add(settingsPage.usersEmail)
      ..subject = "Password Change Confirmation"
      ..text = "Hi ${settingsPage.theNewUser},\n\nWe have noticed that you have changed your password. If you did not do this, please contact starexpedition@hotmail.com as soon as possible.\n\nBest,\nStar Expedition"
    ;

    try{
      final sendingReportNewUser = await send(passwordChangeConfirmationMessageNewUser, mySmtpServer);
      print("The message sent: ${sendingReportNewUser.toString()}");
    }
    on MailerException catch(e){
      print("The message was not sent: ${e.toString()}");
    }

    var theConnectionNewUser = PersistentConnection(mySmtpServer);
    await theConnectionNewUser.close();
  }
}