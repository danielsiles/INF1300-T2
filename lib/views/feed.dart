import 'package:flutter/material.dart';
import 'package:insta_food/views/postPhoto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:insta_food/widgets/feed/postItem.dart';

class PostsBloc {
    final _moviesFetcher = PublishSubject<Element>();

    Observable<Element> get allMovies => _moviesFetcher.stream;
    fetchAllMovies() async {
        final _repository = fetchFeed();
        Element itemModel = await _repository;

        _moviesFetcher.sink.add(itemModel);
    }
    dispose() {
        _moviesFetcher.close();
    }
}
final bloc = PostsBloc();

Future<Element> fetchFeed() async {
    debugPrint("FETCHING AGAIN");
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseUser currentUser = await _auth.currentUser();

    final firestoreInstance = Firestore.instance;
    List<dynamic> posts = new List<dynamic>();
    final fetchedPosts = await firestoreInstance.collection("posts").getDocuments();
    for(var i = 0; i < fetchedPosts.documents.length; i++) {
        var p = fetchedPosts.documents[i];

        final user = await firestoreInstance.collection("users").document(p.documentID).get();
//        debugPrint(p.data["uploads"].toString());
        for(var i = 0; i < p.data["uploads"].length; i++) {
            var picObj = p.data["uploads"][i];
            for(var pic in picObj.entries) {
                bool userLiked = false;
                final postLikes = await firestoreInstance.collection('likes')
                    .where('likes', arrayContains: pic.key).getDocuments();
                for(var doc in postLikes.documents) {
                    if(doc.documentID == currentUser.uid) {
                        userLiked = true;
                        break;
                    }
                }

                posts.add({
                    "name": user.data["name"],
                    "latitude": user.data["latitude"],
                    "longitude": user.data["longitude"],
                    "type": user.data["type"],
                    "username": user.data["username"],
                    "downloadURL": pic.value["downloadURL"],
                    "like_count": pic.value["like_count"],
                    "subtitle": pic.value["subtitle"],
                    "created_at": pic.value["created_at"],
                    "postId": pic.key,
                    "userLiked": userLiked
                });
            }
        }
    }
    return Element.fromJson(posts);
}

class Element {
    final List<dynamic> results;

    Element({this.results});

    factory Element.fromJson(List<dynamic> json) {
//        debugPrint(json.toString());
        return Element(
            results: json,
        );
    }
}

class FeedView extends StatefulWidget {

    @override
    _FeedViewState createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {

    Future<Element> element;

    final firestoreInstance = Firestore.instance;

    @override
    void initState() {
    // TODO: implement initState
    super.initState();
    bloc.fetchAllMovies();

    firestoreInstance.collection("posts").snapshots().listen((data) {
        debugPrint("MUDOU POSTS!");
        bloc.fetchAllMovies();
    });
    firestoreInstance.collection("likes").snapshots().listen((data) {
        bloc.fetchAllMovies();
        debugPrint("MUDOU LIKES!");
    });
  }

    @override
    Widget build(BuildContext context) {

//        fetchFeed();


        postPhoto() {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PostPhotoView()));
        }

        return Scaffold(
            appBar: AppBar(
                leading: Container(
                    child: GestureDetector(
                        onTap: postPhoto,
                        child: Icon(
                            FontAwesomeIcons.camera,
                        ),
                    )
                ),
            ),
            body: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Column(
                        children: <Widget>[
                        StreamBuilder(
                            stream: bloc.allMovies,
                            builder: (context, AsyncSnapshot<Element> snapshot) {
                                if (snapshot.hasData) {
                                    List<Widget> pictures = new List<Widget>();
                                    for(var ele in snapshot.data.results) {
                                      pictures.add(
                                          PostItem(ele)
                                      );
                                    }
    //                                return Text("dadxasa");
                                    return Column(
                                            children: pictures
                                        );

                                } else if (snapshot.hasError) {
                                    return Text(snapshot.error.toString());
                                }
                                return Center(child: CircularProgressIndicator());
                            },
                        ),
                ])

                )
            )
        );
    }
}
