import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService{
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<User?> register(String email, String password,BuildContext context)async{
    try{
      UserCredential user = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return user.user;
    }on FirebaseAuthException catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString())));
    }catch(e){
      print(e);
    }
  }

  Future<User?> login(String email, String password,BuildContext context)async{
    try{
      UserCredential user = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return user.user;
    }on FirebaseAuthException catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString())));
    }catch(e){
      print(e);
    }
  }

  Future<User?> signinWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if(googleUser != null){
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken
        );

        UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
        return userCredential.user;
      }
    }
    catch (e) {
      print(e);
    }
  }

  Future<void> signOut() async{
    await GoogleSignIn().signOut();
    await firebaseAuth.signOut();
  }



}