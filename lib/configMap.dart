import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import 'Models/allUsers.dart';

String API_KEY='AIzaSyA06urkWllGfrZwsKHSomPfZvYKhs8z7v0';



User? firebaseUser;
Users ?userCurrentInfo=Users();
int mechanicRequestTimeOut=40;
User? currentfirebaseUser;

String statusReq="";
String mechanicStatus="Mechanic is coming";
String mechanicName="";
String mechanicPhone="";
String mechanicImage="";
String mechanicId="";
StreamSubscription<Position> ?homeTabStreamSubscription;
double starCounter = 0.0;
String  ?title;


String ? mechanicCategory;

String serverToken = "key=AAAAExIfHMQ:APA91bFtca__FeZ5QfzLjam4CwUNBkCmKcRpRN2VQmcuJu68UpbVUZYTPd7Z9zwShU5ts1tDoXv3ShKnBgCL6qFItPauu0vNA043kXEF0Si5eF6uTGfaGT-TsNMLV34JdY_LVd2bQgvD";