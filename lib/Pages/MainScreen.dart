import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:find_a_mechanic/AllWidgets/Divider.dart';
import 'package:find_a_mechanic/AllWidgets/noMechanicAvailable.dart';
import 'package:find_a_mechanic/Assistants/assistantMethod.dart';
import 'package:find_a_mechanic/Assistants/geofireAssistants.dart';
import 'package:find_a_mechanic/DataHandler/appData.dart';
import 'package:find_a_mechanic/Models/nearbyAvailableMechanic.dart';
import 'package:find_a_mechanic/Pages/loginScreen.dart';
import 'package:find_a_mechanic/Pages/ratingScreen.dart';
import 'package:find_a_mechanic/Pages/searchScreen.dart';
import 'package:find_a_mechanic/configMap.dart';
import 'package:find_a_mechanic/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../AllWidgets/collectPaymentDialog.dart';
import 'RegistertionScreen.dart';
import 'chatScreen.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = 'MainScreen';

  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;
  GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
  LatLng desLocation = LatLng(37.3161, -121.9195);
  Position? currentPositon;
  String? Address;
  bool visibility = true;
  BitmapDescriptor ?nearByIcon;
  bool nearbyAvailableMechanicKeysLoaded=false;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;
  double reqcontHeight=0;
  double contHeight=300.0;
  String state="normal";
   StreamSubscription<DatabaseEvent> ?reqstreamSubscription;
  double mechanicDetailsContainerHeight=0;
  Set<Marker> markersSet={};
  bool isRequestingPositionDetails=false;
  String ?imageurl=userCurrentInfo!.UrlImage.toString();
  List<NearbyAvailableMechanic> ?availableMechanic;
  var _value = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // createIconMarker();
    locatePosition();
    AssistantMethods.getCurrentOnlineUserInfo();

  }
  void displaycont(){
    setState(() {
      reqcontHeight=250.0;
      contHeight=0;
    });
    saveUserRequest();
  }
  void displayMechanicdetailContanier()
  {
    setState(() {
      reqcontHeight=0.0;
      contHeight=0.0;
      mechanicDetailsContainerHeight=320.0;
      bottomPaddingOfMap=290.0;
    });
  }



  void saveUserRequest(){

    if(_value==0){

      mechanicCategory="carMechanic";

    }
    else if(_value==1){
      mechanicCategory="bikeMechanic";
    }

    userRequestsRef = FirebaseDatabase.instance.ref().child("User Requests").push();
    var userLoaction = Provider.of<AppData>(context,listen: false).userLocation;
    Map userlocMap={
      "latitude" : userLoaction!.latitude.toString(),
      "longitude" : userLoaction!.longitude.toString(),
    };
    Map userinfo={
      "mechanic_id":"wating",
      "user_Loc": userlocMap,
      "created_at": DateTime.now().toString(),
      "user_name": userCurrentInfo!.name,
      "user_phone":userCurrentInfo!.phone,
      "user_address":userLoaction.placeName,
      "mechanic_category":mechanicCategory,
    };
    userRequestsRef.set(userinfo);

    reqstreamSubscription = userRequestsRef.onValue.listen((event) async {
      if(event.snapshot.value == null)
      {
        return;
      }

      if(event.snapshot.child("mechanic_name").value!= null)
      {
        setState(() {
          mechanicName = event.snapshot.child("mechanic_name").value.toString();
        });
      }
      if(event.snapshot.child("mechanic_phone").value!= null)
      {
        setState(() {
          mechanicPhone = event.snapshot.child("mechanic_phone").value.toString();
        });
      }

      if(event.snapshot.child("mechanic_location").value!= null)
      {
        double mechanicLat = double.parse(event.snapshot.child("mechanic_location").child("latitude").value.toString());
        double mechanicLng = double.parse(event.snapshot.child("mechanic_location").child("longitude").value.toString());
        LatLng mechanicCurrentLocation = LatLng(mechanicLat, mechanicLng);

        if(statusReq == "accepted")
        {
          UpdateMechanicTime(mechanicCurrentLocation);
        }
        else if(statusReq == "onwork")
        {
          setState(() {
            mechanicStatus = "Mechanic has Arrived.";
          });
        }

      if(event.snapshot.child("status").value!= null)
      {
        statusReq = event.snapshot.child("status").value.toString();
      }
      if(statusReq == "accepted")
      {
        displayMechanicdetailContanier();
        Geofire.stopListener();
      }
      if(statusReq == "ended")
      {
        if(event.snapshot.child("fares").value!= null)
        {
          int fare = int.parse(event.snapshot.child("fares").value.toString());
          var res = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context)=> CollectPaymentDialog(paymentMethod: "cash", fareAmount: fare,),
          );

          String ?mechanicId;
          if(res == "close")
          {
            if(event.snapshot.child("mechanic_id").value != null)
            {
              mechanicId = event.snapshot.child("mechanic_id").value.toString();
            }
            //
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => RatingScreen(mechanicId: mechanicId,)));

            userRequestsRef.onDisconnect();
            reqstreamSubscription?.cancel();
            reqstreamSubscription = null;
            restApp();
          }
        }
      }
    }});



  }
  void UpdateMechanicTime(LatLng mechanicCurrentLocation) async
  {
    if(isRequestingPositionDetails == false)
    {
      isRequestingPositionDetails = true;

      var positionUserLatLng = LatLng(currentPositon!.latitude, currentPositon!.longitude);
      var details = await AssistantMethods.obtainPlaceDirectionDetails(mechanicCurrentLocation, positionUserLatLng);
      if(details == null)
      {
        return;
      }
      setState(() {
        mechanicStatus = "Mechanic is Coming - " + details!.durationText.toString();
      });

      isRequestingPositionDetails = false;
    }
  }


  void cancelReq()
  {
    // if(_value==0){
    //   carUserRef.remove();}
    // else if(_value==1){
    //   bikeUserRef.remove();
    // }
    setState(() {
      state="normal";
    });
    userRequestsRef.remove();
  }

  restApp(){
    setState(() {

      reqcontHeight=0;
      contHeight=300;
      statusReq="";
      mechanicName="";
      mechanicPhone="";
      mechanicDetailsContainerHeight=0.0;
      mechanicStatus="Mechanic is Coming";

    });
    locatePosition();
  }


  void locatePosition() async {
    await _determinePosition();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPositon = position;
    desLocation = LatLng(currentPositon!.latitude, currentPositon!.longitude);
    setState(() {
      CameraPosition cameraPosition =
      CameraPosition(target: desLocation, zoom: 18.0);
      newGoogleMapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    });

    initGeoFireListner();

  }

  @override
  Widget build(BuildContext context) {
    //Screen design


    return Scaffold(
        key: scaffoldkey,
        drawer: Container(
          color: Colors.white,
          width: 255.0,
          child: Drawer(
            child: ListView(
              children: [
                //DrawerHeader
                Container(
                  height: 195.0,
                  child: DrawerHeader(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Row(
                      children: [

                        if(userCurrentInfo!.UrlImage.toString().isNotEmpty)


                          imageurl!=null?
                        ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: CachedNetworkImage(
                            width: 60,
                            height: 60,
                            imageUrl: userCurrentInfo!.UrlImage.toString(),
                          ),
                        )
                        :
                          CircleAvatar(
                              child: Icon(Icons.person)),


                        SizedBox(width: 6.0),
                        Expanded(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  userCurrentInfo!.name.toString(),
                                  style: TextStyle(
                                      fontSize: 16.0, fontFamily: "Brand-Bold"),
                                ),
                                SizedBox(
                                  height: 6.0,
                                ),
                                Text(
                                  userCurrentInfo!.phone.toString(),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                DividerWidget(),

                SizedBox(height: 12.0),

                //Drawer body
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text(
                    "History",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(
                    "Visit profile",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text(
                    "About",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                  },
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text(
                      "SignOut",
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),

        // Map
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: desLocation,
                zoom: 18,
              ),
              onCameraMove: (CameraPosition? position) {
                if (desLocation != position!.target) {
                  setState(() {
                    desLocation = position.target;
                    visibility = false;
                  });
                }
              },
              onCameraIdle: () {
                print(desLocation);
                AssistantMethods.searchCoordinateAddress(desLocation, context);
                print('camer idle');
                setState(() {
                  visibility = true;
                });
              },
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                locatePosition();
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                setState(() {
                  bottomPaddingOfMap = 280.0;
                });

              },
              myLocationEnabled: true,
              markers: markersSet,
              myLocationButtonEnabled: false,
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 330.0),
                child: Image.asset(
                  "images/pin.png",
                  height: 45.0,
                  width: 45.0,
                ),
              ),
            ),

            // locationbutton
            Positioned(
              top: 460.0,
              right: 25.0,
              child: GestureDetector(
                onTap: () {
                 locatePosition();
                },

                child: Container(
                  height: 45.0,
                  width: 45.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(
                        width: 2.0,
                        color: Colors.grey),
                  ),
                  child: Icon(
                    Icons.my_location,
                    size: 30.0,
                  ),
                ),
              ),
            ),

            // Drawer
            Positioned(
              top: 45.0,
              left: 22.0,
              child: GestureDetector(
                onTap: () {
                  scaffoldkey.currentState?.openDrawer();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 6.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                            0.7,
                            0.7,
                          ))
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.menu,
                      color: Colors.black,
                    ),
                    radius: 20.0,
                  ),
                ),
              ),
            ),


            // Search location container
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Visibility(
                visible: visibility,
                child: Container(
                  height: contHeight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18.0),
                          topRight: Radius.circular(18.0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 16.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7),
                        ),
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 6.0,
                        ),
                        Text(
                          "Hi there,",
                          style: TextStyle(fontSize: 13.0),
                        ),
                        Text(
                          "where to?,",
                          style:
                              TextStyle(fontSize: 20.0, fontFamily: "Signatra"),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        GestureDetector(
                          onTap: () async {
                           final result= await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchScreen()));

                            setState(() {
                              LatLng seaLocation= result;
                              CameraPosition cameraPosition =
                              CameraPosition(target: seaLocation, zoom: 18.0);
                              newGoogleMapController!
                                  .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 16.0,
                                    spreadRadius: 0.5,
                                    offset: Offset(0.7, 0.7),
                                  ),
                                ]),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, top: 5, right: 10, bottom: 5),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: Colors.blueAccent,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                 Expanded(child: Container(
                                   child:  Text(
                                     Provider.of<AppData>(context)
                                         .userLocation !=
                                         null
                                         ? Provider.of<AppData>(context)
                                         .userLocation!
                                         .placeName
                                         .toString()
                                         : "Drope your location",
                                   ),
                                 ))
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24.0,
                        ),
                        DividerWidget(),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Row(
                            children: [
                              Text(
                                "Choose Vehicle ",
                                style: TextStyle(
                                    fontSize: 30.0, fontFamily: "Signatra"),
                              ),
                              SizedBox(width: 45),
                              GestureDetector(
                                onTap: () => setState(() => _value = 0),
                                child: Container(
                                  height: 56,
                                  width: 56,
                                  color: _value == 0
                                      ? Colors.limeAccent
                                      : Colors.grey[100],
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "images/car1.png",
                                        height: 35.0,
                                        width: 35.0,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "Car",
                                        style: TextStyle(fontSize: 10.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 25),
                              GestureDetector(
                                onTap: () => setState(() => _value = 1),
                                child: Container(
                                  height: 56,
                                  width: 56,
                                  color: _value == 1
                                      ? Colors.limeAccent
                                      : Colors.grey[100],
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "images/motorbike1.png",
                                        height: 35.0,
                                        width: 35.0,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "Bike",
                                        style: TextStyle(fontSize: 10.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                state="requesting";
                              });
                              displaycont();
                              availableMechanic=GeoFireAssistant.nearbyAvailableMechaniclist;
                              searchNearMechanic();
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
                                  "Request",
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: "Brand-Bold",
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Request Animation
            Positioned(
              bottom: 0.0,
              right: 0.0,
              left: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16.0),
                    topLeft: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black54,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(
                          0.7,
                          0.7,
                        ))
                  ],
                ),
                height: reqcontHeight,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(children: [
                    SizedBox(
                      height: 12.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ColorizeAnimatedTextKit(
                          onTap: () {
                            print("Tap Event");
                          },
                          text: [
                            "Requesting ...",
                            "Please wait ...",
                            "Finding a Mechanic...",
                          ],
                          textStyle:
                              TextStyle(
                                  fontSize: 55.0,
                                  fontFamily: "Signatra"),
                          colors: const [
                            Colors.green,
                            Colors.pink,
                            Colors.purple,
                            Colors.blue,
                            Colors.yellow,
                            Colors.red,
                                ],
                          textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    GestureDetector(
                      onTap: (){
                        cancelReq();
                        restApp();
                      },
                      child: Container(
                        height: 60.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.0),
                          border: Border.all(
                              width: 2.0,
                              color: Colors.grey),
                        ),
                        child: Icon(Icons.close),
                      ),
                    ),
                    SizedBox(height: 10.0,),

                    Container(
                      width: double.infinity,
                      child: Text(
                        "Cancel",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.0),
                      ),

                    )
                  ]),
                ),
              ),
            ),

            // Drvie info

            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0),),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16.0,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                height: mechanicDetailsContainerHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.0,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(mechanicStatus, textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0, fontFamily: "Brand Bold"),),
                        ],
                      ),

                      SizedBox(height: 22.0,),

                      Divider(height: 2.0, thickness: 2.0,),

                      SizedBox(height: 22.0,),

                      // Text(carDetailsDriver, style: TextStyle(color: Colors.grey),),

                      Text(mechanicName, style: TextStyle(fontSize: 20.0),),

                      SizedBox(height: 22.0,),

                      Divider(height: 2.0, thickness: 2.0,),

                      SizedBox(height: 22.0,),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //call button
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: ElevatedButton(
                             style: ButtonStyle(
                               backgroundColor:
                               MaterialStateProperty.all(Colors.black87),
                               shape:
                               MaterialStateProperty.all(RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(24.0),
                               ))
                             ),
                              onPressed: () async
                              {
                                 launchUrl(Uri.parse(('tel://${mechanicPhone}')));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Call  ", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.white),),
                                  Icon(Icons.call, color: Colors.white, size: 15.0,),
                                ],
                              ),
                            ),
                          ),

                          // message button
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all(Colors.black87),
                                  shape:
                                  MaterialStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                  ))
                              ),
                              onPressed: () async
                              {
                                //launchUrl(Uri.parse(('tel://${mechanicPhone}')));
                              //   Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (_) => ChatScreen()));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Message ", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.white),),
                                  Icon(Icons.message, color: Colors.white, size: 15.0,),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ));
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }



  void initGeoFireListner(){
    Geofire.initialize("availableMechanic");
    Geofire.queryAtLocation(currentPositon!.latitude, currentPositon!.longitude, 15)!.listen((map) {

      if (map != null) {
        var callBack = map['callBack'];
        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableMechanic nearbyAvailableMechanic=NearbyAvailableMechanic();
            nearbyAvailableMechanic.key= map['key'];
            nearbyAvailableMechanic.latitude= map['latitude'];
            nearbyAvailableMechanic.longitude= map['longitude'];

            GeoFireAssistant.nearbyAvailableMechaniclist.add(nearbyAvailableMechanic);
            if(nearbyAvailableMechanicKeysLoaded==true)
              {
                updateAvailableMechanicOnMap();
              }
            break;

          case Geofire.onKeyExited:
            GeoFireAssistant.removeMechanicFromList(map['key']);
            updateAvailableMechanicOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyAvailableMechanic nearbyAvailableMechanic=NearbyAvailableMechanic();
            nearbyAvailableMechanic.key= map['key'];
            nearbyAvailableMechanic.latitude= map['latitude'];
            nearbyAvailableMechanic.longitude= map['longitude'];
            GeoFireAssistant.updateMechanicNearbyLocation(nearbyAvailableMechanic);
            updateAvailableMechanicOnMap();


            break;

          case Geofire.onGeoQueryReady:
            updateAvailableMechanicOnMap();
            break;
        }
      }

      setState(() {});
    });
  }

  void updateAvailableMechanicOnMap()async
  {
    setState(() {
      markersSet.clear();
    });

    Set<Marker> tMakers= Set<Marker>();
    for(NearbyAvailableMechanic mechanic in GeoFireAssistant.nearbyAvailableMechaniclist)
      {
        LatLng mechanicAvailablePostion= LatLng(mechanic.latitude!, mechanic.longitude!);

        Marker marker= Marker(markerId: MarkerId('mechanic${mechanic.key}'),
        position: mechanicAvailablePostion,
          icon: await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(48, 48)), 'images/mechanic.png'),
          rotation: AssistantMethods.createRandomNumber(360),

        );
        tMakers.add(marker);

      }
    setState(() {
      markersSet=tMakers;
    });

  }

  // void createIconMarker()
  // {
  //   // BitmapDescriptor.fromAssetImage(
  //   //     ImageConfiguration(size: Size(48, 48)), 'assets/my_icon.png')
  //   //     .then((onValue) {
  //   //   myIcon = onValue;
  //   // });
  //
  //   if(nearByIcon==null)
  //     {
  //       // ImageConfiguration imageConfiguration=createLocalImageConfiguration(context,size:Size(2, 2));
  //       BitmapDescriptor.fromAssetImage( ImageConfiguration(size: Size(48, 48)), "images/mechanic.png")
  //           .then((value)
  //       {
  //         nearByIcon=value;
  //       });
  //
  //
  //     }
  // }
  
  void noMechanicFound()
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NoMechanicAvailable()
    );
  }

  void searchNearMechanic()
  {
    if(availableMechanic?.length==0)
      {
        cancelReq();
        restApp();
        noMechanicFound();
        return;
      }
    var mechanic= availableMechanic?[0];
    mechanicRef.child(mechanic!.key.toString()).child("mechanic_details").child("mechanic_Type").once().then((value) async
    {
      final DataSnapshot snap=value.snapshot;
      if(await snap.value != null)
      {
        String mechanicType = snap.value.toString();
        if(mechanicCategory == mechanicType)
        {
          notifyMechanic(mechanic!);
          availableMechanic?.removeAt(0);
        }
        else
        {
          displayToastMessage(mechanicType + " mechanic not available. Try again.", context);
        }
      }
      else
      {
        displayToastMessage("No mechanic found. Try again.", context);
      }
    });
    // driversRef.child(driver.key).child("mechanic_details").child("mechanic_Type").once().then((DataSnapshot snap) async
    // {
    //   if(await snap.value != null)
    //   {
    //     String mechanicType = snap.value.toString();
    //     if(mechanicCategory == carRideType)
    //     {
    //       notifyDriver(driver);
    //       availableDrivers.removeAt(0);
    //     }
    //     else
    //     {
    //       displayToastMessage(carRideType + " mechanic not available. Try again.", context);
    //     }
    //   }
    //   else
    //   {
    //     displayToastMessage("No mechanic found. Try again.", context);
    //   }
    // });

  }

  void notifyMechanic(NearbyAvailableMechanic mechanic)
  {

    mechanicRef.child(mechanic.key.toString()).child("newReq").set(userRequestsRef.key);

    mechanicRef.child(mechanic.key.toString()).child("token").once().then((value)
    {
      final DataSnapshot snap= value.snapshot;
      if (snap.value != null) {

        String token = snap.value.toString();
        AssistantMethods.sendNotificationToMechanic(token, context, userRequestsRef.key.toString());
      }
      else
        {
          return;
        }
      const oneSecondPassed = Duration(seconds: 1);
      var timer = Timer.periodic(oneSecondPassed, (timer) {
        if(state != "requesting")
        {
          mechanicRef.child(mechanic.key.toString()).child("newReq").set("cancelled");
          mechanicRef.child(mechanic.key.toString()).child("newReq").onDisconnect();
          mechanicRequestTimeOut = 40;
          timer.cancel();
        }

        mechanicRequestTimeOut = mechanicRequestTimeOut - 1;

        mechanicRef.child(mechanic.key.toString()).child("newReq").onValue.listen((event) {
          if(event.snapshot.value.toString() == "accepted")
          {
            mechanicRef.child(mechanic.key.toString()).child("newReq").onDisconnect();
            mechanicRequestTimeOut = 40;
            timer.cancel();
          }
        });

        if(mechanicRequestTimeOut == 0)
        {
          mechanicRef.child(mechanic.key.toString()).child("newReq").set("timeout");
          mechanicRef.child(mechanic.key.toString()).child("newReq").onDisconnect();
          mechanicRequestTimeOut = 40;
          timer.cancel();

          searchNearMechanic();
        }
      });

    });

  }



  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GoogleMapController>(
        'newGoogleMapController', newGoogleMapController));
    properties.add(DiagnosticsProperty<Geolocator>('geoLocator', geoLocator));
  }
}
