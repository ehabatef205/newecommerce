import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newecommerce/constant.dart';
import 'package:newecommerce/screens/admin/add_product.dart';
import 'package:newecommerce/screens/admin/mange_product.dart';
import 'package:newecommerce/screens/admin/orders_screen.dart';
import 'package:newecommerce/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHome extends StatefulWidget {
  static String id = 'AdminHome';

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        SystemNavigator.pop();
        return null;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Container(padding: EdgeInsets.zero, height: 1,),
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'Discover'.toUpperCase(),
            style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            InkWell(
              onTap: () async {
                final SharedPreferences
                sharedPreferences =
                await SharedPreferences
                    .getInstance();
                sharedPreferences
                    .remove("isAdmin");
                Navigator.pushNamed(context, LoginScreen.id);
              },
              child: Icon(
                Icons.logout,
              ),
            ),
            SizedBox(width: 20,),
          ],
          elevation: 2,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AddProduct.id);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Icon(
                        Icons.shop_two,
                        size: 100,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Add new items",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                indent: 50,
                endIndent: 50,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, ManageProducts.id);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 100,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Edit Product',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                indent: 50,
                endIndent: 50,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, OrdersScreen.id);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Icon(
                        Icons.view_comfy,
                        size: 100,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('View orders',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
