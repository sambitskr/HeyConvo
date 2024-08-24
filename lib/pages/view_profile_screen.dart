import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:heyconvo/api/apis.dart';
import 'package:heyconvo/authentication/signup.dart';
import 'package:heyconvo/models/chat_user.dart';
import 'package:image_picker/image_picker.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 27, 27, 27),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromARGB(255, 27, 27, 27),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
              )),
          elevation: 0,
          title: Text(
            widget.user.name,
            style: TextStyle(color: Colors.white, fontSize: 19),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * .05,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * .03,
                  width: MediaQuery.of(context).size.width,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.height * .1),
                  child: CachedNetworkImage(
                    height: MediaQuery.of(context).size.height * .2,
                    width: MediaQuery.of(context).size.height * .2,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .03,
                  width: MediaQuery.of(context).size.width,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.person,
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
                    initialValue: widget.user.name,
                    style: TextStyle(color: Colors.white),
                    readOnly: true,
                    decoration: const InputDecoration(
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                      size: 12,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text("About",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(left: 22, right: 18),
                  child: TextFormField(
                    readOnly: true,
                    initialValue: widget.user.about,
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
                      Icons.email,
                      color: Colors.grey,
                      size: 12,
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
                    initialValue: widget.user.email,
                    style: TextStyle(color: Colors.white),
                    readOnly: true,
                    decoration: const InputDecoration(
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
