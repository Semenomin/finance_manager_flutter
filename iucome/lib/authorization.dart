import 'package:flutter/material.dart';
import 'package:iucome/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:iucome/image_placeholder.dart';
import 'package:iucome/appColors.dart';
import 'package:http/http.dart' as http;
import 'package:iucome/http_config.dart';
import 'package:iucome/database/db.dart';

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
    return Scaffold(
      body: SafeArea(
        child: _MainView(
          usernameController: _usernameController,
          passwordController: _passwordController,
        )
      )
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
  _MainView({
    Key key,
    this.passwordController,
    this.usernameController
  }) : super(key: key);
  
  TextEditingController usernameController;
  TextEditingController passwordController;
  
  @override
  Widget build(BuildContext context) {
    List<Widget> listViewChildren;
    listViewChildren = [
      const _SmallLogo(),
      SizedBox(height: 20),
      _UsernameTextField(usernameController),
      SizedBox(height: 20),
      _PasswordTextField(passwordController),
      SizedBox(height: 110),
      LoginButton(passwordController: passwordController,usernameController: usernameController,)
    ];
                    return Scaffold(
                        body: Column(
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
                                )
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

TextEditingController controller; 

_UsernameTextField(TextEditingController controllerIn){
  controller = controllerIn;
}

  @override
  Widget build(BuildContext context) {

    

    final colorScheme = Theme.of(context).colorScheme;


    return PrimaryColorOverride(
      color: AppColors.gray,
      child: Container(
        child: TextField(
          controller: controller,
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

TextEditingController controller; 

_PasswordTextField(TextEditingController controllerIn){
  controller = controllerIn;
}
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PrimaryColorOverride(
      color: AppColors.gray,
      child: Container(
        child: TextField(
          controller: controller,
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
          _login(usernameController.text.toString(), passwordController.text.toString()).then((res){
            if(res[0]){
              
              DaBa.syncDBout(res[1]);                                                                   //SyncDB
              setdata(res[1]).then(
                Navigator.of(context).pushNamed(IucomeApp.homeRoute,
                arguments: <String,String>{
                'userId': res[1],
                })
              );
            
            }
            else{
              Toast.show('Invalid login or password',context, gravity: Toast.BOTTOM);
            }
          });
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
            _registration(usernameController.text.toString(), passwordController.text.toString()).then((res){
            if(res[0]){
              setdata(res[1]).then(
                DaBa.createUser(res[1]),
                Navigator.of(context).pushNamed(IucomeApp.homeRoute,
                arguments: <String,String>{
                'userId': res[1],
              })
              );
            }
            else{
              Toast.show('User exists!',context, gravity: Toast.BOTTOM);
            }
          });
          },
        ),
      ]
    );
  }

  setdata(String id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('user', id);
  }
}

Future<List> _login(String pass,String login) async {
  
  final response = await http.post('http://${HttpConfig.ip}:${HttpConfig.port}/users/auth?login=$login&pass=$pass');
  print(response.body);
  if(response.body == 'none'){
    return [false,'none'];
  }
  else{
    return [true,response.body];
  }
}

Future<List> _registration(String pass,String login) async{
  final response = await http.post('http://${HttpConfig.ip}:${HttpConfig.port}/users/create?login=$login&pass=$pass');
  if(response.body == 'none'){
    return [false,'none'];
  }
  else{
    return [true,response.body];
  }
}