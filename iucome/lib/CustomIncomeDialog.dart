import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iucome/entitys/wallet.dart';
import 'package:toast/toast.dart';
import 'package:iucome/database/db.dart';

import 'app.dart';

class IncomeCustomDialog extends StatefulWidget {

  IncomeCustomDialog({this.cat,this.wall,this.user_id,Key key}) : super(key: key);
  List<WalletCategory> cat = [];
  List<Wallet> wall = [];
  String user_id;
  @override
  _IncomeCustomDialogState createState() => _IncomeCustomDialogState(cat,wall,user_id);
}

class _IncomeCustomDialogState extends State<IncomeCustomDialog> {
  _IncomeCustomDialogState(List<WalletCategory> cat,List<Wallet> wall,String user_id){
    this.cat = cat;
    this.wall = wall;
    this.user_id = user_id;
  }

  var formatter = new DateFormat('dd-MM-yyyy');

  String user_id;
  List<WalletCategory> cat = [];
  List<Wallet> wall = [];


  TextEditingController _controllerCash = TextEditingController();
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _newCategory = TextEditingController();

  String _selectedCategory;
  String _selectedWallet;
  

  @override
  Widget build(BuildContext context) {

    List<DropdownMenuItem<String>> _dropDownCategoryItem = [];
    List<DropdownMenuItem<String>> _dropDownWalletItem = [];
    _dropDownCategoryItem.clear();
    _dropDownWalletItem.clear();
    for (var item in cat) {
      _dropDownCategoryItem.add(DropdownMenuItem<String>(
        value: item.name,
        child: Text(item.name),
      ));
    }


    for (var item in wall) {
      _dropDownWalletItem.add(DropdownMenuItem<String>(
        value: item.name,
        child: Text(item.name),
      ));
    }

    double width = MediaQuery.of(context).size.width;
 

    return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(width * 0.050)),
        title: Text(
          "Add Income",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.grey,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "\$ ",
                    style:
                        TextStyle(color: Colors.white, fontSize: width * 0.06),
                  ),
                  Flexible(
                    child: TextField(
                        controller: _controllerCash,
                        maxLength: 7,
                        style: TextStyle(fontSize: width * 0.05),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        decoration: new InputDecoration(
                          hintText: "0.00",
                          hintStyle: TextStyle(color: Colors.white54),
                          contentPadding:  EdgeInsets.only(
                              left: width * 0.04, 
                              top: width * 0.041, 
                              bottom: width * 0.041, 
                              right: width * 0.04),//15),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(width * 0.04),
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(width * 0.04),
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                        )),
                  )
                ],
              ),
              TextField(
                  controller: _controllerName,
                  maxLength: 20,
                  style: TextStyle(fontSize: width * 0.05),
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  decoration: new InputDecoration(
                    labelText: "Name",
                    labelStyle: TextStyle(color: Colors.white),
                    contentPadding:  EdgeInsets.only(
                        left: width * 0.04, 
                        top: width * 0.041, 
                        bottom: width * 0.041, 
                        right: width * 0.04),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(width * 0.04),
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(width * 0.04),
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                  )
                ),
              FlatButton(
                color: Colors.blueGrey,
                onPressed: ()async{
                  var res = await showDialog(
                    context: context,
                    builder: (context){
                      return AlertDialog(
                        contentPadding: const EdgeInsets.all(16.0),
                        content: new Row(
                          children: <Widget>[
                            new Expanded(
                              child: new TextField(
                                controller: _newCategory,
                                autofocus: true,
                                decoration: new InputDecoration(
                                labelText: 'Category name', hintText: 'something'),
                              ),
                            )
                          ]
                        ),
                        actions: <Widget>[
                        new FlatButton(
                          child: const Text('CANCEL'),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                        new FlatButton(
                          child: const Text('OK'),
                          onPressed: () {
                            _selectedCategory = _newCategory.text;
                            Navigator.of(context).pop(_newCategory.text);
                          })
                        ],
                      );
                    }  
                  );
                  setState(() {
                    cat.add(WalletCategory(res,0,List<Expence>(),List<Income>()));
                  });
                },
                child:Text(
                  "Add category",
                  style: TextStyle(
                    color:Colors.white
                  ),
                )
              ),
              ListTile(
                title: Text(
                  "Category",
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
                trailing: DropdownButton<String>(
                  value: _selectedCategory,
                  onChanged: (String newValue){
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  items: _dropDownCategoryItem,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: width * 0.09),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        
                        if(_controllerCash.text.isNotEmpty){
                        
                          String cash;
                          if(_controllerCash.text.contains(",")){
                             cash = _controllerCash.text.replaceAll(RegExp(","), ".");
                          }
                          else{
                              cash = _controllerCash.text; 
                          }
                          if(_selectedCategory == null){
                            showToast(
                              "Input Category", 
                              gravity: Toast.BOTTOM
                            );
                          }
                          else{
                            cat[cat.indexWhere((ca)=>ca.name == _selectedCategory)].addIncome(Income(_controllerName.text,double.parse(cash),DateTime.now().toString()),wall);
                            DaBa.addIncome(_controllerName.text,double.parse(cash), _selectedCategory, wall, user_id);
                            Navigator.of(context).pushNamed(IucomeApp.homeRoute,
                             arguments: <String,String>{
                             'userId': user_id,
                             });
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            top: width * 0.02, 
                            bottom: width * 0.02, 
                            left: width * 0.03, 
                            right: width * 0.03
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: width * 0.05),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      );
  }

   void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
