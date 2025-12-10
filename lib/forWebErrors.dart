import 'dart:html' as html;
import 'main.dart' as myMain;

void setupWebJSErrors(){
  html.window.onError.listen((myEvent){
    final ee = myEvent as html.ErrorEvent;

    final myStack = ee.error is Error && (ee.error as Error).stackTrace != null? (ee.error as Error).stackTrace.toString(): '';
    myMain.loggingError(ee.message ?? "Unknown JS-related error", StackTrace.fromString(myStack), null, myExtraInfo: { "origin": "js_window", "filename": ee.filename, "linenumber": ee.lineno, "columnnumber": ee.colno, },);
  });
}