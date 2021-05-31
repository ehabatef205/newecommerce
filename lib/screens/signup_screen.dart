import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newecommerce/constant.dart';
import 'package:newecommerce/provider/modal_hud.dart';
import 'package:newecommerce/screens/login_screen.dart';
import 'file:///D:/Android/newecommerce/lib/screens/user/home_page.dart';
import 'package:newecommerce/services/auth.dart';
import 'package:newecommerce/widgets/custom_logo.dart';
import 'package:newecommerce/widgets/custom_text_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  static String id = 'SignupScreen';

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  String _email, _password, _cpassword;

  TextEditingController emailText = TextEditingController();

  TextEditingController nameText = TextEditingController();

  TextEditingController passwordText = TextEditingController();
  TextEditingController cpasswordText = TextEditingController();

  final _auth = Auth();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () {
        Navigator.pushNamed(context, LoginScreen.id);
        return null;
      },
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: Provider.of<ModelHud>(context).isLoading,
          child: Form(
            key: _globalKey,
            child: ListView(
              children: <Widget>[
                CustomLogo(),
                SizedBox(
                  height: height * .05,
                ),
                InkWell(
                  onTap: _selectAndPickImage,
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.15,
                    backgroundColor: Colors.black.withOpacity(0.5),
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
                SizedBox(
                  height: height * .05,
                ),
                CustomTextField(
                  controller: nameText,
                  onClick: (value) {},
                  icon: Icons.perm_identity,
                  hint: 'Enter your name',
                ),
                SizedBox(
                  height: height * .02,
                ),
                CustomTextField(
                  controller: emailText,
                  onClick: (value) {
                    _email = value;
                  },
                  hint: 'Enter your email',
                  icon: Icons.email,
                ),
                SizedBox(
                  height: height * .02,
                ),
                CustomTextField(
                  controller: passwordText,
                  onClick: (value) {
                    _password = value;
                  },
                  hint: 'Enter your password',
                  icon: Icons.lock,
                ),
                SizedBox(
                  height: height * .02,
                ),
                CustomTextField(
                  controller: cpasswordText,
                  onClick: (value) {
                    _cpassword = value;
                  },
                  hint: 'Enter your password',
                  icon: Icons.lock,
                ),
                SizedBox(
                  height: height * .05,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 120),
                  child: Builder(
                    builder: (context) => FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      onPressed: () async {
                        if (_globalKey.currentState.validate()) {
                          final modelhud =
                              Provider.of<ModelHud>(context, listen: false);
                          modelhud.changeisLoading(true);
                          _globalKey.currentState.save();
                          try {
                            uploadAndSaveImage();
                          } on PlatformException catch (e) {
                            modelhud.changeisLoading(false);
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(e.message),
                            ));
                          }
                        }
                      },
                      color: Colors.black,
                      child: Text(
                        'Sign up',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * .05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Do have an account ? ',
                      style: TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  File _imageFile;
  String userImageUrl = "";

  Future<void> _selectAndPickImage() async {
    var pickerImage = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = File(pickerImage.path);
    });
  }

  Future<void> uploadAndSaveImage() async {
    final modelhud = Provider.of<ModelHud>(context, listen: false);
    modelhud.changeisLoading(true);
    if (_imageFile == null) {
      displayDialog("Please select an image file.");
    } else {
      passwordText.text == cpasswordText.text
          ? emailText.text.isNotEmpty &&
                  passwordText.text.isNotEmpty &&
                  cpasswordText.text.isNotEmpty &&
                  nameText.text.isNotEmpty
              ? uploadToStorage()
              : displayDialog("Please fill up the registration complete form.")
          : displayDialog("Password do not match.");
    }
    modelhud.changeisLoading(false);
  }

  displayDialog(String msg) {
    showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            content: Text(msg),
            actions: <Widget>[
              RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.red,
                child: Center(
                  child: Text("OK"),
                ),
              )
            ],
          );
        });
  }

  uploadToStorage() async {
    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference reference = FirebaseStorage.instance.ref().child(imageFileName);

    UploadTask uploadTask = reference.putFile(_imageFile);

    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() async {
      await reference.getDownloadURL().then((urlImage) {
        userImageUrl = urlImage;

        _registerUser();
      });
    });
  }

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  void _registerUser() async {
    User user;

    await firebaseAuth
        .createUserWithEmailAndPassword(
            email: emailText.text, password: passwordText.text)
        .then((auth) {
      user = auth.user;
    }).catchError((error) {
      displayDialog("Email exits");
    });

    if (user != null) {
      saveUserInfoToFireStore(user).then((value) {
        Navigator.pushNamed(context, HomePage.id);
      });
    }
  }

  Future saveUserInfoToFireStore(User user) async {
    FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "uid": user.uid,
      "username": nameText.text,
      "email": user.email,
      "image": userImageUrl,

    });

    Navigator.pushNamed(context, HomePage.id);
  }
}
