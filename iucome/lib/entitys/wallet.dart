import 'dart:ffi';
import 'package:flutter/foundation.dart';

class Wallet{
  Wallet(this.name,this.cash,this.expense);
  String name;
  double cash;
  List<Expence> expense;
}

class Expence{
  Expence(this.name,this.cash,this.category,this.date,this.wallet);
  String name;
  String category;
  double cash;
  String wallet;
  String date;
}

List<String> category = [
"Products",
"flex",
"hype"
];