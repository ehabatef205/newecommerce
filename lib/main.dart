import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:newecommerce/constant.dart';
import 'package:newecommerce/provider/admin_mode.dart';
import 'package:newecommerce/provider/cart_item.dart';
import 'package:newecommerce/provider/modal_hud.dart';
import 'package:newecommerce/screens/admin/AdminLogin.dart';
import 'package:newecommerce/screens/admin/add_product.dart';
import 'package:newecommerce/screens/admin/edit_product.dart';
import 'package:newecommerce/screens/admin/mange_product.dart';
import 'package:newecommerce/screens/admin/order_details.dart';
import 'file:///D:/Android/newecommerce/lib/screens/admin/admin_home.dart';
import 'package:newecommerce/screens/login_screen.dart';
import 'package:newecommerce/screens/signup_screen.dart';
import 'package:newecommerce/screens/user/cart_screen.dart';
import 'package:newecommerce/screens/user/home_page.dart';
import 'file:///D:/Android/newecommerce/lib/screens/admin/orders_screen.dart';
import 'package:newecommerce/screens/user/productInfo.dart';
import 'package:newecommerce/screens/user/profile.dart';
import 'package:newecommerce/screens/user/search.dart';
import 'package:newecommerce/spalsh.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  bool isUserLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Loading....'),
              ),
            ),
          );
        } else {
          isUserLoggedIn = snapshot.data.getBool(kKeepMeLoggedIn) ?? false;
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<ModelHud>(
                create: (context) => ModelHud(),
              ),
              ChangeNotifierProvider<CartItem>(
                create: (context) => CartItem(),
              ),
              ChangeNotifierProvider<AdminMode>(
                create: (context) => AdminMode(),
              )
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              initialRoute: splashScreen.id,
              routes: {
                OrderDetails.id: (context) => OrderDetails(),
                OrdersScreen.id: (context) => OrdersScreen(),
                CartScreen.id: (context) => CartScreen(),
                ProductInfo.id: (context) => ProductInfo(),
                EditProduct.id: (context) => EditProduct(),
                ManageProducts.id: (context) => ManageProducts(),
                LoginScreen.id: (context) => LoginScreen(),
                SignupScreen.id: (context) => SignupScreen(),
                HomePage.id: (context) => HomePage(),
                AdminHome.id: (context) => AdminHome(),
                AddProduct.id: (context) => AddProduct(),
                Profile.id: (context) => Profile(),
                AdminLogin.id: (context) => AdminLogin(),
                splashScreen.id: (context) => splashScreen(),
                searchProduct.id: (context) => searchProduct()
              },
            ),
          );
        }
      },
    );
  }
}
