import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:insta_food/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;

Future<Element> fetchPost(String query) async {
    final response = await http.get('https://maps.googleapis.com/maps/api/place/details/json?placeid=' + query + '&key=AIzaSyDgkKwW1L29EEQPD4AVr_vcRHu03MTgzwc');

    if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        return Element.fromJson(json.decode(response.body));
    } else {
        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
    }
}

class Element {
    final Map<dynamic, dynamic> results;

    Element({this.results});

    factory Element.fromJson(Map<dynamic, dynamic> json) {
        return Element(
            results: json["result"],
        );
    }
}

class PlaceSignupForm extends StatefulWidget {

    Map<String, dynamic> address;
    Future<Element> element;

    PlaceSignupForm(Map<String, dynamic> data) {
        debugPrint(data.toString());
        address = data;
        element = fetchPost(data["place_id"]);
    }

    @override
    _PlaceSignupFormState createState() => _PlaceSignupFormState();
}

class _PlaceSignupFormState extends State<PlaceSignupForm> {
    String name = "";
    String username = "";
    String email = "";
    String password = "";
    String type = "";
    String latitude = "";
    String longitude = "";

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final firestoreInstance = Firestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    Future<FirebaseUser> _handleSignIn() async {
        final formState = _formKey.currentState;
        formState.save();
        FirebaseUser user = await _auth.createUserWithEmailAndPassword(email: email, password: password);

        firestoreInstance.collection('users').document(user.uid).setData({
            "name": name,
            "username": username,
            "email": email,
            "role": "restaurant",
            "latitude": latitude,
            "longitude": longitude,
            "placeId": widget.address["place_id"],
            "type": type
        }).catchError((e) {
            print(e);
        });
        return user;
    }

    signup() {
        _handleSignIn()
            .then((user) => {
            print(user)
    })
            .catchError((e) => print(e));
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            child: FutureBuilder<Element>(
                future: widget.element,
                builder: (context, snapshot) {
                    if (snapshot.hasData) {
                        Map<String, dynamic> data = snapshot.data.results;
                        latitude = data["geometry"]["location"]["lat"].toString();
                        longitude = data["geometry"]["location"]["lng"].toString();
                        return Form(
                            key: _formKey,
                            child: Column(
                                children: <Widget>[

                                    TextFormField(
                                        onSaved: (input) => name = input,
                                        initialValue: widget.address["structured_formatting"]["main_text"],
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            labelText: MyLocalizations.of(context).getValue("name"),
                                            hintText: MyLocalizations.of(context).getValue("name")
                                        ),
                                    ),
                                    TextFormField(
                                        onSaved: (input) => username = input,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            labelText: MyLocalizations.of(context).getValue("username"),
                                            hintText: MyLocalizations.of(context).getValue("username")
                                        ),
                                    ),
                                    TextFormField(
                                        onSaved: (input) => email = input,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            labelText: "Email",
                                            hintText: 'email'
                                        ),
                                    ),
                                    TextFormField(
                                        onSaved: (input) => password = input,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            labelText: MyLocalizations.of(context).getValue("password"),
                                            hintText: MyLocalizations.of(context).getValue("password")
                                        ),
                                    ),
                                    TextFormField(
                                        onSaved: (input) => type = input,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            labelText: MyLocalizations.of(context).getValue("type"),
//                                            hintText: 'Pizzaria, Japonês, Hamburgueria'
                                        ),
                                    ),
                                    RaisedButton(
                                        onPressed: this.signup,
                                        child: Text(
                                            MyLocalizations.of(context).getValue("register"),
                                            style: TextStyle(fontSize: 20)
                                        ),
                                    ),
                                ],
                            ),
                        );
//                        return
                    } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                    }

                    return Text("Loading...");
                },
            )
        );
    }
}
