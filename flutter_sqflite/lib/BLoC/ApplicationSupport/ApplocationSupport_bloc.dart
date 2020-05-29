import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_sqflite/models/textStorage.dart';

import 'ApplocationSupport_event.dart';

class ApplicationSupportBloc {

  ApplocationSupportBloc() {
    _eventController.stream.listen(_mapEventToState);
  }

  TextStorageApplicationSupportDirectory storage =
      TextStorageApplicationSupportDirectory();
  String _content;

  final _stateController = StreamController<String>();
  StreamSink<String> get _stateSink => _stateController.sink;
  Stream<String> get stateStream => _stateController.stream;

  final _eventController = StreamController<ApplocationSupportEvent>();
  Sink<ApplocationSupportEvent> get eventSink => _eventController.sink;

  void _mapEventToState(ApplocationSupportEvent event) async {
    if (event is WriteSupportEvent) {
      await storage.writeFile(event.text);
      _content = await storage.readFile();
    } else if (event is ReadSupportEvent) {
      _content = await storage.readFile();
    } else if (event is CleanSupportEvent) {
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
