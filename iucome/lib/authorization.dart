import 'package:flutter/material.dart';
import 'package:iucome/app.dart';
import 'package:iucome/image_placeholder.dart';
import 'package:iucome/appColors.dart';
import 'package:http/http.dart' as http;
var client = http.Client();
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
  
  @override
  Widget build(BuildContext context) {
    List<Widget> listViewChildren;
    listViewChildren = [
      const _SmallLogo(),
      SizedBox(height: 20),
      _UsernameTextField(),
      SizedBox(height: 20),
      _PasswordTextField(),
      SizedBox(height: 110),
      LoginButton(passwordController: passwordController,usernameController: usernameController,)
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
            image: AssetImage('images/incomeLightLogo.png'),
            placeholder: SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _UsernameTextField extends StatelessWidget {
  const _UsernameTextField();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final _usernameController = TextEditingController();

    return PrimaryColorOverride(
      color: AppColors.gray,
      child: Container(
        child: TextField(
          controller: _usernameController,
          cursorColor: colorScheme.onSurface,
          decoration: InputDecoration(
            labelText: 'Login',
            border: new OutlineInputBorder(
              borderSide: new BorderSide(color: AppColors.gray)
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordTextField extends StatelessWidget {
  const _PasswordTextField();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final _passwordController = TextEditingController();

    return PrimaryColorOverride(
      color: AppColors.gray,
      child: Container(
        child: TextField(
          controller: _passwordController,
          cursorColor: colorScheme.onSurface,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: new OutlineInputBorder(
              borderSide: new BorderSide(color: AppColors.gray)
            ),
          ),
        ),
      ),
    );
  }
}

class PrimaryColorOverride extends StatelessWidget {
  const PrimaryColorOverride({Key key, this.color, this.child})
      : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context).copyWith(primaryColor: color),
    );
  }
}

class LoginButton extends StatefulWidget {
  LoginButton({ 
    this.passwordController,
    this.usernameController
    });
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  @override
  _LoginButtonState createState() => _LoginButtonState(usernameController,passwordController);
}

class _LoginButtonState  extends State<LoginButton> {
  _LoginButtonState( 
    this.passwordController,
    this.usernameController
    );
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  @override
  Widget build(BuildContext context) {
    return ButtonBar(
       children: [FlatButton(
        onPressed: (){
          List list = _login();
          if(list[0]){
            Navigator.of(context).pushNamed(IucomeApp.homeRoute,
            arguments: <String,int>{
              'userId': list[1],
            });
          }
          else {
            List reg;
            _registration("flexwwx",'wewefwe').then((res)=>reg=res);
            // if(reg[0])
            // {
            //   Navigator.of(context).pushNamed(IucomeApp.homeRoute,
            //   arguments: <String,int>{
            //   'userId': reg[1],
            // });
            // }
          }
        },
        child: Text(
          'Sign in',
          style: TextStyle(color: AppColors.gray),
        ),
        shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
      )
      ,
      RaisedButton(
        child: Padding(
          padding: EdgeInsets.zero,
          child: Text(
            'Sign up',
            style: TextStyle(color: AppColors.gray),
          ),
        ),
        elevation: 1,
        shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        onPressed: () {
            Navigator.of(context).pushNamed(IucomeApp.currencyRoute);
          },
        ),
      ]
    );
  }
}

List _login(){
  int userId = 1;
  return [true,userId];
}

Future<List> _registration(String login,String pass) async{
  final response = await client.post('http://192.168.100.8:3000/users/auth?login=$login&pass=$pass');
  print(response.body);
  print(login);
  print(pass);

  // if(response.body == 'User exist'){
  //   return [false,null];
  // }
  // else {
  //   print(response.body);
  //   return [true,response.body];
  // }
}