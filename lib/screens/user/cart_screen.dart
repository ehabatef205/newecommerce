import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newecommerce/constant.dart';
import 'package:newecommerce/models/product.dart';
import 'package:newecommerce/provider/cart_item.dart';
import 'package:newecommerce/screens/user/productInfo.dart';
import 'package:newecommerce/services/store.dart';
import 'package:newecommerce/widgets/custom_menu.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';

class CartScreen extends StatelessWidget {
  static String id = 'CartScreen';

  @override
  Widget build(BuildContext context) {
    List<Product> products = Provider.of<CartItem>(context).products;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double appBarHeight = AppBar().preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return WillPopScope(
      onWillPop: () {
        Navigator.pushNamed(context, HomePage.id);
        return null;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'My Cart',
            style: TextStyle(color: Colors.black),
          ),
          leading: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, HomePage.id);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            LayoutBuilder(builder: (context, constrains) {
              if (products.isNotEmpty) {
                return SingleChildScrollView(
                  child: Container(
                    height: screenHeight -
                        statusBarHeight -
                        appBarHeight -
                        10 -
                        (screenHeight * .08),
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(15),
                          child: GestureDetector(
                            onTapUp: (details) {
                              showCustomMenu(details, context, products[index]);
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: screenHeight * .15,
                                  child: Row(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: screenHeight * .15 / 2,
                                        backgroundImage: NetworkImage(
                                            products[index].pLocation),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    products[index].pName,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    '${products[index].pPrice} EG',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20),
                                              child: Text(
                                                products[index]
                                                    .pQuantity
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: products.length,
                    ),
                  ),
                );
              } else {
                return Container(
                  height: screenHeight -
                      (screenHeight * .08) -
                      appBarHeight -
                      10 -
                      statusBarHeight,
                  child: Center(
                    child: Text('Cart is Empty'),
                  ),
                );
              }
            }),
            Builder(
              builder: (context) => ButtonTheme(
                minWidth: screenWidth * 0.5,
                height: screenHeight * .07,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                          topLeft: Radius.circular(10))),
                  onPressed: () {
                    showCustomDialog(products, context);
                  },
                  child: Text('Order'.toUpperCase()),
                  color: kMainColor,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }

  void showCustomMenu(details, context, product) async {
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
              Navigator.pop(context);
              Provider.of<CartItem>(context, listen: false);
              Navigator.pushNamed(context, ProductInfo.id, arguments: product);
            },
            child: Text('Edit'),
          ),
          MyPopupMenuItem(
            onClick: () {
              Navigator.pop(context);
              Provider.of<CartItem>(context, listen: false)
                  .deleteProduct(product);
            },
            child: Text('Delete'),
          ),
        ]);
  }

  void showCustomDialog(List<Product> products, context) async {
    var price = getTotallPrice(products);
    var address;
    AlertDialog alertDialog = AlertDialog(
      actions: <Widget>[
        MaterialButton(
          onPressed: () {
            try {
              Store _store = Store();
              _store.storeOrders(
                  {kTotallPrice: price, kAddress: address}, products);

              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Order Successfully'),
              ));
              products.clear();
              Navigator.pop(context);
            } catch (ex) {
              print(ex.message);
            }
          },
          child: Text('Confirm'),
        )
      ],
      content: TextField(
        onChanged: (value) {
          address = value;
        },
        decoration: InputDecoration(hintText: 'Enter your Address'),
      ),
      title: Text('Totall Price  = $price EG'),
    );
    await showDialog(
        context: context,
        builder: (context) {
          return alertDialog;
        });
  }

  getTotallPrice(List<Product> products) {
    var price = 0;
    for (var product in products) {
      price += product.pQuantity * int.parse(product.pPrice);
    }
    return price;
  }
}
