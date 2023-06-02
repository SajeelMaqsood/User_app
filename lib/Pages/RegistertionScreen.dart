import 'package:find_a_mechanic/Pages/MainScreen.dart';
import 'package:find_a_mechanic/Pages/loginScreen.dart';
import 'package:find_a_mechanic/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import  'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../AllWidgets/progressDialog.dart';
import '../configMap.dart';
import 'UserProfile.dart';

class RegisterationScreen extends StatefulWidget {
  static const String idScreen = 'Signup';

  RegisterationScreen({Key? key}) : super(key: key);

  @override
  State<RegisterationScreen> createState() => _RegisterationScreenState();
}

class _RegisterationScreenState extends State<RegisterationScreen> {
  TextEditingController nameTextEditingController = TextEditingController();

  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController phoneTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool passToggle = true;

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
                height: 40.0,
              ),
              CircleAvatar(
                backgroundImage: AssetImage("images/logo.png"),
                radius: 60,
              ),
              SizedBox(
                height: 15.0,
              ),
              Text(
                "SignUp",
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
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: nameTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: "Name",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Name";
                          } else if (nameTextEditingController.text.length <
                              3) {
                            return "Name length should be more than 3 characters";
                          }
                        },
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(
                        height: 10.0,
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
                          } else if (!emailValid) {
                            return "Enter valid Email";
                          }
                        },
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: phoneTextEditingController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: "Phone",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter phoneNo";
                          } else if (phoneTextEditingController.text.length <
                              11) {
                            return "Provided Correct PhoneNo";
                          }
                        },
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(
                        height: 10.0,
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
                            )),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Password";
                          } else if (passwordTextEditingController.text.length <
                              6) {
                            return "Password length should be more than 6 characters";
                          }
                        },
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            registerNewUser(context);
                          }
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ))),
                        child: Container(
                          height: 50.0,
                          child: Center(
                            child: Text(
                              "Create Account",
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
                  "Already have an Account?",
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context,
                          LoginScreen.idScreen, (route) => false);
                    },
                    child: Text(
                      "Login Here.",
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

  void registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(
              message: 'Registering.Please wait...',
            ));

    final User? user = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: passwordTextEditingController.text)
            .catchError((erMsg) {
      Navigator.pop(context);
      displayToastMessage("Error: " + erMsg.toString(), context);
    }))
        .user;
    if (user != null) {
      Map userDataMap = {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };

      userRef.child(user.uid).set(userDataMap);
      displayToastMessage('succefuly create', context);

      currentfirebaseUser= user;
      Navigator.pushNamed(
          context, UserProfile.idScreen);
    } else {
      Navigator.pop(context);
      displayToastMessage('New user account has not been created', context);
    }
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
