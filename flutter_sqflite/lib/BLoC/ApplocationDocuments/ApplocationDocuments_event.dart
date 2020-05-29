import 'package:meta/meta.dart';

@immutable
abstract class ApplocationDocumentsEvent {}

class ReadDocumentEvent extends ApplocationDocumentsEvent {}

class WriteDocumentEvent extends ApplocationDocumentsEvent {
  String text;
  WriteDocumentEvent({this.text});
}

class CleanDocumentEvent extends ApplocationDocumentsEvent {}



