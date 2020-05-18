import 'package:flutter/material.dart';
import 'package:iucome/authorization.dart';
import 'package:iucome/curPage.dart';
import 'package:iucome/home.dart';
import 'package:iucome/database/db.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() {
  runApp(IucomeApp());
}

class IucomeApp extends StatelessWidget {
  const IucomeApp();
  static const String authorizationRoute = "/authorization";
  static const String homeRoute= "/lib";
  static const String currencyRoute = "/curPage";
  @override
  Widget build(BuildContext context) {
    DaBa.connectDB();
    return MaterialApp(
      title: 'Iucome',
      home: AuthorizationPage(),
      initialRoute: authorizationRoute,
      routes: <String,WidgetBuilder>{
        homeRoute: (context) => BottomTabbar(),
        authorizationRoute: (context) => const AuthorizationPage(), 
        currencyRoute: (context) => const CurPage()
      },
    );
  }
}