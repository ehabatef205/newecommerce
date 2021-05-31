import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newecommerce/constant.dart';
import 'package:newecommerce/models/product.dart';
import 'package:newecommerce/screens/admin/orders_screen.dart';
import 'package:newecommerce/services/store.dart';

class OrderDetails extends StatelessWidget {
  static String id = 'OrderDetails';
  Store store = Store();
  @override
  Widget build(BuildContext context) {
    String documentId = ModalRoute.of(context).settings.arguments;
    return WillPopScope(
      // ignore: missing_return
      onWillPop: (){
        Navigator.pushNamed(context, OrdersScreen.id);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pushNamed(context, OrdersScreen.id);
            },
          ),
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'Discover'.toUpperCase(),
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          elevation: 2,
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: store.loadOrderDetails(documentId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Product> products = [];
                for (var doc in snapshot.data.docs) {
                  products.add(Product(
                    pLocation: doc.data()[kProductLocation],
                    pName: doc.data()[kProductName],
                    pQuantity: doc.data()[kProductQuantity],
                    pCategory: doc.data()[kProductCategory],
                  ));
                }

                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            height: MediaQuery.of(context).size.height * .16,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: MediaQuery.of(context).size.width * 0.08,
                                        backgroundImage: NetworkImage(products[index].pLocation),
                                      ),
                                      SizedBox(width: 10,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text('product name : ${products[index].pName}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'Quantity : ${products[index].pQuantity}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'product Category : ${products[index].pCategory}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Divider(
                                    thickness: 1,
                                    indent: 5,
                                    endIndent: 5,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        itemCount: products.length,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: ButtonTheme(
                              buttonColor: kMainColor,
                              child: RaisedButton(
                                onPressed: () {},
                                child: Text('Confirm Order'),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: ButtonTheme(
                              buttonColor: kMainColor,
                              child: RaisedButton(
                                onPressed: () {},
                                child: Text('Delete Order'),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Center(
                  child: Text('Loading Order Details'),
                );
              }
            }),
      ),
    );
  }
}
