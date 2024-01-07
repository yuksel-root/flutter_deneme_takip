import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth fAuth = FirebaseAuth.instance;

  Future<User?> signInWithGoogle() async {
    final gUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken, idToken: gAuth.idToken);

    final UserCredential userCredential =
        await fAuth.signInWithCredential(credential);

    User? userDetails = userCredential.user;
    if (userCredential.user != null) {
      Map<String, dynamic> userInfoMap = {
        "email": userDetails!.email,
        "id": userDetails.uid,
        "name": userDetails.displayName,
        "imgUrl": userDetails.photoURL,
      };
    }
    return userCredential.user;
  }

  Future<void> signOut() async {
    await fAuth.signOut();
    await GoogleSignIn().signOut();
  }
}
