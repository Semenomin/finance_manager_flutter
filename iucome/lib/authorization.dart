import 'package:flutter/material.dart';
import 'package:iucome/app.dart';
import 'package:iucome/image_placeholder.dart';

class AuthorizationPage extends StatefulWidget {
  const AuthorizationPage();

  @override
  _AuthorizationPageState createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
  return Container(
        child: Scaffold(
          body: SafeArea(
            child: _MainView(
              usernameController: _usernameController,
              passwordController: _passwordController,
            ),
          ),
        ),
      );
    }

  @override
  void dispose(){
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _MainView extends StatelessWidget {
  const _MainView({
    Key key,
    this.passwordController,
    this.usernameController
  }) : super(key: key);
  
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  void _login(BuildContext context) {
    Navigator.of(context).pushNamed(IucomeApp.homeRoute);
  }
  
  @override
  Widget build(BuildContext context) {
    List<Widget> listViewChildren;
    listViewChildren = [
      const _SmallLogo()
    ];
    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: listViewChildren,
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallLogo extends StatelessWidget{
  const _SmallLogo({Key key,}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: SizedBox(
        height: 160,
        child: ExcludeSemantics(
          child: FadeInImagePlaceholder(
            image: AssetImage(assetName)
            placeholder: SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}