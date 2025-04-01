import "dart:convert";
import "dart:developer";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";
import "package:google_fonts/google_fonts.dart";
import "package:heyconvo/api/apis.dart";
import "package:heyconvo/helper/dialogs.dart";
import "package:heyconvo/models/chat_user.dart";
import "package:heyconvo/pages/profile.dart";
import "package:heyconvo/utils/chat_user_card.dart";

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late BuildContext _scaffoldContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldContext = context; // Store the context safely
  }

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
    return GestureDetector(
      //for hiding the keyboard when a tap is detected on the screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        // if searhc is on and back button is pressed then close search
        // onWillPop: () {
        //   if (_isSearching) {
        //     setState(() {
        //       _isSearching = !_isSearching;
        //     });
        //     return Future.value(false);
        //   } else {
        //     return Future.value(true);
        //   }
        canPop: false,
        onPopInvoked: (_) {
          if (_isSearching) {
            setState(() => _isSearching = !_isSearching);
            return;
          }

          // some delay before pop
          Future.delayed(
              const Duration(milliseconds: 300), SystemNavigator.pop);
        },
        child: Scaffold(
          // backgroundColor: Color.fromARGB(255, 27, 27, 27),
          appBar: AppBar(
            // backgroundColor: Color.fromARGB(255, 27, 27, 27),

            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(
                  _isSearching ? Icons.clear_rounded : Icons.search,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                ),
                onPressed: () {
                  // Custom popup menu position
                  final RenderBox overlay = Overlay.of(context)
                      .context
                      .findRenderObject() as RenderBox;
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(100.0, 100.0, 0.0,
                        0.0), // Adjust these values for desired position
                    items: [
                      PopupMenuItem(
                        value: 'Profile',
                        child: Text('Profile'),
                      ),
                      PopupMenuItem(
                        value: 'Logout',
                        child: Text('Logout'),
                      ),
                    ],
                  ).then((value) {
                    // Handle the selected option
                    if (value == 'Profile') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(user: APIs.me),
                        ),
                      );
                    } else if (value == 'Logout') {
                      // Log out the user
                    }
                  });
                },
              ),
            ],
            elevation: 0,
            title: _isSearching
                ? TextField(
                    style: TextStyle(color: Colors.white),
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
                    ),
                    autofocus: true,
                  )
                : Text(
                    "Hey Convo",
                    style: GoogleFonts.dmSans(
                        textStyle: TextStyle(fontWeight: FontWeight.bold)),

                    // TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
          ),
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),

            // get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                // if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Center(child: CircularProgressIndicator());

                //if data is loaded already
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                    // get only those user, whos ids are provided
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
                                    top: MediaQuery.of(context).size.height *
                                        .01),
                                itemCount: _isSearching
                                    ? _searchlist.length
                                    : _list.length,
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
                              ),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: FloatingActionButton(
              onPressed: () {
                _addChatUserDialog();
              },
              child: Icon(Icons.add),
            ),
          ),
          // bottomNavigationBar: BottomNavigationBar(
          //   items: [],
          // ),
        ),
      ),
    );
  }

//add new chat user
  void _addChatUserDialog() {
    String email = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //title
        title: Row(
          children: [
            Icon(
              Icons.person,
              color: Colors.blue,
              size: 28,
            ),
            Text(" Add User")
          ],
        ),

        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration: InputDecoration(
            hintText: 'Email Id',
            prefixIcon: Icon(Icons.email),
          ),
        ),

        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('cancel'),
          ),

          //Add Button
          MaterialButton(
            onPressed: () async {
              Navigator.pop(context);
              if (email.trim().isNotEmpty) {
                final userExists = await APIs.addChatUser(email);
                if (!userExists) {
                  ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
                    SnackBar(
                      content: Text("User doesn't exist"),
                    ),
                  );
                }
              }
            },
            child: Text('Add'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    APIs.updateActiveStatus(false);
    super.dispose();
  }
}
