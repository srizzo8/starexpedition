import 'dart:html' as html;
import 'webOnlyStub.dart';

class webOnlyImplementation implements forWebOnly{
  @override
  void performATask(){
    html.window.alert("This is web!");
  }
}

forWebOnly getWebOnly() => webOnlyImplementation();