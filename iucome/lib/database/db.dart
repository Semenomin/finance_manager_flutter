
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:iucome/entitys/wallet.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:iucome/configs/http_config.dart';

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

  static Future<void> connectDB() async {
    var path = await initDb('iucome.db');
    await openDatabase(
      path,
      version: 1,
      onCreate: (Database db,int version) async {
        await db.execute('CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT,login TEXT,pass TEXT, last_sync TEXT)');
        await db.execute('CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT, name TEXT, cash_amount REAL, wallet TEXT, category TEXT,date TEXT, sync TINYINT)');
        await db.execute('CREATE TABLE incomes (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT, name TEXT, cash_amount REAL,date TEXT,category TEXT, sync TINYINT)');
        await db.execute('CREATE TABLE wallets (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT, name TEXT, cash_amount REAL DEFAULT 0.0)');
      }
      );
  }

  static Future<void> createUser(String id,String pass,String login) async{
    var path = await initDb('iucome.db');
    var db = await openDatabase(path);
    await db.rawInsert("insert into wallets (user_id,name) VALUES ('$id','necessary'),('$id','entertainment'), ('$id','saving'),('$id','education'),('$id','reserve'),('$id','presents');");
    await db.rawInsert("insert into users (user_id,login,pass) VALUES ('$id','$login','$pass');");
  }

  static Future<String> getLocalId(String login, String pass)async{
    var path = await initDb('iucome.db');
    var db = await openDatabase(path);
    var res = await db.rawQuery("select user_id from users where login='$login' and pass='$pass'");
    return res.first.values.first;
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

  static Future<List<Wallet>> getWallets(String id) async {
    List<Wallet> wallets = [];
    var res = await DaBa.getOperationsBy('wallets', 'user_id=\'$id\'');
    for (var wallet in res) {
      wallets.add(Wallet(wallet.values.elementAt(2),wallet.values.elementAt(3)));
    }
    return wallets;
  }

  static Future<List<WalletCategory>> getCategories(String id) async {
    var path = await initDb('iucome.db');
    var db = await openDatabase(path);
    List<WalletCategory> cat = [];
    List<WalletCategory> cat2 = [];
    var res = await db.rawQuery("SELECT category,SUM(cash_amount) FROM expenses where user_id=\'$id\' GROUP BY category");
    for (var ca in res) {
      cat.add(WalletCategory(ca.values.elementAt(0),ca.values.elementAt(1),await DaBa.getCategoryExpenses(ca.values.elementAt(0),id),await DaBa.getCategoryIncomes(ca.values.elementAt(0), id)));
    }
    var res2 = await db.rawQuery("SELECT category FROM incomes where user_id=\'$id\' GROUP BY category");
      if(res2.isNotEmpty){
        if(cat.length == 0){
          cat.add(WalletCategory(res2[0].values.elementAt(0),0,await DaBa.getCategoryExpenses(res2[0].values.elementAt(0),id),await DaBa.getCategoryIncomes(res2[0].values.elementAt(0), id)));
        }
        for (var ca in res2) {
          for (var categ in cat) {
            if(categ.name==ca.values.elementAt(0)){
              categ.income=await DaBa.getCategoryIncomes(categ.name, id);
            }
            else cat2.add(WalletCategory(ca.values.elementAt(0),0,await DaBa.getCategoryExpenses(ca.values.elementAt(0),id),await DaBa.getCategoryIncomes(ca.values.elementAt(0), id)));
          }
        }
        for (var cats in cat2) {
          cat.add(cats);
        }
        return cat;
      }
    return cat;

  }

  static Future<List<Expence>> getCategoryExpenses(String category,String id) async {
    List<Expence> ex = [];
    var res = await DaBa.getOperationsBy('expenses', 'category=\'$category\' and user_id=\'$id\'');
    for (var item in res) {
      ex.add(Expence(item.values.elementAt(2),item.values.elementAt(3),item.values.elementAt(6)));
    }
    return ex;
  }

  static Future<List<Income>> getCategoryIncomes(String category,String id) async {
    List<Income> ex = [];
    var res = await DaBa.getOperationsBy('incomes', 'category=\'$category\' and user_id=\'$id\'');
    for (var item in res) {
      ex.add(Income(item.values.elementAt(2),item.values.elementAt(3),item.values.elementAt(5)));
    }
    return ex;
  }

  static void addIncome(String name, double cash, String cat,List<Wallet> wall, String user_id) async{
    var path = await initDb('iucome.db');
    var db = await openDatabase(path);
    try{
      var res = await http.get('http://${HttpConfig.ip}:${HttpConfig.port}');
      if(res.statusCode == 200){
        await db.rawQuery("insert into incomes(user_id,name,cash_amount,category,date,sync) values(\'$user_id\',\'$name\',$cash,\'$cat\',datetime(CURRENT_TIMESTAMP, 'localtime'),1)");
        for(Wallet wallet in wall){
          switch (wallet.name){
            case "necessary":{
              await db.rawQuery("update wallets set cash_amount = cash_amount+${(cash*55)/100} where name='${wallet.name}' and user_id='$user_id'");
            }
            break;
            case "entertainment":{
              await db.rawQuery("update wallets set cash_amount = cash_amount+${(cash*10)/100} where name='${wallet.name}' and user_id='$user_id'");
            }
            break;
            case "saving":{
              await db.rawQuery("update wallets set cash_amount = cash_amount+${(cash*10)/100} where name='${wallet.name}' and user_id='$user_id'");
            }
            break;
            case "education":{
              await db.rawQuery("update wallets set cash_amount = cash_amount+${(cash*10)/100} where name='${wallet.name}' and user_id='$user_id'");
            }
            break;
            case "reserve":{
              await db.rawQuery("update wallets set cash_amount = cash_amount+${(cash*10)/100} where name='${wallet.name}' and user_id='$user_id'");
            }
            break;
            case "presents":{
              await db.rawQuery("update wallets set cash_amount = cash_amount+${(cash*5)/100} where name='${wallet.name}' and user_id='$user_id'");
            }
            break;
          }
        }
        await http.post('http://${HttpConfig.ip}:${HttpConfig.port}/db/createInc?name=$name&cash=$cash&category=$cat&user=$user_id');
        Timer(Duration(seconds: 3), () => db.rawQuery("update users set last_sync=datetime(CURRENT_TIMESTAMP, 'localtime') where user_id=\'$user_id\'"));
      }
    }
    catch(ex){
      await db.rawQuery("insert into incomes(user_id,name,cash_amount,category,date,sync) values(\'$user_id\',\'$name\',$cash,\'$cat\',datetime(CURRENT_TIMESTAMP, 'localtime'),0)");
      for(Wallet wallet in wall){
        switch (wallet.name){
          case "necessary":{
            await db.rawQuery("update wallets set cash_amount = cash_amount+${(cash*55)/100} where name='${wallet.name}' and user_id='$user_id'");
          }
          break;
          case "entertainment":{
            await db.rawQuery("update wallets set cash_amount = cash_amount+${(cash*10)/100} where name='${wallet.name}' and user_id='$user_id'");
          }
          break;
          case "saving":{
            await db.rawQuery("update wallets set cash_amount = cash_amount+${(cash*10)/100} where name='${wallet.name}' and user_id='$user_id'");
          }
          break;
          case "education":{
            await db.rawQuery("update wallets set cash_amount = cash_amount+${(cash*10)/100} where name='${wallet.name}' and user_id='$user_id'");
          }
          break;
          case "reserve":{
            await db.rawQuery("update wallets set cash_amount = cash_amount+${(cash*10)/100} where name='${wallet.name}' and user_id='$user_id'");
          }
          break;
          case "presents":{
            await db.rawQuery("update wallets set cash_amount = cash_amount+${(cash*5)/100} where name='${wallet.name}' and user_id='$user_id'");
          }
          break;
        }
      }
    }
  }

  static void addExpense(String name, String mcash, String cat,String wall,String user_id)async{
    var path = await initDb('iucome.db');
    var db = await openDatabase(path);
    try{
      var res = await http.get('http://${HttpConfig.ip}:${HttpConfig.port}');
      if(res.statusCode == 200){
        await db.rawQuery("insert into expenses(user_id,name,cash_amount,wallet,category,date,sync) values(\'$user_id\',\'$name\',$mcash,\'$wall\',\'$cat\',datetime(CURRENT_TIMESTAMP, 'localtime'),1)");
        await db.rawQuery("update wallets set cash_amount = cash_amount-$mcash where name='$wall' and user_id='$user_id'");
        await http.post('http://${HttpConfig.ip}:${HttpConfig.port}/db/createEx?name=$name&cash=$mcash&category=$cat&user=$user_id&wallet=$wall').then((f){
          Timer(Duration(seconds: 3), () => db.rawQuery("update users set last_sync=datetime(CURRENT_TIMESTAMP, 'localtime') where user_id=\'$user_id\'"));
        });
      }
    }
    catch(ex){
      await db.rawQuery("insert into expenses(user_id,name,cash_amount,wallet,category,date,sync) values($user_id,\'$name\',$mcash,\'$wall\',\'$cat\',datetime(CURRENT_TIMESTAMP, 'localtime'),0)");
      await db.rawQuery("update wallets set cash_amount = cash_amount-$mcash where name='$name' and user_id='$user_id'");
    }
  }

  static void syncDBout(String user_id) async {
    var path = await initDb('iucome.db');
    var db = await openDatabase(path);

    var res = await DaBa.getOperationsBy("expenses","sync=0");    //send expenses
    for (Map item in res) {
      await http.post('http://${HttpConfig.ip}:${HttpConfig.port}/db/createEx?name=${item.values.elementAt(2)}&cash=${item.values.elementAt(3)}&category=${item.values.elementAt(5)}&user=$user_id&wallet=${item.values.elementAt(4)}');
      await db.rawQuery('Update expenses set sync=1 where id = ${item.values.elementAt(0)}');
    }

    var res2 = await DaBa.getOperationsBy("incomes","sync=0");    //send incomes
    for (Map item in res2) {
      await http.post('http://${HttpConfig.ip}:${HttpConfig.port}/db/createInc?name=${item.values.elementAt(2)}&cash=${item.values.elementAt(3)}&category=${item.values.elementAt(5)}&user=$user_id}');
      await db.rawQuery('Update incomes set sync=1 where id = ${item.values.elementAt(0)}');
    }
  }

  static Future<void> syncDBin(String user_id,String login,String pass) async {
    if(await checkUserId(user_id)){
     await DaBa.syncDBexpense(user_id);
     await DaBa.syncDBincome(user_id);

    }
    else {
     await createUser(user_id,pass,login);
     await DaBa.syncDBexpense(user_id);
     await DaBa.syncDBincome(user_id);
   }
  }

  static Future<void> syncDBexpense(String user_id) async {
    var path = await initDb('iucome.db');
    var db = await openDatabase(path);
    var last_sync = await db.rawQuery("select last_sync from users where user_id=\'$user_id\'");
    var res;
    if(last_sync.first.values.first == null){
     res = await http.get('http://${HttpConfig.ip}:${HttpConfig.port}/db/expenses?user_id=$user_id&date=\'1999-01-01 00:00:00.0\'');
    }
    else{
     res = await http.get('http://${HttpConfig.ip}:${HttpConfig.port}/db/expenses?user_id=$user_id&date=${last_sync.first.values.first}');
    }
     Map data = await json.decode(res.body) as Map;
     data["rows"].forEach((f){
      db.rawQuery("insert into expenses(user_id,name,cash_amount,wallet,category,date,sync) values(\'${f["user_id"]}\',\'${f["name"]}\',${f["cash"]},\'${f["wallet"]}\',\'${f["category"]}\',\'${f["date"]}\',1)");
      db.rawQuery("update wallets set cash_amount = cash_amount-${f["cash"]} where name='${f["wallet"]}' and user_id='${f["user_id"]}'");
     });
  }

  static Future<void> syncDBincome(String user_id) async {
    var path = await initDb('iucome.db');
    var db = await openDatabase(path);
    var last_sync = await db.rawQuery("select last_sync from users where user_id=\'$user_id\'");
    var res2;
    if(last_sync.first.values.first == null){
      res2 = await http.get('http://${HttpConfig.ip}:${HttpConfig.port}/db/incomes?user_id=$user_id&date=\'1999-01-01 00:00:00.0\'');
    }
    else{
      res2 = await http.get('http://${HttpConfig.ip}:${HttpConfig.port}/db/incomes?user_id=$user_id&date=${last_sync.first.values.first}');
    }
     Map data2 = await json.decode(res2.body) as Map;
     List<Wallet> wall = await DaBa.getWallets(user_id);
     data2["rows"].forEach((f){
      db.rawQuery("insert into incomes(user_id,name,cash_amount,category,date,sync) values(\'$user_id\',\'${f["name"]}\',${f["cash"]},\'${f["category"]}\',\'${f["date"]}\',1)");
      for(Wallet wallet in wall){
        switch (wallet.name) {
          case "necessary":{
            db.rawQuery("update wallets set cash_amount = cash_amount+${(double.parse(f["cash"])*55)/100} where name='${wallet.name}' and user_id='$user_id'");
          }
          break;
          case "entertainment":{
            db.rawQuery("update wallets set cash_amount = cash_amount+${(double.parse(f["cash"])*10)/100} where name='${wallet.name}' and user_id='$user_id'");
          }
          break;
          case "saving":{
            db.rawQuery("update wallets set cash_amount = cash_amount+${(double.parse(f["cash"])*10)/100} where name='${wallet.name}' and user_id='$user_id'");
          }
          break;
          case "education":{
            db.rawQuery("update wallets set cash_amount = cash_amount+${(double.parse(f["cash"])*10)/100} where name='${wallet.name}' and user_id='$user_id'");
          }
          break;
          case "reserve":{
            db.rawQuery("update wallets set cash_amount = cash_amount+${(double.parse(f["cash"])*10)/100} where name='${wallet.name}' and user_id='$user_id'");
          }
          break;
          case "presents":{
            db.rawQuery("update wallets set cash_amount = cash_amount+${(double.parse(f["cash"])*5)/100} where name='${wallet.name}' and user_id='$user_id'");
          }
          break;
        }
      }
     });
    await db.rawQuery("update users set last_sync=datetime(CURRENT_TIMESTAMP, 'localtime') where user_id=\'$user_id\'");
  }

  static Future<bool> checkUserId(String user_id) async {
    var res = await DaBa.getOperationsBy("wallets","user_id=$user_id");
    if(res.length != 0){
      return true;
    }
    else {
      return false;
    }
  }
}