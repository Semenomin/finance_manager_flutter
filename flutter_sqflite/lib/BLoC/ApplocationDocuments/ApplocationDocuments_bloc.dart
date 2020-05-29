import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_sqflite/models/textStorage.dart';
import 'ApplocationDocuments_event.dart';

class ApplocationDocumentsBloc {

  ApplocationDocumentsBloc(){
    _eventController.stream.listen(_mapEventToState);
  }

  TextStorage storage = TextStorage();
  String _content;

  final _stateController = StreamController<String>();
  StreamSink<String> get _stateSink => _stateController.sink;
  Stream<String> get stateStream => _stateController.stream;

  final _eventController = StreamController<ApplocationDocumentsEvent>();
  Sink<ApplocationDocumentsEvent> get eventSink => _eventController.sink;

  void _mapEventToState(ApplocationDocumentsEvent event)async{
    if(event is WriteDocumentEvent){
      await storage.writeFile(event.text);
      _content = await storage.readFile();
    }else if(event is ReadDocumentEvent){
      _content = await storage.readFile();
    }else if(event is CleanDocumentEvent){
      await storage.cleanFile();
      _content = await storage.readFile();
    }
    _stateSink.add(_content);
  }
  
  void dispose() {
    _stateController.close();
    _eventController.close();
  }
}
