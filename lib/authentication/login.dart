import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:heyconvo/api/apis.dart';
import 'package:heyconvo/pages/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      body: Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: SafeArea(
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
                children: [Text("email")],
              ),
              TextField(
                controller: emailController,
              ),
              Row(
                children: [Text("password")],
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
              ),
              ElevatedButton(
                  onPressed: () async {
                    await APIs.login(emailController.text.toString(),
                        passwordController.text.toString());
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyHomePage()));
                  },
                  child: Text('Sign in')),
              ElevatedButton(
                  onPressed: googleSignIn, child: Text('Sign in with google')),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("New to Hey Convo? Create an account")],
              )
            ],
          ),
        ),
      ),
    );
  }
}
