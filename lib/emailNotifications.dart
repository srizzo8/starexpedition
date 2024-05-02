import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
//import 'package:backendless_sdk/backendless_sdk.dart';
import 'googleAuthApi.dart';
import 'main.dart' as myMain;
import 'registerPage.dart' as registerPage;

class emailNotifications extends StatelessWidget {
  const emailNotifications ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Email Notifications",
    );
  }
}

Future registrationConfirmationEmail() async{
  final myUser = await GoogleAuthApi.signIn();

  if(myUser == null){
    return;
  }

  final myEmail = myUser?.email;
  final au = await myUser?.authentication;
  final token = au?.accessToken;

  print("Howdy partner! Nice to meet you! Your email ${myEmail} has been authenticated!");

  final mySmtpServer = gmailSaslXoauth2(myEmail!, token!);

  final emailInfo = Message()
    ..from = Address(myEmail)
    ..recipients = [registerPage.myNewEmail]
    ..subject = "Welcome to Star Expedition"
    ..text = "I hope you enjoy Star Expedition!";

  try{
    await send(emailInfo, mySmtpServer);
  } on MailerException catch(e){
    print("This is e: ${e}");
  }
}

