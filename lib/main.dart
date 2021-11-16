// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:english_words/english_words.dart';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hello_me/Favorite.dart';
import 'package:hello_me/LoginStatus.dart';
import 'package:hello_me/login.dart';
import 'package:provider/provider.dart';

///****************************************************************************************///

void main() {
  /// ensure initialized - needed for firebase engine.
  WidgetsFlutterBinding.ensureInitialized();

  /// runapp() function takes the given Widget and makes it the root of the widget tree.
  /// use LoginStatus as a Provider.
  runApp(ChangeNotifierProvider(
    create: (_) => LoginStatus(),
    child: App(),
  ));
}

///****************************************************************************************///

/// this class encapsulate the initialization of Firebase.
class App extends StatelessWidget with ChangeNotifier {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  ///****************************************************************************************///

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        /// if has error then print it to the screen
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }

        /// if done, launch the app
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }

        /// if not ready yet, show a progress circle.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

///****************************************************************************************///

/// MyApp stateful class is the main screen widget.
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

///****************************************************************************************///

/// MyApp state class
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// appBar title
      title: 'Startup Name Generator',
      theme: ThemeData(
        // Add the 5 lines from here...
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      // ... to here.
      /// the content of the main screen is RandomWords widget which holds all the logic.
      home: RandomWords(),
    );
  }
}

///****************************************************************************************///

/// RandomWords state class.
class _RandomWordsState extends State<RandomWords> {
  bool loggedIn = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _suggestions = <WordPair>[]; // all suggestions
  final _saved = <WordPair>{}; // saved suggestions
  final _biggerFont = const TextStyle(fontSize: 18.0);
  late SnappingSheetController mySnappingController = SnappingSheetController();
  bool waitingForImage = false;

  ///****************************************************************************************///

  /// build a ListView with

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),

        ///  ListView.builder() constructor creates items as they’re scrolled onto the screen.
        ///  great for big or infinite lists.
        itemBuilder: /*1*/ (context, i) {
          /// 1,3,5,7,... will be used as placeholders for dividers.
          if (i.isOdd) return const Divider();
          /*2*/

          /// the ~/ operator performs a division and returns an integer.
          final index = i ~/ 2; /*3*/

          /// if we're out of suggestions, then generate 10 more.
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10)); /*4*/
          }

          /// DON'T UNDERSTAND THE CALCULATION OF INDEX !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          /// take the suggestion and build a list tile.
          return _buildRow(_suggestions[index]);
        });
  }

  // #enddocregion _buildSuggestions

  ///****************************************************************************************///

  /// gets a suggestion and build a list tile.
  Widget _buildRow(WordPair pair) {
    final alreadySaved =
        _saved.contains(pair); // check if pair already in the set.
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.star : Icons.star_border,
        color: alreadySaved ? Colors.deepPurple : null,
        semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
      ),
      onTap: () {
        // NEW lines from here...

        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
            if (Provider.of<LoginStatus>(context, listen: false).loggedIn) {
              removeFromUserFavorite(pair.asPascalCase);
            }
          } else {
            _saved.add(pair);
            if (Provider.of<LoginStatus>(context, listen: false).loggedIn) {
              addToUserFavorite(pair.asPascalCase);
            }
          }
        });
      },
    );
  }

  ///****************************************************************************************///
  void addToUserFavorite(String pair) {
    String uid = Provider.of<LoginStatus>(context, listen: false).userID;
    _firestore
        .collection('users')
        .doc(uid)
        .set({pair: pair}, SetOptions(merge: true));
  }

  ///****************************************************************************************///
  void removeFromUserFavorite(String pair) {
    String uid = Provider.of<LoginStatus>(context, listen: false).userID;
    _firestore.collection('users').doc(uid).update({pair: FieldValue.delete()});
    setState(() {});
  }

  ///****************************************************************************************///

  Widget mainPageLoggedIn() {
    String msg = 'Welcome back, ' +
        Provider.of<LoginStatus>(context, listen: false).email;

    return SnappingSheet(
      controller: mySnappingController,
      snappingPositions: [
        SnappingPosition.factor(
          positionFactor: 0.0,
          snappingCurve: Curves.linear,
          snappingDuration: Duration(milliseconds: 100),
          grabbingContentOffset: GrabbingContentOffset.top,
        ),
        // SnappingPosition.pixels(
        //   positionPixels: 200,
        //   snappingCurve: Curves.linear,
        //   snappingDuration: Duration(milliseconds: 1000),
        // ),

        SnappingPosition.pixels(
          positionPixels: 130,
          snappingCurve: Curves.linear,
          snappingDuration: Duration(milliseconds: 100),
          grabbingContentOffset: GrabbingContentOffset.middle,
        ),
      ],
      lockOverflowDrag: true,
      child: _buildSuggestions(),
      grabbingHeight: 60,
      grabbing: GestureDetector(
        onTap: sheetReposition,
        child: Container(
          color: Colors.grey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(msg), Icon(Icons.keyboard_arrow_up)],
            ),
          ),
        ),
      ),
      sheetBelow: SnappingSheetContent(
        sizeBehavior: SheetSizeStatic(expandOnOverflow: true, size: 120.0),

        draggable: false,
        // TODO: Add your sheet content here
        child: avatarSheet(),
      ),
    );
  }

  ///****************************************************************************************///

  /// build the main screen (home page)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: _pushSavedFavorite,
            tooltip: 'Saved Suggestions',
          ),
          IconButton(
            icon: Icon(loggedIn ? Icons.exit_to_app : Icons.login),
            onPressed: (loggedIn) ? _signOut : _pushSavedLogin,
            tooltip: (loggedIn) ? 'Logout' : 'Login',
          )
        ],
      ),
      body: (loggedIn) ? mainPageLoggedIn() : _buildSuggestions(),
    );
  }

  ///****************************************************************************************///

  void sheetReposition() {
    if (mySnappingController.currentPosition == 130)
      mySnappingController
          .snapToPosition(SnappingPosition.factor(positionFactor: 0.04));
    else
      mySnappingController
          .snapToPosition(SnappingPosition.pixels(positionPixels: 130));
  }

  ///****************************************************************************************///

  Widget avatarSheet() {
    String userAvatarUrl =
        Provider.of<LoginStatus>(context, listen: false).userAvatarUrl;
    String userEmail = Provider.of<LoginStatus>(context, listen: false).email;

    return Container(
      //alignment: Alignment.center,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0, left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: const Color(0xff7c94b6),
                    image: DecorationImage(
                      image: NetworkImage(userAvatarUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(1000)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0, left: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userEmail,
                  style: TextStyle(fontSize: 20),
                ),
                TextButton(
                  onPressed: () => changeAvatar(),
                  child: Text("Change avatar",
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1)),
                    backgroundColor: Colors.blue,
                    //minimumSize: Size(100,55),
                    fixedSize: Size(130, 25),
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///****************************************************************************************///

  void changeAvatar() async {
    final ref;
    final file = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png']);
    String fileName = Provider.of<LoginStatus>(context, listen: false).userID;

    fileName += ".png";

    if (file != null) {
      final path = file.files.single.path!;
      File _file = File(path);

      ref = FirebaseStorage.instance.ref(fileName);
      await ref.putFile(_file);
      Provider.of<LoginStatus>(context, listen: false).userAvatarUrl = '';
      Provider.of<LoginStatus>(context, listen: false).userAvatarUrl =
          await ref.getDownloadURL();
      setState(() {});
    } else {
      SnackBar snackBar = SnackBar(content: Text('No image selected'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
  }

  ///****************************************************************************************///

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Provider.of<LoginStatus>(context, listen: false).email = '';
    Provider.of<LoginStatus>(context, listen: false).password = '';
    Provider.of<LoginStatus>(context, listen: false).loggedIn = false;
    Provider.of<LoginStatus>(context, listen: false).userAvatarUrl = '';
    SnackBar snackBar2 = SnackBar(content: Text('Successfully logged out'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar2);
    setState(() {
      loggedIn = false;
    });
  }

  ///****************************************************************************************///

  void _pushSavedFavorite() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
            (pair) {
              return Favorite.setWithPair(pair, removeFromSet);
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ), // ...to here.
    );
  }

  ///****************************************************************************************///

  void removeFromSet(WordPair pair) {
    _saved.remove(pair);
    setState(() {});
  }

  ///****************************************************************************************///

  void _pushSavedLogin() {
    /// navigate to Login screen and afterward reconstruct favorite list and add
    /// current favorite to user firebase.
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) {
        return Login();
      }),
    ).then((_) => setState(() {
          loggedIn = Provider.of<LoginStatus>(context, listen: false).loggedIn;
          if (loggedIn) {
            _saved.forEach((element) {
              /// add all new choices to user firebase
              addToUserFavorite(element.asPascalCase);
            });

            /// get user ID
            String uid =
                Provider.of<LoginStatus>(context, listen: false).userID;

            /// clear local Set of choices
            _saved.clear();

            /// get all favorite from user firebase
            _firestore.collection('users').doc(uid).snapshots().listen((event) {
              event.data()?.forEach((key, value) {
                /// separate PascalWord to 2 Strings using regular expressions.
                final _pascalWordsRE = RegExp(r"(?<=[a-z])(?=[A-Z])");
                List<String> getPascalWords(String input) =>
                    key.split(_pascalWordsRE);
                _saved.add(
                    WordPair(getPascalWords(key)[0], getPascalWords(key)[1]));
              });
            });
          }
        }));
  }
}

///****************************************************************************************///

class RandomWords extends StatefulWidget {
  @override
  State<RandomWords> createState() => _RandomWordsState();
}

///****************************************************************************************///
