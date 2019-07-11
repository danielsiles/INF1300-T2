import 'package:flutter/material.dart';
import 'package:insta_food/forms/signupForm.dart';
import 'package:insta_food/views/login.dart';
import 'package:insta_food/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;

class SignupView extends StatelessWidget {
    final VoidCallback onChangeLanguage;
    SignupView(this.onChangeLanguage);
    @override
    Widget build(BuildContext context) {

        signup() {
            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginView(onChangeLanguage)));
        }

        return Scaffold(
            appBar: AppBar(),
            body: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                    children: <Widget>[
                        SignupForm(),
                        RaisedButton(
                            onPressed: signup,
                            child: Text(
                                MyLocalizations.of(context).getValue("alreadyAccount"),
                                style: TextStyle(fontSize: 20)
                            ),
                        ),
                    ],
                )

            )

        );
    }
}
