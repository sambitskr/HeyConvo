import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:heyconvo/api/apis.dart';
import 'package:heyconvo/models/chat_user.dart';
import 'package:heyconvo/models/message.dart';
import 'package:heyconvo/pages/view_profile_screen.dart';
import 'package:heyconvo/utils/message_card.dart';
import 'package:heyconvo/utils/my_date_util.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all messages
  List<Message> _list = [];

  // for handling message text changes
  TextEditingController _textEditingController = TextEditingController();

// showEmoji --> for storing values of showing emoji or not (default:false)
// isUploading --> for checking is the image is uploading or not
  bool _showEmoji = false, _isUploading = false;

  void _onEmojiSelected(Emoji emoji) {
    _textEditingController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: _textEditingController.text.length),
      );
  }

  void _onBackspacePressed() {
    _textEditingController
      ..text = _textEditingController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: _textEditingController.text.length),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Color.fromARGB(255, 27, 27, 27), // Match AppBar color
        statusBarIconBrightness:
            Brightness.light, // Light icons on dark background
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: WillPopScope(
            onWillPop: () {
              if (_showEmoji) {
                setState(() {
                  _showEmoji = !_showEmoji;
                });
                return Future.value(false);
              } else {
                return Future.value(true);
              }
            },
            child: Scaffold(
              backgroundColor: Color.fromARGB(255, 27, 27, 27),
              appBar: AppBar(
                // scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Color.fromARGB(
                      255, 27, 27, 27), // Match status bar color with AppBar
                  statusBarIconBrightness:
                      Brightness.light, // Set the color of the status bar icons
                ),
                automaticallyImplyLeading: false,
                elevation: 0,
                flexibleSpace: _appBar(),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: APIs.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          // if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return SizedBox();

                          //if data is loaded already
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data!.docs;
                            // log('Data: ${jsonEncode(data![0].data())}');

                            _list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];

                            // final _list = ["hi", "hello"];

                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  reverse: true,
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          .01),
                                  itemCount: _list.length,
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    // return ChatUserCard(
                                    //   user: _isSearching
                                    //       ? _searchlist[index]
                                    //       : _list[index],
                                    // );
                                    return MessageCard(
                                      message: _list[index],
                                    );
                                    // return Text('Name: ${_list[index]}');
                                  });
                            } else {
                              return Center(
                                child: Text(
                                  "Say Hi!",
                                  style: TextStyle(fontSize: 20),
                                ),
                              );
                            }
                        }
                      },
                    ),
                  ),

                  // progress indicator for showing uploading
                  if (_isUploading)
                    Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )),

                  _chatInput(),

                  //show emoji on keyboard emoji button click & vice versa
                  if (_showEmoji)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: EmojiPicker(
                        textEditingController: _textEditingController,
                        onEmojiSelected: (Category? category, Emoji emoji) {
                          _onEmojiSelected(emoji);
                        },
                        onBackspacePressed: _onBackspacePressed,
                        config: const Config(
                          bottomActionBarConfig: BottomActionBarConfig(
                              buttonColor: Colors.grey,
                              backgroundColor: Colors.grey),
                          emojiViewConfig: EmojiViewConfig(
                            emojiSizeMax: 30,
                            gridPadding: EdgeInsets.zero,
                            recentsLimit: 28,
                            noRecents: const Text(
                              'No Recents',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black26,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            loadingIndicator: const SizedBox.shrink(),
                            buttonMode: ButtonMode.MATERIAL,
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

//app bar widget
  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    )),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.height * .03),
                  child: CachedNetworkImage(
                    height: MediaQuery.of(context).size.height * .055,
                    width: MediaQuery.of(context).size.height * .055,
                    fit: BoxFit.cover,
                    imageUrl:
                        list.isNotEmpty ? list[0].image : widget.user.image,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.person),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: list[0].lastActive)
                          : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.user.lastActive),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              ],
            );
          },
        ));
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * .01,
          horizontal: MediaQuery.of(context).size.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Color.fromARGB(255, 51, 51, 51),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(
                        () {
                          _showEmoji = !_showEmoji;
                        },
                      );
                    },
                    icon: Icon(
                      Icons.emoji_emotions,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    controller: _textEditingController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if (_showEmoji)
                        setState(
                          () {
                            _showEmoji = !_showEmoji;
                          },
                        );
                    },
                    decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.white),
                        hintText: 'Type Something...',
                        border: InputBorder.none),
                  )),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      // Picking Multiple images.
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);

                      //uploading and sending images one by one
                      for (var i in images) {
                        log('Image Path: ${i.path}');
                        setState(
                          () {
                            _isUploading = true;
                          },
                        );
                        await APIs.sendChatImage(widget.user, File(i.path));
                        setState(
                          () {
                            _isUploading = false;
                          },
                        );
                      }
                    },
                    icon: Icon(
                      Icons.photo_size_select_actual_rounded,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);

                      if (image != null) {
                        log("Image path ${image.path}");
                        setState(
                          () {
                            _isUploading = true;
                          },
                        );
                        await APIs.sendChatImage(widget.user, File(image.path));
                        setState(
                          () {
                            _isUploading = true;
                          },
                        );
                      }
                    },
                    icon: Icon(
                      Icons.camera_alt_sharp,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),

          //Send message button
          MaterialButton(
            shape: CircleBorder(),
            minWidth: 0,
            padding: EdgeInsets.all(10),
            color: const Color.fromARGB(255, 192, 247, 166),
            onPressed: () {
              if (_textEditingController.text.isNotEmpty) {
                APIs.sendMessage(
                    widget.user, _textEditingController.text, Type.text);
                _textEditingController.text = '';
              }
            },
            child: Icon(
              Icons.send,
              color: Color.fromARGB(255, 51, 51, 51),
            ),
          )
        ],
      ),
    );
  }
}
