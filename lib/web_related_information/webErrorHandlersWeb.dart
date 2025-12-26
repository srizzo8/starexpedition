import 'dart:html' as html;
import 'dart:js_util' as jsUtil;

import '../main.dart';
import 'webErrorHandlers.dart';

void setupWebErrorHandlers(){
  //JS runtime errors:
  html.window.addEventListener("error", (myEvent){
    final myJsError = myEvent as html.ErrorEvent;

    final myStack = jsUtil.getProperty(myJsError.error ?? {}, "stack") as String?;

    loggingError(myJsError.message ?? "Unknown JS-related error", StackTrace.fromString(myStack ?? ""), determiningUsername(), myExtraInfo: {'origin': 'js_error', 'file_name': myJsError.filename, 'line': myJsError.lineno, 'column': myJsError.colno});
  });

  //For unhandled promise rejections:
  html.window.addEventListener("unhandledRejection", (myEvent){
    final myRejection = myEvent as html.PromiseRejectionEvent;

    final myReason = myRejection.reason;

    final myStack = jsUtil.getProperty(myReason ?? {}, "stack") as String?;

    loggingError(myReason.toString(), StackTrace.fromString(myStack ?? ""), determiningUsername(), myExtraInfo: {'origin': 'js_promise'});
  });
}