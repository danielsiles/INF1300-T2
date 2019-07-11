import 'package:flutter/material.dart';
import 'package:insta_food/forms/placeSignupForm.dart';
import 'package:insta_food/views/login.dart';
import 'package:insta_food/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;
class PlaceSignupView extends StatelessWidget {
    final VoidCallback onChangeLanguage;

    Map<String, dynamic> address;

    PlaceSignupView(Map<String, dynamic> data, this.onChangeLanguage) {
        address = data;
    }

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
                        PlaceSignupForm(this.address),
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
