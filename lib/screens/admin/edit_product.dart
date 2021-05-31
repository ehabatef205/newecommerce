import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newecommerce/constant.dart';
import 'package:newecommerce/models/product.dart';
import 'package:newecommerce/provider/modal_hud.dart';
import 'package:newecommerce/screens/admin/add_product.dart';
import 'package:newecommerce/screens/admin/mange_product.dart';
import 'package:newecommerce/services/store.dart';
import 'package:newecommerce/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

import 'admin_home.dart';

class EditProduct extends StatefulWidget {
  static String id = 'EditProduct';

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  String _imageLocation;

  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController category = TextEditingController();

  final _store = Store();

  File _imageFile;

  String userImageUrl;

  bool isLoading = false;

  String id = "";

  var categories = [
    'jackets',
    'trousers',
    't-shirts',
    'shoes',
  ];

  var selectedCategory;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        Product product = ModalRoute.of(context).settings.arguments;
        name.text = product.pName;
        description.text = product.pDescription;
        price.text = product.pPrice;
        id = product.pId;
        _imageLocation = product.pLocation;
        selectedCategory = product.pCategory;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        Navigator.pushNamed(context, ManageProducts.id);
        return null;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pushNamed(context, ManageProducts.id);
            },
          ),
          title: Text(
            'Discover'.toUpperCase(),
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          elevation: 2,
        ),
        body: !isLoading? Form(
          key: _globalKey,
          child: ListView(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: InkWell(
                      onTap: _selectAndPickImage,
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.15,
                        backgroundColor: Colors.white,
                        backgroundImage: _imageFile == null
                            ? NetworkImage(_imageLocation)
                            : FileImage(_imageFile),
                      ),
                    ),
                  ),
                  CustomTextField(
                    controller: name,
                    hint: 'Product Name',
                    onClick: (value) {
                      value = name.text;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    controller: price,
                    onClick: (value) {
                      value = price.text;
                    },
                    hint: 'Product price',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    controller: description,
                    onClick: (value) {
                      value = description.text;
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
                        'Edit Product',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ) : Center(child: CircularProgressIndicator(),),
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
    if (_imageFile != null) {
      String filePath = _imageLocation.replaceAll(
          new RegExp(
              r'https://firebasestorage.googleapis.com/v0/b/dulcet-bucksaw-306120.appspot.com/o/'),
          '');

      filePath = filePath.replaceAll(new RegExp(r'%2F'), '/');

      filePath = filePath.replaceAll(new RegExp(r'(\?alt).*'), '');

      Reference storageReferance = FirebaseStorage.instance.ref();

      storageReferance
          .child(filePath)
          .delete()
          .then((_) => print('Successfully deleted $filePath storage item'));

      String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();

      Reference reference =
          FirebaseStorage.instance.ref().child("items").child(imageFileName);

      UploadTask uploadTask = reference.putFile(_imageFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() async {
        await reference.getDownloadURL().then((urlImage) {
          userImageUrl = urlImage;

          _store.editProduct({
            kProductName: name.text,
            kProductLocation:
                userImageUrl == null ? _imageLocation : userImageUrl,
            kProductCategory: selectedCategory,
            kProductDescription: description.text,
            kProductPrice: price.text
          }, id);
        });

        Navigator.pushNamed(context, AdminHome.id);
      });
    } else {
      _store.editProduct({
        kProductName: name.text,
        kProductLocation: _imageLocation,
        kProductCategory: selectedCategory,
        kProductDescription: description.text,
        kProductPrice: price.text
      }, id);
      Navigator.pushNamed(context, AdminHome.id);
    }

    setState(() {
      isLoading = false;
    });
  }
}
