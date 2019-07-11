import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:rxdart/rxdart.dart';
import 'package:insta_food/widgets/comments/commentInput.dart';
import 'package:insta_food/widgets/comments/commentItem.dart';
import 'package:insta_food/widgets/comments/commentTextItem.dart';

class CommentsBloc {
    var _repository;
    CommentsBloc(String postId) {
        _repository = fetchComments(postId);
    }

    final _commentsFetcher = PublishSubject<Element>();

    Observable<Element> get allComments => _commentsFetcher.stream;
    fetchAllComments() async {

        Element itemModel = await _repository;

        _commentsFetcher.sink.add(itemModel);
    }
    dispose() {
        _commentsFetcher.close();
    }
}


Future<Element> fetchComments(String postId) async {
    final firestoreInstance = Firestore.instance;
    List<dynamic> comments = new List<dynamic>();
    final fetchedComments = await firestoreInstance.collection("comments").document(postId).get();
//    debugPrint(fetchedComments.data.toString());
    if(fetchedComments.exists) {
        for (var i = 0; i < fetchedComments.data["comments"].length; i++) {
            var c = fetchedComments.data["comments"][i];
            //        debugPrint(c.toString());
            for (var com in c.entries) {
                if (com.value["type"] == "audio") {
                    comments.add({
                        "type": com.value["type"],
                        "downloadURL": com.value["downloadURL"],
                        "created_at": com.value["created_at"],
                        "username": com.value["username"],
                    });
                }
                else if (com.value["type"] == "text") {
                    comments.add({
                        "type": com.value["type"],
                        "comment": com.value["comment"],
                        "created_at": com.value["created_at"],
                        "username": com.value["username"],
                    });
                }
            }
        }
    }
    debugPrint(comments.toString());
    return Element.fromJson(comments);
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

class CommentsView extends StatefulWidget {

    String postId;

    CommentsView(String postId) {
        this.postId = postId;
    }

    @override
    _CommentsViewState createState() => _CommentsViewState();
}

class _CommentsViewState extends State<CommentsView> {

    FlutterSound flutterSound = new FlutterSound();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final firestoreInstance = Firestore.instance;
    var uuid = new Uuid();

    bool _isPlaying = false;
    String _playerTxt;
    String audioPath = "";
    var _recorderSubscription;



    @override
    Widget build(BuildContext context) {
        var bloc = CommentsBloc(widget.postId);
        bloc.fetchAllComments();

        return Scaffold(
            appBar: AppBar(),
            body: SingleChildScrollView(
                child: Container(
                    child: Column(
                        children: <Widget>[
                            StreamBuilder(
                                stream: bloc.allComments,
                                builder: (context, AsyncSnapshot<Element> snapshot) {
                                    if (snapshot.hasData) {
                                        debugPrint(snapshot.data.results.toString());
                                        List<Widget> pictures = new List<Widget>();
                                        for(var ele in snapshot.data.results) {
                                            debugPrint(ele.toString());
                                            if(ele["type"] == "audio") {
                                                pictures.add(
                                                    CommentItem(ele["username"],
                                                        ele["downloadURL"])
                                                );
                                            }
                                            else {
                                                pictures.add(
                                                    CommentTextItem(ele["username"], ele["comment"])
                                                );
                                            }
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
                            CommentInput(widget.postId)
                        ],
                    ),
                ),
            )
        );
    }
}
