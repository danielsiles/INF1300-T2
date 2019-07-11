import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:insta_food/views/feed.dart';
import 'package:insta_food/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;
class LoginForm extends StatefulWidget {

    @override
    _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
    String email = "";
    String password = "";

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    final FirebaseAuth _auth = FirebaseAuth.instance;

    Future<FirebaseUser> _handleSignIn() async {
        final formState = _formKey.currentState;
        print(formState);
        formState.save();
        print(email);
        print(password);
        FirebaseUser user = await _auth.signInWithEmailAndPassword(email: email, password: password);
        return user;
    }

    login() {
        _handleSignIn()
        .then((FirebaseUser user) => {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FeedView()))
        })
            .catchError((e) => print("ERROOOOOU"));
    }

    @override
    Widget build(BuildContext context) {
        return Form(
            key: _formKey,
            child: Column(
                children: <Widget>[
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
                        onPressed: this.login,
                        child: Text(
                            MyLocalizations.of(context).getValue("login"),
                            style: TextStyle(fontSize: 20)
                        ),
                    ),
                ],
            ),
        );
    }
}
