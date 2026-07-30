import 'dart:html' as html;
import 'dart:html';
import 'dart:js_interop_unsafe';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'login_information/loginStatus.dart';
import 'main.dart' as myMain;

void setupWebJSErrors(){
  if(!kIsWeb){
    return;
  }
  else{
    html.window.onError.listen((myEvent){
      final ee = myEvent as html.ErrorEvent;

      final mySafeStack = ee.error is Error ? (ee.error as Error).stackTrace?.toString() ?? "No JS stack trace" : ee.message ?? "Unknown JS-related error";

      final myStack = StackTrace.fromString(mySafeStack);

      myMain.loggingError(ee.message ?? "Unknown JS-related error", myStack, loginStatus.myCachedUsername, myExtraInfo: { "origin": "js_window", "filename": ee.filename, "linenumber": ee.lineno, "columnnumber": ee.colno, },);
    });
  }
}

void setupDartWebErrorCatcher(){
  if(kIsWeb){
    //Catches asynchronous web errors that Flutter typically ignores:
    ErrorWidget.builder = (FlutterErrorDetails myDetails){
      myMain.loggingError(myDetails.exceptionAsString(), myDetails.stack ?? StackTrace.current, loginStatus.myCachedUsername, myExtraInfo: {"origin": "dart_web_async"});

      //Returning the error as text so Star Expedition does not crash:
      return Text("We apologize for the error that has occurred");
    };
  }
}