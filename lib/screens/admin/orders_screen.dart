import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newecommerce/constant.dart';
import 'package:newecommerce/models/order.dart';
import 'package:newecommerce/screens/admin/order_details.dart';
import 'package:newecommerce/services/store.dart';

import 'admin_home.dart';

class OrdersScreen extends StatelessWidget {
  static String id = 'OrdersScreen';
  final Store _store = Store();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: (){
        Navigator.pushNamed(context, AdminHome.id);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pushNamed(context, AdminHome.id);
            },
          ),
          centerTitle: true,
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
          stream: _store.loadOrders(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Text('there is no orders'),
              );
            } else {
              List<Order> orders = [];
              for (var doc in snapshot.data.docs) {
                orders.add(Order(
                  documentId: doc.id,
                  address: doc.data()[kAddress],
                  totallPrice: doc.data()[kTotallPrice],
                ));
              }
              return ListView.builder(
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, OrderDetails.id,
                          arguments: orders[index].documentId);
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * .15,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Totall Price = ${orders[index].totallPrice} EG',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Address is ${orders[index].address}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10,),
                            Divider(
                              thickness: 2,
                              endIndent: 5,
                              indent: 5,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                itemCount: orders.length,
              );
            }
          },
        ),
      ),
    );
  }
}
