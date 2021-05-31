import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:newecommerce/constant.dart';
import 'package:newecommerce/provider/admin_mode.dart';
import 'package:newecommerce/provider/modal_hud.dart';
import 'package:newecommerce/screens/admin/admin_home.dart';
import 'package:newecommerce/screens/login_screen.dart';
import 'file:///D:/Android/newecommerce/lib/screens/user/home_page.dart';
import 'package:newecommerce/screens/signup_screen.dart';
import 'package:newecommerce/services/auth.dart';
import 'package:newecommerce/widgets/custom_logo.dart';
import 'package:newecommerce/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLogin extends StatefulWidget {
  static String id = 'AdminLogin';
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  String _email, password;

  final _auth = Auth();

  final adminPassword = 'Admin1234@';

  bool keepMeLoggedIn = false;

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  TextEditingController emailText = TextEditingController();
  TextEditingController passwordText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: (){
        Navigator.pushNamed(context, LoginScreen.id);
        return null;
      },
      child: Scaffold(
        key: _globalKey,
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
                  hint: 'Enter your ID',
                  icon: Icons.person,
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
                        if (widget.globalKey.currentState.validate()) {
                          widget.globalKey.currentState.save();
                          loginAdmin();
                        }
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Provider.of<AdminMode>(context, listen: false)
                                .changeIsAdmin(false);
                            Navigator.pushNamed(context, LoginScreen.id);
                          },
                          child: Text(
                            'i\'m a user',
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
      ),
    );
  }

  loginAdmin() {
    FirebaseFirestore.instance.collection("admins").get().then((snapshot) {
      snapshot.docs.forEach((result) {
        if (result.data()["id"] != emailText.text.trim().toUpperCase()) {
          _globalKey.currentState
              .showSnackBar(SnackBar(content: Text("Your id is not correct")));
        } else if (result.data()["password"] != passwordText.text.trim()) {
          _globalKey.currentState
            .showSnackBar(
                SnackBar(content: Text("Your password is not correct")));
        } else {
          setState(() {
            emailText.text = "";
            passwordText.text = "";
          });
          keepLogIn();
          Navigator.pushNamed(context, AdminHome.id);
        }
      });
    });
  }

  Future keepLogIn() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setBool("isAdmin", true);
  }
}
