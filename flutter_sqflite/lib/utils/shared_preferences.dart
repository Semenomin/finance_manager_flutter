import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesTest extends StatefulWidget {
  SharedPreferencesTest() : super();

  final String title = "Shared Preferences Test";

  @override
  SharedPreferencesTestState createState() => SharedPreferencesTestState();
}

class SharedPreferencesTestState extends State<SharedPreferencesTest> {
  String data = "";
  String nameKey = "_key_name";
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<bool> saveData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(nameKey, controller.text);
  }

  Future<String> loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(nameKey);
  }

  Future<bool> removeData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.remove(nameKey);
  }

  setData() {
    loadData().then((value) {
      setState(() {
        if(value == null){
          data = "null";
        } else{
          data = value;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: controller,
                decoration: InputDecoration(
                    hintText: "Input name", fillColor: Colors.grey),
              ),
              MaterialButton(
                child: Text(
                  "SAVE NAME",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  saveData();
                },
                color: Colors.black,
              ),
              Text(
                data,
                style: TextStyle(fontSize: 20),
              ),
              OutlineButton(
                child: Text("LOAD NAME"),
                onPressed: () {
                  setData();
                },
              ),
              MaterialButton(
                child: Text(
                  "DELETE NAME",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  removeData();
                },
                color: Colors.red,
              ),
            ],
          ),
        ));
  }
}
