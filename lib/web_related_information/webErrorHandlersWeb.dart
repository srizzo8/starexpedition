import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:js_interop_unsafe' as jsInterop;

import '../login_information/loginStatus.dart';
import '../main.dart';
import 'webErrorHandlers.dart';

void setupWebErrorHandlers(){
  //JS runtime errors:
  html.window.addEventListener("error", (myEvent){
    final myJsError = myEvent as html.ErrorEvent;

    final myStack = (myJsError.error as JSObject?)?.getProperty("stack".toJS)?.toString();

    loggingError(myJsError.message ?? "Unknown JS-related error", StackTrace.fromString(myStack ?? ""), loginStatus.myCachedUsername, myExtraInfo: {'origin': 'js_error', 'file_name': myJsError.filename, 'line': myJsError.lineno, 'column': myJsError.colno});
  });

  //For unhandled promise rejections:
  html.window.addEventListener("unhandledRejection", (myEvent){
    final myRejection = myEvent as html.PromiseRejectionEvent;

    final myReason = myRejection.reason;

    final myStack = (myReason as JSObject?)?.getProperty("stack".toJS)?.toString();

    loggingError(myReason.toString(), StackTrace.fromString(myStack ?? ""), loginStatus.myCachedUsername, myExtraInfo: {'origin': 'js_promise'});
  });
}