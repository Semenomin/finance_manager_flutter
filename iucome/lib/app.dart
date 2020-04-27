import 'package:flutter/material.dart';
import 'package:iucome/authorization.dart';
import 'package:iucome/curPage.dart';
import 'package:iucome/home.dart';
import 'package:iucome/registration.dart';
import 'package:iucome/database/db.dart';
void main() {
  runApp(IucomeApp());
}

class IucomeApp extends StatelessWidget {
  const IucomeApp();
  static const String authorizationRoute = "/authorization";
  static const String homeRoute= "/lib";
  static const String registrationRoute = "/registration";
  static const String currencyRoute = "/curPage";
  @override
  Widget build(BuildContext context) {
    DaBa.connectDB();
    return MaterialApp(
      title: 'Iucome',
      home: const BottomTabbar(),
      initialRoute: authorizationRoute,
      routes: <String,WidgetBuilder>{
        homeRoute: (context) => const BottomTabbar(),
        authorizationRoute: (context) => const AuthorizationPage(), 
        registrationRoute: (context) => const RegistrationPage(),
        currencyRoute: (context) => const CurPage()
      },
    );
  }
}