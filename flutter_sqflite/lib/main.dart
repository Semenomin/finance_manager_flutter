import 'package:flutter/semantics.dart';
import 'package:flutter_sqflite/path/path_ApplicationDocumentsDirectory.dart';
import 'package:flutter_sqflite/path/path_ApplicationSupportDirectory.dart';
import 'package:flutter_sqflite/path/path_ExternalStorageDirectory.dart';
import 'package:flutter_sqflite/utils/repository_service_playlist.dart';
import 'package:flutter_sqflite/path/path_TemporaryDirectory.dart';
import 'package:flutter_sqflite/utils/shared_preferences.dart';
import 'package:flutter_sqflite/utils/database_creator.dart';
import 'package:flutter_sqflite/utils/work_with_files.dart';
import 'package:flutter_sqflite/utils/firebase.dart';
import 'package:flutter_sqflite/models/track.dart';
import 'package:flutter/material.dart';
import 'models/textStorage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseCreator().initDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        home: SqfLiteCrud(title: 'Flutter Demo Home Page'),
        routes: {
          PathPage.routeName: (context) =>
          PathPage(title: 'path_provider'),
          PathDemo.routeName: (context) =>
          PathDemo(storage:TextStorage()),
          PathTemporaryDirectory.routeName: (context) =>
          PathTemporaryDirectory(storage:TextStorageTemporaryDirectory()),
          PathApplicationSupportDirectory.routeName: (context) =>
          PathApplicationSupportDirectory(storage:TextStorageApplicationSupportDirectory()),
          PathExternalStorageDirectory.routeName: (context) =>
          PathExternalStorageDirectory(storage:TextStorageExternalStorageDirectory())

        });
  }
}

class SqfLiteCrud extends StatefulWidget {
  SqfLiteCrud({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SqfLiteCrudState createState() => _SqfLiteCrudState();
}

class _SqfLiteCrudState extends State<SqfLiteCrud> {
  final _formKey = GlobalKey<FormState>();
  Future<List<Track>> future;
  String name;
  String performer;
  int id;

  @override
  initState() {
    super.initState();
    future = RepositoryServiceTrack.getAllTracks();
  }

  void readData() async {
    final track = await RepositoryServiceTrack.getTrack(id);
    print(track.name);
  }

  updateTrack(Track track) async {
    track.name = 'New track till friday 1p.m.';
    await RepositoryServiceTrack.updateTrack(track);
    setState(() {
      future = RepositoryServiceTrack.getAllTracks();
    });
  }

  deleteTrack(Track track) async {
    await RepositoryServiceTrack.deleteTrack(track);
    setState(() {
      id = null;
      future = RepositoryServiceTrack.getAllTracks();
    });
  }

  Card buildItem(Track track) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${track.performer}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '${track.name}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () => updateTrack(track),
                  child: Text('Update', style: TextStyle(color: Colors.white)),
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                FlatButton(
                  onPressed: () => deleteTrack(track),
                  child: Text('Delete'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  TextFormField getNameFromField() {
    return TextFormField(
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Track',
        fillColor: Colors.grey[300],
        filled: true,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
      },
      onSaved: (value) => name = value,
    );
  }

  TextFormField getPerformerFromField() {
    return TextFormField(
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Artist',
        fillColor: Colors.grey[300],
        filled: true,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
      },
      onSaved: (value) => performer = value,
    );
  }

  void createTrack() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      int count = await RepositoryServiceTrack.tracksCount();
      final todo = Track(count, name, performer);
      await RepositoryServiceTrack.addTrack(todo);
      setState(() {
        id = todo.id;
        future = RepositoryServiceTrack.getAllTracks();
      });
      print(todo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('sqfLite CRUD'),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SharedPreferencesTest()));
            },
            child: Text('SharedPreferences',
                style: TextStyle(color: Colors.white)),
            color: Colors.black,
          ),
          RaisedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FirebaseCrud()));
            },
            child: Text('Firebase Database',
                style: TextStyle(color: Colors.black)),
            color: Colors.orange,
          ),
          RaisedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PathPage()));
            },
            child: Text('Work with files',
                style: TextStyle(color: Colors.white)),
            color: Colors.green,
          ),
               RaisedButton(
              child: Text("Write ApplicationDocumentsDirectory", style: TextStyle(color: Colors.black)),
              color: Colors.yellow,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                PathDemo.routeName
                );
              },
            ),
             RaisedButton(
              child: Text("Write TemporaryDirectory", style: TextStyle(color: Colors.black)),
              color: Colors.yellow,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                 PathTemporaryDirectory.routeName
                );
              },
            ),
             RaisedButton(
              child: Text("Write ApplicationSupportDirectory", style: TextStyle(color: Colors.black)),
              color: Colors.yellow,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                PathApplicationSupportDirectory.routeName
                );
              },
            ),
            RaisedButton(
              child: Text("Write ExternalStorageDirectory", style: TextStyle(color: Colors.black)),
              color: Colors.yellow,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                PathExternalStorageDirectory.routeName
                );
              },
            ),
          Form(
            key: _formKey,
            child: Column(children: <Widget>[
              getNameFromField(),
              getPerformerFromField()
            ]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                onPressed: createTrack,
                child: Text('Create', style: TextStyle(color: Colors.white)),
                color: Colors.green,
              ),
              RaisedButton(
                onPressed: id != null ? readData : null,
                child: Text('Read', style: TextStyle(color: Colors.white)),
                color: Colors.blue,
              ),
            ],
          ),
          FutureBuilder<List<Track>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                    children: snapshot.data
                        .map((track) => buildItem(track))
                        .toList());
              } else {
                return SizedBox();
              }
            },
          )
        ],
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