import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class starList{
  String starName;
  String constellation;
  Set starsTracked = 0;
  DatabaseReference identification;

  starList(this.starName, this.constellation);

  void trackTheStar(FirebaseUser guy){
    if(this.starsTracked.contains(guy.uid)){
      this.starsTracked.remove(guy.uid);
    }
    else{
      this.starsTracked.add(guy.uid);
    }
  }

  void idGenerator(DatabaseReference myID){
    this.identification = identification;
  }

  Map<String, dynamic> goesToJson(){
    return{
      'starName': this.starName;
      'constellation': this.constellation;
      'starsTracked': this.starsTracked.toList();
    };
  }
}