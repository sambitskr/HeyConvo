import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:heyconvo/api/apis.dart';
import 'package:heyconvo/models/message.dart';
import 'package:heyconvo/utils/my_date_util.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;

    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

// sender message
  Widget _blueMessage() {
    //update last read message if sender and receiver are different
    if (widget.message.read.isEmpty)
      APIs.updateMessageReadStatus(widget.message);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .04,
                vertical: MediaQuery.of(context).size.height * .01),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * .04),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 51, 51, 51),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                )),
            child: widget.message.type == Type.text
                ?
                // show text
                Text(widget.message.msg, style: TextStyle(color: Colors.white))
                :
                //show image
                ClipRRect(
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.height * .03),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        Text(
          MyDateUtil.getFormattedTime(
              context: context, time: widget.message.sent),
          style: TextStyle(color: Colors.white),
        )
      ],
    );
  }

  //our message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            //double tick blue icon for message read
            if (widget.message.read.isNotEmpty)
              Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .04,
                vertical: MediaQuery.of(context).size.height * .01),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * .04),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 192, 247, 166),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                )),
            child: widget.message.type == Type.text
                ?
                // show text
                Text(widget.message.msg)
                :
                //show image
                ClipRRect(
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.height * .03),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        backgroundColor: Color.fromARGB(255, 27, 27, 27),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.015,
                    horizontal: MediaQuery.of(context).size.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              widget.message.type == Type.text
                  ?
                  //Copy Message
                  _OptionItem(
                      icon: Icon(
                        Icons.copy,
                        color: Colors.white,
                        size: 26,
                      ),
                      name: 'Copy Text',
                      onTap: () async {
                        Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.of(context).pop(mounted);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Text Copied!')));
                        });
                      })
                  :
                  //Save Image
                  _OptionItem(
                      icon: Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 26,
                      ),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: 'Hey Convo')
                              .then((success) {
                            Navigator.of(context).pop(mounted);
                            if (success != null && success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Image saved!')));
                            }
                          });
                        } catch (e) {
                          log(e.toString());
                        }
                      }),

              if (widget.message.type == Type.text && isMe)

                //Edit Message
                _OptionItem(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 26,
                    ),
                    name: 'Edit Message',
                    onTap: () {
                      //to hide the popup
                      Navigator.of(context).pop(mounted);
                      _showMessageUpdateDialog();
                    }),

              // Delete Message
              if (isMe)
                _OptionItem(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 26,
                    ),
                    name: 'Delete Message',
                    onTap: () async {
                      await APIs.deleteMessage(widget.message).then((value) {
                        Navigator.of(context).pop(mounted);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Message deleted')));
                      });
                    }),

              //Sent At
              _OptionItem(
                  icon: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 26,
                  ),
                  name:
                      'Sent At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),

              //Read At
              _OptionItem(
                  icon: Icon(
                    Icons.done_all,
                    color: Colors.white,
                    size: 26,
                  ),
                  name: widget.message.read.isEmpty
                      ? 'Read At : Not Seen yet'
                      : 'Read At : ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {}),
            ],
          );
        });
  }

  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              //title
              title: Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text("Update Message")
                ],
              ),

              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
              ),

              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('cancel'),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    APIs.editMessage(widget.message, updatedMsg);
                  },
                  child: Text('Update'),
                )
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.05,
            top: MediaQuery.of(context).size.height * .015,
            bottom: MediaQuery.of(context).size.height * 0.025),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '    $name',
              style: TextStyle(color: Colors.white),
            ))
          ],
        ),
      ),
    );
  }
}
