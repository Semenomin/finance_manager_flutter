import 'package:flutter_sqflite/BLoC/ApplicationSupport/ApplocationSupport_bloc.dart';
import 'package:flutter_sqflite/BLoC/ApplicationSupport/ApplocationSupport_event.dart';
import 'package:flutter_sqflite/models/textStorage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PathApplicationSupportDirectory extends StatefulWidget {
  final TextStorageApplicationSupportDirectory storage;
  static const routeName = '/noPathApplicationSupportDirectory';
  PathApplicationSupportDirectory({Key key, @required this.storage})
      : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<PathApplicationSupportDirectory> {
  TextEditingController _textField = new TextEditingController();
  final _bloc = ApplicationSupportBloc();

  @override
  void initState() {
    super.initState();
    _bloc.eventSink.add(ReadSupportEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Read/Write File Example'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
                controller: _textField,
                decoration: InputDecoration.collapsed(
                    hintText: "Write in ApplicationSupportDirectory")),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: RaisedButton(
                child: Text('Write to File'),
                onPressed: () {
                  _bloc.eventSink.add(WriteSupportEvent(text:_textField.text.toString()));
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: RaisedButton(
                child: Text(
                  'Clear Contents',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.redAccent,
                onPressed: () {
                  _bloc.eventSink.add(CleanSupportEvent());
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: StreamBuilder<String>(
                stream: _bloc.stateStream,
                builder: (context, snapshot) {
                  return new SingleChildScrollView(
                    child: Text(
                      snapshot.data.toString(),
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 22.0,
                      ),
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
