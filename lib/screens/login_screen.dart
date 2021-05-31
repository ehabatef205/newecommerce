import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:newecommerce/constant.dart';
import 'package:newecommerce/provider/admin_mode.dart';
import 'package:newecommerce/provider/modal_hud.dart';
import 'package:newecommerce/screens/admin/AdminLogin.dart';
import 'file:///D:/Android/newecommerce/lib/screens/admin/admin_home.dart';
import 'file:///D:/Android/newecommerce/lib/screens/user/home_page.dart';
import 'package:newecommerce/screens/signup_screen.dart';
import 'package:newecommerce/services/auth.dart';
import 'package:newecommerce/widgets/custom_logo.dart';
import 'package:newecommerce/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'LoginScreen';
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email, password;

  bool keepMeLoggedIn = false;

  TextEditingController emailText = TextEditingController();
  TextEditingController passwordText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: Provider.of<ModelHud>(context).isLoading,
        child: Form(
          key: widget.globalKey,
          child: ListView(
            children: <Widget>[
              CustomLogo(),
              SizedBox(
                height: height * .1,
              ),
              CustomTextField(
                onClick: (value) {
                  _email = value;
                },
                controller: emailText,
                hint: 'Enter your email',
                icon: Icons.email,
              ),
              SizedBox(
                height: 10,
              ),
              CustomTextField(
                controller: passwordText,
                onClick: (value) {
                  password = value;
                },
                hint: 'Enter your password',
                icon: Icons.lock,
              ),
              SizedBox(
                height: height * .05,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 120),
                child: Builder(
                  builder: (context) => FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      _validate(context);
                    },
                    color: Colors.black,
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height * .05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Don\'t have an account ? ',
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, SignupScreen.id);
                    },
                    child: Text(
                      'Signup',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Provider.of<AdminMode>(context, listen: false)
                              .changeIsAdmin(true);
                          Navigator.pushNamed(context, AdminLogin.id);
                        },
                        child: Text(
                          'i\'m an admin',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  void _validate(BuildContext context) async {
    if (widget.globalKey.currentState.validate()) {
      widget.globalKey.currentState.save();
      try {
        await firebaseAuth.signInWithEmailAndPassword(
            email: emailText.text.trim(), password: passwordText.text.trim());
        Navigator.pushNamed(context, HomePage.id);
      } catch (e) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(e.message),
        ));
      }
    }
  }
}
