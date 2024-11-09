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

  /*
  var myStorage = FlutterSecureStorage();
  await myStorage.write(key: emailForSmtpServer, value: passwordForSmtpServer);
  print("This is myStorage: ${myStorage!.toString()}");*/

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

  await dotenv.load(fileName: "dotenv.env");
  var emailForGmail = dotenv.env["EMAIL_ADDRESS"];
  var passwordForGmail = dotenv.env["APP_PASS"];
  //print("${emailForGmail}, ${passwordForGmail}");

  /*EmailSender es = EmailSender();
  var theResponse = await es.customMessage(emailForGmail!, passwordForGmail!, registerPage.myNewEmail, "Welcome to Star Expedition!", "Welcome to Star Expedition!", "Hi ${registerPage.myNewUsername},\n\nWe hope you enjoy your time on here.\n\nIf you have any questions or concerns, please send an email to starexpedition@hotmail.com.\n\nBest,\nStar Expedition");
  //var theResponse = await es.sendMessage(registerPage.myNewEmail, "Welcome to Star Expedition!", "Welcome to Star Expedition!", "Hi ${registerPage.myNewUsername},\n\nWe hope you enjoy your time on here.\n\nIf you have any questions or concerns, please send an email to starexpedition@hotmail.com.\n\nBest,\nStar Expedition");

  print("theResponse: ${theResponse}");

  if(theResponse["message"] == "emailSendSuccess"){
    print("theResponse: ${theResponse}");
  }
  else{
    print("The message was not able to get sent");
    print("theResponse: ${theResponse}");
  }*/

  //DO NOT ERASE BELOW

  await dotenv.load(fileName: "dotenv.env");

  var emailForSmtpServer = dotenv.env["EMAIL_ADDRESS"];
  var passwordForSmtpServer = dotenv.env["APP_PASS"];

  var smtpServer = gmail(emailForSmtpServer!, passwordForSmtpServer!);

  var myMessage = Message()
    ..from = Address("starexpedition.theapp@gmail.com")
    ..recipients.add(registerPage.myNewEmail)
    ..subject = "Welcome to Star Expedition!"
    ..text = "Hi ${registerPage.myNewUsername},\n\nWe hope you enjoy your time on here.\n\nIf you have any questions or concerns, please send an email to starexpedition.theapp@gmail.com.\n\nBest,\nStar Expedition"
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
  var myPasswordForSmtpServer = dotenv.env["APP_PASS"];

  var mySmtpServer = gmail(myEmailForSmtpServer!, myPasswordForSmtpServer!);

  if(settingsPage.theUser != "" && settingsPage.theNewUser == ""){
    var passwordChangeConfirmationMessageExistingUser = Message()
      ..from = Address("starexpedition.theapp@gmail.com")
      ..recipients.add(settingsPage.usersEmail)
      ..subject = "Password Change Confirmation"
      ..text = "Hi ${settingsPage.theUser},\n\nWe have noticed that you have changed your password. If you did not do this, please contact starexpedition.theapp@gmail.com as soon as possible.\n\nBest,\nStar Expedition"
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
      ..from = Address("starexpedition.theapp@gmail.com")
      ..recipients.add(settingsPage.usersEmail)
      ..subject = "Password Change Confirmation"
      ..text = "Hi ${settingsPage.theNewUser},\n\nWe have noticed that you have changed your password. If you did not do this, please contact starexpedition.theapp@gmail.com as soon as possible.\n\nBest,\nStar Expedition"
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

Future<void> emailAddressChangeConfirmationEmail() async{
  await dotenv.load(fileName: "dotenv.env");

  var theEmailForSmtpServer = dotenv.env["EMAIL_ADDRESS"];
  var thePasswordForSmtpServer = dotenv.env["APP_PASS"];

  var theSmtpServer = gmail(theEmailForSmtpServer!, thePasswordForSmtpServer!);

  //For previous email address
  var emailChangeConfirmationMessageForPreviousEmailAddress = Message()
    ..from = Address("starexpedition.theapp@gmail.com")
    ..recipients.add(settingsPage.usersEmailForEmailChangeMessage)
    ..subject = "Email Change Confirmation"
    ..text = "Hi ${settingsPage.userForEmailChange},\n\nWe have noticed that you have changed your email address from ${settingsPage.usersEmailForEmailChangeMessage} to ${settingsPage.usersNewEmail}. If you did not do this, please contact starexpedition.theapp@gmail.com as soon as possible.\n\nBest,\nStar Expedition"
  ;

  try{
    final sendingReport = await send(emailChangeConfirmationMessageForPreviousEmailAddress, theSmtpServer);
    print("The message sent: ${sendingReport.toString()}");
  }
  on MailerException catch(e){
    print("The message was not sent: ${e.toString()}");
  }

  //For new email address
  var emailChangeConfirmationMessageForNewEmailAddress = Message()
    ..from = Address("starexpedition.theapp@gmail.com")
    ..recipients.add(settingsPage.usersNewEmail)
    ..subject = "Email Change Confirmation"
    ..text = "Hi ${settingsPage.userForEmailChange},\n\nThis message is to confirm that you have changed your email address from ${settingsPage.usersEmailForEmailChangeMessage} to ${settingsPage.usersNewEmail}.\n\nBest,\nStar Expedition"
  ;

  try{
    final sendingReport = await send(emailChangeConfirmationMessageForNewEmailAddress, theSmtpServer);
    print("The message sent: ${sendingReport.toString()}");
  }
  on MailerException catch(e){
    print("The message was not sent: ${e.toString()}");
  }

  //The connection
  var theConnection = PersistentConnection(theSmtpServer);
  await theConnection.close();
}