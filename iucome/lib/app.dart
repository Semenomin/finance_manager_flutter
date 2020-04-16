import 'package:flutter/material.dart';
import 'package:iucome/authorization.dart';
import 'package:iucome/home.dart';
void main() {
  runApp(IucomeApp());
}

class IucomeApp extends StatelessWidget {
  const IucomeApp();
  static const String authorizationRoute = "/authorization";
  static const String homeRoute= "/lib";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iucome',
      home: const AuthorizationPage(),
      initialRoute: authorizationRoute,
      routes: <String,WidgetBuilder>{
        homeRoute: (context) => const HomePage(),
        authorizationRoute: (context) => const AuthorizationPage(), 
      },
    );
  }
}