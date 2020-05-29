import 'package:flutter_sqflite/utils/database_creator.dart';

class Track{
  int id;
  String name;
  String performer;
  //String time;

  Track(this.id, this.name, this.performer);

  Track.fromJson(Map<String, dynamic> json){
    this.id = json[DatabaseCreator.id];
    this.name = json[DatabaseCreator.name];
    this.performer = json[DatabaseCreator.performer];
    //this.time = json[DatabaseCreator.time];
  }
}