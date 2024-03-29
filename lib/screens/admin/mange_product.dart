import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newecommerce/constant.dart';
import 'package:newecommerce/models/product.dart';
import 'package:newecommerce/screens/admin/admin_home.dart';
import 'package:newecommerce/services/store.dart';
import 'package:newecommerce/widgets/custom_menu.dart';
import 'package:newecommerce/widgets/custom_text_field.dart';

import 'edit_product.dart';

class ManageProducts extends StatefulWidget {
  static String id = 'ManageProducts';
  @override
  _ManageProductsState createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  final _store = Store();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: (){
        Navigator.pushNamed(context, AdminHome.id);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pushNamed(context, AdminHome.id);
            },
          ),
          title: Text(
            'Discover'.toUpperCase(),
            style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          elevation: 2,
        ),
        body: StreamBuilder<QuerySnapshot>(
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
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .8,
                ),
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Card(
                    elevation: 3,
                    child: GestureDetector(
                      onTapUp: (details) async {
                        double dx = details.globalPosition.dx;
                        double dy = details.globalPosition.dy;
                        double dx2 = MediaQuery.of(context).size.width - dx;
                        double dy2 = MediaQuery.of(context).size.width - dy;
                        await showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(dx, dy, dx2, dy2),
                            items: [
                              MyPopupMenuItem(
                                onClick: () {
                                  Navigator.pushNamed(context, EditProduct.id,
                                      arguments: products[index]);
                                },
                                child: Text('Edit'),
                              ),
                              MyPopupMenuItem(
                                onClick: () {
                                  _store.deleteProduct(products[index].pId);
                                  Navigator.pop(context);
                                },
                                child: Text('Delete'),
                              ),
                            ]);
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
                                        style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }
}
