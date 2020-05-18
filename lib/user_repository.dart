import 'dart:async';
import 'package:RunControl/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final firestoreInstance;
  // static final FacebookLogin facebookSignIn = new FacebookLogin();

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        firestoreInstance = Firestore.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();

  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);
    var curentUser = await _firebaseAuth.currentUser();
    return curentUser;
  }

  Future<FirebaseUser> signInWithFacebook() async {
    ///This object comes from facebook_login_plugin package
    final facebookLogin = new FacebookLogin();

    final facebookLoginResult = await facebookLogin
        .logInWithReadPermissions(['email', 'public_profile']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        break;

      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        break;

      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");

        /// calling the auth mehtod and getting the logged user
        var token = facebookLoginResult.accessToken.token;
        AuthCredential fbCredential =
            FacebookAuthProvider.getCredential(accessToken: token);
        _firebaseAuth.signInWithCredential(fbCredential);
    }
    return _firebaseAuth.currentUser();
  }

  Future<void> signInWithCredentials(String email, String password) async {
    var result =await  _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result;
  }

  Future<void> signUp({String email, String password}) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  Future<String> getUser() async {
    return (await _firebaseAuth.currentUser()).email;
  }

  Future<FirebaseUser> getCurrentUser() async {
    return (await _firebaseAuth.currentUser());
  }

  Future<User> getFirebaseUser() async {
    var uid = (await _firebaseAuth.currentUser()).uid;
   var result =  await firestoreInstance.collection('users').where('id', isEqualTo: uid).getDocuments();
    if (result.documents.length>0) return User.fromData(result.documents[0].data);
    else return User("","","","","","0","0","","","");
  } 

  Future<User> createNewFirebaseUser() async {
    var authUser = (await _firebaseAuth.currentUser());
    var displayName = authUser.displayName!=null?authUser.displayName:"";
   var user = User(authUser.uid,displayName , "undefined",authUser.email, "", "0.0", "0.0", "","","");
   await firestoreInstance.collection("users").add({
     'id': authUser.uid,
      'fullName': displayName,
      'gender': 'undefined',
      'email':authUser.email,
      'userRole': '',
      'weight':'0.0',
      'height':'0.0',
      'address':'',
      'profileImagePath':'',
      'backgroundImagePath':'',
    });
    return user;
  }

}
