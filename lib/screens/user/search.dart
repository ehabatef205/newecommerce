import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:newecommerce/constant.dart';
import 'package:newecommerce/functions.dart';
import 'package:newecommerce/models/product.dart';
import 'package:newecommerce/screens/user/productInfo.dart';
import 'package:newecommerce/services/store.dart';

import 'home_page.dart';

extension CapExtension on String {
  String get inCaps => this.length > 0 ?'${this[0].toUpperCase()}${this.substring(1)}':'';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach => this.replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.inCaps).join(" ");
}

class searchProduct extends StatefulWidget {
  static String id = "searchProduct";

  @override
  _searchProductState createState() => _searchProductState();
}

class _searchProductState extends State<searchProduct> {
  String name = "";

  final _store = Store();
  List<Product> _products;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        title: TextField(
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.black,), hintText: 'Search...'),
          onChanged: (val) {
            setState(() {
              name = val;
            });
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (name != "" && name != null)
            ? FirebaseFirestore.instance
                .collection('Products')
                .where("productName", isGreaterThanOrEqualTo: name.capitalizeFirstofEach)
                .where('productName', isLessThan: name.capitalizeFirstofEach + 'z')
                .snapshots()
            : FirebaseFirestore.instance
                .collection('Products')
                .where("productName", isEqualTo: name)
                .snapshots(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot data = snapshot.data.docs[index];
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
                    products = getProductByCategory(data["productCategory"], _products);
                    return Column(
                      children: [
                        ListTile(
                          onTap: (){
                            Navigator.pushNamed(context, ProductInfo.id,
                                arguments: products[0]);
                          },
                          title: Text(
                            data['productName'],
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          subtitle: Text(
                            "${data['productPrice']} EG",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(data['productLocation']),
                              ),
                            ),
                          ),
                        ),
                        index < snapshot.data.docs.length - 1? Divider(
                          thickness: 1,
                          endIndent: 5,
                          indent: 5,
                        ) : Container()
                      ],
                    );
                  },
                );
        },
      ),
    );
  }
}
