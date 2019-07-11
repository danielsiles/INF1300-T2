import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:insta_food/views/feed.dart';

class PostPhotoView extends StatefulWidget {
    @override
    _PostPhotoViewState createState() => _PostPhotoViewState();
}

class _PostPhotoViewState extends State<PostPhotoView> {
    String subtitle = "";
    File _image;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final firestoreInstance = Firestore.instance;
    var uuid = new Uuid();
    final inputController = TextEditingController();
    bool uploading = false;

    uploadImage() async {
        this.setState(() {
            uploading = true;
        });
        // TODO pegar os dados do usuario na primeira execucao do widget
        final FirebaseUser user = await _auth.currentUser();
        final userSnapshot = await firestoreInstance.collection("users").document(user.uid).get();
        final dataValue = userSnapshot.data;
//        debugPrint(dataValue.data.toString());
        if(dataValue["role"] == "restaurant") {
            final String fileName = uuid.v4();
            final StorageReference storageRef = FirebaseStorage.instance.ref().child(fileName);
            final StorageUploadTask uploadTask = storageRef.putFile(_image);
            StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
            String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
            final userPost = await firestoreInstance.collection('posts').document(user.uid).get();
            if(userPost.exists) {
                firestoreInstance.collection('posts').document(user.uid).updateData({
                    "uploads": FieldValue.arrayUnion([{fileName: {
                        "subtitle": inputController.text,
                        "like_count": 0,
                        "created_at": new DateTime.now().toString(),
                        "downloadURL": downloadUrl,
                    }}])
                });
            }
            else {
                firestoreInstance.collection('posts').document(user.uid).setData({
                    "uploads": FieldValue.arrayUnion([{fileName: {
                        "subtitle": inputController.text,
                        "like_count": 0,
                        "created_at": new DateTime.now().toString(),
                        "downloadURL": downloadUrl,
                    }}])
                });
            }
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FeedView()));
        }
        this.setState(() {
            uploading = true;
        });
    }

    Future getImage() async {
        var image = await ImagePicker.pickImage(source: ImageSource.camera);

        setState(() {
            _image = image;
        });
    }

    renderForm() {
        Widget uploadButton = RaisedButton(
            elevation: 7.0,
            child: Text("UPLOAD"),
            onPressed: uploadImage
        );

        if(uploading) {
            uploadButton = CircularProgressIndicator();
        }
        if(_image == null) {
            return Container();
        }
        else {
            return Column(
                children: <Widget>[
                    Image.file(_image, height: 320, fit: BoxFit.cover,),
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextField(
                            controller: inputController,
                            decoration: InputDecoration(
                                hintText: 'Type a message',
                                border: InputBorder.none,
                            ),
                        ),
                    ),
                    uploadButton
                ]
            );
        }
    }

    @override
    Widget build(BuildContext context) {

        return Scaffold(
            appBar: AppBar(
                title: Text('Upload'),
            ),
            body: SingleChildScrollView(
                child: renderForm(),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: getImage,
                tooltip: 'Pick Image',
                child: Icon(Icons.add_a_photo),
            ),
        );
    }
}