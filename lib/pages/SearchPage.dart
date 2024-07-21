// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_is_empty

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/ChatRoomModel.dart';
import '../models/UserModel.dart';
import 'ChatRoomPage.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;

  void handleSearch() {
    final query = searchController.text.trim();

    if (query.isNotEmpty) {
      setState(() {
        searchResultsFuture = FirebaseFirestore.instance
            .collection('user')
            .where('email', isEqualTo: query)
            .get();
        // .snapshots()
        // .first;
      });
    }
  }

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('participants.${widget.userModel.uid}', isEqualTo: true)
        .where('participants.${targetUser.uid}', isEqualTo: false)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatroom;
    } else {
      // Create a new one
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: '',
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
        // users: [widget.userModel.uid.toString(), targetUser.uid.toString()],
        // createdon: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;

      log('New Chatroom Created!');
    }

    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(labelText: 'Email Address'),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: handleSearch,
                color: Theme.of(context).colorScheme.secondary,
                child: Text('Search'),
              ),
              SizedBox(
                height: 20,
              ),
              searchResultsFuture == null
                  ? Container()
                  : FutureBuilder(
                      future: searchResultsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            QuerySnapshot dataSnapshot =
                                snapshot.data as QuerySnapshot;

                            if (dataSnapshot.docs.isNotEmpty) {
                              Map<String, dynamic> userMap =
                                  dataSnapshot.docs[0].data()
                                      as Map<String, dynamic>;

                              UserModel searchedUser =
                                  UserModel.fromMap(userMap);

                              return ListTile(
                                onTap: () async {
                                  ChatRoomModel? chatroomModel =
                                      await getChatroomModel(searchedUser);

                                  if (chatroomModel != null) {
                                    Navigator.pop(context);
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ChatRoomPage(
                                        targetUser: searchedUser,
                                        userModel: widget.userModel,
                                        firebaseUser: widget.firebaseUser,
                                        chatroom: chatroomModel,
                                      );
                                    }));
                                  }
                                },
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(searchedUser.profilepic!),
                                  backgroundColor: Colors.grey[500],
                                ),
                                title: Text(searchedUser.fullname!),
                                subtitle: Text(searchedUser.email!),
                                trailing: Icon(Icons.keyboard_arrow_right),
                              );
                            } else {
                              return Text('No results found!');
                            }
                          } else if (snapshot.hasError) {
                            return Text('An error occurred!');
                          } else {
                            return Text('No results found!');
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
