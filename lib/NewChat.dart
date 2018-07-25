import 'dart:async';

import 'package:flutter/material.dart';

import 'package:simple_chat/tabViews/ChatRooms.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseUser;
import 'package:cloud_firestore/cloud_firestore.dart';

class NewChat extends StatelessWidget {
  final FirebaseUser _user;

  NewChat(this._user);

  @override
  Widget build(BuildContext context) {
    return MyNewChat(_user);
  }
}

class MyNewChat extends StatefulWidget {
  final FirebaseUser _user;

  MyNewChat(this._user);

  @override
  _MyNewChatState createState() => _MyNewChatState(_user);
}

class _MyNewChatState extends State<MyNewChat> {
  final FirebaseUser _user;

  _MyNewChatState(this._user);

  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New chat"),
      ),
      body: Column(
        children: <Widget>[
          Row(children: <Widget>[
            Expanded(child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            )),
            RaisedButton(
              child: Text("Send"),
              onPressed: () {
                Firestore.instance.runTransaction((transaction) async {
                  DocumentReference ref =
                      Firestore.instance.collection('chatRooms').document();
                  DocumentSnapshot freshSnap = await transaction.get(ref);
                  await transaction.set(
                      freshSnap.reference, {"messages": [], "title": "TEST"});
                  Firestore.instance.runTransaction((transaction) async {
                    DocumentSnapshot freshSnap = await transaction.get(Firestore
                        .instance
                        .collection('users')
                        .document(_user.uid));
                    List<dynamic> newList = List.from(freshSnap['chatRooms']);
                    newList.add(ref.documentID);
                    await transaction
                        .set(freshSnap.reference, {"chatRooms": newList});
                  });
                });
              },
            ),
          ]),
          // Text(_result == null ? "Nei" : _result),
          Expanded(
            child: _searchText.isEmpty
                ? Text("Enter search")
                : StreamBuilder(
                    stream: Firestore.instance
                        .collection('usersPublic')
                        .getDocuments()
                        .asStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text("No data");
                      return ListView.builder(
                        itemExtent: 80.0,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) => ListTile(
                              title: snapshot
                                          .data.documents[index].documentID ==
                                      _searchText
                                  ? Text(
                                      snapshot.data.documents[index].documentID)
                                  : Text("No"),
                            ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
