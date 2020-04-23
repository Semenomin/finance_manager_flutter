import 'package:flutter/material.dart';
import 'package:iucome/appColors.dart';
import 'package:iucome/entitys/tab.dart';
import 'package:iucome/entitys/wallet.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:iucome/entitys/subItem.dart';

class BottomTabbar extends StatefulWidget {
  const BottomTabbar({Key key}) : super(key: key);

  @override
  _BottomTabbarState createState() => _BottomTabbarState();
}

class _BottomTabbarState extends State<BottomTabbar> with SingleTickerProviderStateMixin{
  TabController _tabController;

  static const _kTabPages = <Widget>[
    Center(child: Icon(Icons.cloud, size:64.0, color:AppColors.gray)),
    WalletsTab(),
    Center(child: Icon(Icons.cloud, size:64.0, color:AppColors.gray))
  ];

  static const _kTabs = <Widget>[
    Tab(icon: Icon(Icons.arrow_downward),text:'Incomes'),
    Tab(icon: Icon(Icons.account_balance_wallet),text:'Wallets'),
    Tab(icon: Icon(Icons.arrow_upward),text:'Expences')
  ];
  
  @override
  void initState(){
    super.initState();
    _tabController = TabController(
      length: _kTabPages.length,
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
      body: TabBarView(
        children: _kTabPages,
        controller: _tabController,
      ),
      bottomNavigationBar: Material(
        color: AppColors.gray,
        child: TabBar(
          tabs: _kTabs,
        controller: _tabController
        ),
      ),
    );
  }
}

class WalletsTab extends StatelessWidget {

  const WalletsTab();

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
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.gray,
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
          children: [
            PieWallet(),
            PieWallet(),
            PieWallet(),
            PieWallet(),
            PieWallet(),
            PieWallet(),
          ]
        )
      )
    );
  }
}

class PieWallet extends StatefulWidget {
  PieWallet({this.sample,Key key}) : super(key: key);
  SubItem sample;
  @override
  _PieWalletState createState() => _PieWalletState(sample);
}

class _PieWalletState extends State<PieWallet> {
  _PieWalletState(this.sample);
  final SubItem sample;
  @override
  Widget build(BuildContext context) {
    List<Expence> ex = [
      Expence("A",5000,category[0],"12-12-1999","nessesary"),
      Expence("B",2000,category[1],"12-12-1999","nessesary"),
      Expence("C",1000,category[2],"12-12-1999","nessesary"),
    ];
    return getDefaultPieChart(false,Wallet("nessesary",10000,ex));
  }
}

SfCircularChart getDefaultPieChart(bool isTileView,Wallet wallet) {
  return SfCircularChart(
    
    title: ChartTitle(text: isTileView ? '' : 'Sales by sales person'),
    legend: Legend(isVisible: isTileView ? false : true),
    series: getDefaultPieSeries(isTileView,wallet),
  );
}

List<PieSeries<ChartSampleData, String>> getDefaultPieSeries(bool isTileView,Wallet wallet) {
  final List<ChartSampleData> pieData = <ChartSampleData>[
    ChartSampleData(x: wallet.expense[0].category, y: wallet.expense[0].cash, text: wallet.expense[0].category),
    ChartSampleData(x: wallet.expense[1].category, y: wallet.expense[1].cash, text: wallet.expense[1].category),
    ChartSampleData(x: wallet.expense[2].category, y: wallet.expense[2].cash, text: wallet.expense[2].category),

  ];
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



