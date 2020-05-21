 
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:iucome/entitys/wallet.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:iucome/http_config.dart';

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
    await openDatabase(
      path,
      version: 1,
      onCreate: (Database db,int version) async {
        await db.execute('CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT, name TEXT, cash_amount REAL, wallet TEXT, category TEXT,date TEXT, sync TINYINT)');
        await db.execute('CREATE TABLE incomes (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT, name TEXT, cash_amount REAL,date TEXT,category y TEXT, sync TINYINT)');
        await db.execute('CREATE TABLE wallets (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,user_id TEXT, name TEXT, cash_amount REAL DEFAULT 0.0)');
      }
      );
  }

  static void createUser(String id) async{
    var path = await initDb('iucome.db');
    var db = await openDatabase(path);
    await db.rawInsert("insert into wallets (user_id,name) VALUES ('$id','necessary'),('$id','entertainment'), ('$id','saving'),('$id','education'),('$id','reserve'),('$id','presents');");
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
    var res = await db.rawQuery("SELECT category,SUM(cash_amount) FROM expenses  where user_id=\'$id\' GROUP BY category");
    for (var ca in res) {
      cat.add(WalletCategory(ca.values.elementAt(0),ca.values.elementAt(1),await DaBa.getCategoryExpenses(ca.values.elementAt(0),id),await DaBa.getCategoryIncomes(ca.values.elementAt(0), id)));
    }
    var res2 = await db.rawQuery("SELECT category FROM incomes where user_id=\'$id\' GROUP BY category");
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
    var res = await http.get('http://${HttpConfig.ip}:${HttpConfig.port}');
    if(res.statusCode == 200){
      await db.rawQuery("insert into incomes(user_id,name,cash_amount,category,date,sync) values(\'$user_id\',\'$name\',$cash,\'$cat\',CURRENT_TIMESTAMP,1)");
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
    }
    else{
      await db.rawQuery("insert into incomes(user_id,name,cash_amount,category,date,sync) values(\'$user_id\',\'$name\',$cash,\'$cat\',CURRENT_TIMESTAMP,0)");
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
    var res = await http.get('http://${HttpConfig.ip}:${HttpConfig.port}');
    if(res.statusCode == 200){
      await db.rawQuery("insert into expenses(user_id,name,cash_amount,wallet,category,date,sync) values(\'$user_id\',\'$name\',$mcash,\'$wall\',\'$cat\',CURRENT_TIMESTAMP,1)");
      await db.rawQuery("update wallets set cash_amount = cash_amount-$mcash where name='$wall' and user_id='$user_id'");
      await http.post('http://${HttpConfig.ip}:${HttpConfig.port}/db/createEx?name=$name&cash=$mcash&category=$cat&user=$user_id&wallet=$wall');
    }
    else{
      await db.rawQuery("insert into expenses(name,cash_amount,wallet,category,date,sync) values(\'$name\',$mcash,\'$wall\',\'$cat\',CURRENT_TIMESTAMP,0)");
      await db.rawQuery("update wallets set cash_amount = cash_amount-$mcash where name='$name' and user_id='$user_id'");
    }

  }

  static void syncDBout(String user_id) async {
    var path = await initDb('iucome.db');
    var db = await openDatabase(path);
    var res = await DaBa.getOperationsBy("expenses","sync=0");
    for (Map item in res) {
      await http.post('http://${HttpConfig.ip}:${HttpConfig.port}/db/createEx?name=${item.values.elementAt(1)}&cash=${item.values.elementAt(2)}&category=${item.values.elementAt(4)}&user=$user_id&wallet=${item.values.elementAt(3)}');
      await db.rawQuery('Update expenses set sync=1 where id = ${item.values.elementAt(0)}');
    }
  }

  static void syncDBin(String user_id){

  }
}