import 'dart:async';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Database db;

class DatabaseCreator {
  static const tracksTable = 'tracks';
  static const id = 'id';
  static const name = 'name';
  static const performer = 'performer';

  static void dbLog(
      String functionName,
      String sql,
      List<Map<String, dynamic>> selectQueryResult,
      int insertAndUpdateQueryResult) {
    print(functionName);
    print(sql);

    if (selectQueryResult != null) {
      print(selectQueryResult);
    } else if (insertAndUpdateQueryResult != null) {
      print(insertAndUpdateQueryResult);
    }
  }

  Future<void> createPlaylistTable(Database db) async {
    final playlistSql = '''CREATE TABLE $tracksTable (
      $id INTEGER PRIMARY KEY,
      $name TEXT,
      $performer TEXT
    )''';

    await db.execute(playlistSql);
  }

  Future<String> getDatabasePath(String dbName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    if (await Directory(dirname(path)).exists()) {
      //await deleteDatabase(path);
    } else {
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }

  Future<void> initDatabase() async {
    final path = await getDatabasePath('tracks.db');
    db = await openDatabase(path, version: 1, onCreate: onCreate);
    print(db);
  }

  Future<void> onCreate(Database db, int version) async {
    await createPlaylistTable(db);
  }
}
