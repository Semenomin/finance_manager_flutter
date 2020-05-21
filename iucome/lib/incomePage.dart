import 'package:flutter/material.dart';
import 'package:iucome/entitys/currency.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'CustomDialog.dart';
import 'CustomIncomeDialog.dart';
import 'entitys/wallet.dart';

class IncomePage extends StatefulWidget {
  IncomePage({this.cat,this.wall,this.user_id, Key key}) : super(key: key);
    List<WalletCategory> cat = [];
    List<Wallet> wall = [];
    String user_id;
  @override
  _IncomePageState createState() => _IncomePageState(cat,wall,user_id);
}

class _IncomePageState extends State<IncomePage> {
  _IncomePageState(this.cat,this.wall,this.user_id);

  List<WalletCategory> cat = [];
  List<Wallet> wall = [];
  String user_id;
  List<SizedBox> incomeBoxes = [];

  @override
  Widget build(BuildContext context) {

  for(WalletCategory catt in cat){
    for(Income income in catt.income){
          incomeBoxes.add(SizedBox(
            height: 150.0,
            child: Card(
            elevation: 2,
            color: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(16.0)
              ),
            ),
            child: InkWell(
              onTap: (){

              },
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child:Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text("Name:",
                          style: TextStyle(fontSize: 25)
                          ),
                          Text("Cash:",
                          style: TextStyle(fontSize: 30)),
                          Text("Category:",
                          style: TextStyle(fontSize: 15))
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(income.name,
                          style: TextStyle(fontSize: 25)
                          ),
                          Text(income.cash.toString(),
                          style: TextStyle(fontSize: 30)),
                          Text(catt.name,
                          style: TextStyle(fontSize: 15))
                        ],
                      )
                    ],
                  ) 
                ),
              )
            ),
          ),
        )
      );
    }
  }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        leading: Icon(Icons.arrow_downward),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){
              showDialog(
                context: context,
                builder: (context){
                return IncomeCustomDialog(cat: cat,wall:wall,user_id: user_id,);
              }
            );
            },
          )
        ],
      ),
      body: ListView(
          padding: EdgeInsets.all(10),
          children: incomeBoxes,
        ),
    );
  }
}