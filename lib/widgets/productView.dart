import 'package:flutter/material.dart';
import 'package:newecommerce/functions.dart';
import 'package:newecommerce/models/product.dart';
import 'package:newecommerce/screens/user/productInfo.dart';

Widget ProductsView(String pCategory, List<Product> allProducts) {
  List<Product> products;
  products = getProductByCategory(pCategory, allProducts);
  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: .8,
    ),
    itemBuilder: (context, index) => Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
    itemCount: products.length,
  );
}