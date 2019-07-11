import 'package:flutter/material.dart';
import 'package:insta_food/views/placeSignup.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

Future<Element> fetchPost(String query) async {
    final response = await http.get('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=' + query + '&language=pt_BR&key=AIzaSyDgkKwW1L29EEQPD4AVr_vcRHu03MTgzwc');

    if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        return Element.fromJson(json.decode(response.body));
    } else {
        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
    }
}

class Element {
    final List<dynamic> results;

    Element({this.results});

    factory Element.fromJson(Map<String, dynamic> json) {
//        debugPrint(json.toString());
        return Element(
            results: json['predictions'],
        );
    }
}

class PlacePickerView extends SearchDelegate {
    final VoidCallback onChangeLanguage;
    PlacePickerView(this.onChangeLanguage);
    Future<Element> element;

    @override
    List<Widget> buildActions(BuildContext context) {
        return [
            IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                    query = '';
                },
            ),
        ];
    }

    @override
    Widget buildLeading(BuildContext context) {
        return IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {

                close(context, null);
            },

        );
    }

    @override
    Widget buildResults(BuildContext context) {

        if (query.length < 3) {

            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    Center(
                        child: Text(
                            "Search term must be longer than two letters.",
                        ),
                    )
                ],
            );
        }



        element = fetchPost(query);

        return Center(
            child: FutureBuilder<Element>(
                future: element,
                builder: (context, snapshot) {
//                    debugPrint(snapshot.toString());
                    if (snapshot.hasData) {

                        return ListView.builder(
                            padding: new EdgeInsets.all(8.0),
                            itemBuilder: (_, int index) {
                                Map<String, dynamic> data = snapshot.data.results[index];
                                    String secondaryText = "";
                                    if(data["structured_formatting"]["secondary_text"] != null) {
                                       secondaryText = data["structured_formatting"]["secondary_text"];
                                    }
                                    return ListTile(
                                        title: Text(data["structured_formatting"]["main_text"]),
                                        subtitle: Text(secondaryText),
                                        enabled: true,
                                        onTap: () => {
                                            Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => PlaceSignupView(data, onChangeLanguage)))
                                        }
                                );


                            },
                            itemCount: snapshot.data.results.length,

                        );
//                        return
                    } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                    }

                    return Text("Loading...");
//                    return CinfoLoader();
                },
            ),
        );

//
    }

    @override
    Widget buildSuggestions(BuildContext context) {
        // This method is called everytime the search term changes.
        // If you want to add search suggestions as the user enters their search term, this is the place to do that.
        return Column();
    }
}