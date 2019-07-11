import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insta_food/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;

class SignupForm extends StatefulWidget {

    @override
    _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
    String name = "";
    String username = "";
    String email = "";
    String password = "";

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
        return Form(
            key: _formKey,
            child: Column(
                children: <Widget>[
                    TextFormField(
                        onSaved: (input) => name = input,
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
    }
}
