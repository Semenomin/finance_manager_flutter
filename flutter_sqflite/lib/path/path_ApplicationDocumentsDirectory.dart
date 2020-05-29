import 'package:flutter_sqflite/BLoC/ApplocationDocuments/ApplocationDocuments_event.dart';
import 'package:flutter_sqflite/BLoC/ApplocationDocuments/ApplocationDocuments_bloc.dart';
import 'package:flutter_sqflite/models/textStorage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PathDemo extends StatefulWidget {
  final TextStorage storage;
  static const routeName = '/noPath';
  PathDemo({Key key, @required this.storage}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<PathDemo> {
  TextEditingController _textField = new TextEditingController();
  ApplocationDocumentsBloc applocationDocumentsBloc = ApplocationDocumentsBloc();

  @override
  void initState() {
    super.initState();
    applocationDocumentsBloc.eventSink.add(ReadDocumentEvent());
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
                    hintText: "Write in ApplicationDocumentsDirectory")),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: RaisedButton(
                child: Text('Write to File'),
                onPressed: () {
                  if (_textField.text.isNotEmpty) {
                    applocationDocumentsBloc.eventSink.add(WriteDocumentEvent(text:_textField.text));
                  }
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
                  applocationDocumentsBloc.eventSink.add(CleanDocumentEvent());
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: StreamBuilder<Object>(
                  stream: applocationDocumentsBloc.stateStream,
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
                  }),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() { 
    applocationDocumentsBloc.dispose();
    super.dispose();
  }
}
