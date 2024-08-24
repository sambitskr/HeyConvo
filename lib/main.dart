import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:heyconvo/authentication/login.dart';
import 'package:heyconvo/authentication/signup.dart';
import 'package:heyconvo/firebase_options.dart';
import 'package:heyconvo/pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? currentuser = FirebaseAuth.instance.currentUser;

  if (currentuser != null) {
    //logged in
    runApp(MyAppLoggedIn());
  } else {
    // not logged in
    runApp(const MyApp());
  }
}

//Not Logged in
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HeyConvo',
      home: const LoginPage(),
    );
  }
}

//Logged in
class MyAppLoggedIn extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}
