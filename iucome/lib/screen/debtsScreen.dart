import 'package:flutter/material.dart';
import 'package:iucome/configs/appColors.dart';
import 'package:iucome/entitys/wallet.dart';
import 'package:iucome/database/db.dart';
import 'package:iucome/screen/CustomDebtDialog.dart';

class DebtsScreen extends StatefulWidget {
  DebtsScreen({Key key, this.cat, this.user_id}) : super(key: key);

  List<WalletCategory> cat = [];
  String user_id;

  @override
  _DebtsScreenState createState() => _DebtsScreenState(cat, user_id);
}

class _DebtsScreenState extends State<DebtsScreen> {
  List<WalletCategory> cat = [];
  String user_id;
  String filter = 'null';
  _DebtsScreenState(this.cat, this.user_id);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.gray60,
          leading: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return CustomDialogDebt(user_id: user_id,);
                    });
              }),
          title: Text('Debts'),
        ),
        body: FutureBuilder<List<Debt>>(
            future: DaBa.getDebts(user_id),
            builder:
                (BuildContext context, AsyncSnapshot<List<Debt>> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                print(2);
                List<Card> debts = makeDebtCards(snapshot.data, filter);
                return ListView(
                  padding: EdgeInsets.all(10),
                  children: debts,
                );
              }
            }),
      ),
    );
  }

  List<Card> makeDebtCards(List<Debt> debts, String filter) {
    try{
        List<Card> cards = [];
      Color color;
      for (var debt in debts) {
        if (debt.close) {
          color = Colors.green;
        } else
          color = Colors.red;
        cards.add(Card(
          elevation: 2,
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: InkWell(
              onTap: () async {
                if (debt.close) {
                  var r = await DaBa.openDebt(user_id, debt.person).then((f) {
                    setState(() {});
                  });
                } else {
                  var r = await DaBa.closeDebt(user_id, debt.person).then((f) {
                    setState(() {});
                  });
                }
              },
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text("Person:", style: TextStyle(fontSize: 25)),
                            Text("Cash:", style: TextStyle(fontSize: 30)),
                            Text("Date:", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(debt.person, style: TextStyle(fontSize: 25)),
                            Text(debt.cash.toString(),
                                style: TextStyle(fontSize: 30)),
                            Text(debt.date, style: TextStyle(fontSize: 15))
                          ],
                        ),
                        debt.is_income
                            ? Center(child: Icon(Icons.arrow_downward))
                            : Center(child: Icon(Icons.arrow_upward))
                      ],
                    )),
              )),
        ));
      }
    return cards;
    }
    catch(ex){
      return null;
    }
  }
}
