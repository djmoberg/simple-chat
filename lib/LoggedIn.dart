import 'package:flutter/material.dart';

import 'package:simple_chat/tabViews/ChatRooms.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseUser;
import 'package:cloud_firestore/cloud_firestore.dart';

class LoggedIn extends StatelessWidget {
  final FirebaseUser _user;

  LoggedIn(this._user);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Simple Chat"),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.chat)),
              Tab(icon: Icon(Icons.people)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.message),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              StreamBuilder(
                stream: Firestore.instance
                    .collection('users')
                    .document(_user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  return DrawerHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          _user.displayName,
                          style: Theme.of(context).textTheme.headline,
                        ),
                        Text(
                          _user.email,
                          style: Theme.of(context).textTheme.subhead,
                        ),
                      ],
                    ),
                    decoration:
                        BoxDecoration(color: Theme.of(context).primaryColor),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text("Home"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text("Sign out"),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChatRooms(_user),
            Icon(Icons.directions_transit),
          ],
        ),
      ),
    );
  }
}
