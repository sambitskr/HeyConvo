import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:heyconvo/api/apis.dart';
import 'package:heyconvo/main.dart';
import 'package:heyconvo/models/chat_user.dart';
import 'package:heyconvo/models/message.dart';
import 'package:heyconvo/pages/chat_screen.dart';
import 'package:heyconvo/utils/my_date_util.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message info (if null  -->  no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Color.fromARGB(255, 27, 27, 27),
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .04, vertical: 04),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

              if (list.isNotEmpty) {
                _message = list[0];
              }

              return ListTile(
                leading:
                    //  const CircleAvatar(
                    //   child: Icon(Icons.person),
                    // ),
                    ClipRRect(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.height * .3),
                  child: CachedNetworkImage(
                    imageUrl: widget.user.image,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),

                //username
                title: Text(
                  widget.user.name,
                  style: TextStyle(color: Colors.white),
                ),

                //last message
                subtitle: Text(
                  _message != null
                      ? _message!.type == Type.image
                          ? 'image'
                          : _message!.msg
                      : widget.user.about,
                  maxLines: 1,
                  style: TextStyle(color: Colors.grey),
                ),

                //last message time
                trailing: _message == null
                    ? null // show nothing when no message is sent
                    : _message!.read.isEmpty &&
                            _message!.fromId != APIs.user.uid
                        ?
                        //show for unread message
                        Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                color: Colors.lightGreenAccent.shade400,
                                borderRadius: BorderRadius.circular(10)),
                          )

                        //message sent time
                        : Text(
                            MyDateUtil.getLastMessageTime(
                                context: context, time: _message!.sent),
                            style: TextStyle(color: Colors.white),
                          ),
                // trailing: Text("12:00 PM"),
              );
            },
          )),
    );
  }
}
