import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';

class CommentInput extends StatefulWidget {
    String postId;
    CommentInput(String postId) {
        this.postId = postId;
    }

    @override
    _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
    Widget sendIcon = Icon(Icons.mic);
    bool _inputIsEmpty = true;
    bool _recording = false;
    var _recorderSubscription;
    String audioPath;

    final inputController = TextEditingController();

    FlutterSound flutterSound = new FlutterSound();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final firestoreInstance = Firestore.instance;
    var uuid = new Uuid();

    inputListener(String text) {
        if (text.length == 0) {
            this.setState(() {
                sendIcon = Icon(Icons.mic);
                _inputIsEmpty = true;
            });
        }
        else if (_inputIsEmpty) {
            this.setState(() {
                sendIcon = Icon(Icons.send);
                _inputIsEmpty = false;
            });
        }
    }

    startRecording() async {
        String path = await flutterSound.startRecorder(null);
        _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
            if (e != null) {
                DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
//                String txt = DateFormat("mm:ss:SS").format(date);
                if(_inputIsEmpty && !_recording) {
                    this.setState(() {
                        sendIcon = Icon(Icons.stop);
                        _recording = true;
                        audioPath = path;
                    });
                }
            }
        });
    }

    stopRecording() async {
        String result = await flutterSound.stopRecorder();
        if (_recorderSubscription != null) {
            _recorderSubscription.cancel();
            _recorderSubscription = null;

            if(_recording) {
                this.setState(() {
                    sendIcon = Icon(Icons.mic);
                    _recording = false;
                });
            }

            final FirebaseUser user = await _auth.currentUser();
            final userSnapshot = await firestoreInstance.collection("users").document(user.uid).get();
            final dataValue = userSnapshot.data;

            File audio = File(audioPath);
            final String fileName = uuid.v4();
            final StorageReference storageRef = FirebaseStorage.instance.ref().child(fileName);
            final StorageUploadTask uploadTask = storageRef.putFile(audio);
            StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
            String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

            final postComments = await firestoreInstance.collection('comments').document(widget.postId).get();
            if(postComments.exists) {
                firestoreInstance.collection('comments').document(widget.postId).updateData({
                    "comments": FieldValue.arrayUnion([{user.uid: {
                        "type": "audio",
                        "created_at": new DateTime.now().toString(),
                        "downloadURL": downloadUrl,
                        "username": dataValue["username"]
                    }}])
                });
            }
            else {
                firestoreInstance.collection('comments').document(widget.postId).setData({
                    "comments": FieldValue.arrayUnion([{user.uid: {
                        "type": "audio",
                        "created_at": new DateTime.now().toString(),
                        "downloadURL": downloadUrl,
                        "username": dataValue["username"]
                    }}])
                });
            }
        }
    }

    sendTextMessage() async {
        final comment = inputController.text;
        inputController.text = "";
        this.setState(() {
            sendIcon = Icon(Icons.mic);
            _inputIsEmpty = true;
        });
        final FirebaseUser user = await _auth.currentUser();
        final userSnapshot = await firestoreInstance.collection("users").document(user.uid).get();
        final dataValue = userSnapshot.data;

//        final postId = "e2fcc0e7-4750-49bc-ba79-184d088c5ef9";
        final postComments = await firestoreInstance.collection('comments').document(widget.postId).get();
        if(postComments.exists) {
            firestoreInstance.collection('comments').document(widget.postId).updateData({
                "comments": FieldValue.arrayUnion([{user.uid: {
                    "type": "text",
                    "created_at": new DateTime.now().toString(),
                    "comment": comment,
                    "username": dataValue["username"]
                }}])
            });
        }
        else {
            firestoreInstance.collection('comments').document(widget.postId).setData({
                "comments": FieldValue.arrayUnion([{user.uid: {
                    "type": "text",
                    "created_at": new DateTime.now().toString(),
                    "comment": comment,
                    "username": dataValue["username"]
                }}])
            });
        }
    }

    sendMessage() {
        if(_inputIsEmpty && !_recording) {
            startRecording();
        }
        else if(_recording) {
            stopRecording();
        }
        else if(!_inputIsEmpty) {
            sendTextMessage();
        }
    }

    @override
    Widget build(BuildContext context) {

        return Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
                children: <Widget>[
                    Expanded(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Container(
                                color: Colors.white,
                                child: Row(
                                    children: <Widget>[
                                        SizedBox(width: 8.0),
                                        Icon(Icons.insert_emoticon,
                                            size: 30.0, color: Theme.of(context).hintColor),
                                        SizedBox(width: 8.0),
                                        Expanded(
                                            child: TextField(
                                                onChanged: inputListener,
                                                controller: inputController,
                                                decoration: InputDecoration(
                                                    hintText: 'Type a message',
                                                    border: InputBorder.none,
                                                ),
                                            ),
                                        ),

                                        SizedBox(width: 8.0),
                                    ],
                                ),
                            ),
                        ),
                    ),
                    SizedBox(
                        width: 5.0,
                    ),
                    GestureDetector(
                        onTap: sendMessage,
                        child: CircleAvatar(
                            child: this.sendIcon,
                        ),
                    ),
                ],
            ),
        );
    }
}
