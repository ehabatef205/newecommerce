import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newecommerce/models/product.dart';
import 'package:newecommerce/screens/admin/admin_home.dart';
import 'package:newecommerce/services/store.dart';
import 'package:newecommerce/widgets/custom_text_field.dart';

class AddProduct extends StatefulWidget {
  static String id = 'AddProduct';

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  String _name, _price, _description, _category, _imageLocation;

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  final _store = Store();

  File _imageFile;

  bool isLoading = false;

  String userImageUrl = "";

  var categories = [
    'jackets',
    'trousers',
    't-shirts',
    'shoes',
  ];

  var selectedCategory;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        Navigator.pushNamed(context, AdminHome.id);
        return null;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pushNamed(context, AdminHome.id);
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
        body: !isLoading? Form(
          key: _globalKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: _selectAndPickImage,
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.15,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          _imageFile == null ? null : FileImage(_imageFile),
                      child: _imageFile == null
                          ? Icon(
                              Icons.add_photo_alternate,
                              size: MediaQuery.of(context).size.width * 0.15,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                ),
                CustomTextField(
                  hint: 'Product Name',
                  onClick: (value) {
                    _name = value;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  onClick: (value) {
                    _price = value;
                  },
                  hint: 'Product Price',
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  onClick: (value) {
                    _description = value;
                  },
                  hint: 'Product Description',
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    new Text(
                      "Category",
                      style: new TextStyle(fontSize: 20.0),
                    ),
                    DropdownButton(
                      items: categories.map((item) {
                        return DropdownMenuItem(
                          child: Text(item),
                          value: item,
                        );
                      }).toList(),
                      value: selectedCategory == null
                          ? null
                          : selectedCategory,
                      hint: Text("Select category"),
                      onChanged: (newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                RaisedButton(
                  onPressed: () {
                    if (_globalKey.currentState.validate()) {
                      _globalKey.currentState.save();

                      uploadToStorage();
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  color: Colors.teal,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Add Product',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                )
              ],
            ),
          ),
        ) : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _selectAndPickImage() async {
    var pickerImage = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = File(pickerImage.path);
    });
  }

  uploadToStorage() async {
    setState(() {
      isLoading = true;
    });

    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference reference = FirebaseStorage.instance.ref().child("items").child(imageFileName);

    UploadTask uploadTask = reference.putFile(_imageFile);

    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() async {
      await reference.getDownloadURL().then((urlImage) {
        userImageUrl = urlImage;

        _store.addProduct(Product(
            pName: _name,
            pPrice: _price,
            pDescription: _description,
            pLocation: userImageUrl,
            pCategory: selectedCategory));
      });

      Navigator.pushNamed(context, AdminHome.id);
    });

    setState(() {
      isLoading = true;
    });
  }
}
