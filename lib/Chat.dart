import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat extends StatelessWidget {
  final String _currentChat;
  final FirebaseUser _user;

  Chat(this._currentChat, this._user);

  @override
  Widget build(BuildContext context) {
    return MyChat(_currentChat, _user);
  }
}

class MyChat extends StatefulWidget {
  final String _currentChat;
  final FirebaseUser _user;

  MyChat(this._currentChat, this._user);

  @override
  _MyChatState createState() => _MyChatState(_currentChat, _user);
}

class _MyChatState extends State<MyChat> {
  final String _currentChat;
  final FirebaseUser _user;

  _MyChatState(this._currentChat, this._user);

  String _newMessage;
  TextEditingController _controller = TextEditingController();
  bool _sendButtonDisabled = true;

  Future<String> getDisplayName(String uid) async {
    DocumentSnapshot snapshot =
        await Firestore.instance.collection('users').document(uid).get();
    return snapshot.data['displayName'];
  }

  Widget _getDisplayName(BuildContext context, index, document) {
    // return FutureBuilder<String>(
    //   future: getDisplayName(Map<String, dynamic>.from(
    //       List.from(document['messages'])[index])['user']),
    //   builder: (context, snapshot) {
    //     if (!snapshot.hasData) {
    //       return Text("");
    //     }
    //     return Text(snapshot.data);
    //   },
    // );
    return Text(Map<String, dynamic>.from(
        List.from(document['messages'])[index])['displayName']);
  }

  Widget _getMessage(BuildContext context, index, document, fromUser) {
    return Chip(
      backgroundColor: fromUser ? Theme.of(context).primaryColor : Colors.black,
      label: Text(
        Map<String, dynamic>.from(List.from(document['messages'])[index])[
            'value'],
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _myListTile(BuildContext context, index, document) {
    if (Map<String, dynamic>.from(List.from(document['messages'])[index])[
            'displayName'] ==
        _user.displayName)
      return ListTile(
        // title: _getDisplayName(context, index, document),
        trailing: _getMessage(context, index, document, true),
      );
    else
      return ListTile(
        leading: _getMessage(context, index, document, false),
        // title: _getDisplayName(context, index, document),
      );
  }

  Widget _page(BuildContext context, DocumentSnapshot document) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document['title']),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                reverse: true,
                itemExtent: 60.0,
                itemCount: document['messages'].length,
                itemBuilder: (context, index) => _myListTile(context,
                    document['messages'].length - index - 1, document)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Message',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _newMessage = value;
                      _sendButtonDisabled = value.length == 0 ? true : false;
                    });
                  },
                )),
                SizedBox(width: 8.0),
                RaisedButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    _sendButtonDisabled
                        ? null
                        : Firestore.instance
                            .runTransaction((transaction) async {
                            DocumentSnapshot freshSnap =
                                await transaction.get(document.reference);
                            List<dynamic> newList =
                                List.from(freshSnap['messages']);
                            newList.add({
                              'displayName': _user.displayName,
                              'user': _user.uid,
                              'value': _newMessage
                            });
                            await transaction.update(
                                freshSnap.reference, {"messages": newList});
                            setState(() {
                              _newMessage = "";
                            });
                            _controller.clear();
                          });
                  },
                  child: Text("Send"),
                ),
              ],
            ),
          ),
          // TextField(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('chatRooms')
          .document(_currentChat)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text("Loading...");
        }
        return _page(context, snapshot.data);
      },
    );
  }
}
