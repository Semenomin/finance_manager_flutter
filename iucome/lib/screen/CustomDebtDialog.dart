import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iucome/configs/appColors.dart';
import 'package:iucome/entitys/wallet.dart';
import 'package:toast/toast.dart';
import 'package:iucome/database/db.dart';
import 'package:iucome/app.dart';

class CustomDialogDebt extends StatefulWidget {
  CustomDialogDebt({this.user_id, Key key}) : super(key: key);
  String user_id;
  @override
  _CustomDialogDebtState createState() => _CustomDialogDebtState(user_id);
}

class _CustomDialogDebtState extends State<CustomDialogDebt> {
  _CustomDialogDebtState(String user_id) {
    this.user_id = user_id;
  }

  String user_id;

  TextEditingController _controllerCash = TextEditingController();
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _newCategory = TextEditingController();

  String _selectedCategory;
  String _selectedWallet;
  bool _checkBoxVal = true;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.050)),
        title: Text(
          "Add Debt",
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
                          contentPadding: EdgeInsets.only(
                              left: width * 0.04,
                              top: width * 0.041,
                              bottom: width * 0.041,
                              right: width * 0.04), //15),
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
                    labelText: "Person",
                    labelStyle: TextStyle(color: Colors.white),
                    //hintStyle: TextStyle(color: Colors.grey[400]),
                    contentPadding: EdgeInsets.only(
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
                  )),
              Row(
                children: <Widget>[
                  Text(
                    'Is Income?  ',
                    style: TextStyle(color: AppColors.white60, fontSize: 20),
                  ),
                  Checkbox(
                      value: _checkBoxVal,
                      onChanged: (val) {
                        setState(() {
                          _checkBoxVal = val;
                        });
                      }),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: width * 0.09),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        try {
                          if (_controllerCash.text.isNotEmpty) {
                            String cash;
                            if (_controllerCash.text.contains(",")) {
                              cash = _controllerCash.text
                                  .replaceAll(RegExp(","), ".");
                            } else {
                              cash = _controllerCash.text;
                            }
                            await DaBa.addDebt(
                                Debt(
                                    cash: double.parse(cash),
                                    person: _controllerName.text,
                                    date: DateTime.now().toString(),
                                    is_income: _checkBoxVal,
                                    close: false),
                                user_id);
                            await Navigator.of(context).pushNamed(
                                IucomeApp.homeRoute,
                                arguments: <String, String>{
                                  'userId': user_id,
                                });
                          }
                        } catch (ex) {
                          Navigator.of(context).pushNamed(IucomeApp.homeRoute,
                              arguments: <String, String>{
                                'userId': user_id,
                              });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            top: width * 0.02,
                            bottom: width * 0.02,
                            left: width * 0.03,
                            right: width * 0.03),
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
        ));
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
