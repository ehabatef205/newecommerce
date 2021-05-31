import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newecommerce/constant.dart';
import 'package:newecommerce/functions.dart';
import 'package:newecommerce/models/product.dart';
import 'package:newecommerce/provider/cart_item.dart';
import 'package:newecommerce/screens/login_screen.dart';
import 'package:newecommerce/screens/user/cart_screen.dart';
import 'package:newecommerce/screens/user/productInfo.dart';
import 'package:newecommerce/screens/user/profile.dart';
import 'package:newecommerce/screens/user/search.dart';
import 'package:newecommerce/services/auth.dart';
import 'package:newecommerce/services/store.dart';
import 'package:newecommerce/widgets/productView.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static String id = "HomePage";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabBarIndex = 0;
  final _store = Store();
  List<Product> _products;

  @override
  Widget build(BuildContext context) {
    List<Product> products = Provider.of<CartItem>(context).products;
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
        return null;
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            leading: Container(
              padding: EdgeInsets.zero,
              height: 1,
            ),
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            title: Text(
              'Discover'.toUpperCase(),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            actions: [
              GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, searchProduct.id);
                  },
                  child: Icon(Icons.search)),
              SizedBox(
                width: 20,
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, CartScreen.id);
                  },
                  child: Icon(Icons.shopping_cart)),
              SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Profile.id);
                },
                child: Icon(
                  Icons.person,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              InkWell(
                onTap: () async {
                  products.clear();
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamed(context, LoginScreen.id);
                },
                child: Icon(
                  Icons.logout,
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
            elevation: 0,
            bottom: TabBar(
              indicatorColor: kMainColor,
              onTap: (value) {
                setState(() {
                  _tabBarIndex = value;
                });
              },
              tabs: <Widget>[
                Text(
                  'Jackets',
                  style: TextStyle(
                    color: kUnActiveColor,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Trouser',
                  style: TextStyle(
                    color: kUnActiveColor,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'T-shirts',
                  style: TextStyle(
                    color: kUnActiveColor,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Shoes',
                  style: TextStyle(
                    color: kUnActiveColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              RefreshIndicator(
                  onRefresh: () {
                    return Future.delayed(
                      Duration(seconds: 1),
                      () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    super.widget));
                      },
                    );
                  },
                  child: jacketView()),
              RefreshIndicator(
                  onRefresh: () {
                    setState(() {
                      _tabBarIndex = 1;
                    });
                    return Future.delayed(
                      Duration(seconds: 1),
                      () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    super.widget));
                      },
                    );
                  },
                  child: trousers()),
              RefreshIndicator(
                  onRefresh: () {
                    setState(() {
                      _tabBarIndex = 2;
                    });
                    return Future.delayed(
                      Duration(seconds: 1),
                      () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    super.widget));
                      },
                    );
                  },
                  child: tShirtView()),
              RefreshIndicator(
                  onRefresh: () {
                    setState(() {
                      _tabBarIndex = 3;
                    });
                    return Future.delayed(
                      Duration(seconds: 1),
                      () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    super.widget));
                      },
                    );
                  },
                  child: shoesView()),
            ],
          ),
        ),
      ),
    );
  }

  Widget jacketView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _store.loadProducts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Product> products = [];
          for (var doc in snapshot.data.docs) {
            var data = doc.data;
            products.add(Product(
                pId: doc.id,
                pPrice: data()[kProductPrice],
                pName: data()[kProductName],
                pDescription: data()[kProductDescription],
                pLocation: data()[kProductLocation],
                pCategory: data()[kProductCategory]));
          }
          _products = [...products];
          products.clear();
          products = getProductByCategory(kJackets, _products);
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .8,
            ),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Card(
                elevation: 2,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, ProductInfo.id,
                        arguments: products[index]);
                  },
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Image(
                          fit: BoxFit.fill,
                          image: NetworkImage(products[index].pLocation),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Opacity(
                          opacity: .6,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    products[index].pName,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('${products[index].pPrice} EG')
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            itemCount: products.length,
          );
        } else {
          return Center(child: Text('Loading...'));
        }
      },
    );
  }

  Widget trousers() {
    return StreamBuilder<QuerySnapshot>(
      stream: _store.loadProducts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Product> products = [];
          for (var doc in snapshot.data.docs) {
            var data = doc.data;
            products.add(Product(
                pId: doc.id,
                pPrice: data()[kProductPrice],
                pName: data()[kProductName],
                pDescription: data()[kProductDescription],
                pLocation: data()[kProductLocation],
                pCategory: data()[kProductCategory]));
          }
          _products = [...products];
          products.clear();
          products = getProductByCategory(kTrousers, _products);
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .8,
            ),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Card(
                elevation: 2,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, ProductInfo.id,
                        arguments: products[index]);
                  },
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Image(
                          fit: BoxFit.fill,
                          image: NetworkImage(products[index].pLocation),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Opacity(
                          opacity: .6,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    products[index].pName,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('${products[index].pPrice} EG')
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            itemCount: products.length,
          );
        } else {
          return Center(child: Text('Loading...'));
        }
      },
    );
  }

  Widget tShirtView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _store.loadProducts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Product> products = [];
          for (var doc in snapshot.data.docs) {
            var data = doc.data;
            products.add(Product(
                pId: doc.id,
                pPrice: data()[kProductPrice],
                pName: data()[kProductName],
                pDescription: data()[kProductDescription],
                pLocation: data()[kProductLocation],
                pCategory: data()[kProductCategory]));
          }
          _products = [...products];
          products.clear();
          products = getProductByCategory(kTshirts, _products);
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .8,
            ),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Card(
                elevation: 2,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, ProductInfo.id,
                        arguments: products[index]);
                  },
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Image(
                          fit: BoxFit.fill,
                          image: NetworkImage(products[index].pLocation),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Opacity(
                          opacity: .6,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    products[index].pName,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('${products[index].pPrice} EG')
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            itemCount: products.length,
          );
        } else {
          return Center(child: Text('Loading...'));
        }
      },
    );
  }

  Widget shoesView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _store.loadProducts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Product> products = [];
          for (var doc in snapshot.data.docs) {
            var data = doc.data;
            products.add(Product(
                pId: doc.id,
                pPrice: data()[kProductPrice],
                pName: data()[kProductName],
                pDescription: data()[kProductDescription],
                pLocation: data()[kProductLocation],
                pCategory: data()[kProductCategory]));
          }
          _products = [...products];
          products.clear();
          products = getProductByCategory(kShoes, _products);
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .8,
            ),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Card(
                elevation: 2,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, ProductInfo.id,
                        arguments: products[index]);
                  },
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Image(
                          fit: BoxFit.fill,
                          image: NetworkImage(products[index].pLocation),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Opacity(
                          opacity: .6,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    products[index].pName,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('${products[index].pPrice} EG')
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            itemCount: products.length,
          );
        } else {
          return Center(child: Text('Loading...'));
        }
      },
    );
  }
}
