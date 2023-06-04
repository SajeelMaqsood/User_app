import 'package:find_a_mechanic/DataHandler/appData.dart';
import 'package:find_a_mechanic/Pages/MainScreen.dart';
import 'package:find_a_mechanic/Pages/RegistertionScreen.dart';
import 'package:find_a_mechanic/Pages/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Pages/UserProfile.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

Size mq=Size(0, 0);

DatabaseReference  userRef= FirebaseDatabase.instance.ref().child("users");
DatabaseReference  mechanicRef= FirebaseDatabase.instance.ref().child("mechanic");
DatabaseReference  userRequestsRef= FirebaseDatabase.instance.ref().child("User Requests").push();

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context)=> AppData(),
      child: MaterialApp(
        title: 'Find Mechanic',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: FirebaseAuth.instance.currentUser==null ? LoginScreen.idScreen: MainScreen.idScreen,
        // initialRoute: UserProfile.idScreen,
        routes: {
           RegisterationScreen.idScreen: (context)=> RegisterationScreen(),
          LoginScreen.idScreen: (context)=> LoginScreen(),
          UserProfile.idScreen:(context)=>UserProfile(),
          MainScreen.idScreen: (context)=> MainScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );

  }
}
