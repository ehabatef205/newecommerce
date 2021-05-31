import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newecommerce/screens/admin/admin_home.dart';
import 'package:newecommerce/screens/login_screen.dart';
import 'package:newecommerce/screens/user/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/custom_logo.dart';

class splashScreen extends StatefulWidget {
  static String id = "splashScreen";

  _splashScreenState createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  bool isAdmin;

  Future getValidationData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var arabic = sharedPreferences.getBool("isAdmin");
    isAdmin = arabic;
    print(isAdmin);
  }

  @override
  void initState() {
    super.initState();
    getValidationData().whenComplete(() async {
      Timer(Duration(seconds: 5), () {
        isAdmin == null
            ? FirebaseAuth.instance.currentUser == null
                ? Navigator.pushNamed(context, LoginScreen.id)
                : Navigator.pushNamed(context, HomePage.id)
            : Navigator.pushNamed(context, AdminHome.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CustomLogo()));
  }
}
