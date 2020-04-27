import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iucome/CustomDialog.dart';
import 'package:iucome/appColors.dart';
import 'package:iucome/entitys/tab.dart';
import 'package:iucome/entitys/wallet.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:iucome/entitys/subItem.dart';
import 'package:backdrop/backdrop.dart';
import 'package:iucome/database/db.dart';



class BottomTabbar extends StatefulWidget {
  const BottomTabbar({Key key}) : super(key: key);
  
  @override
  _BottomTabbarState createState() => _BottomTabbarState();

}

class _BottomTabbarState extends State<BottomTabbar> with SingleTickerProviderStateMixin{
  
  
 
  
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
    
    return Scaffold(
      appBar: null,
      body: FutureBuilder<List<Wallet>>(
        future: DaBa.getWallets(),
        builder: (BuildContext context, AsyncSnapshot<List<Wallet>> snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          else {
            final wallets = snapshot.data;
            return FutureBuilder<List<WalletCategory>>(
              future: DaBa.getCategories(),
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
                      Center(child: Icon(Icons.cloud, size:64.0, color:AppColors.gray)),
                      WalletsTab(wallets,categories),
                      AppBarExpensesPage(cat:categories,wall:wallets),   
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
      text: isTileView ? '' : wallet.cash.toString()),
    legend: Legend(isVisible: isTileView ? false : true),
    series: getDefaultPieSeries(isTileView,wallet,cat),
  );
}

List<PieSeries<ChartSampleData, String>> getDefaultPieSeries(bool isTileView,Wallet wallet, List<WalletCategory> cat) {
  final List<ChartSampleData> pieData = <ChartSampleData>[];
   for (var categ in cat) {
       pieData.add(ChartSampleData(x: categ.name, y: categ.cash, text: categ.name+' '+categ.cash.toString()));
    }
  return <PieSeries<ChartSampleData, String>>[
    PieSeries<ChartSampleData, String>(
        explode: true,
        explodeIndex: 0,
        explodeOffset: '10%',
        dataSource: pieData,
        xValueMapper: (ChartSampleData data, _) => data.x,
        yValueMapper: (ChartSampleData data, _) => data.y,
        dataLabelMapper: (ChartSampleData data, _) => data.text,
        startAngle: 90,
        endAngle: 90,
        dataLabelSettings: DataLabelSettings(isVisible: true)),
  ];
}

class AppBarExpensesPage extends StatelessWidget {
  AppBarExpensesPage({this.cat,this.wall,Key key}) : super(key: key);
  List<WalletCategory> cat = [];
  List<Wallet> wall = [];
  @override
  Widget build(BuildContext context) {
    List<SizedBox> boxes = [];
    for (var item in cat) {
      boxes.add(SizedBox(
            height: 50,
            child: FlatButton(
              onPressed: ()=>{DaBa.getCategories()}, 
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
        children: <Widget>[
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
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Flex"),
                ),
              )
              
            ),
          ),
          )
        ],
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
              return CustomDialog(cat: cat,wall:wall,);
            }
          );
        }
      )
      ],
    );
  }
}



