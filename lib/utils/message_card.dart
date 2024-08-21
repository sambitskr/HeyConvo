import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
        _showBottomSheet();
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
            decoration: BoxDecoration(color: Colors.blue.shade200),
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
        Text(
          MyDateUtil.getFormattedTime(
              context: context, time: widget.message.sent),
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
            ),
          ],
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .04,
                vertical: MediaQuery.of(context).size.height * .01),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * .04),
            decoration: BoxDecoration(color: Colors.green.shade200),
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

  void _showBottomSheet() {
    showModalBottomSheet(
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
                    vertical: MediaQuery.of(context).size.height * 0.15,
                    horizontal: MediaQuery.of(context).size.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),
              _OptionItem(
                  icon: Icon(
                    Icons.copy,
                    size: 26,
                  ),
                  name: 'Copy Text',
                  onTap: () {}),
              _OptionItem(
                  icon: Icon(
                    Icons.copy,
                    size: 26,
                  ),
                  name: 'Copy Text',
                  onTap: () {}),
              _OptionItem(
                  icon: Icon(
                    Icons.copy,
                    size: 26,
                  ),
                  name: 'Copy Text',
                  onTap: () {}),
            ],
          );
        });
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
      onTap: () => onTap,
      child: Padding(
        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.5),
        child: Row(
          children: [icon, Flexible(child: Text('    $name'))],
        ),
      ),
    );
  }
}
