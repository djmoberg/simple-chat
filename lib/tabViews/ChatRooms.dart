import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:simple_chat/Chat.dart';

class ChatRooms extends StatelessWidget {
  final FirebaseUser _user;

  ChatRooms(this._user);

  Widget _chatRoomList(BuildContext context, DocumentSnapshot document) {
    return ListView.builder(
      itemExtent: 80.0,
      itemCount: document['chatRooms'].length,
      itemBuilder: (context, index) => StreamBuilder(
            stream: Firestore.instance
                .collection('chatRooms')
                .document(document['chatRooms'][index])
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(
                  child: CircularProgressIndicator(),
                );
              return ListTile(
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Chat(document['chatRooms'][index], _user)));
                },
                leading: Icon(Icons.portrait),
                // leading: Container(
                //   width: 50.0,
                //   height: 50.0,
                //   decoration: BoxDecoration(
                //       shape: BoxShape.circle,
                //       image: DecorationImage(
                //           fit: BoxFit.fill,
                //           image: NetworkImage(
                //               "https://firebasestorage.googleapis.com/v0/b/simple-chat-e8b88.appspot.com/o/37786613_10154851468077395_6105005443841523712_n.jpg?alt=media&token=06758f34-a86f-47d0-b1bd-2863e15584ad"))),
                // ),
                trailing: Text("19.06"),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      snapshot.data['title'],
                      style: Theme.of(context).textTheme.body2,
                    ),
                    Text(
                      "Du: " +
                          Map<String, dynamic>.from(List
                                  .from(snapshot.data['messages'])[
                              snapshot.data['messages'].length - 1])['value'],
                      style: Theme.of(context).textTheme.body1,
                    )
                  ],
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .document(_user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(
            child: CircularProgressIndicator(),
          );
        return Center(
          child: _chatRoomList(context, snapshot.data),
        );
      },
    );
  }
}
