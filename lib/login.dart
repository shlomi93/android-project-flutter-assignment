import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hello_me/LoginStatus.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

///****************************************************************************************///

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

///****************************************************************************************///

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verifyPasswordController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _tryingToLogin = false;
  String _email = '';
  String _password = '';

  ///****************************************************************************************///

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _emailController.dispose();
    _passwordController.dispose();
    _verifyPasswordController.dispose();
    super.dispose();
  }

  ///****************************************************************************************///

  @override
  Widget build(BuildContext context) {
    return _tryingToLogin ? tryingToLogin() : notLoggedIn();
  }

  Widget notLoggedIn() {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Login'),
        ),
        body: Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
                child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                  Text("Welcome to Startup Name Generator, please log in below",
                      textAlign: TextAlign.left),
                  TextField(
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Email',
                    ),
                    controller: _emailController,
                  ),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Password',
                    ),
                    controller: _passwordController,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(left: 132, right: 132),
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor: Colors.deepPurple,
                        primary: Colors.white,
                        shape: const StadiumBorder()),
                    onPressed: preSignIn,
                    child: const Text('Log in'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(left: 60, right: 60),
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor: Colors.blue,
                        primary: Colors.white,
                        shape: const StadiumBorder()),
                    onPressed: () => showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => addNewUser(),
                    ),
                    child: const Text('New user? Click to sign up'),
                  )
                ]))));
  }

  ///****************************************************************************************///

  Widget addNewUser() {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: 200,
        color: Colors.white,
        child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text("Please confirm your password below:"),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 32, right: 32, top: 16, bottom: 16),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Password',
                  ),
                  controller: _verifyPasswordController,
                ),
              ),
              TextButton(
                onPressed: () => signUp(),
                child: Text("Confirm",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3)),
                  backgroundColor: Colors.blue,
                  //minimumSize: Size(100,55),
                  //fixedSize: Size(130, 25),
                  //minimumSize: Size.zero,
                  padding: EdgeInsets.only(left: 20, right: 20),
                ),
              )
            ]),
      ),
    );
  }

  ///****************************************************************************************///

  void signUp() async {
    if (!(_verifyPasswordController.text == _passwordController.text)) {
      SnackBar snackBar = SnackBar(content: Text('Passwords must match'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text
      );
      preSignIn();
    }
    Navigator.pop(context);
  }

  ///****************************************************************************************///

  Widget tryingToLogin() {
    signIn();
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Login'),
        ),
        body: Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
                child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                  Text("Welcome to Startup Name Generator, please log in below",
                      textAlign: TextAlign.left),
                  TextField(
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Email',
                    ),
                    controller: _emailController,
                  ),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Password',
                    ),
                    controller: _passwordController,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                  ),
                  CircularProgressIndicator()
                ]))));
  }

  ///****************************************************************************************///

  void preSignIn() {
    FocusScope.of(context).unfocus();
    setState(() {
      _email = _emailController.text;
      _password = _passwordController.text;
      _tryingToLogin = true;
    });
  }

  ///****************************************************************************************///

  Future<bool> signIn() async {
    try {
      UserCredential? userCredential = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
    } on FirebaseAuthException catch (e) {
      SnackBar snackBar2 =
          SnackBar(content: Text('There was an error logging into the app'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar2);

      resetLoginVariable();
      setState(() {
        _tryingToLogin = false;
      });
      return false;
    }

    Provider.of<LoginStatus>(context, listen: false).email = _email;
    Provider.of<LoginStatus>(context, listen: false).password = _password;
    Provider.of<LoginStatus>(context, listen: false).userID =
        _auth.currentUser!.uid;

    try {
      final ref =
          FirebaseStorage.instance.ref().child(_auth.currentUser!.uid + '.png');
      Provider.of<LoginStatus>(context, listen: false).userAvatarUrl =
          await ref.getDownloadURL();
    } catch (e) {
      final ref = FirebaseStorage.instance.ref().child('default.png');
      Provider.of<LoginStatus>(context, listen: false).userAvatarUrl =
          await ref.getDownloadURL();
      print('No avatar for user - use Default.png');
    }

    /// Very bad use of not-null (!) operator
    Provider.of<LoginStatus>(context, listen: false).loggedIn = true;
    setState(() {
      _tryingToLogin = false;
    });

    Navigator.of(context).pop();
    return true;
  }

  ///****************************************************************************************///

  ///****************************************************************************************///

  void resetLoginVariable() {
    _email = '';
    _password = '';
    _tryingToLogin = false;
  }
}

///****************************************************************************************///
