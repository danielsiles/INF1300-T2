import 'package:flutter/material.dart';
import 'package:insta_food/views/login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:insta_food/initialize_i18n.dart' show initializeI18n;
import 'package:insta_food/constants.dart' show languages;
import 'package:insta_food/localizations.dart' show MyLocalizations, MyLocalizationsDelegate;
import 'package:flutter/services.dart';


void main() async {
  Map<String, Map<String, String>> localizedValues = await initializeI18n();
  runApp(MyApp(localizedValues));
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  MyApp(this.localizedValues);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<MyApp> {

  String _locale = 'pt';
  onChangeLanguage() {
    debugPrint("chamandoo");
    if (_locale == 'en') {
      setState(() {
        _locale = 'pt';
      });
    } else {
      setState(() {
        _locale = 'en';
      });
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insta Food',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginView(onChangeLanguage),
      locale: Locale(_locale),
      localizationsDelegates: [
        MyLocalizationsDelegate(widget.localizedValues),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('pt'), // English
        const Locale('en'), // Portuguese
        // ... other locales the app supports
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
