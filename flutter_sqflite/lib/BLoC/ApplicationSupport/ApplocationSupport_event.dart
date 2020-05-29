import 'package:meta/meta.dart';

@immutable
abstract class ApplocationSupportEvent {}

class ReadSupportEvent extends ApplocationSupportEvent {}

class WriteSupportEvent extends ApplocationSupportEvent {
  String text;
  WriteSupportEvent({this.text});
}

class CleanSupportEvent extends ApplocationSupportEvent {}



