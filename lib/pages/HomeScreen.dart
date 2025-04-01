import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heyconvo/api/apis.dart';
import 'package:heyconvo/models/chat_user.dart';
import 'package:heyconvo/pages/homepage.dart';
import 'package:heyconvo/pages/profile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeSelfInfo();
  }

// Separate async function to handle self-info initialization
  Future<void> _initializeSelfInfo() async {
    await APIs.getSelfInfo();

    // After fetching data, update the state to refresh the UI
    setState(() {});
  }

  // List of pages for each tab
  final List<Widget> _pages = [
    MyHomePage(),
    NewChatPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late BuildContext _scaffoldContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldContext = context; // Store the context safely
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.black,
              size: 35,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ElevatedButton.icon(
              onPressed: () {
                _addChatUserDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 27, 27, 27),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'New Chat',
                style: GoogleFonts.hedvigLettersSans(
                  textStyle: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              size: 35,
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  //add new chat user
  void _addChatUserDialog() {
    String email = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        //title
        title: Row(
          children: [
            Icon(
              Icons.person,
              color: Colors.black,
              size: 28,
            ),
            Text(" Add User")
          ],
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(isDense: true),
              ),
            ),
          ],
        ),

        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
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
}

// Example pages for each tab
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Home Page"));
  }
}

class NewChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("New Chat Page"));
  }
}
