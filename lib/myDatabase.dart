import 'package:firebase_database/firebase_database.dart';
import 'starList.dart';

final theReference = FirebaseDatabase.instance.reference();
/*The above (line 3) is saying that we are connected to Firebase
and that we should get the firebase database instance
and a reference to it*/

DatabaseReference saveTrack(starList myList){
  var theIdentification = theReference.child('starList/').push();
  theIdentification.set(starList.goesToJson());
  return theIdentification;
}