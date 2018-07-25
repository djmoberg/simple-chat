import 'package:flutter/material.dart';

import 'package:simple_chat/Login.dart';
import 'package:simple_chat/LoggedIn.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseUser;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isAuthenticated = false;
  FirebaseUser _user;

  void _listener() {
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _isAuthenticated = user != null;
        _user = user != null ? user : null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _listener();
    return _isAuthenticated ? LoggedIn(_user) : Login();
  }
}
