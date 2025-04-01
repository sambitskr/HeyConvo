import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:heyconvo/api/apis.dart';
import 'package:heyconvo/authentication/login.dart';
import 'package:heyconvo/pages/homepage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // void createAccount() async {
  //   String email = emailController.text.trim();
  //   String password = passwordController.text.trim();

  //   if (email == "" || password == "") {
  //     log("Please fill in all the details");
  //   } else {
  //     log("Signup successful");

  //     UserCredential? userCredential;

  //     try {
  //       userCredential = await FirebaseAuth.instance
  //           .createUserWithEmailAndPassword(email: email, password: password);

  //       if (userCredential != null) {
  //         String uid = userCredential.user!.uid;
  //       }
  //     } on FirebaseAuthException catch (ex) {
  //       log(ex.code.toString());
  //     }

  //     if (userCredential != null) {
  //       String uid = userCredential.user!.uid;
  //     }
  //   }
  // }

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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
              Icon(
                Icons.message,
                size: 60,
                color: Colors.grey,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Welcome to Hey Convo",
                      style: TextStyle(color: Colors.grey.shade600))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sign up or sign in to access your chats",
                      style: TextStyle(color: Colors.grey.shade600))
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Row(
                children: [
                  Icon(
                    Icons.email_rounded,
                    color: Colors.grey,
                    size: 12.84,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text("Name",
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(left: 22, right: 18),
                child: TextFormField(
                  controller: nameController,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Row(
                children: [
                  Icon(
                    Icons.email_rounded,
                    color: Colors.grey,
                    size: 12.84,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text("Email",
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(left: 22, right: 18),
                child: TextFormField(
                  controller: emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Row(
                children: [
                  Icon(
                    Icons.email_rounded,
                    color: Colors.grey,
                    size: 12.84,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text("Password",
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(left: 22, right: 18),
                child: TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              GestureDetector(
                onTap: () async {
                  await APIs.createAccount(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                      nameController.text.trim());
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyHomePage()));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 51, 51, 51),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign up',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              GestureDetector(
                onTap: googleSignIn,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 51, 51, 51),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/google.png',
                        color: Colors.white,
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.07,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Sign up with Google',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? "),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
