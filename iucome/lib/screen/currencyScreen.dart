import 'package:flutter/material.dart';
import 'package:iucome/entitys/currency.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class CurPage extends StatefulWidget {
  const CurPage({Key key}) : super(key: key);

  @override
  _CurPageState createState() => _CurPageState();
}

class _CurPageState extends State<CurPage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Currencies'),
      ),
      body: new FutureBuilder(
        future: fetchCur(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData)
            return new Container();
          List content = snapshot.data;
          return new ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: content.length,
            itemBuilder: (BuildContext context, int index) {
              return new CurWidget(cur: content[index]);
            },
          );
        }
      )
    );
  }
}

Future<List<Currency>> fetchCur() async{
  try{
    String base = 'USD';
    String appId = '3861d8bbdc994542b5ef26fadf159471';
    List<Currency> cur = new List<Currency>();
    final response = await http.get('https://openexchangerates.org/api/latest.json?app_id=$appId&base=$base');
    if (response.statusCode == 200) {
      Map data = await json.decode(response.body) as Map;
      data['rates'].forEach((k,v){
        cur.add(Currency(curAbbreviation: k,rate: v.toString()));
      });
      return cur;
    }
    else{
      throw Exception('error fetching currencies');
    }
  }
  catch (e){
    print(e.toString());
  }

}

class CurWidget extends StatelessWidget {
  final Currency cur;

  const CurWidget({Key key, @required this.cur}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("${cur.curAbbreviation} => ${cur.rate}")
    );
  }
}