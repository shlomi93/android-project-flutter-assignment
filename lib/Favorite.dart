import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hello_me/LoginStatus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

///****************************************************************************************///

class Favorite extends StatefulWidget {
  //const Favorite({Key? key}) : super(key: key);
  late final WordPair pair;
  late final removeFromSet;

  Favorite.setWithPair(this.pair, this.removeFromSet);

  @override
  _FavoriteState createState() => _FavoriteState();
}

///****************************************************************************************///

class _FavoriteState extends State<Favorite> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  SnackBar snackBar =
      SnackBar(content: Text('Deletion is not implemented yet'));

  ///****************************************************************************************///

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Delete Suggestion',
                style: TextStyle(fontSize: 22),
              ),
              content: Text(
                  'Are you sure you want to delete ${widget.pair.asPascalCase.toString()} from your saved suggestions?',
                  style: TextStyle(fontSize: 18)),
              actions: [
                TextButton(
                  onPressed: () => removeFromUserFavorite(),
                  child: Text('Yes'),
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      primary: Colors.white),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'),
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      primary: Colors.white),
                )
              ],
            );
          },
        );
      },
      background: Container(
        color: Colors.deepPurple,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: const <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Padding(padding: EdgeInsets.all(1)),
            Text(
              'Delete Suggestion',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      key: Key(widget.pair.asPascalCase),
      child: ListTile(
        title: Text(
          widget.pair.asPascalCase,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  ///****************************************************************************************///

  void removeFromUserFavorite() {
    String uid = Provider.of<LoginStatus>(context, listen: false).userID;
    bool loggedIn = Provider.of<LoginStatus>(context, listen: false).loggedIn;
    if (loggedIn) {
      _firestore
          .collection('users')
          .doc(uid)
          .update({widget.pair.asPascalCase.toString(): FieldValue.delete()});
    }
    widget.removeFromSet(widget.pair);
    Navigator.of(context, rootNavigator: true).pop(true);
  }

  ///****************************************************************************************///

  ///****************************************************************************************///

  ///****************************************************************************************///

  ///****************************************************************************************///

  ///****************************************************************************************///

  ///****************************************************************************************///

}
