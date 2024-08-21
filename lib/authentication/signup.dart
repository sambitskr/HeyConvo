import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:heyconvo/api/apis.dart';
import 'package:heyconvo/pages/homepage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void createAccount() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      log("Please fill in all the details");
    } else {
      log("Signup successful");

      UserCredential? userCredential;

      try {
        userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch (ex) {
        log(ex.code.toString());
      }

      if (userCredential != null) {
        String uid = userCredential.user!.uid;
      }
    }
  }

  Future<void> googleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          if ((await APIs.userExists())) {
            // navigate to another page
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyHomePage()));
          } else {
            await APIs.googleCreateUser().then((value) {
              // navigate to another page
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyHomePage()));
            });
          }
        }
      }
    } on FirebaseAuthException catch (ex) {
      log(ex.code.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Welcome to Hey Convo")],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Sign up or sign in to access your chats")],
              ),
              Row(
                children: [Text("Email")],
              ),
              TextField(
                controller: emailController,
              ),
              Row(
                children: [Text("password")],
              ),
              TextField(
                obscureText: true,
                controller: passwordController,
              ),
              ElevatedButton(onPressed: createAccount, child: Text('Sign up')),
              ElevatedButton(
                  onPressed: googleSignIn, child: Text('Sign up with google')),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Already have an account? Sign In")],
              )
            ],
          ),
        ),
      ),
    );
  }
}
