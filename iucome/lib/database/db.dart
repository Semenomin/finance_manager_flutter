 
import 'dart:async';
import 'dart:io';

import 'package:iucome/entitys/wallet.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DaBa {
  

  static Future<String> initDb(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    // make sure the folder exists
    if (await Directory(dirname(path)).exists()) {
    } else {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        print(e);
      }
    }
    return path;
  }

  static void connectDB() async {
    var path = await initDb('iucome.db');
    var db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db,int version) async {
        await db.execute('CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT, cash_amount REAL, wallet TEXT, category TEXT,date TEXT, sync TINYINT)');
        await db.execute('CREATE TABLE incomes (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT, cash_amount REAL,date TEXT, sync TINYINT)');
        await db.execute('CREATE TABLE wallets (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT, cash_amount REAL DEFAULT 0.0)');
        await db.rawInsert("insert into wallets (name) VALUES ('necessary'),('entertainment'), ('saving'),('education'),('reserve'),('presents');");
      }
      );
  }

  static Future<List<Map>> getOperationsBy(String what,String where) async {
    var path = await initDb('iucome.db');
    var db = await openDatabase(path);
    var res;
    if(where != null){
      res = await db.rawQuery("Select * from $what WHERE $where");
    }
    else {
      res = await db.rawQuery("Select * from $what");
    }
    return res;
  }

  static Future<List<Wallet>> getWallets() async {
    List<Wallet> wallets = [];
    var res = await DaBa.getOperationsBy('wallets', null);
    for (var wallet in res) {
      wallets.add(Wallet(wallet.values.elementAt(1),wallet.values.elementAt(2),await DaBa.getWalletExpenses(wallet.values.elementAt(1))));
    }
    return wallets;
  }

  static Future<List<WalletCategory>> getCategories() async {
    var path = await initDb('iucome.db');
    var db = await openDatabase(path);
    await db.rawQuery("insert into expenses(name,cash_amount,wallet,category,date,sync) values('sucker',30.0,'presents','Porn','12-12-12',0)");
    List<WalletCategory> cat = [];
    var res = await db.rawQuery("SELECT category,SUM(cash_amount) FROM expenses GROUP BY category");
    for (var ca in res) {
      cat.add(WalletCategory(ca.values.elementAt(0),ca.values.elementAt(1),await DaBa.getCategoryExpenses(ca.values.elementAt(0))));
    }
    return cat; 
  }

  static Future<List<Expence>> getWalletExpenses(String wallet) async {
    List<Expence> ex = [];
    var res = await DaBa.getOperationsBy('expenses', 'wallet=\'$wallet\'');
    for (var item in res) {
      ex.add(Expence(item.values.elementAt(1),item.values.elementAt(2),item.values.elementAt(5)));
    }
    return ex;
  }


  static Future<List<Expence>> getCategoryExpenses(String category) async {
    List<Expence> ex = [];
    var res = await DaBa.getOperationsBy('expenses', 'category=\'$category\'');
    for (var item in res) {
      ex.add(Expence(item.values.elementAt(1),item.values.elementAt(2),item.values.elementAt(5)));
    }
    return ex;
  }
}