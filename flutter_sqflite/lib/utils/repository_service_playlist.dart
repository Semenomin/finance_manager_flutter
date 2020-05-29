import 'package:flutter_sqflite/models/track.dart';
import 'package:flutter_sqflite/utils/database_creator.dart';

class RepositoryServiceTrack{
  static Future<List<Track>> getAllTracks() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.tracksTable}''';
    final data = await db.rawQuery(sql);
    List<Track> tracks = List();

    for (final node in data){
      final track = Track.fromJson(node);
      tracks.add(track);
    }
    return tracks;
  }

  static Future<Track> getTrack(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.tracksTable}
    WHERE ${DatabaseCreator.id} == $id''';

    final data = await db.rawQuery(sql);

    final track = Track.fromJson(data[0]);
    return track;
  }

  static Future<void> addTrack(Track track) async{
    final sql = '''INSERT INTO ${DatabaseCreator.tracksTable}
    (
      ${DatabaseCreator.id},
      ${DatabaseCreator.name},
      ${DatabaseCreator.performer}
    )
    VALUES
    (
      ${track.id},
      "${track.name}",
      "${track.performer}"
    )''';

    final result = await db.rawInsert(sql);
    DatabaseCreator.dbLog('Add track', sql, null, result);
  }

  static Future<void> deleteTrack(Track track) async {
    final sql = '''DELETE FROM ${DatabaseCreator.tracksTable}
    WHERE ${DatabaseCreator.id} == ${track.id}''';

    final result = await db.rawDelete(sql);
    DatabaseCreator.dbLog('Delete track', sql, null, result);
  }

  static Future<void> updateTrack(Track track) async {
    final sql = '''UPDATE ${DatabaseCreator.tracksTable}
    SET ${DatabaseCreator.name} = "${track.name}"
    WHERE ${DatabaseCreator.id} == ${track.id}''';

    final result = await db.rawUpdate(sql);
    DatabaseCreator.dbLog('Delete track', sql, null, result);
  }

  static Future<int> tracksCount() async {
    final data = await db.rawQuery('''SELECT COUNT(*) FROM ${DatabaseCreator.tracksTable}''');

    int count = data[0].values.elementAt(0);
    return count;
  }
}