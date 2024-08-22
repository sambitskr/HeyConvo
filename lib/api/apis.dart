import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:heyconvo/models/chat_user.dart';
import 'package:heyconvo/models/message.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for authentication
  static FirebaseStorage storage = FirebaseStorage.instance;

  // to return current user
  static User get user => auth.currentUser!;

  //for storing self information
  static late ChatUser me;

  // for accessing firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //check if the user already exists or not
  static Future<bool> userExists() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    return (await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((user) {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        googleCreateUser().then((value) => getSelfInfo());
      }
    }));
  }

  //for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  //update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'isOnline': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString()
    });
  }

  // Google signin create new user
  static Future<void> googleCreateUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        name: user.displayName.toString(),
        about: "Hey, I am using HeyConvo",
        createdAt: time,
        isOnline: false,
        id: user.uid,
        lastActive: time,
        pushToken: "",
        email: user.email.toString());

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

// to get all the users from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //to update the user info
  static Future<void> updateUserInfo() async {
    return await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({"name": me.name, "about": me.about});
  }

  //update a profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    log('Extension: $ext');
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'images/$ext'))
        .then((p0) {
      log("Data Transferred : ${p0.bytesTransferred / 1000} kb");
    });
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      "image": me.image,
    });
  }

  /************Chat Screen Related APIs****************/

  //chats (collection) --> conversation_id(doc) --> messages(collection) --> message(doc)

  //useful for getting conversion id
  static String getConversionID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversionID(user.id)}/messages')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //for sending messages
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(
        msg: msg,
        toId: chatUser.id,
        read: '',
        type: type,
        sent: time,
        fromId: user.uid);

    final ref =
        firestore.collection('chats/${getConversionID(chatUser.id)}/messages');
    await ref.doc(time).set(message.toJson());
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversionID(message.fromId)}/messages')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversionID(user.id)}/messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;

    final ref = storage.ref().child(
        'images/${getConversionID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'images/$ext'))
        .then((p0) {
      log("Data Transferred : ${p0.bytesTransferred / 1000} kb");
    });
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversionID(message.toId)}/messages')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image)
      await storage.refFromURL(message.msg).delete();
  }

  //update or edit the message
  static Future<void> editMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversionID(message.toId)}/messages')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
