import 'package:find_a_mechanic/AllWidgets/progressDialog.dart';
import 'package:find_a_mechanic/Pages/RegistertionScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'MainScreen.dart';

class LoginScreen extends StatefulWidget {
  static const String idScreen = 'Login';

  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();

  bool passToggle = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(

        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 50.0,
              ),
              CircleAvatar(
                backgroundImage: AssetImage("images/logo.png"),
                radius: 60,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                "Login",
                style: TextStyle(
                    fontSize: 24.0,
                    fontFamily: "Brand-Bold",
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )),
                        validator: (value) {
                          bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value!);
                          if (value!.isEmpty) {
                            return "Enter Email";
                          }
                         else if (!emailValid) {
                            return "Enter valid Email";
                          }
                        },
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        controller: passwordTextEditingController,
                        obscureText: passToggle,
                        decoration: InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  passToggle = !passToggle;
                                });
                              },
                              child: Icon(passToggle
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                            ),
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )
                        ),
                        validator: (value){
                          if(value!.isEmpty){
                            return"Enter Password";
                          }
                          else if(passwordTextEditingController.text.length<6){
                            return"Password length should be more than 6 characters";
                          }

                        },
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      ElevatedButton(
                        onPressed: () {

                          if(_formKey.currentState!.validate()){
                            LoginAuthcationUser(context);

                          }
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black),
                            shape:
                                MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            )
                                )
                        ),
                        child: Container(
                          height: 50.0,
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: "Brand-Bold",
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  "Do not have an Account?",
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context,
                          RegisterationScreen.idScreen, (route) => false);
                    },
                    child: Text(
                      "Register Here.",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ))
              ]),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void LoginAuthcationUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(
              message: 'Authenticating.Please wait...',
            ));

    final User? user = (await _firebaseAuth
            .signInWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: passwordTextEditingController.text)
            .catchError((erMsg) {
      Navigator.pop(context);
      displayToastMessage("Error: " + erMsg.toString(), context);
    }))
        .user;
    if (user != null) {
      userRef.child(user.uid).once().then((value) {
        final DataSnapshot snap = value.snapshot;


        if (snap.value != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, MainScreen.idScreen, (route) => false);
          displayToastMessage('login successfully', context);
        } else {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayToastMessage('No record exists, Create new Account', context);
        }
      });
    } else {
      Navigator.pop(context);
      displayToastMessage('Error occured, can not be Signin ', context);
    }
  }
}
