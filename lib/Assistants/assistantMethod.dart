import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:find_a_mechanic/Assistants/requestAssistant.dart';
import 'package:find_a_mechanic/DataHandler/appData.dart';
import 'package:find_a_mechanic/Models/address.dart';
import 'package:find_a_mechanic/Models/allUsers.dart';
import 'package:find_a_mechanic/configMap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../Models/directDetails.dart';
import '../main.dart';

class AssistantMethods
{

  // get Address from Latlng


  static Future<DirectionDetails?> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async
  {

    print(initialPosition);
    print(finalPosition);
    print(API_KEY);
    String apiUri="https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$API_KEY";

    final Uri directionUrl = Uri.parse(apiUri);
    // String directionUrl = Uri.parse("https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$API_KEY");
    var res = await RequestAssistant.getRequest(directionUrl);

    print("REES");
    print(res.toString());

    if(res == "failed")
    {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints = res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText = res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue = res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText = res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue = res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }


  // static void disableHomeTabLiveLocationUpdates()
  // {
  //   // homeTabPageStreamSubscription.pause();
  //   homeTabStreamSubscription?.pause();
  //   Geofire.removeLocation(currentfirebaseUser!.uid);
  // }
  //
  // static void enableHomeTabLiveLocationUpdates()
  // {
  //   homeTabStreamSubscription?.resume();
  //   Geofire.setLocation(currentfirebaseUser!.uid,!.latitude, currentPositon!.longitude);
  // }

  static Future<String> searchCoordinateAddress(LatLng latLaPosition,context)async
  {
    String placeAddress= "";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          latLaPosition.latitude, latLaPosition.longitude,
          localeIdentifier: "en");
      placeAddress = placemarks[0].street! + " " + placemarks[4].name! + " "
          + placemarks[4].subLocality! + " " + placemarks[4].locality!;
    }catch(e)
    {
      placeAddress="Loading...";
    }
    // for(int i=0; i<placemarks.length; i++)
    //   {
    //     print("Index $i ${placemarks[i]}");
    //   }
        Address userAddress= new Address();
        userAddress.longitude=latLaPosition.longitude;
        userAddress.latitude=latLaPosition.latitude;
        userAddress.placeName=placeAddress;

        Provider.of<AppData>(context, listen: false).updateUserLocation(userAddress);

    return placeAddress;
  }

  //Current userInfo

  static void  getCurrentOnlineUserInfo()async{
    firebaseUser= await FirebaseAuth.instance.currentUser;
    String? userId= firebaseUser!.uid;
    userRef.child(userId).once().then((value){

      final DataSnapshot snap = value.snapshot;
      if (snap.value != null) {

        userCurrentInfo= Users.fromSnapshot(snap);
      }

    });

  }

  static double createRandomNumber(int num)
  {
    var random=Random();
    int radNumber=random.nextInt(num);
    return radNumber.toDouble();

  }

  static void sendNotificationToMechanic(String token, context, String user_request_id)async {

    var destionation = Provider.of<AppData>(context, listen: false).userLocation;
    Map<String, String> headerMap =
    {
      'Content-Type': 'application/json',
      'Authorization': serverToken,
    };

    Map notificationMap =
    {
      'body': 'User Address, ${destionation!.placeName}',
      'title': 'New User Request'
    };

    Map dataMap =
    {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'user_request_id': user_request_id,
    };

    Map sendNotificationMap =
    {
      "notification": notificationMap,
      "data": dataMap,
      "priority": "high",
      "to": token,
    };



    String apiUri='https://fcm.googleapis.com/fcm/send';
    final Uri url = Uri.parse(apiUri);
    var res = await http.post(
      url,
      headers: headerMap,
      body: jsonEncode(sendNotificationMap),
    );
  }
}