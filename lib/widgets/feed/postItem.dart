import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:insta_food/views/comments.dart';
import 'package:insta_food/views/maps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insta_food/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;

class PostItem extends StatelessWidget {
    String downloadUrl;
    String username;
    String latitude;
    String longitude;
    String postId;
    String subtitle;
    bool userLiked;
    Widget heartIcon;

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final firestoreInstance = Firestore.instance;

    PostItem(Map<String, dynamic> data) {
        downloadUrl = data["downloadURL"];
        username = data["username"];
        latitude = data["latitude"];
        longitude = data["longitude"];
        postId = data["postId"];
        subtitle = data["subtitle"];
        userLiked = data["userLiked"];
        if(userLiked) {
            heartIcon = new Icon(
                FontAwesomeIcons.solidHeart,
                color: Colors.red,
            );
        }
        else {
            heartIcon = new Icon(
                FontAwesomeIcons.heart,
            );
        }
    }

    likePost() async {
        final FirebaseUser user = await _auth.currentUser();
        final userSnapshot = await firestoreInstance.collection("users").document(user.uid).get();
        final dataValue = userSnapshot.data;

//        final postId = "e2fcc0e7-4750-49bc-ba79-184d088c5ef9";
        bool alreadyLiked = false;
        final postLikes = await firestoreInstance.collection('likes')
            .where('likes', arrayContains: this.postId).getDocuments();
        for(var doc in postLikes.documents) {
            debugPrint(doc.documentID);
            if(doc.documentID == user.uid) {
                alreadyLiked = true;
                break;
            }
        }
        if(alreadyLiked) {
            firestoreInstance.collection('likes')
                .document(user.uid)
                .updateData({
                     "likes": FieldValue.arrayRemove([this.postId])
                 });
        }
        else {
            final userLikes = await firestoreInstance.collection('likes')
                .document(user.uid)
                .get();

            if (userLikes.exists) {
                firestoreInstance.collection('likes')
                    .document(user.uid)
                    .updateData({
                    "likes": FieldValue.arrayUnion([this.postId])
                });
            }
            else {
                firestoreInstance.collection('likes')
                    .document(user.uid)
                    .setData({
                    "likes": FieldValue.arrayUnion([this.postId])
                });
            }
        }
    }




    @override
    Widget build(BuildContext context) {

        goToMaps() {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MapsView(this.latitude, this.longitude)));
        }

        commentPost() {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CommentsView(this.postId)));
        }

        var deviceSize = MediaQuery.of(context).size;
        return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                            Row(
                                children: <Widget>[
                                    new Container(
                                        height: 40.0,
                                        width: 40.0,
                                        decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: new DecorationImage(
                                                fit: BoxFit.fill,
                                                image: new NetworkImage(
                                                    "https://pbs.twimg.com/profile_images/916384996092448768/PF1TSFOE_400x400.jpg")),
                                        ),
                                    ),
                                    new SizedBox(
                                        width: 10.0,
                                    ),
                                    Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                            Text(
                                                this.username,
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            GestureDetector(
                                                onTap: goToMaps,
                                                child: Text(
                                                    MyLocalizations.of(context).getValue("seeLocation"),
                                                ),
                                            )


                                        ],
                                    )

                                ],
                            ),
                            new IconButton(
                                icon: Icon(Icons.more_vert),
                                onPressed: null,
                            )
                        ],
                    ),
                ),
                Flexible(
                    fit: FlexFit.loose,
                    child: new Image.network(
                        this.downloadUrl,
                        fit: BoxFit.cover,
                        height: 320,
                    ),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 16.0,right: 16.0,top: 16.0,bottom: 16.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                            new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                    GestureDetector(
                                        onTap: likePost,
                                        child: heartIcon
                                    ),
                                    new SizedBox(
                                        width: 16.0,
                                    ),
                                    GestureDetector(
                                        onTap: commentPost,
                                        child: new Icon(
                                            FontAwesomeIcons.comments,
                                        ),
                                    ),
                                    new SizedBox(
                                        width: 16.0,
                                    ),
//                                    new Icon(FontAwesomeIcons.paperPlane),
                                ],
                            ),
                            new Icon(FontAwesomeIcons.bookmark)
                        ],
                    ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                        "25 " + MyLocalizations.of(context).getValue("likes"),
                        style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                    child:  Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            Text(
                                this.username,
                                style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                                " "
                            ),
                            Flexible(
                                child: Text(
                                    subtitle,
                                    textAlign: TextAlign.left
                                ),
                            )
                        ],
                    ),
                ),
//                Padding(
//                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 8.0),
//                    child: Row(
//                        mainAxisAlignment: MainAxisAlignment.start,
//                        children: <Widget>[
//                            new Container(
//                                height: 40.0,
//                                width: 40.0,
//                                decoration: new BoxDecoration(
//                                    shape: BoxShape.circle,
//                                    image: new DecorationImage(
//                                        fit: BoxFit.fill,
//                                        image: new NetworkImage(
//                                            "https://pbs.twimg.com/profile_images/916384996092448768/PF1TSFOE_400x400.jpg")),
//                                ),
//                            ),
//                            new SizedBox(
//                                width: 10.0,
//                            ),
//                            Expanded(
//                                child: new TextField(
//                                    decoration: new InputDecoration(
//                                        border: InputBorder.none,
//                                        hintText: "Add a comment...",
//                                    ),
//                                ),
//                            ),
//                        ],
//                    ),
//                ),

            ],
        );
    }
}