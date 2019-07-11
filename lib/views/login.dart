import 'package:flutter/material.dart';
import 'package:insta_food/forms/loginForm.dart';
import 'package:insta_food/views/signup.dart';
import 'package:insta_food/views/placePicker.dart';
import 'package:insta_food/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;
class LoginView extends StatelessWidget {
  final VoidCallback onChangeLanguage;
  LoginView(this.onChangeLanguage);

  @override
  Widget build(BuildContext context) {

    signup() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SignupView(onChangeLanguage)));
    }


    placeSignup() {
//      Navigator.push(context, MaterialPageRoute(builder: (context) => PlaceSignupView()));
      showSearch(
          context: context,
          delegate: PlacePickerView(onChangeLanguage)
      );
    }

    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            // action button

            // action button
            IconButton(
              icon: Icon(Icons.language),
              onPressed: onChangeLanguage
            ),


          ],
        ),
      body: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              LoginForm(),
              RaisedButton(
                onPressed: signup,
                child: Text(
                    MyLocalizations.of(context).getValue("register"),
                    style: TextStyle(fontSize: 20)
                ),
              ),
              RaisedButton(
                onPressed: placeSignup,
                child: Text(
                    MyLocalizations.of(context).getValue("placeRegister"),
                    style: TextStyle(fontSize: 20)
                ),
              ),
            ],
          )

      ) 
      
    );
  }
}
