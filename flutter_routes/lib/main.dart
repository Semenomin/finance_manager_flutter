import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_lab6/noArguments.dart';
import 'package:flutter_lab6/pageView.dart';
import 'package:flutter_lab6/platformMethodChannel.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  var hive = await Hive.openBox<String>("strings");
  runApp(MyApp(hive));
}

class MyApp extends StatelessWidget {
  MyApp(this.hive);
  var hive;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == PassArgumentsScreen.routeName) {
            final ScreenArguments args = settings.arguments;
            return MaterialPageRoute(
              builder: (context) {
                return PassArgumentsScreen(
                  title: args.title,
                  message: args.message,
                );
              },
            );
          }
          assert(false, 'Need to implement ${settings.name}');
          return null;
        },
        title: 'Navigation with Arguments',
        home: HomeScreen(hive),
        routes: {
          ExtractArgumentsScreen.routeName: (context) =>
              ExtractArgumentsScreen(),
          MyHomePage.routeName: (context) => MyHomePage(title: "no arguments"),
          PageViewDemo.routeName: (context) => PageViewDemo(),
          PlatformChannel.routeName: (context) => PlatformChannel()
        });
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen(this.hive);
  Box<String> hive;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text("Navigate to screen that extracts arguments"),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  ExtractArgumentsScreen.routeName,
                  arguments: ScreenArguments(
                    'Extract Arguments Screen',
                    'This message is extracted in the build method.',
                  ),
                );
              },
            ),
            RaisedButton(
              child: Text("Navigate to a named that accepts arguments"),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  PassArgumentsScreen.routeName,
                  arguments: ScreenArguments(
                    'Accept Arguments Screen',
                    'This message is extracted in the onGenerateRoute function.',
                  ),
                );
              },
            ),
            RaisedButton(
              child: Text("Navigate no Arguments"),
              onPressed: () {
                Navigator.pushNamed(context, MyHomePage.routeName);
              },
            ),
            RaisedButton(
              child: Text("PageView"),
              onPressed: () {
                Navigator.pushNamed(context, PageViewDemo.routeName);
              },
            ),
            RaisedButton(
              child: Text("Platform Channel"),
              onPressed: () {
                Navigator.pushNamed(context, PlatformChannel.routeName);
              },
            ),
            Text(hive != null ? hive.get('batteryLevel').toString():'Паша, привет')
          ],
        ),
      ),
    );
  }
}

class ExtractArgumentsScreen extends StatelessWidget {
  static const routeName = '/extractArguments';

  @override
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.title),
      ),
      body: Center(
        child: Text(args.message),
      ),
    );
  }
}

class PassArgumentsScreen extends StatelessWidget {
  static const routeName = '/passArguments';

  final String title;
  final String message;
  const PassArgumentsScreen({
    Key key,
    @required this.title,
    @required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(message),
      ),
    );
  }
}

class ScreenArguments {
  final String title;
  final String message;

  ScreenArguments(this.title, this.message);
}
