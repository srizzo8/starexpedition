import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthApi{
  static final googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> signIn() async{
    if(await googleSignIn.isSignedIn()){
      return googleSignIn.currentUser;
    } else{
      return await googleSignIn.signIn();
    }
  }
}