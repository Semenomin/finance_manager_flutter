import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iucome/screen/CustomDialog.dart';
import 'package:iucome/app.dart';
import 'package:iucome/entitys/tab.dart';
import 'package:iucome/entitys/wallet.dart';
import 'package:iucome/screen/incomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:iucome/entitys/subItem.dart';
import 'package:backdrop/backdrop.dart';
import 'package:iucome/database/db.dart';



class BottomTabbar extends StatefulWidget {
  BottomTabbar({Key key}) : super(key: key);

  @override
  _BottomTabbarState createState() => _BottomTabbarState();

}

class _BottomTabbarState extends State<BottomTabbar> with SingleTickerProviderStateMixin{

  String user_id;

  TabController _tabController;

  static const _kTabs = <Widget>[
    Tab(icon: Icon(Icons.arrow_downward),text:'Incomes'),
    Tab(icon: Icon(Icons.account_balance_wallet),text:'Wallets'),
    Tab(icon: Icon(Icons.arrow_upward),text:'Expences')
  ];

  @override
  void initState(){
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this
    );
  }

  @override
  void dispose(){
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    if(arguments != null){
      user_id = arguments.values.first;
    }
    return Scaffold(
      appBar: null,
      body: FutureBuilder<List<Wallet>>(
        future: DaBa.getWallets(user_id),
        builder: (BuildContext context, AsyncSnapshot<List<Wallet>> snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          else {
            final wallets = snapshot.data;
            return FutureBuilder<List<WalletCategory>>(
              future: DaBa.getCategories(user_id),
              builder: (BuildContext context, AsyncSnapshot<List<WalletCategory>> snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                else {
                  var categories = snapshot.data;

                  return TabBarView(
                    children: <Widget>[
                      IncomePage(cat: categories,wall: wallets,user_id: user_id),
                      WalletsTab(wallets,categories),
                      AppBarExpensesPage(cat:categories,wall:wallets,user_id: user_id,),
                    ],
                    controller: _tabController
                  );
                }
              }
            );
          }
        },
      ),
      bottomNavigationBar: Material(
        color: Colors.grey,
        child: TabBar(
          tabs: _kTabs,
        controller: _tabController
        ),
      ),
    );
  }
}

class WalletsTab extends StatelessWidget {

  WalletsTab(this.wallets,this.categories);
  List<Wallet> wallets = [];
  List<WalletCategory> categories = [];
  static final tabs = <MyTab>[
   MyTab("Necessary",    "55%"),
   MyTab("Entertainment","10%"),
   MyTab("Saving",       "10%"),
   MyTab("Education",    "10%"),
   MyTab("Reserve",      "10%"),
   MyTab("Presents",     "5%"),
  ];

  @override
  Widget build(BuildContext context) {
    List<PieWallet> pie = [];
    for (var item in wallets) {
      pie.add(PieWallet(wallet:item,cat:categories,));
    }
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          automaticallyImplyLeading: false,
          title: Text("Wallets"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.assessment),
              onPressed: (){
                Navigator.of(context).pushNamed(IucomeApp.currencyRoute);
              },
              )
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for(final tab in tabs)
              Tab(
                child: Column(
                  children: <Widget>[
                    Text(tab.name),
                    Text(tab.percent)
                  ],
                ),
              ),
            ]
          ),
        ),
        body: TabBarView(
          children: pie
        )
      )
    );
  }
}

class PieWallet extends StatefulWidget {
  PieWallet({this.wallet,this.cat,Key key}) : super(key: key);
  Wallet wallet;
  List<WalletCategory> cat = [];
  @override
  _PieWalletState createState() => _PieWalletState(wallet,cat);
}

class _PieWalletState extends State<PieWallet> {
  _PieWalletState(this.wallet,this.cat);
  final Wallet wallet;
  List<WalletCategory> cat = [];
  @override
  Widget build(BuildContext context) {

    return getDefaultPieChart(false,wallet,cat);
  }
}

SfCircularChart getDefaultPieChart(bool isTileView,Wallet wallet,List<WalletCategory> cat) {
  return SfCircularChart(

    title: ChartTitle(
      text: isTileView ? '' : wallet.cash.toString()+" \$"),
    legend: Legend(isVisible: isTileView ? false : true),
    series: getDefaultPieSeries(isTileView,wallet,cat),
  );
}

List<PieSeries<ChartSampleData, String>> getDefaultPieSeries(bool isTileView,Wallet wallet, List<WalletCategory> cat) {
  final List<ChartSampleData> pieData = <ChartSampleData>[];
   for (var categ in cat) {
      if(categ.cash != 0){
       pieData.add(ChartSampleData(x: categ.name, y: categ.cash, text: categ.name+' '+categ.cash.toString()));
      }
    }
  return <PieSeries<ChartSampleData, String>>[
    PieSeries<ChartSampleData, String>(
        explode: true,
        explodeIndex: 0,
        explodeOffset: '0',
        dataSource: pieData,
        xValueMapper: (ChartSampleData data, _) => data.x,
        yValueMapper: (ChartSampleData data, _) => data.y,
        dataLabelMapper: (ChartSampleData data, _) => data.text,
        startAngle: 90,
        endAngle: 90,
        dataLabelSettings: DataLabelSettings(isVisible: true)),
  ];
}

class AppBarExpensesPage extends StatefulWidget {
  AppBarExpensesPage({this.cat,this.wall,this.user_id,Key key}) : super(key: key);
  List<WalletCategory> cat = [];
  List<Wallet> wall = [];
  String user_id;

  @override
  _AppBarExpensesPageState createState() => _AppBarExpensesPageState(cat,wall,user_id);
}

class _AppBarExpensesPageState extends State<AppBarExpensesPage> {

  _AppBarExpensesPageState(this.cat,this.wall,this.user_id){}
  List<WalletCategory> cat = [];
  List<Wallet> wall = [];
  String user_id;
  String excat;

  @override
  void initState() {
    super.initState();
    excat = null;
  }

  @override
  Widget build(BuildContext context) {
    List<SizedBox> boxes = [];
    List<SizedBox> expenceBoxes = [];


    for (var item in cat) {
      if(item.name == excat||excat == null){
      for(var item2 in item.expence){
        expenceBoxes.add(
        SizedBox(
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
                          Text(item2.name,
                          style: TextStyle(fontSize: 25)
                          ),
                          Text(item2.cash.toString(),
                          style: TextStyle(fontSize: 30)),
                          Text(item.name,
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

      boxes.add(SizedBox(
            height: 50,
            child: FlatButton(
              onPressed: (){
                setState((){
                  excat = item.name;
                });
              },
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal
                ),
              )),
          ));
    }

    return BackdropScaffold(
      title:Text("Expences"),
      iconPosition: BackdropIconPosition.leading,
      headerHeight: 0.0,
      frontLayer: ListView(
        padding: EdgeInsets.all(10),
        children: expenceBoxes,
      ),
      backLayer: ListView(
        padding: EdgeInsets.all(10),
        children: boxes,
      ),
      actions: <Widget>[
      IconButton(
        icon: Icon(Icons.add),
        onPressed: (){
          showDialog(
            context: context,
            builder: (context){
              return CustomDialog(cat: cat,wall:wall,user_id: user_id,);
            }
          );
        }
      )
      ],
    );
  }
}

getdata() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String value = preferences.getString('user');
  return value;
}

