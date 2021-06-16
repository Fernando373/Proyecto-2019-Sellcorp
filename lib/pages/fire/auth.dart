import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class Auth {
  Auth._internal();
  static Auth get instance => Auth._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<FirebaseUser> get user async {
    return (_firebaseAuth.currentUser());
  }

  Future<FirebaseUser> loginByPassword(
    BuildContext context, {
    @required String email,
    @required String password,
  }) async {
    try {
      final AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (result.user != null) {
        return result.user;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<FirebaseUser> facebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == 200) {
        final userData = await FacebookAuth.instance.getUserData();
        print(userData);
        return user;
      } else if (result.status == 403) {
        print("facebook login cancelled");
      } else {
        print("facebook login failed");
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<FirebaseUser> google() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication authentication =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
      );

      final AuthResult result =
          await _firebaseAuth.signInWithCredential(credential);
      final FirebaseUser user = result.user;
      print("username: ${user.displayName}");
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<FirebaseUser> signUp(
    BuildContext context, {
    @required String username,
    @required String email,
    @required String password,
  }) async {
    try {
      final AuthResult result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        final UserUpdateInfo userUpdateInfo = UserUpdateInfo();
        userUpdateInfo.displayName = username;
        await result.user.updateProfile(userUpdateInfo);
        return result.user;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> sendResetEmailLink(BuildContext context,
      {@required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> logOut() async {
    final String providerId = (await user).providerId;
    print("provider: $providerId");
  }
}
