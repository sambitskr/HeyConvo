import "dart:convert";
import "dart:developer";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:heyconvo/api/apis.dart";
import "package:heyconvo/models/chat_user.dart";
import "package:heyconvo/pages/profile.dart";
import "package:heyconvo/utils/chat_user_card.dart";

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //for storing all users
  List<ChatUser> _list = [];

  // for storing searched items
  final List<ChatUser> _searchlist = [];

  //for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();
    //for setting user status to active
    APIs.updateActiveStatus(true);

    //for updating user active status according to lifecycle  events
    //  resume --> active or online
    //pause  --> inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Mesaage: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume'))
          APIs.updateActiveStatus(true);
        if (message.toString().contains('pause'))
          APIs.updateActiveStatus(false);
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // if searhc is on and back button is pressed then close search
      onWillPop: () {
        if (_isSearching) {
          setState(() {
            _isSearching = !_isSearching;
          });
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 27, 27, 27),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 27, 27, 27),
          centerTitle: true,
          // leading: Image.asset(
          //   'images/HeyConvoIcon.png',
          //   height: 10,
          //   width: 10,
          // ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              },
              icon: Icon(
                _isSearching ? Icons.clear_rounded : Icons.search,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(user: APIs.me)));
              },
              icon: Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
              ),
            )
          ],
          elevation: 0,
          title: _isSearching
              ? TextField(
                  onChanged: (val) {
                    //search logic
                    _searchlist.clear();
                    for (var i in _list) {
                      if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                          i.email.toLowerCase().contains(val.toLowerCase())) {
                        _searchlist.add(i);

                        setState(() {
                          _searchlist;
                        });
                      }
                    }
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name, Email....',
                      hintStyle: TextStyle(color: Colors.white)),
                  autofocus: true,
                )
              : Text(
                  "Hey Convo",
                  style: TextStyle(color: Colors.white, fontSize: 19),
                ),
        ),
        body: GestureDetector(
          //for hiding the keyboard when a tap is detected on the screen
          onTap: () => FocusScope.of(context).unfocus(),
          child: StreamBuilder(
              stream: APIs.getAllUsers(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  // if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(child: CircularProgressIndicator());

                  //if data is loaded already
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;

                    _list = data
                            ?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                        [];

                    if (_list.isNotEmpty) {
                      return ListView.builder(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * .01),
                          itemCount:
                              _isSearching ? _searchlist.length : _list.length,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ChatUserCard(
                              user: _isSearching
                                  ? _searchlist[index]
                                  : _list[index],
                            );
                            // return Text('Name: ${list[index]}');
                          });
                    } else {
                      return Center(
                          child: Text(
                        "no users found",
                        style: TextStyle(color: Colors.white),
                      ));
                    }
                }
              }),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: FloatingActionButton(
            onPressed: () {},
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
