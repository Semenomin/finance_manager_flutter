
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iucome/entitys/wallet.dart';
import 'package:toast/toast.dart';

class CustomDialog extends StatefulWidget {

  CustomDialog({this.cat,this.wall,Key key}) : super(key: key);
  List<WalletCategory> cat = [];
  List<Wallet> wall = [];

  @override
  _CustomDialogState createState() => _CustomDialogState(cat,wall);
}

class _CustomDialogState extends State<CustomDialog> {
  _CustomDialogState(List<WalletCategory> cat,List<Wallet> wall){
    this.cat = cat;
    this.wall = wall;
  }

  var formatter = new DateFormat('dd-MM-yyyy');

  List<WalletCategory> cat = [];
  List<Wallet> wall = [];


  TextEditingController _controllerCash = TextEditingController();
  TextEditingController _controllerName = TextEditingController();

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
          "Add Expence",
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
                    //hintText: "descrição",
                    labelText: "Name",
                    labelStyle: TextStyle(color: Colors.white),
                    //hintStyle: TextStyle(color: Colors.grey[400]),
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
              ListTile(
                title: Text(
                  "Wallet",
                   style: TextStyle(
                    color: Colors.white
                  ),
                ),
                trailing: DropdownButton<String>(
                  value: _selectedWallet,
                  onChanged: (String newValue){
                    setState(() {
                      _selectedWallet = newValue;
                    });
                  },
                  items: _dropDownWalletItem,
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
                          if(_selectedCategory == null||_selectedWallet == null){
                            showToast(
                              "Input Category or Wallet", 
                              gravity: Toast.BOTTOM
                            );
                          }
                          else{
                            Navigator.pop(context);
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
